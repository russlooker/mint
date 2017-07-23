view: merchant_facts {
  label: "Merchant"
  derived_table: {
    sql:
      SELECT
         T."Description"
        ,SUM(T."Amount")                                              AS total_amount
        ,COUNT(DISTINCT T.id)                                         AS volume
        ,AVG(T."Amount")                                              AS avg_amount
        ,MAX(T."Amount")                                              AS max_amount
        ,COUNT(DISTINCT id)*1.0/NULLIF(MAX(T."Date")-MIN(T."Date"),0) AS frequency
        ,MIN(T."Date")                                                AS first_transaction
        ,MAX(T."Date")                                                AS last_transaction
        ,MAX(T."Date")-MIN(T."Date")                                  AS duration
        ,ROW_NUMBER() OVER (ORDER BY SUM(T."Amount") DESC)            AS rank_by_amount
        ,ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT T.id) DESC)       AS rank_by_number
        ,ROW_NUMBER() OVER (ORDER BY AVG(T."Amount") DESC)            AS rank_by_avg
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
      GROUP BY
        1
       ;;
  }

  filter: tail {
    type: number
  }

  dimension: merchant {
    type: string
    sql: ${TABLE}."Description" ;;
  }

####### AMOUNT #######
  dimension: rank_by_amount {
    type: number
    sql: ${TABLE}.rank_by_amount ;;
  }
  dimension: merchant_by_amount {
    type: string
    sql:
          CASE
          WHEN ${rank_by_amount} < 10 THEN '00' || ${rank_by_amount} || ') ' || ${merchant}
          WHEN ${rank_by_amount} < 100 THEN '0' || ${rank_by_amount} || ') ' || ${merchant}
          ELSE                                     ${rank_by_amount} || ') ' || ${merchant}
          END
    ;;
  }
  dimension: merchant_by_amount_tail {
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_amount} {% endcondition %} THEN ${merchant_by_amount}
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
  dimension: merchant_by_number {
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
    type: string
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_number} {% endcondition %} THEN ${merchant_by_number}
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
  dimension: merchant_by_avg {
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
    sql:
          CASE
          WHEN {% condition tail %} ${rank_by_avg} {% endcondition %} THEN ${merchant_by_avg}
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
