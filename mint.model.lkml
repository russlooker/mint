connection: "mint"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

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
    sql_on:  ${transactions.description} = ${merchant_facts.merchant}  ;;
  }
  join: category_facts {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${transactions.category} = ${category_facts.category}  ;;
  }
}
