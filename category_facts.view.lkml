
view: taxonomy {
  sql_table_name: public.taxonomy ;;

  dimension: category {
    label: "High Level Category"
    view_label: "Category"
    type: string
    sql: ${TABLE}."category" ;;
  }

  dimension: subcategory {
    hidden: yes
    primary_key: yes
    type: string
    sql: ${TABLE}."subcategory" ;;
  }

  dimension: is_nondiscretionary {
    label: "Discretionary"
    view_label: "Category"
    type: yesno
    sql: NOT ${TABLE}.nondiscretionary ;;
  }
}

view: category_facts {
  label: "Category"
  derived_table: {
    explore_source: transactions {
      column: category {}
      column: total_amount  { field: transactions.total_spend_amount }
      column: volume        { field: transactions.count }
      column: avg_amount    { field: transactions.average_spend_amount }
      column: max_amount    { field: transactions.largest_transaction }
      derived_column: rank_by_amount { sql: ROW_NUMBER() OVER (ORDER BY total_amount DESC) ;;}
      derived_column: rank_by_number { sql: ROW_NUMBER() OVER (ORDER BY volume DESC) ;;}
      derived_column: rank_by_avg    { sql: ROW_NUMBER() OVER (ORDER BY volume DESC) ;;}
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
    description: "Ordinal rank at which categories will be grouped into an other bucket..."
  }

  dimension: category {
    hidden: yes
    type: string
    sql: ${TABLE}.category ;;
  }

####### AMOUNT #######
  dimension: rank_by_amount {
    type: number
    sql: ${TABLE}.rank_by_amount ;;
  }
  dimension: category_by_amount {
    type: string
    sql:
          CASE
          WHEN ${rank_by_amount} < 10 THEN '00' || ${rank_by_amount} || ') ' || ${category}
          WHEN ${rank_by_amount} < 100 THEN '0' || ${rank_by_amount} || ') ' || ${category}
          ELSE                                     ${rank_by_amount} || ') ' || ${category}
          END
    ;;
  }
  dimension: category_by_amount_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_amount} {% endcondition %} THEN ${category_by_amount}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: total_amount {
    type: number
    sql: ${TABLE}.total_amount ;;
    value_format_name: usd
  }
####### AMOUNT #######

####### NUMBER #######
  dimension: rank_by_number {
    type: number
    sql: ${TABLE}.rank_by_number ;;
  }
  dimension: category_by_number {
    type: string
    sql:
          CASE
          WHEN ${rank_by_number} < 10 THEN '00' || ${rank_by_number} || ') ' || ${category}
          WHEN ${rank_by_number} < 100 THEN '0' || ${rank_by_number} || ') ' || ${category}
          ELSE                                     ${rank_by_number} || ') ' || ${category}
          END
    ;;
  }
  dimension: category_by_number_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_number} {% endcondition %} THEN ${category_by_number}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: volume {
    type: number
    sql: ${TABLE}.volume ;;
  }
####### NUMBER #######

####### AVG #######
  dimension: rank_by_avg {
    type: number
    sql: ${TABLE}.rank_by_avg ;;
  }
  dimension: category_by_avg {
    type: string
    sql:
          CASE
          WHEN ${rank_by_avg} < 10 THEN '00' || ${rank_by_avg} || ') ' || ${category}
          WHEN ${rank_by_avg} < 100 THEN '0' || ${rank_by_avg} || ') ' || ${category}
          ELSE                                  ${rank_by_avg} || ') ' || ${category}
          END
    ;;
  }
  dimension: category_by_avg_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_avg} {% endcondition %} THEN ${category_by_avg}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: avg_amount {
    type: number
    sql: ${TABLE}.avg_amount ;;
    value_format_name: usd
  }
}


view: category_facts_legacy {
  label: "Category"
  derived_table: {
    sql:
      SELECT
         T."Category"                                             AS "TCategory"
        ,SUM(T."Amount")                                          AS total_amount
        ,COUNT(DISTINCT T.id)                                     AS volume
        ,AVG(T."Amount")                                          AS avg_amount
        ,MAX(T."Amount")                                          AS max_amount
        ,ROW_NUMBER() OVER (ORDER BY SUM(T."Amount") DESC)        AS rank_by_amount
        ,ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT T.id) DESC)   AS rank_by_number
        ,ROW_NUMBER() OVER (ORDER BY AVG(T."Amount") DESC)        AS rank_by_avg
      FROM
        public.transactions T
      WHERE
        1=1
        AND {% condition transactions.transaction_type %}   T."Transaction Type"     {% endcondition %}
        AND {% condition transactions.category %}           T."Category"             {% endcondition %}
        AND {% condition transactions.notes %}              T."Notes"                {% endcondition %}
        AND {% condition transactions.labels %}             T."Labels"               {% endcondition %}
        AND {% condition transactions.description %}        T."Description"          {% endcondition %}
        AND {% condition transactions.account_name %}       T."Account Name"         {% endcondition %}
        AND {% condition transactions.date_date %}          T."Date"                 {% endcondition %}
        AND {% condition transactions.date_month %}         T."Date"                 {% endcondition %}
        AND {% condition transactions.date_quarter %}       T."Date"                 {% endcondition %}
        AND {% condition transactions.date_year %}          T."Date"                 {% endcondition %}
        AND {% condition transactions.date_week %}          T."Date"                 {% endcondition %}
        AND {% condition transactions.date_week_of_year %}  T."Date"                 {% endcondition %}
        AND {% condition transactions.date_month_num %}     T."Date"                 {% endcondition %}
        AND {% condition transactions.date_day_of_year %}   T."Date"                 {% endcondition %}
        AND {% condition transactions.date_day_of_week %}   T."Date"                 {% endcondition %}
        AND {% condition transactions.date_day_of_week_index %} T."Date"             {% endcondition %}
        AND {% condition transactions.is_transfer %}             {{ transactions.is_transfer._sql }}               {% endcondition %}
        AND {% condition transactions.is_expensable %}            {{ transactions.is_expensable._sql}}             {% endcondition %}
                AND ({% if transactions.comparison_period_imputed._in_query %}
                   T."Date" >= ({% date_start transactions.reporting_period %}
                  - INTERVAL '{% parameter transactions.imputed_periods %} {% parameter transactions.imputed_periods_type %}')
                    AND T."Date" <= {% date_end transactions.reporting_period %}

            {% else %}
              1=1
            {% endif %})
      GROUP BY
        1
       ;;
  }

  filter: tail {
    type: number
    label: "Other Threshold"
    description: "Ordinal rank at which categories will be grouped into an other bucket..."
  }

  dimension: category {
    hidden: yes
    type: string
    sql: ${TABLE}."TCategory" ;;
  }

####### AMOUNT #######
  dimension: rank_by_amount {
    type: number
    sql: ${TABLE}.rank_by_amount ;;
  }
  dimension: category_by_amount {
    type: string
    sql:
          CASE
          WHEN ${rank_by_amount} < 10 THEN '00' || ${rank_by_amount} || ') ' || ${category}
          WHEN ${rank_by_amount} < 100 THEN '0' || ${rank_by_amount} || ') ' || ${category}
          ELSE                                     ${rank_by_amount} || ') ' || ${category}
          END
    ;;
  }
  dimension: category_by_amount_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_amount} {% endcondition %} THEN ${category_by_amount}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: total_amount {
    type: number
    sql: ${TABLE}.total_amount ;;
    value_format_name: usd
  }
####### AMOUNT #######

####### NUMBER #######
  dimension: rank_by_number {
    type: number
    sql: ${TABLE}.rank_by_number ;;
  }
  dimension: category_by_number {
    type: string
    sql:
          CASE
          WHEN ${rank_by_number} < 10 THEN '00' || ${rank_by_number} || ') ' || ${category}
          WHEN ${rank_by_number} < 100 THEN '0' || ${rank_by_number} || ') ' || ${category}
          ELSE                                     ${rank_by_number} || ') ' || ${category}
          END
    ;;
  }
  dimension: category_by_number_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_number} {% endcondition %} THEN ${category_by_number}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: volume {
    type: number
    sql: ${TABLE}.volume ;;
  }
####### NUMBER #######

####### AVG #######
  dimension: rank_by_avg {
    type: number
    sql: ${TABLE}.rank_by_avg ;;
  }
  dimension: category_by_avg {
    type: string
    sql:
          CASE
          WHEN ${rank_by_avg} < 10 THEN '00' || ${rank_by_avg} || ') ' || ${category}
          WHEN ${rank_by_avg} < 100 THEN '0' || ${rank_by_avg} || ') ' || ${category}
          ELSE                                  ${rank_by_avg} || ') ' || ${category}
          END
    ;;
  }
  dimension: category_by_avg_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_avg} {% endcondition %} THEN ${category_by_avg}
          ELSE 'x) Other'
          END
    ;;
  }
  dimension: avg_amount {
    type: number
    sql: ${TABLE}.avg_amount ;;
    value_format_name: usd
  }
####### AVG #######
}
