start
  = (_? stmt _? ";")* 

stmt
  = delete_statement__positioned
  / delete_statement__searched
  / dynamic_delete_statement__positioned
  / insert_statement
  / rollback_statement
  / search_condition
  / query_specification
  / update_statement__positioned
  / update_statement__searched
  / dynamic_update_statement__positioned
  / "@QUERY_EXPRESSION:" _? query_expression
  / "@VALUE_EXPRESSION:" _? value_expression
  / "@GENERAL_LITERAL:" _? general_literal
  / "@IDENTIFIER:" _? identifier
  / "@TABLE_REFERENCE:" _? table_reference
  / "@TABLE_EXPRESSION:" _? table_expression
  / "@SEARCH_CONDITION:" _? search_condition
  / "@COMPARISON_PREDICATE:" _? comparison_predicate
  / "@BOOLEAN_TEST:" _? boolean_test
  / "@WHERE_CLAUSE:" _? where_clause
  / "@FROM_CLAUSE:" _? from_clause

