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
    sql:  "Labels" = 'expensable' ;;
  }

  dimension: is_transfer {
    type: yesno
    sql: "Category" in
          ('transfer',
           'transfer for cash spending',
          'withdrawal',
          'cash & atm',
          'financial','hide from budgets & trends','credit card payment')
      ;;
  }

set: transaction_detail {
  fields: [date_date,description,category,notes,transaction_type,total_spend_amount]
}


}
