{
  var keywords = { "ABSOLUTE": true, "ACTION": true, "ADD": true, "ALL": true, "ALLOCATE": true, "ALTER": true, "AND": true, "ANY": true, "ARE": true, "AS": true, "ASC": true, "ASSERTION": true, "AT": true, "AUTHORIZATION": true, "AVG": true, "BEGIN": true, "BETWEEN": true, "BIT": true, "BIT_LENGTH": true, "BOTH": true, "BY": true, "CASCADE": true, "CASCADED": true, "CASE": true, "CAST": true, "CATALOG": true, "CHAR": true, "CHARACTER": true, "CHARACTER_LENGTH": true, "CHAR_LENGTH": true, "CHECK": true, "CLOSE": true, "COALESCE": true, "COLLATE": true, "COLLATION": true, "COLUMN": true, "COMMIT": true, "CONNECT": true, "CONNECTION": true, "CONSTRAINT": true, "CONSTRAINTS": true, "CONTINUE": true, "CONVERT": true, "CORRESPONDING": true, "CREATE": true, "CROSS": true, "CURRENT": true, "CURRENT_DATE": true, "CURRENT_TIME": true, "CURRENT_TIMESTAMP": true, "CURRENT_USER": true, "CURSOR": true, "DATE": true, "DAY": true, "DEALLOCATE": true, "DEC": true, "DECIMAL": true, "DECLARE": true, "DEFAULT": true, "DEFERRABLE": true, "DEFERRED": true, "DELETE": true, "DESC": true, "DESCRIBE": true, "DESCRIPTOR": true, "DIAGNOSTICS": true, "DISCONNECT": true, "DISTINCT": true, "DOMAIN": true, "DOUBLE": true, "DROP": true, "ELSE": true, "END": true, "END-EXEC": true, "ESCAPE": true, "EXCEPT": true, "EXCEPTION": true, "EXEC": true, "EXECUTE": true, "EXISTS": true, "EXTERNAL": true, "EXTRACT": true, "FALSE": true, "FETCH": true, "FIRST": true, "FLOAT": true, "FOR": true, "FOREIGN": true, "FOUND": true, "FROM": true, "FULL": true, "GET": true, "GLOBAL": true, "GO": true, "GOTO": true, "GRANT": true, "GROUP": true, "HAVING": true, "HOUR": true, "IDENTITY": true, "IMMEDIATE": true, "IN": true, "INDICATOR": true, "INITIALLY": true, "INNER": true, "INPUT": true, "INSENSITIVE": true, "INSERT": true, "INT": true, "INTEGER": true, "INTERSECT": true, "INTERVAL": true, "INTO": true, "IS": true, "ISOLATION": true, "JOIN": true, "KEY": true, "LANGUAGE": true, "LAST": true, "LEADING": true, "LEFT": true, "LEVEL": true, "LIKE": true, "LOCAL": true, "LOWER": true, "MATCH": true, "MAX": true, "MIN": true, "MINUTE": true, "MODULE": true, "MONTH": true, "NAMES": true, "NATIONAL": true, "NATURAL": true, "NCHAR": true, "NEXT": true, "NO": true, "NOT": true, "NULL": true, "NULLIF": true, "NUMERIC": true, "OCTET_LENGTH": true, "OF": true, "ON": true, "ONLY": true, "OPEN": true, "OPTION": true, "OR": true, "ORDER": true, "OUTER": true, "OUTPUT": true, "OVERLAPS": true, "PAD": true, "PARTIAL": true, "POSITION": true, "PRECISION": true, "PREPARE": true, "PRESERVE": true, "PRIMARY": true, "PRIOR": true, "PRIVILEGES": true, "PROCEDURE": true, "PUBLIC": true, "READ": true, "REAL": true, "REFERENCES": true, "RELATIVE": true, "RESTRICT": true, "REVOKE": true, "RIGHT": true, "ROLLBACK": true, "ROWS": true, "SCHEMA": true, "SCROLL": true, "SECOND": true, "SECTION": true, "SELECT": true, "SESSION": true, "SESSION_USER": true, "SET": true, "SIZE": true, "SMALLINT": true, "SOME": true, "SPACE": true, "SQL": true, "SQLCODE": true, "SQLERROR": true, "SQLSTATE": true, "SUBSTRING": true, "SUM": true, "SYSTEM_USER": true, "TABLE": true, "TEMPORARY": true, "THEN": true, "TIME": true, "TIMESTAMP": true, "TIMEZONE_HOUR": true, "TIMEZONE_MINUTE": true, "TO": true, "TRAILING": true, "TRANSACTION": true, "TRANSLATE": true, "TRANSLATION": true, "TRIM": true, "TRUE": true, "UNION": true, "UNIQUE": true, "UNKNOWN": true, "UPDATE": true, "UPPER": true, "USAGE": true, "USER": true, "USING": true, "VALUE": true, "VALUES": true, "VARCHAR": true, "VARYING": true, "VIEW": true, "WHEN": true, "WHENEVER": true, "WHERE": true, "WITH": true, "WORK": true, "WRITE": true, "YEAR": true, "ZONE": true, "ADA": true, "C": true, "CATALOG_NAME": true, "CHARACTER_SET_CATALOG": true, "CHARACTER_SET_NAME": true, "CHARACTER_SET_SCHEMA": true, "CLASS_ORIGIN": true, "COBOL": true, "COLLATION_CATALOG": true, "COLLATION_NAME": true, "COLLATION_SCHEMA": true, "COLUMN_NAME": true, "COMMAND_FUNCTION": true, "COMMITTED": true, "CONDITION_NUMBER": true, "CONNECTION_NAME": true, "CONSTRAINT_CATALOG": true, "CONSTRAINT_NAME": true, "CONSTRAINT_SCHEMA": true, "CURSOR_NAME": true, "DATA": true, "DATETIME_INTERVAL_CODE": true, "DATETIME_INTERVAL_PRECISION": true, "DYNAMIC_FUNCTION": true, "FORTRAN": true, "LENGTH": true, "MESSAGE_LENGTH": true, "MESSAGE_OCTET_LENGTH": true, "MESSAGE_TEXT": true, "MORE": true, "MUMPS": true, "NAME": true, "NULLABLE": true, "NUMBER": true, "PASCAL": true, "PLI": true, "REPEATABLE": true, "RETURNED_LENGTH": true, "RETURNED_OCTET_LENGTH": true, "RETURNED_SQLSTATE": true, "ROW_COUNT": true, "SCALE": true, "SCHEMA_NAME": true, "SERIALIZABLE": true, "SERVER_NAME": true, "SUBCLASS_ORIGIN": true, "TABLE_NAME": true, "TYPE": true, "UNCOMMITTED": true, "UNNAMED": true };
  var keywords_i = { "FROM": true, "WHERE": true };
  function isKeyword(str) {
    return str in keywords || str.toUpperCase() in keywords_i;
  }
}

start
  = (_? stmt _? ";" _? / _? stmt _? eof)*

stmt
  = delete_statement_searched
  / insert_statement
  / rollback_statement
  / search_condition
  / query_specification
  / update_statement_searched
  / table_definition
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
  / "@VALUE_EXPRESSION_PRIMARY:" _? value_expression_primary
  / "@COLUMN_REFERENCE:" _? column_reference


