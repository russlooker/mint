view: transactions {
  sql_table_name: public.transactions ;;

###### Basic Fields ######
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."id" ;;
    hidden: yes
  }

  dimension: expensify_report_id {
    type: number
    sql:
        CASE WHEN ${is_reimbursement} THEN CAST(substring(${original_description} from '\d{8}') AS NUMERIC)
        ELSE NULL
        END
    ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."Account Name" ;;
  }

  dimension: amount_range {
    type: tier
    style: integer
    sql: CASE WHEN ${amount} < 0 THEN ${amount}*-1.0 ELSE ${amount} END  ;;
    tiers: [0,6,11,21,51,101,501,1001]
  }

  dimension: amount {
    type: number
    group_label: "Details"
    sql:
        CASE
          WHEN ${transaction_type} = 'debit' then ${TABLE}."Amount" * -1.0
          ELSE ${TABLE}."Amount"
        END
        ;;
  }

  dimension: category {
    view_label: "Category"
    label: "Category"
    type: string
    sql: ${TABLE}."Category" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."Description" ;;
    label: "1) Merchant"
    view_label: "Merchant"
    link: {
      label: "View Merchant Transactions in Mint"
      icon_url: "https://mint.intuit.com/favicon.ico"
      url: "https://mint.intuit.com/transaction.event#location:%7B%22query%22%3A%22description%3A%20{{value | uri_encode }}%22%2C%22offset%22%3A0%2C%22typeFilter%22%3A%22cash%22%2C%22typeSort%22%3A8%7D"
    }
    link: {
      label: "View Merchant Lookup Dashboard"
      icon_url: "http://looker.com/favicon.ico"
      url: "/dashboards/2?Merchant={{value | uri_encode }}"
    }
  }

  dimension: labels {
    type: string
    sql: ${TABLE}."Labels" ;;
    group_label: "Details"
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."Notes" ;;
    group_label: "Details"
  }

  dimension: original_description {
    type: string
    sql: ${TABLE}."Original Description" ;;
    label: "Full Transaction Code"
    group_label: "Details"
    link: {
      label: "View Report in Expensify"
      url: "https://www.expensify.com/report?param={% raw %}{{% endraw %}%22pageReportID%22:%22{{expensify_report_id._value}}%22,%22keepCollection%22:true{% raw %}}{% endraw %}"
      icon_url: "https://looker.com/favicon.ico"
    }
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."Transaction Type" ;;
    label: "Debit/Credit"
  }

### Date Logic ###
  dimension_group: date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year,
      week_of_year,
      month_num,
      day_of_week,
      day_of_week_index,
      day_of_year,
      day_of_month
    ]
    convert_tz: no
    sql: ${TABLE}."Date" ;;
    label: "1) Transaction"
  }

  dimension: synthetic_end_date {
    type: date
    hidden: yes
    sql:
        CASE
          WHEN
          CURRENT_DATE <
          {% if date_date._is_filtered %} {% date_end date_date %} {% else %} {% date_end reporting_period %} {% endif %} THEN CURRENT_DATE
          ELSE {% if date_date._is_filtered %} {% date_end date_date %} {% else %} {% date_end reporting_period %} - INTERVAL '1 day' {% endif %}
        END
        ;;
  }

  dimension: is_before_wtd {
    description: "Filter this on 'yes' to compare to same period in previous weeks"
    group_label: "1) Transaction Date"
    type: yesno
    sql:
      (EXTRACT(DOW FROM ${date_raw}) < EXTRACT(DOW FROM CURRENT_DATE)
        OR
        (
          EXTRACT(DOW FROM ${date_raw}) = EXTRACT(DOW FROM CURRENT_DATE) AND
          EXTRACT(HOUR FROM ${date_raw}) < EXTRACT(HOUR FROM CURRENT_DATE)
        )
        OR
        (
          EXTRACT(DOW FROM ${date_raw}) = EXTRACT(DOW FROM CURRENT_DATE) AND
          EXTRACT(HOUR FROM ${date_raw}) <= EXTRACT(HOUR FROM CURRENT_DATE) AND
          EXTRACT(MINUTE FROM ${date_raw}) < EXTRACT(MINUTE FROM CURRENT_DATE)
        )
      );;
  }

  dimension: is_before_mtd {
    #since this is only at the day level this needed to be converted to a less than or equal to expression
    description: "Filter this on 'yes' to compare to same period in previous months"
    group_label: "1) Transaction Date"
    type: yesno
    sql:
      (EXTRACT(DAY FROM ${date_raw}) <= EXTRACT(DAY FROM ${synthetic_end_date})

      );;
  }

  dimension: is_before_ytd {
    description: "Filter this on 'yes' to compare to same period in previous years"
    group_label: "1) Transaction Date"
    type: yesno
    sql:
      (EXTRACT(DOY FROM ${date_raw}) < EXTRACT(DOY FROM CURRENT_DATE)
        OR
        (
          EXTRACT(DOY FROM ${date_raw}) = EXTRACT(DOY FROM CURRENT_DATE) AND
          EXTRACT(HOUR FROM ${date_raw}) < EXTRACT(HOUR FROM CURRENT_DATE)
        )
        OR
        (
          EXTRACT(DOY FROM ${date_raw}) = EXTRACT(DOY FROM CURRENT_DATE) AND
          EXTRACT(HOUR FROM ${date_raw}) <= EXTRACT(HOUR FROM CURRENT_DATE) AND
          EXTRACT(MINUTE FROM ${date_raw}) < EXTRACT(MINUTE FROM CURRENT_DATE)
        )
      );;
  }

### Filters ###
  filter: reporting_period {
    type: date
  }

  filter: comparison_period {
    type: date
    sql:
     ${date_raw}>= {% date_start comparison_period  %}
  AND ${date_raw} < {% date_end reporting_period %}
  ;;
  }

  parameter: imputed_periods {
    type: number
  }

  parameter: imputed_periods_type {
    type: unquoted
    allowed_value: {
      label: "Months"
      value: "month"
    }
    allowed_value: {
      label: "Years"
      value: "year"
    }
    allowed_value: {
      label: "Days"
      value: "day"
    }
  }

  filter: comparison_period_imputed {
    type: yesno
    sql:
     ${date_raw} >= ({% date_start transactions.reporting_period %} - INTERVAL '{% parameter transactions.imputed_periods %} {% parameter transactions.imputed_periods_type %}')
  AND ${date_raw} < {% date_end transactions.reporting_period %}
  ;;

    }


###### Flags ######
  dimension: is_expensable {
      type: yesno
      sql:  lower("Labels") like '%expensable%' ;;
    }

  dimension: is_reimbursement {
      type: yesno
      sql:
      (lower("Original Description") LIKE '%looker%expensify%')
      OR
      (lower("Category") like '%reimbursement%' )
    ;;
    }

  dimension: is_transfer {
      type: yesno
      sql: lower("Category") in
          ('transfer',
           'transfer for cash spending',
          'withdrawal',
          'cash & atm',
          'financial','hide from budgets & trends','credit card payment','Credit Card Payment')
      ;;
    }


###### Measures ######
  measure: count {
      type: count
      drill_fields: [transaction_detail*, total_income_amount]
    }

  measure: total_income_amount {
      type: sum
      sql: ${amount} ;;
      drill_fields: [transaction_detail*, -total_spend_amount, total_income_amount]
      filters: {
        field: transaction_type
        value: "credit"
      }
      value_format_name: usd
    }

  measure: total_spend_amount {
      type: sum
      sql: ${amount} * -1 ;;
      drill_fields: [transaction_detail*]
      filters: {
        field: transaction_type
        value: "debit"
      }
      value_format_name: usd
      link: {
        label: "Top Merchants"
        url: "
        {% assign vis_config = '{
        \"stacking\"              : \"normal\",
        \"legend_position\"       : \"right\",
        \"x_axis_gridlines\"      : false,
        \"y_axis_gridlines\"      : true,
        \"show_view_names\"       : false,
        \"y_axis_combined\"       : true,
        \"show_y_axis_labels\"    : true,
        \"show_y_axis_ticks\"     : true,
        \"y_axis_tick_density\"   : \"default\",
        \"show_x_axis_label\"     : true,
        \"show_x_axis_ticks\"     : true,
        \"show_null_points\"      : false,
        \"type\"                  : \"looker_pie\",
        \"inner_radius\"          : 50,
        \"colors\": [\"palette: Mixed Dark\"]
        }' %}
        /explore/mint/transactions?fields=transactions.total_spend_amount,merchant_facts.merchant_by_amount_tail&f[merchant_facts.tail]=%3C%3D10&f[transactions.transaction_type]=debit&f[transactions.is_expensable]=No&f[transactions.is_transfer]=No
        {% if transactions.date_month._is_selected %}
        &f[transactions.date_month]={{transactions.date_month._value | encode_uri }}
        {% elsif transactions.date_week._is_selected %}
        &f[transactions.date_week]={{transactions.date_week._value | encode_uri }}
        {% elsif transactions.date_date._is_selected %}
        &f[transactions.date_date]={{transactions.date_date._value | encode_uri }}
        {% elsif transactions.date_year._is_selected %}
        &f[transactions.date_year]={{transactions.date_year._value | encode_uri }}
        {% endif %}&sorts=merchant_facts.merchant_by_amount_tail&limit=500&column_limit=50&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis"
      }
      link: {
        label: "Top Categories"
        url: "
        {% assign vis_config = '{
        \"stacking\"              : \"normal\",
        \"legend_position\"       : \"right\",
        \"x_axis_gridlines\"      : false,
        \"y_axis_gridlines\"      : true,
        \"show_view_names\"       : false,
        \"y_axis_combined\"       : true,
        \"show_y_axis_labels\"    : true,
        \"show_y_axis_ticks\"     : true,
        \"y_axis_tick_density\"   : \"default\",
        \"show_x_axis_label\"     : true,
        \"show_x_axis_ticks\"     : true,
        \"show_null_points\"      : false,
        \"type\"                  : \"looker_pie\",
        \"inner_radius\"          : 50,
        \"colors\": [\"palette: Mixed Dark\"]
        }' %}
        /explore/mint/transactions?fields=transactions.total_spend_amount,category_facts.category_by_amount_tail&f[category_facts.tail]=%3C%3D10&f[transactions.transaction_type]=debit&f[transactions.is_expensable]=No&f[transactions.is_transfer]=No
        {% if transactions.date_month._is_selected %}
        &f[transactions.date_month]={{transactions.date_month._value | encode_uri }}
        {% elsif transactions.date_week._is_selected %}
        &f[transactions.date_week]={{transactions.date_week._value | encode_uri }}
        {% elsif transactions.date_date._is_selected %}
        &f[transactions.date_date]={{transactions.date_date._value | encode_uri }}
        {% elsif transactions.date_year._is_selected %}
        &f[transactions.date_year]={{transactions.date_year._value | encode_uri }}
        {% endif %}
        &sorts=category_facts.category_by_amount_tail&limit=500&column_limit=50&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis"
      }
    }




  measure: net_income {
      type: sum
      sql:  ${amount} ;;
      value_format_name: usd
      drill_fields: [transaction_detail*]
    }

  measure: running_total_spend {
      label: "Running Total Spend"
      drill_fields: [transaction_detail*]
      type: running_total
      sql: ${total_spend_amount} ;;
    }

  measure: average_spend_amount {
      type: average
      sql: ${amount} * -1 ;;
      drill_fields: [transaction_detail*]
      filters: {
        field: transaction_type
        value: "debit"
      }
      value_format_name: usd
    }

  measure: total_expenses {
      type: sum
      sql: ${amount} * -1 ;;
      drill_fields: [transaction_detail*]
      filters: {
        field: transaction_type
        value: "debit"
      }
      filters: {
        field: is_expensable
        value: "yes"
      }
      value_format_name: usd
    }

  measure: total_reimbursement {
      type: sum
      sql: ${amount}  ;;
      drill_fields: [income_detail*]
      filters: {
        field: transaction_type
        value: "credit"
      }
      filters: {
        field: is_reimbursement
        value: "yes"
      }

      value_format_name: usd
    }

  measure: largest_transaction {
    hidden: yes
    type: max
    sql: ${amount} ;;
    value_format_name: usd
  }

  measure: first_transaction {
    hidden: yes
    type: min
    sql: ${date_date} ;;
    value_format_name: usd
  }

  measure: last_transaction {
    hidden: yes
    type: max
    sql: ${date_date} ;;
    value_format_name: usd
  }

  measure: count_of_amounts {
    hidden: yes
    type: count_distinct
    sql: ${amount} ;;
    value_format_name: usd
  }

###### SETS ######
  set: transaction_detail {
      fields: [date_date,description,category,notes,transaction_type,account_name,total_spend_amount]
    }

  set: income_detail {
      fields: [date_date,original_description,category,notes,transaction_type,account_name,net_income]
    }

  }
