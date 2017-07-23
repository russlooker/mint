view: transactions {
  sql_table_name: public.transactions ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."id" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."Account Name" ;;
  }

  dimension: raw_amount {
    type: number
    sql: ${TABLE}."Amount" ;;
  }

  dimension: amount {
    type: number
    sql:
        CASE
          WHEN ${transaction_type} = 'debit' then ${raw_amount} * -1.0
          ELSE ${TABLE}."Amount"
        END
        ;;
  }


  dimension: category {
    hidden: yes
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
      month_num
    ]
    convert_tz: no
    sql: ${TABLE}."Date" ;;
    label: "Transaction"
  }

  dimension: is_before_wtd {
    description: "Filter this on 'yes' to compare to same period in previous weeks"
    group_label: "Transaction Date"
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
    group_label: "Transaction Date"
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
    group_label: "Transaction Date"
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
    hidden: yes
  }

  dimension: labels {
    type: string
    sql: ${TABLE}."Labels" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."Notes" ;;
  }

  dimension: original_description {
    type: string
    sql: ${TABLE}."Original Description" ;;
    label: "Description"
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."Transaction Type" ;;
    label: "Debit/Credit"
  }

  measure: count {
    type: count
    drill_fields: [id, account_name]
  }

  measure: total_net_amount {
    type: sum
    sql: ${amount} ;;
    drill_fields: [date_date,description,category,notes,transaction_type,total_net_amount]
    value_format_name: usd
  }

  measure: total_income_amount {
    type: sum
    sql: ${amount} ;;
    drill_fields: [date_date,description,category,notes,transaction_type,total_income_amount]
    filters: {
      field: transaction_type
      value: "credit"
    }
    value_format_name: usd
  }

  measure: total_spend_amount {
    type: sum
    sql: ${amount} * -1 ;;
    drill_fields: [date_date,description,category,notes,transaction_type,total_spend_amount]
    filters: {
      field: transaction_type
      value: "debit"
    }
    value_format_name: usd
  }

  measure: average_spend_amount {
    type: average
    sql: ${amount} * -1 ;;
    drill_fields: [date_date,description,category,notes,transaction_type,total_spend_amount]
    filters: {
      field: transaction_type
      value: "debit"
    }
    value_format_name: usd
  }


  dimension: is_expensable {
    type: yesno
    sql:  ${labels} = 'expensable' ;;
  }

  dimension: is_transfer {
    type: yesno
    sql: ${category} in
          ('transfer',
           'transfer for cash spending',
          'withdrawal',
          'cash & atm',
          'financial','hide from budgets & trends','auto payment','credit card payment','mortgage & rent')
      ;;
  }



}
