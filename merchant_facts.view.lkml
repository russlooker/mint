view: merchant_facts {
  label: "Merchant"
  derived_table: {
    explore_source: transactions {
      column: description {}
      column: total_amount  { field: transactions.total_spend_amount }
      column: volume        { field: transactions.count }
      column: avg_amount    { field: transactions.average_spend_amount }
      column: max_amount    { field: transactions.largest_transaction }
      column: first_transaction {}
      column: last_transaction {}
      column: count_of_amounts {}
      derived_column: rank_by_amount { sql: ROW_NUMBER() OVER (ORDER BY total_amount DESC) ;;}
      derived_column: rank_by_number { sql: ROW_NUMBER() OVER (ORDER BY volume DESC) ;;}
      derived_column: rank_by_avg    { sql: ROW_NUMBER() OVER (ORDER BY volume DESC) ;;}
      derived_column: frequency                { sql: (volume * 1.0)/NULLIF(last_transaction - first_transaction,0) ;;}
      derived_column: duration                 { sql: last_transaction - first_transaction ;;}

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
    }
  }

  filter: tail {
    type: number
    label: "Other Threshold"
    description: "Ordinal rank at which merchants will be grouped into an other bucket..."
  }

  dimension: merchant {
    type: string
    sql: ${TABLE}.description ;;
    hidden: yes
  }

  dimension: max_amount {
    type: number
    group_label: "Facts"
    label: "Max Amount"
    sql: ${TABLE}.max_amount ;;
  }
  dimension: first_transaction {
    type: date
    group_label: "Facts"
    label: "First Transaction"
    sql: ${TABLE}.first_transaction ;;
  }
  dimension: last_transaction {
    type: date
    group_label: "Facts"
    label: "Last Transaction"
    sql: ${TABLE}.last_transaction ;;
  }
  dimension: duration_between_first_and_last_transaction {
    type: number
    group_label: "Facts"
    label: "Duration between first and last"
    sql: ${TABLE}.duration ;;
  }
  dimension: frequency {
    type: number
    group_label: "Facts"
    label: "Charge Regularity"
    sql: ${TABLE}.frequency ;;
    value_format_name: decimal_3
  }
dimension: charge_diversity {
  type: number
  group_label: "Facts"
  sql: ${TABLE}.count_of_amounts ;;
}
dimension: charge_diversity_ratio {
  type: number
#   hidden: yes
  sql: ${volume}*1.0/${charge_diversity} ;;
  value_format_name: decimal_2
}
  dimension: tolerance {
    type: number
    hidden: yes
    sql: 1.75 ;;
  }

  dimension: lower_bound {
    type: number
    hidden: yes
    sql: ((1.0/30)*(1-${tolerance})) ;;
  }
  dimension: upper_bound {
    type: number
    hidden: yes
    sql: ((1.0/30)*(1+${tolerance})) ;;
  }
  dimension: frequency_tier {
    type: string
    group_label: "Facts"
    label: "Charge Regularity Tier"
    sql:
    CASE WHEN ${charge_diversity_ratio} >= 2 THEN
      CASE
        WHEN ${frequency} BETWEEN ((1.0/30)*(1-${tolerance})) AND ((1.0/30)*(1+${tolerance})) THEN 'Monthly'
        WHEN ${frequency} BETWEEN ((1.0/90)*(1-${tolerance})) AND ((1.0/90)*(1+${tolerance})) THEN 'Quarterly'
        WHEN ${frequency} BETWEEN ((1.0/365)*(1-${tolerance})) AND ((1.0/365)*(1+${tolerance})) THEN 'Annual'
        WHEN ${frequency} BETWEEN ((1.0/7)*(1-${tolerance})) AND ((1.0/7)*(1+${tolerance})) THEN 'Weekly'
      ELSE 'No Pattern'
      END
    ELSE 'No Pattern'
    END
;;
    value_format_name: decimal_3
  }

  dimension: days_since_last_charge {
    type: number
    group_label: "Facts"
    label: "Days Since Last"
    sql: current_date - ${last_transaction} ;;
  }

  dimension: days_a_customer {
    type: number
    group_label: "Facts"
    label: "Days since start"
    sql: current_date - ${first_transaction} ;;
  }

####### AMOUNT #######
  dimension: rank_by_amount {
    type: number
    sql: ${TABLE}.rank_by_amount ;;
    group_label: "Rankings"
    label: "By Total Amount"
    skip_drill_filter: yes
  }
  dimension: merchant_by_amount {
    type: string
    group_label: "Merchant with Ranks"
    hidden: yes
    sql:
          CASE
          WHEN ${rank_by_amount} < 10 THEN '00' || ${rank_by_amount} || ') ' || ${merchant}
          WHEN ${rank_by_amount} < 100 THEN '0' || ${rank_by_amount} || ') ' || ${merchant}
          ELSE                                     ${rank_by_amount} || ') ' || ${merchant}
          END
    ;;

  }
  dimension: merchant_by_amount_tail {
    group_label: "Ranked Names"
    label: "By Total Amount"
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_amount} {% endcondition %} THEN ${merchant_by_amount}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: total_amount {
    group_label: "Facts"
    label: "Total Amount"
    type: number
    sql: ${TABLE}.total_amount ;;
    value_format_name: usd
  }
####### AMOUNT #######

####### NUMBER #######
  dimension: rank_by_number {
    group_label: "Rankings"
    label: "By Volume"
    type: number
    sql: ${TABLE}.rank_by_number ;;
    skip_drill_filter: yes
  }
  dimension: merchant_by_number {
    group_label: "Merchant with Ranks"
    hidden: yes
    type: string
    sql:
          CASE
          WHEN ${rank_by_number} < 10 THEN '00' || ${rank_by_number} || ') ' || ${merchant}
          WHEN ${rank_by_number} < 100 THEN '0' || ${rank_by_number} || ') ' || ${merchant}
          ELSE                                     ${rank_by_number} || ') ' || ${merchant}
          END
    ;;
  }
  dimension: merchant_by_number_tail {
    group_label: "Ranked Names"
    label: "By Volume"
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_number} {% endcondition %} THEN ${merchant_by_number}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: volume {
    group_label: "Facts"
    label: "Transaction Volume"
    type: number
    sql: ${TABLE}.volume ;;
  }
####### NUMBER #######

####### AVG #######
  dimension: rank_by_avg {
    group_label: "Rankings"
    label: "By Avg Amount"
    type: number
    sql: ${TABLE}.rank_by_avg ;;
    skip_drill_filter: yes
  }
  dimension: merchant_by_avg {
    group_label: "Merchant with Ranks"
    hidden: yes
    type: string
    sql:
          CASE
          WHEN ${rank_by_avg} < 10 THEN '00' || ${rank_by_avg} || ') ' || ${merchant}
          WHEN ${rank_by_avg} < 100 THEN '0' || ${rank_by_avg} || ') ' || ${merchant}
          ELSE                                  ${rank_by_avg} || ') ' || ${merchant}
          END
    ;;
  }
  dimension: merchant_by_avg_tail {
    type: string
    group_label: "Ranked Names"
    label: "By Avg Amount"
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_avg} {% endcondition %} THEN ${merchant_by_avg}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: avg_amount {
    group_label: "Facts"
    label: "Avg Amount"
    type: number
    sql: ${TABLE}.avg_amount ;;
    value_format_name: usd
  }
####### AVG #######
}


#     sql:
#       SELECT
#          T."Description"
#         ,SUM(T."Amount")                                              AS total_amount
#         ,COUNT(DISTINCT T.id)                                         AS volume
#         ,AVG(T."Amount")                                              AS avg_amount
#         ,MAX(T."Amount")                                              AS max_amount
#         ,COUNT(DISTINCT id)*1.0/NULLIF(MAX(T."Date")-MIN(T."Date"),0) AS frequency
#         ,COUNT(DISTINCT T."Amount")                                   AS charge_amount_diversity
#         ,MIN(T."Date")                                                AS first_transaction
#         ,MAX(T."Date")                                                AS last_transaction
#         ,MAX(T."Date")-MIN(T."Date")                                  AS duration
#         ,ROW_NUMBER() OVER (ORDER BY SUM(T."Amount") DESC)            AS rank_by_amount
#         ,ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT T.id) DESC)       AS rank_by_number
#         ,ROW_NUMBER() OVER (ORDER BY AVG(T."Amount") DESC)            AS rank_by_avg
#       FROM
#         public.transactions T
#       WHERE
#         1=1
#         AND {% condition transactions.transaction_type %}   T."Transaction Type"     {% endcondition %}
#         AND {% condition transactions.category %}           T."Category"             {% endcondition %}
#         AND {% condition transactions.notes %}              T."Notes"                {% endcondition %}
#         AND {% condition transactions.labels %}             T."Labels"               {% endcondition %}
#         AND {% condition transactions.description %}        T."Description"          {% endcondition %}
#         AND {% condition transactions.account_name %}       T."Account Name"         {% endcondition %}
#         AND {% condition transactions.date_date %}          T."Date"                 {% endcondition %}
#         AND {% condition transactions.date_month %}         T."Date"                 {% endcondition %}
#         AND {% condition transactions.date_quarter %}       T."Date"                 {% endcondition %}
#         AND {% condition transactions.date_year %}          T."Date"                 {% endcondition %}
#         AND {% condition transactions.date_week %}          T."Date"                 {% endcondition %}
#         AND {% condition transactions.date_week_of_year %}  T."Date"                 {% endcondition %}
#         AND {% condition transactions.date_month_num %}     T."Date"                 {% endcondition %}
#         AND {% condition transactions.date_day_of_year %}   T."Date"                 {% endcondition %}
#         AND {% condition transactions.date_day_of_week %}   T."Date"                 {% endcondition %}
#         AND {% condition transactions.date_day_of_week_index %} T."Date"             {% endcondition %}
#         AND {% condition transactions.is_transfer %}  {{ transactions.is_transfer._sql }}  {% endcondition %}
#         AND {% condition transactions.is_expensable %} {{ transactions.is_expensable._sql }}{% endcondition %}
#         AND ({% if transactions.comparison_period_imputed._in_query %}
#                    T."Date" >= ({% date_start transactions.reporting_period %}
#                   - INTERVAL '{% parameter transactions.imputed_periods %} {% parameter transactions.imputed_periods_type %}')
#                     AND T."Date" <= {% date_end transactions.reporting_period %}
#
#             {% else %}
#               1=1
#             {% endif %})
#       GROUP BY
#         1
#        ;;
