view: transactions {
  sql_table_name: public.transactions ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."id" ;;
    hidden: yes
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
      day_of_year
    ]
    convert_tz: no
    sql: ${TABLE}."Date" ;;
    label: "1) Transaction"
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
    description: "Filter this on 'yes' to compare to same period in previous months"
    group_label: "1) Transaction Date"
    type: yesno
    sql:
      (EXTRACT(DAY FROM ${date_raw}) < EXTRACT(DAY FROM CURRENT_DATE)
        OR
        (
          EXTRACT(DAY FROM ${date_raw}) = EXTRACT(DAY FROM CURRENT_DATE) AND
          EXTRACT(HOUR FROM ${date_raw}) < EXTRACT(HOUR FROM CURRENT_DATE)
        )
        OR
        (
          EXTRACT(DAY FROM ${date_raw}) = EXTRACT(DAY FROM CURRENT_DATE) AND
          EXTRACT(HOUR FROM ${date_raw}) <= EXTRACT(HOUR FROM CURRENT_DATE) AND
          EXTRACT(MINUTE FROM ${date_raw}) < EXTRACT(MINUTE FROM CURRENT_DATE)
        )
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
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."Transaction Type" ;;
    label: "Debit/Credit"
  }

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

  dimension: is_expensable {
    type: yesno
    sql:  lower("Labels") = 'expensable' ;;
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

set: transaction_detail {
  fields: [date_date,description,category,notes,transaction_type,total_spend_amount]
}


}
