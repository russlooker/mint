connection: "mint"

include: "*.view.lkml"         # include all views in this project

explore: transactions {
  label: "Mint Transactions"
  description: "Filtered to normal expenses by default"
  always_filter: {
    filters: {
      field: transactions.is_transfer
      value: "No"
    }
    filters: {
      field: transactions.is_expensable
      value: "No"
    }
    filters: {
      field: transactions.transaction_type
      value: "debit"
    }
  }
  join: merchant_facts {
    type: left_outer
    relationship: many_to_one
    sql_on:  lower(${transactions.description}) = lower(${merchant_facts.merchant})  ;;
  }
  join: category_facts {
    type: left_outer
    relationship: many_to_one
    sql_on:  lower(${transactions.category}) = lower(${category_facts.category})  ;;
  }
  join: taxonomy {
    type: left_outer
    sql_on:  lower(${transactions.category}) = ${taxonomy.subcategory}  ;;
    relationship: many_to_one
  }

  join: month_facts_intermediate {
    type: left_outer
    sql_on: ${transactions.date_month} = ${month_facts_intermediate.date_month} ;;
    relationship: many_to_one
  }
  join: month_facts {
    type: cross
    relationship: many_to_one
  }

# NEEDS TO BE ZERO FILLED FOR AVERAGES TO WORK OUT CORRECTLY
#   join: month_category_facts_intermediate {
#     type: left_outer
#     sql_on: ${transactions.date_month} = ${month_category_facts_intermediate.date_month}
#     AND ${transactions.category} = ${month_category_facts_intermediate.category}
#     ;;
#     relationship: many_to_one
#   }
#   join: month_category_facts {
#     type: cross
#     relationship: many_to_one
#   }


}



view: month_facts {
  derived_table: {
    explore_source: transactions {
      column: average_spend {
        field: month_facts_intermediate.average_spend
      }
      column: min_spend {
        field: month_facts_intermediate.min_spend
      }
      column: max_spend {
        field: month_facts_intermediate.max_spend
      }
      column: agg_spend {
        field: month_facts_intermediate.agg_spend
      }
      bind_filters: {
        from_field: transactions.transaction_type
        to_field: transactions.transaction_type
      }
      bind_filters: {
        from_field: transactions.category
        to_field: transactions.category
      }
      bind_filters: {
        from_field: transactions.notes
        to_field: transactions.notes
      }
      bind_filters: {
        from_field: transactions.labels
        to_field: transactions.labels
      }
      bind_filters: {
        from_field: transactions.description
        to_field: transactions.description
      }
      bind_filters: {
        from_field: transactions.account_name
        to_field: transactions.account_name
      }
      bind_filters: {
        from_field: transactions.date_date
        to_field: transactions.date_date
      }
      bind_filters: {
        from_field: transactions.date_month
        to_field: transactions.date_month
      }
      bind_filters: {
        from_field: transactions.date_quarter
        to_field: transactions.date_quarter
      }
      bind_filters: {
        from_field: transactions.date_year
        to_field: transactions.date_year
      }
      bind_filters: {
        from_field: transactions.date_week
        to_field: transactions.date_week
      }
      bind_filters: {
        from_field: transactions.date_week_of_year
        to_field: transactions.date_week_of_year
      }
      bind_filters: {
        from_field: transactions.date_month_num
        to_field: transactions.date_month_num
      }
      bind_filters: {
        from_field: transactions.date_day_of_year
        to_field: transactions.date_day_of_year
      }
      bind_filters: {
        from_field: transactions.date_day_of_week
        to_field: transactions.date_day_of_week
      }
      bind_filters: {
        from_field: transactions.date_day_of_week_index
        to_field: transactions.date_day_of_week_index
      }
      bind_filters: {
        from_field: transactions.is_transfer
        to_field: transactions.is_transfer
      }
      bind_filters: {
        from_field: transactions.is_expensable
        to_field: transactions.is_expensable
      }
      bind_filters: {
        from_field: transactions.is_reimbursement
        to_field: transactions.is_reimbursement
      }
      bind_filters: {
        from_field: transactions.comparison_period_imputed
        to_field: transactions.comparison_period_imputed
      }
      bind_filters: {
        from_field: transactions.imputed_periods
        to_field: transactions.imputed_periods
      }
      bind_filters: {
        from_field: transactions.imputed_periods_type
        to_field: transactions.imputed_periods_type
      }
      bind_filters: {
        from_field: transactions.reporting_period
        to_field: transactions.reporting_period
      }
      bind_filters: {
        from_field: transactions.comparison_period
        to_field: transactions.comparison_period
      }
      bind_filters: {
        from_field: transactions.is_before_mtd
        to_field: transactions.is_before_mtd
      }
      bind_filters: {
        from_field: transactions.is_before_ytd
        to_field: transactions.is_before_ytd
      }
      bind_filters: {
        from_field: transactions.is_before_wtd
        to_field: transactions.is_before_wtd
      }
      }
  }
  measure: average_monthly_spend {
    type: max
    sql: ${TABLE}.average_spend ;;
    value_format_name: usd
  }
  measure: max_monthly_spend {
#     hidden: yes
    type: max
    sql: ${TABLE}.max_spend ;;
    value_format_name: usd
  }

  measure: min_monthly_spend {
#     hidden: yes
    type: max
    sql: ${TABLE}.min_spend ;;
    value_format_name: usd
  }

  measure: agg_monthly_spend {
#     hidden: yes
    type: max
    sql: ${TABLE}.agg_spend ;;
    value_format_name: usd
  }
}


view: month_facts_intermediate {
  derived_table: {
    explore_source: transactions {
      column: date_month {}
      column: total_spend_amount {}
      column: total_income_amount {}
      bind_filters: {
        from_field: transactions.transaction_type
        to_field: transactions.transaction_type
      }
      bind_filters: {
        from_field: transactions.category
        to_field: transactions.category
      }
      bind_filters: {
        from_field: transactions.notes
        to_field: transactions.notes
      }
      bind_filters: {
        from_field: transactions.labels
        to_field: transactions.labels
      }
      bind_filters: {
        from_field: transactions.description
        to_field: transactions.description
      }
      bind_filters: {
        from_field: transactions.account_name
        to_field: transactions.account_name
      }
      bind_filters: {
        from_field: transactions.date_date
        to_field: transactions.date_date
      }
      bind_filters: {
        from_field: transactions.date_month
        to_field: transactions.date_month
      }
      bind_filters: {
        from_field: transactions.date_quarter
        to_field: transactions.date_quarter
      }
      bind_filters: {
        from_field: transactions.date_year
        to_field: transactions.date_year
      }
      bind_filters: {
        from_field: transactions.date_week
        to_field: transactions.date_week
      }
      bind_filters: {
        from_field: transactions.date_week_of_year
        to_field: transactions.date_week_of_year
      }
      bind_filters: {
        from_field: transactions.date_month_num
        to_field: transactions.date_month_num
      }
      bind_filters: {
        from_field: transactions.date_day_of_year
        to_field: transactions.date_day_of_year
      }
      bind_filters: {
        from_field: transactions.date_day_of_week
        to_field: transactions.date_day_of_week
      }
      bind_filters: {
        from_field: transactions.date_day_of_week_index
        to_field: transactions.date_day_of_week_index
      }
      bind_filters: {
        from_field: transactions.is_transfer
        to_field: transactions.is_transfer
      }
      bind_filters: {
        from_field: transactions.is_expensable
        to_field: transactions.is_expensable
      }
      bind_filters: {
        from_field: transactions.is_reimbursement
        to_field: transactions.is_reimbursement
      }
      bind_filters: {
        from_field: transactions.comparison_period_imputed
        to_field: transactions.comparison_period_imputed
      }
      bind_filters: {
        from_field: transactions.imputed_periods
        to_field: transactions.imputed_periods
      }
      bind_filters: {
        from_field: transactions.imputed_periods_type
        to_field: transactions.imputed_periods_type
      }
      bind_filters: {
        from_field: transactions.reporting_period
        to_field: transactions.reporting_period
      }
      bind_filters: {
        from_field: transactions.comparison_period
        to_field: transactions.comparison_period
      }
      bind_filters: {
        from_field: transactions.is_before_mtd
        to_field: transactions.is_before_mtd
      }
      bind_filters: {
        from_field: transactions.is_before_ytd
        to_field: transactions.is_before_ytd
      }
      bind_filters: {
        from_field: transactions.is_before_wtd
        to_field: transactions.is_before_wtd
      }

    }
  }

  dimension: total_spend_amount {
    type: number
    hidden: yes
  }

  dimension: date_month {
    type: string
    hidden: yes
    primary_key: yes
  }

  measure: average_spend {
    hidden: yes
    type: average
    sql: ${total_spend_amount} ;;
    value_format_name: usd
  }

  measure: max_spend {
    hidden: yes
    type: max
    sql: ${total_spend_amount} ;;
    value_format_name: usd
  }

  measure: min_spend {
    hidden: yes
    type: min
    sql: ${total_spend_amount} ;;
    value_format_name: usd
  }

  measure: agg_spend {
    hidden: yes
    type: sum
    sql: ${total_spend_amount} ;;
    value_format_name: usd
  }

}


# NEEDS TO BE ZERO FILLED FOR AVERAGES TO WORK OUT CORRECTLY
# view: month_category_facts {
#   derived_table: {
#     explore_source: transactions {
#       column: category {
#         field: transactions.category
#       }
#       column: average_spend {
#         field: month_category_facts_intermediate.average_spend
#       }
#       column: min_spend {
#         field: month_category_facts_intermediate.min_spend
#       }
#       column: max_spend {
#         field: month_category_facts_intermediate.max_spend
#       }
#       column: agg_spend {
#         field: month_category_facts_intermediate.agg_spend
#       }
#       bind_filters: {
#         from_field: transactions.transaction_type
#         to_field: transactions.transaction_type
#       }
#       bind_filters: {
#         from_field: transactions.category
#         to_field: transactions.category
#       }
#       bind_filters: {
#         from_field: transactions.notes
#         to_field: transactions.notes
#       }
#       bind_filters: {
#         from_field: transactions.labels
#         to_field: transactions.labels
#       }
#       bind_filters: {
#         from_field: transactions.description
#         to_field: transactions.description
#       }
#       bind_filters: {
#         from_field: transactions.account_name
#         to_field: transactions.account_name
#       }
#       bind_filters: {
#         from_field: transactions.date_date
#         to_field: transactions.date_date
#       }
#       bind_filters: {
#         from_field: transactions.date_month
#         to_field: transactions.date_month
#       }
#       bind_filters: {
#         from_field: transactions.date_quarter
#         to_field: transactions.date_quarter
#       }
#       bind_filters: {
#         from_field: transactions.date_year
#         to_field: transactions.date_year
#       }
#       bind_filters: {
#         from_field: transactions.date_week
#         to_field: transactions.date_week
#       }
#       bind_filters: {
#         from_field: transactions.date_week_of_year
#         to_field: transactions.date_week_of_year
#       }
#       bind_filters: {
#         from_field: transactions.date_month_num
#         to_field: transactions.date_month_num
#       }
#       bind_filters: {
#         from_field: transactions.date_day_of_year
#         to_field: transactions.date_day_of_year
#       }
#       bind_filters: {
#         from_field: transactions.date_day_of_week
#         to_field: transactions.date_day_of_week
#       }
#       bind_filters: {
#         from_field: transactions.date_day_of_week_index
#         to_field: transactions.date_day_of_week_index
#       }
#       bind_filters: {
#         from_field: transactions.is_transfer
#         to_field: transactions.is_transfer
#       }
#       bind_filters: {
#         from_field: transactions.is_expensable
#         to_field: transactions.is_expensable
#       }
#       bind_filters: {
#         from_field: transactions.is_reimbursement
#         to_field: transactions.is_reimbursement
#       }
#       bind_filters: {
#         from_field: transactions.comparison_period_imputed
#         to_field: transactions.comparison_period_imputed
#       }
#       bind_filters: {
#         from_field: transactions.imputed_periods
#         to_field: transactions.imputed_periods
#       }
#       bind_filters: {
#         from_field: transactions.imputed_periods_type
#         to_field: transactions.imputed_periods_type
#       }
#       bind_filters: {
#         from_field: transactions.reporting_period
#         to_field: transactions.reporting_period
#       }
#       bind_filters: {
#         from_field: transactions.comparison_period
#         to_field: transactions.comparison_period
#       }
#       bind_filters: {
#         from_field: transactions.is_before_mtd
#         to_field: transactions.is_before_mtd
#       }
#       bind_filters: {
#         from_field: transactions.is_before_ytd
#         to_field: transactions.is_before_ytd
#       }
#       bind_filters: {
#         from_field: transactions.is_before_wtd
#         to_field: transactions.is_before_wtd
#       }
#     }
#   }
#   dimension: category {}
#   measure: average_monthly_spend {
#     type: max
#     sql: ${TABLE}.average_spend ;;
#     value_format_name: usd
#   }
#   measure: max_monthly_spend {
# #     hidden: yes
#   type: max
#   sql: ${TABLE}.max_spend ;;
#   value_format_name: usd
# }
#
# measure: min_monthly_spend {
# #     hidden: yes
# type: max
# sql: ${TABLE}.min_spend ;;
# value_format_name: usd
# }
#
# measure: agg_monthly_spend {
# #     hidden: yes
# type: max
# sql: ${TABLE}.agg_spend ;;
# value_format_name: usd
# }
# }
#
#
# view: month_category_facts_intermediate {
#   derived_table: {
#     explore_source: transactions {
#       column: date_month {}
#       column: category {
#         field: transactions.category
#       }
#       column: total_spend_amount {}
#       bind_filters: {
#         from_field: transactions.transaction_type
#         to_field: transactions.transaction_type
#       }
#       bind_filters: {
#         from_field: transactions.category
#         to_field: transactions.category
#       }
#       bind_filters: {
#         from_field: transactions.notes
#         to_field: transactions.notes
#       }
#       bind_filters: {
#         from_field: transactions.labels
#         to_field: transactions.labels
#       }
#       bind_filters: {
#         from_field: transactions.description
#         to_field: transactions.description
#       }
#       bind_filters: {
#         from_field: transactions.account_name
#         to_field: transactions.account_name
#       }
#       bind_filters: {
#         from_field: transactions.date_date
#         to_field: transactions.date_date
#       }
#       bind_filters: {
#         from_field: transactions.date_month
#         to_field: transactions.date_month
#       }
#       bind_filters: {
#         from_field: transactions.date_quarter
#         to_field: transactions.date_quarter
#       }
#       bind_filters: {
#         from_field: transactions.date_year
#         to_field: transactions.date_year
#       }
#       bind_filters: {
#         from_field: transactions.date_week
#         to_field: transactions.date_week
#       }
#       bind_filters: {
#         from_field: transactions.date_week_of_year
#         to_field: transactions.date_week_of_year
#       }
#       bind_filters: {
#         from_field: transactions.date_month_num
#         to_field: transactions.date_month_num
#       }
#       bind_filters: {
#         from_field: transactions.date_day_of_year
#         to_field: transactions.date_day_of_year
#       }
#       bind_filters: {
#         from_field: transactions.date_day_of_week
#         to_field: transactions.date_day_of_week
#       }
#       bind_filters: {
#         from_field: transactions.date_day_of_week_index
#         to_field: transactions.date_day_of_week_index
#       }
#       bind_filters: {
#         from_field: transactions.is_transfer
#         to_field: transactions.is_transfer
#       }
#       bind_filters: {
#         from_field: transactions.is_expensable
#         to_field: transactions.is_expensable
#       }
#       bind_filters: {
#         from_field: transactions.is_reimbursement
#         to_field: transactions.is_reimbursement
#       }
#       bind_filters: {
#         from_field: transactions.comparison_period_imputed
#         to_field: transactions.comparison_period_imputed
#       }
#       bind_filters: {
#         from_field: transactions.imputed_periods
#         to_field: transactions.imputed_periods
#       }
#       bind_filters: {
#         from_field: transactions.imputed_periods_type
#         to_field: transactions.imputed_periods_type
#       }
#       bind_filters: {
#         from_field: transactions.reporting_period
#         to_field: transactions.reporting_period
#       }
#       bind_filters: {
#         from_field: transactions.comparison_period
#         to_field: transactions.comparison_period
#       }
#       bind_filters: {
#         from_field: transactions.is_before_mtd
#         to_field: transactions.is_before_mtd
#       }
#       bind_filters: {
#         from_field: transactions.is_before_ytd
#         to_field: transactions.is_before_ytd
#       }
#       bind_filters: {
#         from_field: transactions.is_before_wtd
#         to_field: transactions.is_before_wtd
#       }
#
#     }
#   }
#
#   dimension: category {
#     hidden: yes
#   }
#
#   dimension: total_spend_amount {
#     type: number
#     hidden: yes
#   }
#
#   dimension: date_month {
#     type: string
#     hidden: yes
#     primary_key: yes
#   }
#
#   measure: average_spend {
#     hidden: yes
#     type: average
#     sql: ${total_spend_amount} ;;
#     value_format_name: usd
#   }
#
#   measure: max_spend {
#     hidden: yes
#     type: max
#     sql: ${total_spend_amount} ;;
#     value_format_name: usd
#   }
#
#   measure: min_spend {
#     hidden: yes
#     type: min
#     sql: ${total_spend_amount} ;;
#     value_format_name: usd
#   }
#
#   measure: agg_spend {
#     hidden: yes
#     type: sum
#     sql: ${total_spend_amount} ;;
#     value_format_name: usd
#   }
#
# }


# explore: calendar {
#   always_filter: {
#     filters: {
#       field: calendar.range
#       value: "3 months"
#     }
#   }
# }


# explore: transactions_calendar {
#   extends: [transactions]
#   view_name: calendar
#   join: transactions {
#     type: left_outer
#     sql_on:  ${calendar.date_date} = ${transactions.date_date} ;;
#   }
# }




# view: calendar {
#   derived_table: {
#     sql: select date::date
#       from generate_series(
#         {% date_start calendar.range %},
#         {% date_end calendar.range %} - INTERVAL '1 days',
#         '1 day'::interval
#       ) date
#        ;;
#   }
#
#   filter: range {
#     type: date
#   }
#
#   measure: day_count {
#     type: count_distinct
#     sql: ${date_date} ;;
#   }
#
#   measure: month_count {
#     type: count_distinct
#     sql: ${date_month} ;;
#   }
#
#   dimension_group: date {
#     type: time
#     sql: ${TABLE}.date ;;
#     timeframes: [
#       raw,
#       date,
#       month,
#       week,
#       year,
#       month_num,
#       week_of_year,
#       day_of_week,
#       day_of_month,
#       day_of_week_index
#
#     ]
#   }
#
# }
