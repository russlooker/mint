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
#     from: category_facts_2
    type: left_outer
    relationship: many_to_one
    sql_on:  lower(${transactions.category}) = lower(${category_facts.category})  ;;
  }
  join: taxonomy {
    type: left_outer
    sql_on:  lower(${transactions.category}) = ${taxonomy.subcategory}  ;;
    relationship: many_to_one
  }
}
