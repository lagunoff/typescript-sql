start
  = (test_ast newline)* 

test_ast
  = _ "@query_specification:" _ query_specification
  / _ "@query_expression:" _ query_expression
  / _ "@value_expression:" _ value_expression
  / _ "@general_literal:" _ general_literal
  / _ "@identifier:" _ identifier
  / _ "@table_reference:" _ table_reference
  / _ "@qualified_name:" _ qualified_name
  / _ "@table_expression:" _ table_expression
  / _ "@search_condition:" _ search_condition
  / _ "@comparison_predicate:" _ comparison_predicate
  / _ "@boolean_test:" _ boolean_test
  / _ "@where_clause:" _ where_clause
  / _ "@from_clause:" _ from_clause

