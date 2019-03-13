{
  var keywords = { "ABSOLUTE": true, "ACTION": true, "ADD": true, "ALL": true, "ALLOCATE": true, "ALTER": true, "AND": true, "ANY": true, "ARE": true, "AS": true, "ASC": true, "ASSERTION": true, "AT": true, "AUTHORIZATION": true, "AVG": true, "BEGIN": true, "BETWEEN": true, "BIT": true, "BIT_LENGTH": true, "BOTH": true, "BY": true, "CASCADE": true, "CASCADED": true, "CASE": true, "CAST": true, "CATALOG": true, "CHAR": true, "CHARACTER": true, "CHARACTER_LENGTH": true, "CHAR_LENGTH": true, "CHECK": true, "CLOSE": true, "COALESCE": true, "COLLATE": true, "COLLATION": true, "COLUMN": true, "COMMIT": true, "CONNECT": true, "CONNECTION": true, "CONSTRAINT": true, "CONSTRAINTS": true, "CONTINUE": true, "CONVERT": true, "CORRESPONDING": true, "CREATE": true, "CROSS": true, "CURRENT": true, "CURRENT_DATE": true, "CURRENT_TIME": true, "CURRENT_TIMESTAMP": true, "CURRENT_USER": true, "CURSOR": true, "DATE": true, "DAY": true, "DEALLOCATE": true, "DEC": true, "DECIMAL": true, "DECLARE": true, "DEFAULT": true, "DEFERRABLE": true, "DEFERRED": true, "DELETE": true, "DESC": true, "DESCRIBE": true, "DESCRIPTOR": true, "DIAGNOSTICS": true, "DISCONNECT": true, "DISTINCT": true, "DOMAIN": true, "DOUBLE": true, "DROP": true, "ELSE": true, "END": true, "END-EXEC": true, "ESCAPE": true, "EXCEPT": true, "EXCEPTION": true, "EXEC": true, "EXECUTE": true, "EXISTS": true, "EXTERNAL": true, "EXTRACT": true, "FALSE": true, "FETCH": true, "FIRST": true, "FLOAT": true, "FOR": true, "FOREIGN": true, "FOUND": true, "FROM": true, "FULL": true, "GET": true, "GLOBAL": true, "GO": true, "GOTO": true, "GRANT": true, "GROUP": true, "HAVING": true, "HOUR": true, "IDENTITY": true, "IMMEDIATE": true, "IN": true, "INDICATOR": true, "INITIALLY": true, "INNER": true, "INPUT": true, "INSENSITIVE": true, "INSERT": true, "INT": true, "INTEGER": true, "INTERSECT": true, "INTERVAL": true, "INTO": true, "IS": true, "ISOLATION": true, "JOIN": true, "KEY": true, "LANGUAGE": true, "LAST": true, "LEADING": true, "LEFT": true, "LEVEL": true, "LIKE": true, "LOCAL": true, "LOWER": true, "MATCH": true, "MAX": true, "MIN": true, "MINUTE": true, "MODULE": true, "MONTH": true, "NAMES": true, "NATIONAL": true, "NATURAL": true, "NCHAR": true, "NEXT": true, "NO": true, "NOT": true, "NULL": true, "NULLIF": true, "NUMERIC": true, "OCTET_LENGTH": true, "OF": true, "ON": true, "ONLY": true, "OPEN": true, "OPTION": true, "OR": true, "ORDER": true, "OUTER": true, "OUTPUT": true, "OVERLAPS": true, "PAD": true, "PARTIAL": true, "POSITION": true, "PRECISION": true, "PREPARE": true, "PRESERVE": true, "PRIMARY": true, "PRIOR": true, "PRIVILEGES": true, "PROCEDURE": true, "PUBLIC": true, "READ": true, "REAL": true, "REFERENCES": true, "RELATIVE": true, "RESTRICT": true, "REVOKE": true, "RIGHT": true, "ROLLBACK": true, "ROWS": true, "SCHEMA": true, "SCROLL": true, "SECOND": true, "SECTION": true, "SELECT": true, "SESSION": true, "SESSION_USER": true, "SET": true, "SIZE": true, "SMALLINT": true, "SOME": true, "SPACE": true, "SQL": true, "SQLCODE": true, "SQLERROR": true, "SQLSTATE": true, "SUBSTRING": true, "SUM": true, "SYSTEM_USER": true, "TABLE": true, "TEMPORARY": true, "THEN": true, "TIME": true, "TIMESTAMP": true, "TIMEZONE_HOUR": true, "TIMEZONE_MINUTE": true, "TO": true, "TRAILING": true, "TRANSACTION": true, "TRANSLATE": true, "TRANSLATION": true, "TRIM": true, "TRUE": true, "UNION": true, "UNIQUE": true, "UNKNOWN": true, "UPDATE": true, "UPPER": true, "USAGE": true, "USER": true, "USING": true, "VALUE": true, "VALUES": true, "VARCHAR": true, "VARYING": true, "VIEW": true, "WHEN": true, "WHENEVER": true, "WHERE": true, "WITH": true, "WORK": true, "WRITE": true, "YEAR": true, "ZONE": true, "ADA": true, "C": true, "CATALOG_NAME": true, "CHARACTER_SET_CATALOG": true, "CHARACTER_SET_NAME": true, "CHARACTER_SET_SCHEMA": true, "CLASS_ORIGIN": true, "COBOL": true, "COLLATION_CATALOG": true, "COLLATION_NAME": true, "COLLATION_SCHEMA": true, "COLUMN_NAME": true, "COMMAND_FUNCTION": true, "COMMITTED": true, "CONDITION_NUMBER": true, "CONNECTION_NAME": true, "CONSTRAINT_CATALOG": true, "CONSTRAINT_NAME": true, "CONSTRAINT_SCHEMA": true, "CURSOR_NAME": true, "DATA": true, "DATETIME_INTERVAL_CODE": true, "DATETIME_INTERVAL_PRECISION": true, "DYNAMIC_FUNCTION": true, "FORTRAN": true, "LENGTH": true, "MESSAGE_LENGTH": true, "MESSAGE_OCTET_LENGTH": true, "MESSAGE_TEXT": true, "MORE": true, "MUMPS": true, "NAME": true, "NULLABLE": true, "NUMBER": true, "PASCAL": true, "PLI": true, "REPEATABLE": true, "RETURNED_LENGTH": true, "RETURNED_OCTET_LENGTH": true, "RETURNED_SQLSTATE": true, "ROW_COUNT": true, "SCALE": true, "SCHEMA_NAME": true, "SERIALIZABLE": true, "SERVER_NAME": true, "SUBCLASS_ORIGIN": true, "TABLE_NAME": true, "TYPE": true, "UNCOMMITTED": true, "UNNAMED": true };
  var keywords_i = { "FROM": true };
  function isKeyword(str) {
    return str in keywords || str.toUpperCase() in keywords_i;
  }
}

start
  = (_? stmt _? ";" _? / _? stmt _? eof)*

stmt
  = delete_statement
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


//= type delete_statement = { tag: 'delete_statement', table_name: table_name, search_condition: search_condition };
//= printers["delete_statement"] = function(value) { return String(value); };
delete_statement "delete_statement"
  = "DELETE"i _ "FROM"i _ table_name:table_name where:(_ "WHERE"i _? search_condition)?
    { return { tag: 'delete_statement', table_name: table_name, search_condition: where ? where[3] : null }; }

//= type table_name = qualified_name;
//= printers["table_name"] = function(value) { throw 'print "table_name": unimplemented'; };
table_name "table_name"
  = qualified_name

//= type period = string;
period "period"
  = "."

//= type qualified_identifier = identifier;
//= printers["qualified_identifier"] = printers["identifier"];
qualified_identifier "qualified_identifier"
  = identifier

//= type character_set_name = { tag: "character_set_name", schema_name: schema_name|null, name: SQL_language_identifier };
//= printers["character_set_name"] = function(value) { throw 'print "character_set_name": unimplemented'; };
character_set_name "character_set_name"
  = schema_name:(schema_name period)? name:SQL_language_identifier
    { return { tag: "character_set_name", schema_name: schema_name ? schema_name[0] : null, name: name }; }

//= type schema_name = { tag: "schema_name", catalog_name: catalog_name|null, name: unqualified_schema_name };
//= printers["schema_name"] = function(value) { throw 'print "schema_name": unimplemented'; };
schema_name "schema_name"
  = catalog_name:(catalog_name period)? name:unqualified_schema_name
    { return { tag: "schema_name", catalog_name: catalog_name ? catalog_name[0] : null, name: name }; }
    

//= type catalog_name = { tag: "catalog_name" };
//= printers["catalog_name"] = function(value) { throw 'print "catalog_name": unimplemented'; };
catalog_name "catalog_name"
  = identifier

//= type identifier = { tag: "identifier", character_set: character_set_name|null, identifier: actual_identifier };
//= printers["identifier"] = function(value) { throw 'print "identifier": unimplemented'; };
identifier "identifier"
  = character_set:(introducer character_set_name)? identifier:actual_identifier
    { return { tag: "identifier", character_set: character_set ? character_set[1] : null, identifier: identifier }; }

//= type unqualified_schema_name = identifier;
//= printers["unqualified_schema_name"] = printers["identifier"];
unqualified_schema_name "unqualified_schema_name"
  = identifier

//= type introducer = string;
introducer "introducer"
  = underscore

//= type underscore = string;
underscore "underscore"
  = "_"

//= type actual_identifier = string;
//= printers["actual_identifier"] = function(value) { throw 'print "actual_identifier": unimplemented'; };
actual_identifier "actual_identifier"
  = regular_identifier
  / $(double_quote delimited_identifier_body double_quote)

//= type double_quote = { tag: "double_quote" };
//= printers["double_quote"] = function(value) { throw 'print "double_quote": unimplemented'; };
double_quote "double_quote"
  = "\""

//= type delimited_identifier_body = string;
delimited_identifier_body "delimited_identifier_body"
  = delimited_identifier_part+

//= type delimited_identifier_part = string;
delimited_identifier_part "delimited_identifier_part"
  = nondoublequote_character
  / doublequote_symbol

//= type doublequote_symbol = string;
doublequote_symbol "doublequote_symbol"
  = $(double_quote double_quote)

//= type SQL_language_identifier = { tag: "SQL_language_identifier", identifier: string };
//= printers["SQL_language_identifier"] = function(value) { throw 'print "SQL_language_identifier": unimplemented'; };
SQL_language_identifier "SQL_language_identifier"
  = identifier:$(SQL_language_identifier_start (_? (underscore / SQL_language_identifier_part))*)
    { return { tag: "SQL_language_identifier", identifier: identifier }; }

//= type SQL_language_identifier_part = string;
SQL_language_identifier_part "SQL_language_identifier_part"
  = simple_Latin_letter
  / digit

//= type digit = string;
digit "digit"
  = [0-9]

//= type simple_Latin_letter = string;
simple_Latin_letter "simple_Latin_letter"
  = simple_Latin_upper_case_letter
  / simple_Latin_lower_case_letter

//= type simple_Latin_lower_case_letter = string;
simple_Latin_lower_case_letter "simple_Latin_lower_case_letter"
  = [a-z]

//= type simple_Latin_upper_case_letter = string;
simple_Latin_upper_case_letter "simple_Latin_upper_case_letter"
  = [A-Z]

//= type SQL_language_identifier_start = string;
SQL_language_identifier_start "SQL_language_identifier_start"
  = simple_Latin_letter

//= type qualified_name = { tag: "qualified_name", catalog_name: catalog_name|null, schema_name: schema_name|null, identifier: qualified_identifier };
//= printers["qualified_name"] = function(value) { throw 'print "qualified_name": unimplemented'; };
qualified_name "qualified_name"
  = catalog_name:catalog_name period schema_name:unqualified_schema_name period identifier:qualified_identifier
    { return { tag: "qualified_name", catalog_name: catalog_name, schema_name: schema_name, identifier: identifier }; }
  / schema_name:unqualified_schema_name period identifier:qualified_identifier
    { return { tag: "qualified_name", catalog_name: null, schema_name: schema_name, identifier: identifier }; }
  / identifier:qualified_identifier
    { return { tag: "qualified_name", catalog_name: null, schema_name: null, identifier: identifier }; }

//= type value_expression_primary = value_expression;
//= printers["value_expression_primary"] = function(value) { throw 'print "value_expression_primary": unimplemented'; };
value_expression_primary "value_expression_primary"
  = unsigned_value_specification
  / set_function_specification
  / column_reference
  / scalar_subquery
  / case_expression
  / left_paren _? expr:value_expression _? right_paren { return expr; }
  / cast_specification

//= type value_expression = { tag: "value_expression" };
//= printers["value_expression"] = function(value) { throw 'print "value_expression": unimplemented'; };
value_expression "value_expression"
  = string_value_expression
  / numeric_value_expression
  / datetime_value_expression
  / interval_value_expression

//= type string_value_expression = { tag: "string_value_expression" };
//= printers["string_value_expression"] = function(value) { throw 'print "string_value_expression": unimplemented'; };
string_value_expression "string_value_expression"
  = character_value_expression
  / bit_value_expression

//= type character_value_expression = { tag: "character_value_expression" };
//= printers["character_value_expression"] = function(value) { throw 'print "character_value_expression": unimplemented'; };
character_value_expression "character_value_expression"
  = $(character_factor (_? concatenation_operator _? character_factor)*)

//= type character_factor = { tag: "character_factor" };
//= printers["character_factor"] = function(value) { throw 'print "character_factor": unimplemented'; };
character_factor "character_factor"
  = $(character_primary (_? collate_clause)?)

//= type character_primary = { tag: "character_primary" };
//= printers["character_primary"] = function(value) { throw 'print "character_primary": unimplemented'; };
character_primary "character_primary"
  = value_expression_primary
  / string_value_function

//= type string_value_function = { tag: "string_value_function" };
//= printers["string_value_function"] = function(value) { throw 'print "string_value_function": unimplemented'; };
string_value_function "string_value_function"
  = character_value_function
  / bit_value_function

//= type character_value_function = { tag: "character_value_function" };
//= printers["character_value_function"] = function(value) { throw 'print "character_value_function": unimplemented'; };
character_value_function "character_value_function"
  = character_substring_function
  / fold
  / form_of_use_conversion
  / character_translation
  / trim_function

//= type character_substring_function = { tag: "character_substring_function" };
//= printers["character_substring_function"] = function(value) { throw 'print "character_substring_function": unimplemented'; };
character_substring_function "character_substring_function"
  = $("SUBSTRING"i _? left_paren _? character_value_expression _? "FROM"i _? start_position (_? "FOR"i _? string_length)? _? right_paren)

//= type start_position = { tag: "start_position" };
//= printers["start_position"] = function(value) { throw 'print "start_position": unimplemented'; };
start_position "start_position"
  = numeric_value_expression

//= type numeric_value_expression = { tag: "numeric_value_expression" };
//= printers["numeric_value_expression"] = function(value) { throw 'print "numeric_value_expression": unimplemented'; };
numeric_value_expression "numeric_value_expression"
  = $(term (_? (plus_sign / minus_sign) _? term)*)

//= type term = { tag: "term" };
//= printers["term"] = function(value) { throw 'print "term": unimplemented'; };
term "term"
  = $(factor (_? (asterisk / solidus) _? factor)*)

//= type factor = { tag: "factor" };
//= printers["factor"] = function(value) { throw 'print "factor": unimplemented'; };
factor "factor"
  = $((sign _?)? numeric_primary)

//= type numeric_primary = { tag: "numeric_primary" };
//= printers["numeric_primary"] = function(value) { throw 'print "numeric_primary": unimplemented'; };
numeric_primary "numeric_primary"
  = value_expression_primary
  / numeric_value_function

//= type numeric_value_function = { tag: "numeric_value_function" };
//= printers["numeric_value_function"] = function(value) { throw 'print "numeric_value_function": unimplemented'; };
numeric_value_function "numeric_value_function"
  = position_expression
  / extract_expression
  / length_expression

//= type position_expression = { tag: "position_expression" };
//= printers["position_expression"] = function(value) { throw 'print "position_expression": unimplemented'; };
position_expression "position_expression"
  = $("POSITION"i _? left_paren _? character_value_expression _? "IN"i _? character_value_expression _? right_paren)

//= type extract_expression = { tag: "extract_expression" };
//= printers["extract_expression"] = function(value) { throw 'print "extract_expression": unimplemented'; };
extract_expression "extract_expression"
  = $("EXTRACT"i _? left_paren _? extract_field _? "FROM"i _? extract_source _? right_paren)

//= type extract_source = { tag: "extract_source" };
//= printers["extract_source"] = function(value) { throw 'print "extract_source": unimplemented'; };
extract_source "extract_source"
  = datetime_value_expression
  / interval_value_expression

//= type datetime_value_expression = { tag: "datetime_value_expression" };
//= printers["datetime_value_expression"] = function(value) { throw 'print "datetime_value_expression": unimplemented'; };
datetime_value_expression "datetime_value_expression"
  = $(datetime_term (_? (asterisk / solidus) _? interval_term)*)
  / $(interval_value_expression _? plus_sign _? datetime_term)

//= type interval_value_expression = { tag: "interval_value_expression" };
//= printers["interval_value_expression"] = function(value) { throw 'print "interval_value_expression": unimplemented'; };
interval_value_expression "interval_value_expression"
  = $(interval_term (_? (plus_sign / minus_sign) _? interval_term)*)
  / $(left_paren _? datetime_value_expression _? minus_sign _? datetime_term _? right_paren _? interval_qualifier)

//= type datetime_term = { tag: "datetime_term" };
//= printers["datetime_term"] = function(value) { throw 'print "datetime_term": unimplemented'; };
datetime_term "datetime_term"
  = datetime_factor

//= type datetime_factor = { tag: "datetime_factor" };
//= printers["datetime_factor"] = function(value) { throw 'print "datetime_factor": unimplemented'; };
datetime_factor "datetime_factor"
  = $(datetime_primary (_? time_zone)?)

//= type datetime_primary = { tag: "datetime_primary" };
//= printers["datetime_primary"] = function(value) { throw 'print "datetime_primary": unimplemented'; };
datetime_primary "datetime_primary"
  = value_expression_primary
  / datetime_value_function

//= type time_zone = { tag: "time_zone" };
//= printers["time_zone"] = function(value) { throw 'print "time_zone": unimplemented'; };
time_zone "time_zone"
  = $("AT"i _? time_zone_specifier)

//= type time_zone_specifier = { tag: "time_zone_specifier" };
//= printers["time_zone_specifier"] = function(value) { throw 'print "time_zone_specifier": unimplemented'; };
time_zone_specifier "time_zone_specifier"
  = "LOCAL"i
  / $("TIME"i _? "ZONE"i _? interval_value_expression)

//= type interval_term = { tag: "interval_term" };
//= printers["interval_term"] = function(value) { throw 'print "interval_term": unimplemented'; };
interval_term "interval_term"
  = $(interval_factor (_? (asterisk / solidus) _? factor)*)
  / $(term _? asterisk _? interval_factor)

//= type interval_factor = { tag: "interval_factor" };
//= printers["interval_factor"] = function(value) { throw 'print "interval_factor": unimplemented'; };
interval_factor "interval_factor"
  = $((sign _?)? interval_primary)

//= type interval_primary = { tag: "interval_primary" };
//= printers["interval_primary"] = function(value) { throw 'print "interval_primary": unimplemented'; };
interval_primary "interval_primary"
  = $(value_expression_primary (_? interval_qualifier)?)

//= type length_expression = { tag: "length_expression" };
//= printers["length_expression"] = function(value) { throw 'print "length_expression": unimplemented'; };
length_expression "length_expression"
  = char_length_expression
  / octet_length_expression
  / bit_length_expression

//= type char_length_expression = { tag: "char_length_expression" };
//= printers["char_length_expression"] = function(value) { throw 'print "char_length_expression": unimplemented'; };
char_length_expression "char_length_expression"
  = $(("CHAR_LENGTH"i / "CHARACTER_LENGTH"i) _? left_paren _? string_value_expression _? right_paren)

//= type octet_length_expression = { tag: "octet_length_expression" };
//= printers["octet_length_expression"] = function(value) { throw 'print "octet_length_expression": unimplemented'; };
octet_length_expression "octet_length_expression"
  = $("OCTET_LENGTH"i _? left_paren _? string_value_expression _? right_paren)

//= type bit_length_expression = { tag: "bit_length_expression" };
//= printers["bit_length_expression"] = function(value) { throw 'print "bit_length_expression": unimplemented'; };
bit_length_expression "bit_length_expression"
  = $("BIT_LENGTH"i _? left_paren _? string_value_expression _? right_paren)

//= type string_length = { tag: "string_length" };
//= printers["string_length"] = function(value) { throw 'print "string_length": unimplemented'; };
string_length "string_length"
  = numeric_value_expression

//= type fold = { tag: "fold" };
//= printers["fold"] = function(value) { throw 'print "fold": unimplemented'; };
fold "fold"
  = $(("UPPER"i / "LOWER"i) _? left_paren _? character_value_expression _? right_paren)

//= type form_of_use_conversion = { tag: "form_of_use_conversion" };
//= printers["form_of_use_conversion"] = function(value) { throw 'print "form_of_use_conversion": unimplemented'; };
form_of_use_conversion "form_of_use_conversion"
  = $("CONVERT"i _? left_paren _? character_value_expression _? "USING"i _? form_of_use_conversion_name _? right_paren)

//= type character_translation = { tag: "character_translation" };
//= printers["character_translation"] = function(value) { throw 'print "character_translation": unimplemented'; };
character_translation "character_translation"
  = $("TRANSLATE"i _? left_paren _? character_value_expression _? "USING"i _? translation_name _? right_paren)

//= type trim_function = { tag: "trim_function" };
//= printers["trim_function"] = function(value) { throw 'print "trim_function": unimplemented'; };
trim_function "trim_function"
  = $("TRIM"i _? left_paren _? trim_operands _? right_paren)

//= type trim_operands = { tag: "trim_operands" };
//= printers["trim_operands"] = function(value) { throw 'print "trim_operands": unimplemented'; };
trim_operands "trim_operands"
  = $((trim_specification? (_? trim_character)? _? "FROM"i _?)? trim_source)

//= type trim_character = { tag: "trim_character" };
//= printers["trim_character"] = function(value) { throw 'print "trim_character": unimplemented'; };
trim_character "trim_character"
  = character_value_expression

//= type trim_source = { tag: "trim_source" };
//= printers["trim_source"] = function(value) { throw 'print "trim_source": unimplemented'; };
trim_source "trim_source"
  = character_value_expression

//= type bit_value_function = { tag: "bit_value_function" };
//= printers["bit_value_function"] = function(value) { throw 'print "bit_value_function": unimplemented'; };
bit_value_function "bit_value_function"
  = bit_substring_function

//= type bit_substring_function = { tag: "bit_substring_function" };
//= printers["bit_substring_function"] = function(value) { throw 'print "bit_substring_function": unimplemented'; };
bit_substring_function "bit_substring_function"
  = $("SUBSTRING"i _? left_paren _? bit_value_expression _? "FROM"i _? start_position (_? "FOR"i _? string_length)? _? right_paren)

//= type bit_value_expression = { tag: "bit_value_expression" };
//= printers["bit_value_expression"] = function(value) { throw 'print "bit_value_expression": unimplemented'; };
bit_value_expression "bit_value_expression"
  = $(bit_factor (_? concatenation_operator _? bit_factor)*)

//= type bit_factor = { tag: "bit_factor" };
//= printers["bit_factor"] = function(value) { throw 'print "bit_factor": unimplemented'; };
bit_factor "bit_factor"
  = bit_primary

//= type bit_primary = { tag: "bit_primary" };
//= printers["bit_primary"] = function(value) { throw 'print "bit_primary": unimplemented'; };
bit_primary "bit_primary"
  = value_expression_primary
  / string_value_function

//= type set_function_specification = { tag: "set_function_specification" };
//= printers["set_function_specification"] = function(value) { throw 'print "set_function_specification": unimplemented'; };
set_function_specification "set_function_specification"
  = $("COUNT"i _? left_paren _? asterisk _? right_paren)
  / general_set_function

//= type general_set_function = { tag: "general_set_function" };
//= printers["general_set_function"] = function(value) { throw 'print "general_set_function": unimplemented'; };
general_set_function "general_set_function"
  = $(set_function_type _? left_paren (_? set_quantifier)? _? value_expression _? right_paren)

//= type scalar_subquery = { tag: "scalar_subquery" };
//= printers["scalar_subquery"] = function(value) { throw 'print "scalar_subquery": unimplemented'; };
scalar_subquery "scalar_subquery"
  = subquery

//= type subquery = { tag: "subquery" };
//= printers["subquery"] = function(value) { throw 'print "subquery": unimplemented'; };
subquery "subquery"
  = $(left_paren _? query_expression _? right_paren)

//= type query_expression = { tag: "query_expression" };
//= printers["query_expression"] = function(value) { throw 'print "query_expression": unimplemented'; };
query_expression "query_expression"
  = non_join_query_expression
  / joined_table

//= type non_join_query_expression = { tag: "non_join_query_expression" };
//= printers["non_join_query_expression"] = function(value) { throw 'print "non_join_query_expression": unimplemented'; };
non_join_query_expression "non_join_query_expression"
  = $(non_join_query_term (_? ("UNION"i / "EXCEPT"i) (_? "ALL"i)? (_? corresponding_spec)? _? query_term)*)

//= type non_join_query_term = { tag: "non_join_query_term" };
//= printers["non_join_query_term"] = function(value) { throw 'print "non_join_query_term": unimplemented'; };
non_join_query_term "non_join_query_term"
  = $(query_term (_? "INTERSECT"i (_? "ALL"i)? (_? corresponding_spec)? _? query_primary)*)

//= type query_term = { tag: "query_term" };
//= printers["query_term"] = function(value) { throw 'print "query_term": unimplemented'; };
query_term "query_term"
  = non_join_query_primary
  / joined_table

//= type joined_table = { tag: "joined_table" };
//= printers["joined_table"] = function(value) { throw 'print "joined_table": unimplemented'; };
joined_table "joined_table"
  = cross_join
  / qualified_join
  / $(left_paren _? joined_table _? right_paren)

//= type cross_join = { tag: "cross_join" };
//= printers["cross_join"] = function(value) { throw 'print "cross_join": unimplemented'; };
cross_join "cross_join"
  = $(table_reference _? "CROSS"i _? "JOIN"i _? table_reference)

//= type table_reference = { tag: "table_reference" };
//= printers["table_reference"] = function(value) { throw 'print "table_reference": unimplemented'; };
table_reference "table_reference"
  = $(table_reference_factor (_? ("CROSS"i _? "JOIN"i / "NATURAL"i? (_? join_type)? _? "JOIN"i) _? table_reference_factor (_? join_specification)?)*)
  / $(left_paren _? joined_table _? right_paren)

//= type table_reference_factor = { tag: "table_reference_factor" };
//= printers["table_reference_factor"] = function(value) { throw 'print "table_reference_factor": unimplemented'; };
table_reference_factor "table_reference_factor"
  = $(table_name (_? correlation_specification)?)
  / $(derived_table _? correlation_specification)

//= type derived_table = { tag: "derived_table" };
//= printers["derived_table"] = function(value) { throw 'print "derived_table": unimplemented'; };
derived_table "derived_table"
  = table_subquery

//= type table_subquery = { tag: "table_subquery" };
//= printers["table_subquery"] = function(value) { throw 'print "table_subquery": unimplemented'; };
table_subquery "table_subquery"
  = subquery

//= type join_specification = { tag: "join_specification" };
//= printers["join_specification"] = function(value) { throw 'print "join_specification": unimplemented'; };
join_specification "join_specification"
  = join_condition
  / named_columns_join

//= type join_condition = { tag: "join_condition" };
//= printers["join_condition"] = function(value) { throw 'print "join_condition": unimplemented'; };
join_condition "join_condition"
  = $("ON"i _? search_condition)

//= type search_condition = { tag: "search_condition" };
//= printers["search_condition"] = function(value) { throw 'print "search_condition": unimplemented'; };
search_condition "search_condition"
  = $(boolean_term (_? "OR"i _? boolean_term)*)

//= type boolean_term = { tag: "boolean_term" };
//= printers["boolean_term"] = function(value) { throw 'print "boolean_term": unimplemented'; };
boolean_term "boolean_term"
  = $(boolean_factor (_? "AND"i _? boolean_factor)*)

//= type boolean_factor = { tag: "boolean_factor" };
//= printers["boolean_factor"] = function(value) { throw 'print "boolean_factor": unimplemented'; };
boolean_factor "boolean_factor"
  = $(("NOT"i _?)? boolean_test)

//= type boolean_test = { tag: "boolean_test" };
//= printers["boolean_test"] = function(value) { throw 'print "boolean_test": unimplemented'; };
boolean_test "boolean_test"
  = $(boolean_primary (_? "IS"i (_? "NOT"i)? _? truth_value)?)

//= type boolean_primary = { tag: "boolean_primary" };
//= printers["boolean_primary"] = function(value) { throw 'print "boolean_primary": unimplemented'; };
boolean_primary "boolean_primary"
  = predicate
  / $(left_paren _? search_condition _? right_paren)

//= type predicate = { tag: "predicate" };
//= printers["predicate"] = function(value) { throw 'print "predicate": unimplemented'; };
predicate "predicate"
  = between_predicate
  / in_predicate
  / comparison_predicate
  / like_predicate
  / null_predicate
  / quantified_comparison_predicate
  / exists_predicate
  / match_predicate
  / overlaps_predicate

//= type between_predicate = { tag: "between_predicate" };
//= printers["between_predicate"] = function(value) { throw 'print "between_predicate": unimplemented'; };
between_predicate "between_predicate"
  = $(row_value_constructor (_? "NOT"i)? _? "BETWEEN"i _? row_value_constructor _? "AND"i _? row_value_constructor)

//= type row_value_constructor = { tag: "row_value_constructor" };
//= printers["row_value_constructor"] = function(value) { throw 'print "row_value_constructor": unimplemented'; };
row_value_constructor "row_value_constructor"
  = row_value_constructor_element
  / $(left_paren _? row_value_constructor_list _? right_paren)
  / row_subquery

//= type row_value_constructor_element = { tag: "row_value_constructor_element" };
//= printers["row_value_constructor_element"] = function(value) { throw 'print "row_value_constructor_element": unimplemented'; };
row_value_constructor_element "row_value_constructor_element"
  = value_expression
  / null_specification
  / default_specification

//= type row_value_constructor_list = { tag: "row_value_constructor_list" };
//= printers["row_value_constructor_list"] = function(value) { throw 'print "row_value_constructor_list": unimplemented'; };
row_value_constructor_list "row_value_constructor_list"
  = $(row_value_constructor_element (_? comma _? row_value_constructor_element)*)

//= type row_subquery = { tag: "row_subquery" };
//= printers["row_subquery"] = function(value) { throw 'print "row_subquery": unimplemented'; };
row_subquery "row_subquery"
  = subquery

//= type in_predicate = { tag: "in_predicate" };
//= printers["in_predicate"] = function(value) { throw 'print "in_predicate": unimplemented'; };
in_predicate "in_predicate"
  = $(row_value_constructor (_? "NOT"i)? _? "IN"i _? in_predicate_value)

//= type in_predicate_value = { tag: "in_predicate_value" };
//= printers["in_predicate_value"] = function(value) { throw 'print "in_predicate_value": unimplemented'; };
in_predicate_value "in_predicate_value"
  = table_subquery
  / $(left_paren _? in_value_list _? right_paren)

//= type in_value_list = { tag: "in_value_list" };
//= printers["in_value_list"] = function(value) { throw 'print "in_value_list": unimplemented'; };
in_value_list "in_value_list"
  = $(value_expression (_? comma _? value_expression)+)

//= type comparison_predicate = { tag: "comparison_predicate" };
//= printers["comparison_predicate"] = function(value) { throw 'print "comparison_predicate": unimplemented'; };
comparison_predicate "comparison_predicate"
  = $(row_value_constructor _? comp_op _? row_value_constructor)

//= type like_predicate = { tag: "like_predicate" };
//= printers["like_predicate"] = function(value) { throw 'print "like_predicate": unimplemented'; };
like_predicate "like_predicate"
  = $(match_value (_? "NOT"i)? _? "LIKE"i _? pattern (_? "ESCAPE"i _? escape_character)?)

//= type match_value = { tag: "match_value" };
//= printers["match_value"] = function(value) { throw 'print "match_value": unimplemented'; };
match_value "match_value"
  = character_value_expression

//= type pattern = { tag: "pattern" };
//= printers["pattern"] = function(value) { throw 'print "pattern": unimplemented'; };
pattern "pattern"
  = character_value_expression

//= type escape_character = { tag: "escape_character" };
//= printers["escape_character"] = function(value) { throw 'print "escape_character": unimplemented'; };
escape_character "escape_character"
  = character_value_expression

//= type null_predicate = { tag: "null_predicate" };
//= printers["null_predicate"] = function(value) { throw 'print "null_predicate": unimplemented'; };
null_predicate "null_predicate"
  = $(row_value_constructor _? "IS"i (_? "NOT"i)? _? "NULL"i)

//= type quantified_comparison_predicate = { tag: "quantified_comparison_predicate" };
//= printers["quantified_comparison_predicate"] = function(value) { throw 'print "quantified_comparison_predicate": unimplemented'; };
quantified_comparison_predicate "quantified_comparison_predicate"
  = $(row_value_constructor _? comp_op _? quantifier _? table_subquery)

//= type exists_predicate = { tag: "exists_predicate" };
//= printers["exists_predicate"] = function(value) { throw 'print "exists_predicate": unimplemented'; };
exists_predicate "exists_predicate"
  = $("EXISTS"i _? table_subquery)

//= type match_predicate = { tag: "match_predicate" };
//= printers["match_predicate"] = function(value) { throw 'print "match_predicate": unimplemented'; };
match_predicate "match_predicate"
  = $(row_value_constructor _? "MATCH"i (_? "UNIQUE"i)? (_? ("PARTIAL"i / "FULL"i))? _? table_subquery)

//= type overlaps_predicate = { tag: "overlaps_predicate" };
//= printers["overlaps_predicate"] = function(value) { throw 'print "overlaps_predicate": unimplemented'; };
overlaps_predicate "overlaps_predicate"
  = $(row_value_constructor_1 _? "OVERLAPS"i _? row_value_constructor_2)

//= type row_value_constructor_1 = { tag: "row_value_constructor_1" };
//= printers["row_value_constructor_1"] = function(value) { throw 'print "row_value_constructor_1": unimplemented'; };
row_value_constructor_1 "row_value_constructor_1"
  = row_value_constructor

//= type row_value_constructor_2 = { tag: "row_value_constructor_2" };
//= printers["row_value_constructor_2"] = function(value) { throw 'print "row_value_constructor_2": unimplemented'; };
row_value_constructor_2 "row_value_constructor_2"
  = row_value_constructor

//= type qualified_join = { tag: "qualified_join" };
//= printers["qualified_join"] = function(value) { throw 'print "qualified_join": unimplemented'; };
qualified_join "qualified_join"
  = $(table_reference (_? "NATURAL"i)? (_? join_type)? _? "JOIN"i _? table_reference (_? join_specification)?)

//= type non_join_query_primary = { tag: "non_join_query_primary" };
//= printers["non_join_query_primary"] = function(value) { throw 'print "non_join_query_primary": unimplemented'; };
non_join_query_primary "non_join_query_primary"
  = simple_table
  / $(left_paren _? non_join_query_expression _? right_paren)

//= type simple_table = { tag: "simple_table" };
//= printers["simple_table"] = function(value) { throw 'print "simple_table": unimplemented'; };
simple_table "simple_table"
  = query_specification
  / table_value_constructor
  / explicit_table

//= type query_specification = { tag: "query_specification" };
//= printers["query_specification"] = function(value) { throw 'print "query_specification": unimplemented'; };
query_specification "query_specification"
  = $("SELECT"i (_? set_quantifier)? _? select_list _? table_expression)

//= type select_list = { tag: "select_list" };
//= printers["select_list"] = function(value) { throw 'print "select_list": unimplemented'; };
select_list "select_list"
  = asterisk
  / $(select_sublist (_? comma _? select_sublist)*)

//= type select_sublist = { tag: "select_sublist" };
//= printers["select_sublist"] = function(value) { throw 'print "select_sublist": unimplemented'; };
select_sublist "select_sublist"
  = derived_column
  / $(qualifier _? period _? asterisk)

//= type derived_column = { tag: "derived_column" };
//= printers["derived_column"] = function(value) { throw 'print "derived_column": unimplemented'; };
derived_column "derived_column"
  = $(value_expression (_? as_clause)?)

//= type table_expression = { tag: "table_expression" };
//= printers["table_expression"] = function(value) { throw 'print "table_expression": unimplemented'; };
table_expression "table_expression"
  = $(from_clause (_? where_clause)? (_? group_by_clause)? (_? having_clause)?)

//= type from_clause = { tag: "from_clause" };
//= printers["from_clause"] = function(value) { throw 'print "from_clause": unimplemented'; };
from_clause "from_clause"
  = $("FROM"i _? table_reference (_? comma _? table_reference)*)

//= type where_clause = { tag: "where_clause" };
//= printers["where_clause"] = function(value) { throw 'print "where_clause": unimplemented'; };
where_clause "where_clause"
  = $("WHERE"i _? search_condition)

//= type having_clause = { tag: "having_clause" };
//= printers["having_clause"] = function(value) { throw 'print "having_clause": unimplemented'; };
having_clause "having_clause"
  = $("HAVING"i _? search_condition)

//= type table_value_constructor = { tag: "table_value_constructor" };
//= printers["table_value_constructor"] = function(value) { throw 'print "table_value_constructor": unimplemented'; };
table_value_constructor "table_value_constructor"
  = $("VALUES"i _? table_value_constructor_list)

//= type table_value_constructor_list = { tag: "table_value_constructor_list" };
//= printers["table_value_constructor_list"] = function(value) { throw 'print "table_value_constructor_list": unimplemented'; };
table_value_constructor_list "table_value_constructor_list"
  = $(row_value_constructor (_? comma _? row_value_constructor)*)

//= type query_primary = { tag: "query_primary" };
//= printers["query_primary"] = function(value) { throw 'print "query_primary": unimplemented'; };
query_primary "query_primary"
  = non_join_query_primary
  / joined_table

//= type case_expression = { tag: "case_expression" };
//= printers["case_expression"] = function(value) { throw 'print "case_expression": unimplemented'; };
case_expression "case_expression"
  = case_abbreviation
  / case_specification

//= type case_abbreviation = { tag: "case_abbreviation" };
//= printers["case_abbreviation"] = function(value) { throw 'print "case_abbreviation": unimplemented'; };
case_abbreviation "case_abbreviation"
  = $("NULLIF"i _? left_paren _? value_expression _? comma _? value_expression _? right_paren)
  / $("COALESCE"i _? left_paren _? value_expression (_? comma _? value_expression)+ _? right_paren)

//= type case_specification = { tag: "case_specification" };
//= printers["case_specification"] = function(value) { throw 'print "case_specification": unimplemented'; };
case_specification "case_specification"
  = simple_case
  / searched_case

//= type simple_case = { tag: "simple_case" };
//= printers["simple_case"] = function(value) { throw 'print "simple_case": unimplemented'; };
simple_case "simple_case"
  = $("CASE"i _? case_operand (_? simple_when_clause)+ (_? else_clause)? _? "END"i)

//= type case_operand = { tag: "case_operand" };
//= printers["case_operand"] = function(value) { throw 'print "case_operand": unimplemented'; };
case_operand "case_operand"
  = value_expression

//= type simple_when_clause = { tag: "simple_when_clause" };
//= printers["simple_when_clause"] = function(value) { throw 'print "simple_when_clause": unimplemented'; };
simple_when_clause "simple_when_clause"
  = $("WHEN"i _? when_operand _? "THEN"i _? result)

//= type when_operand = { tag: "when_operand" };
//= printers["when_operand"] = function(value) { throw 'print "when_operand": unimplemented'; };
when_operand "when_operand"
  = value_expression

//= type result = { tag: "result" };
//= printers["result"] = function(value) { throw 'print "result": unimplemented'; };
result "result"
  = result_expression
  / "NULL"i

//= type result_expression = { tag: "result_expression" };
//= printers["result_expression"] = function(value) { throw 'print "result_expression": unimplemented'; };
result_expression "result_expression"
  = value_expression

//= type else_clause = { tag: "else_clause" };
//= printers["else_clause"] = function(value) { throw 'print "else_clause": unimplemented'; };
else_clause "else_clause"
  = $("ELSE"i _? result)

//= type searched_case = { tag: "searched_case" };
//= printers["searched_case"] = function(value) { throw 'print "searched_case": unimplemented'; };
searched_case "searched_case"
  = $("CASE"i (_? searched_when_clause)+ (_? else_clause)? _? "END"i)

//= type searched_when_clause = { tag: "searched_when_clause" };
//= printers["searched_when_clause"] = function(value) { throw 'print "searched_when_clause": unimplemented'; };
searched_when_clause "searched_when_clause"
  = $("WHEN"i _? search_condition _? "THEN"i _? result)

//= type cast_specification = { tag: "cast_specification" };
//= printers["cast_specification"] = function(value) { throw 'print "cast_specification": unimplemented'; };
cast_specification "cast_specification"
  = $("CAST"i _? left_paren _? cast_operand _? "AS"i _? cast_target _? right_paren)

//= type cast_operand = { tag: "cast_operand" };
//= printers["cast_operand"] = function(value) { throw 'print "cast_operand": unimplemented'; };
cast_operand "cast_operand"
  = value_expression
  / "NULL"i

//= type quantifier = { tag: "quantifier" };
//= printers["quantifier"] = function(value) { throw 'print "quantifier": unimplemented'; };
quantifier "quantifier"
  = all
  / some

//= type some = { tag: "some" };
//= printers["some"] = function(value) { throw 'print "some": unimplemented'; };
some "some"
  = "SOME"i
  / "ANY"i

//= type all = { tag: "all" };
//= printers["all"] = function(value) { throw 'print "all": unimplemented'; };
all "all"
  = "ALL"i

//= type trim_specification = { tag: "trim_specification" };
//= printers["trim_specification"] = function(value) { throw 'print "trim_specification": unimplemented'; };
trim_specification "trim_specification"
  = "LEADING"i
  / "TRAILING"i
  / "BOTH"i

//= type set_quantifier = { tag: "set_quantifier" };
//= printers["set_quantifier"] = function(value) { throw 'print "set_quantifier": unimplemented'; };
set_quantifier "set_quantifier"
  = "DISTINCT"i
  / "ALL"i

//= type set_function_type = { tag: "set_function_type" };
//= printers["set_function_type"] = function(value) { throw 'print "set_function_type": unimplemented'; };
set_function_type "set_function_type"
  = "AVG"i
  / "MAX"i
  / "MIN"i
  / "SUM"i
  / "COUNT"i

//= type default_specification = { tag: "default_specification" };
//= printers["default_specification"] = function(value) { throw 'print "default_specification": unimplemented'; };
default_specification "default_specification"
  = "DEFAULT"i

//= type null_specification = { tag: "null_specification" };
//= printers["null_specification"] = function(value) { throw 'print "null_specification": unimplemented'; };
null_specification "null_specification"
  = "NULL"i

//= type truth_value = { tag: "truth_value" };
//= printers["truth_value"] = function(value) { throw 'print "truth_value": unimplemented'; };
truth_value "truth_value"
  = "TRUE"i
  / "FALSE"i
  / "UNKNOWN"i

//= type extract_field = { tag: "extract_field" };
//= printers["extract_field"] = function(value) { throw 'print "extract_field": unimplemented'; };
extract_field "extract_field"
  = datetime_field
  / time_zone_field

//= type time_zone_field = { tag: "time_zone_field" };
//= printers["time_zone_field"] = function(value) { throw 'print "time_zone_field": unimplemented'; };
time_zone_field "time_zone_field"
  = "TIMEZONE_HOUR"i
  / "TIMEZONE_MINUTE"i

//= type datetime_field = { tag: "datetime_field" };
//= printers["datetime_field"] = function(value) { throw 'print "datetime_field": unimplemented'; };
datetime_field "datetime_field"
  = non_second_datetime_field
  / "SECOND"i

//= type non_second_datetime_field = { tag: "non_second_datetime_field" };
//= printers["non_second_datetime_field"] = function(value) { throw 'print "non_second_datetime_field": unimplemented'; };
non_second_datetime_field "non_second_datetime_field"
  = "YEAR"i
  / "MONTH"i
  / "DAY"i
  / "HOUR"i
  / "MINUTE"i

//= type concatenation_operator = { tag: "concatenation_operator" };
//= printers["concatenation_operator"] = function(value) { throw 'print "concatenation_operator": unimplemented'; };
concatenation_operator "concatenation_operator"
  = "||"

//= type join_type = { tag: "join_type" };
//= printers["join_type"] = function(value) { throw 'print "join_type": unimplemented'; };
join_type "join_type"
  = "INNER"i
  / $(outer_join_type (_? "OUTER"i)?)
  / "UNION"i

//= type outer_join_type = { tag: "outer_join_type" };
//= printers["outer_join_type"] = function(value) { throw 'print "outer_join_type": unimplemented'; };
outer_join_type "outer_join_type"
  = "LEFT"i
  / "RIGHT"i
  / "FULL"i

//= type comp_op = { tag: "comp_op" };
//= printers["comp_op"] = function(value) { throw 'print "comp_op": unimplemented'; };
comp_op "comp_op"
  = equals_operator
  / not_equals_operator
  / less_than_operator
  / greater_than_operator
  / less_than_or_equals_operator
  / greater_than_or_equals_operator

//= type less_than_or_equals_operator = { tag: "less_than_or_equals_operator" };
//= printers["less_than_or_equals_operator"] = function(value) { throw 'print "less_than_or_equals_operator": unimplemented'; };
less_than_or_equals_operator "less_than_or_equals_operator"
  = "<="

//= type greater_than_or_equals_operator = { tag: "greater_than_or_equals_operator" };
//= printers["greater_than_or_equals_operator"] = function(value) { throw 'print "greater_than_or_equals_operator": unimplemented'; };
greater_than_or_equals_operator "greater_than_or_equals_operator"
  = ">="

//= type not_equals_operator = { tag: "not_equals_operator" };
//= printers["not_equals_operator"] = function(value) { throw 'print "not_equals_operator": unimplemented'; };
not_equals_operator "not_equals_operator"
  = "<>"

//= type equals_operator = { tag: "equals_operator" };
//= printers["equals_operator"] = function(value) { throw 'print "equals_operator": unimplemented'; };
equals_operator "equals_operator"
  = "="

//= type greater_than_operator = { tag: "greater_than_operator" };
//= printers["greater_than_operator"] = function(value) { throw 'print "greater_than_operator": unimplemented'; };
greater_than_operator "greater_than_operator"
  = ">"

//= type less_than_operator = { tag: "less_than_operator" };
//= printers["less_than_operator"] = function(value) { throw 'print "less_than_operator": unimplemented'; };
less_than_operator "less_than_operator"
  = "<"

//= type solidus = { tag: "solidus" };
//= printers["solidus"] = function(value) { throw 'print "solidus": unimplemented'; };
solidus "solidus"
  = "/"

//= type minus_sign = { tag: "minus_sign" };
//= printers["minus_sign"] = function(value) { throw 'print "minus_sign": unimplemented'; };
minus_sign "minus_sign"
  = "-"

//= type comma = { tag: "comma" };
//= printers["comma"] = function(value) { throw 'print "comma": unimplemented'; };
comma "comma"
  = ","

//= type plus_sign = { tag: "plus_sign" };
//= printers["plus_sign"] = function(value) { throw 'print "plus_sign": unimplemented'; };
plus_sign "plus_sign"
  = "+"

//= type sign = { tag: "sign" };
//= printers["sign"] = function(value) { throw 'print "sign": unimplemented'; };
sign "sign"
  = plus_sign
  / minus_sign

//= type asterisk = { tag: "asterisk" };
//= printers["asterisk"] = function(value) { throw 'print "asterisk": unimplemented'; };
asterisk "asterisk"
  = "*"

//= type right_paren = { tag: "right_paren" };
//= printers["right_paren"] = function(value) { throw 'print "right_paren": unimplemented'; };
right_paren "right_paren"
  = ")"

//= type left_paren = { tag: "left_paren" };
//= printers["left_paren"] = function(value) { throw 'print "left_paren": unimplemented'; };
left_paren "left_paren"
  = "("

//= type interval_qualifier = { tag: "interval_qualifier" };
//= printers["interval_qualifier"] = function(value) { throw 'print "interval_qualifier": unimplemented'; };
interval_qualifier "interval_qualifier"
  = $(start_field _? "TO"i _? end_field)
  / single_datetime_field

//= type end_field = { tag: "end_field" };
//= printers["end_field"] = function(value) { throw 'print "end_field": unimplemented'; };
end_field "end_field"
  = non_second_datetime_field
  / $("SECOND"i (_? left_paren _? interval_fractional_seconds_precision _? right_paren)?)

//= type interval_fractional_seconds_precision = { tag: "interval_fractional_seconds_precision" };
//= printers["interval_fractional_seconds_precision"] = function(value) { throw 'print "interval_fractional_seconds_precision": unimplemented'; };
interval_fractional_seconds_precision "interval_fractional_seconds_precision"
  = unsigned_integer

//= type unsigned_integer = { tag: "unsigned_integer" };
//= printers["unsigned_integer"] = function(value) { throw 'print "unsigned_integer": unimplemented'; };
unsigned_integer "unsigned_integer"
  = digit+

//= type single_datetime_field = { tag: "single_datetime_field" };
//= printers["single_datetime_field"] = function(value) { throw 'print "single_datetime_field": unimplemented'; };
single_datetime_field "single_datetime_field"
  = $(non_second_datetime_field (_? left_paren _? interval_leading_field_precision _? right_paren)?)
  / $("SECOND"i (_? left_paren _? interval_leading_field_precision (_? comma _? left_paren _? interval_fractional_seconds_precision)? _? right_paren)?)

//= type interval_leading_field_precision = { tag: "interval_leading_field_precision" };
//= printers["interval_leading_field_precision"] = function(value) { throw 'print "interval_leading_field_precision": unimplemented'; };
interval_leading_field_precision "interval_leading_field_precision"
  = unsigned_integer

//= type start_field = { tag: "start_field" };
//= printers["start_field"] = function(value) { throw 'print "start_field": unimplemented'; };
start_field "start_field"
  = $(non_second_datetime_field (_? left_paren _? interval_leading_field_precision _? right_paren)?)

//= type datetime_value_function = { tag: "datetime_value_function" };
//= printers["datetime_value_function"] = function(value) { throw 'print "datetime_value_function": unimplemented'; };
datetime_value_function "datetime_value_function"
  = current_date_value_function
  / current_time_value_function
  / current_timestamp_value_function

//= type current_date_value_function = { tag: "current_date_value_function" };
//= printers["current_date_value_function"] = function(value) { throw 'print "current_date_value_function": unimplemented'; };
current_date_value_function "current_date_value_function"
  = "CURRENT_DATE"i

//= type current_timestamp_value_function = { tag: "current_timestamp_value_function" };
//= printers["current_timestamp_value_function"] = function(value) { throw 'print "current_timestamp_value_function": unimplemented'; };
current_timestamp_value_function "current_timestamp_value_function"
  = $("CURRENT_TIMESTAMP"i (_? left_paren _? timestamp_precision _? right_paren)?)

//= type timestamp_precision = { tag: "timestamp_precision" };
//= printers["timestamp_precision"] = function(value) { throw 'print "timestamp_precision": unimplemented'; };
timestamp_precision "timestamp_precision"
  = time_fractional_seconds_precision

//= type time_fractional_seconds_precision = { tag: "time_fractional_seconds_precision" };
//= printers["time_fractional_seconds_precision"] = function(value) { throw 'print "time_fractional_seconds_precision": unimplemented'; };
time_fractional_seconds_precision "time_fractional_seconds_precision"
  = unsigned_integer

//= type current_time_value_function = { tag: "current_time_value_function" };
//= printers["current_time_value_function"] = function(value) { throw 'print "current_time_value_function": unimplemented'; };
current_time_value_function "current_time_value_function"
  = $("CURRENT_TIME"i (_? left_paren _? time_precision _? right_paren)?)

//= type time_precision = { tag: "time_precision" };
//= printers["time_precision"] = function(value) { throw 'print "time_precision": unimplemented'; };
time_precision "time_precision"
  = time_fractional_seconds_precision

//= type as_clause = { tag: "as_clause" };
//= printers["as_clause"] = function(value) { throw 'print "as_clause": unimplemented'; };
as_clause "as_clause"
  = $(("AS"i _?)? column_name)

//= type column_name = { tag: "column_name" };
//= printers["column_name"] = function(value) { throw 'print "column_name": unimplemented'; };
column_name "column_name"
  = identifier

//= type corresponding_spec = { tag: "corresponding_spec" };
//= printers["corresponding_spec"] = function(value) { throw 'print "corresponding_spec": unimplemented'; };
corresponding_spec "corresponding_spec"
  = $("CORRESPONDING"i (_? "BY"i _? left_paren _? corresponding_column_list _? right_paren)?)

//= type corresponding_column_list = { tag: "corresponding_column_list" };
//= printers["corresponding_column_list"] = function(value) { throw 'print "corresponding_column_list": unimplemented'; };
corresponding_column_list "corresponding_column_list"
  = column_name_list

//= type column_name_list = { tag: "column_name_list" };
//= printers["column_name_list"] = function(value) { throw 'print "column_name_list": unimplemented'; };
column_name_list "column_name_list"
  = $(column_name (_? comma _? column_name)*)

//= type named_columns_join = { tag: "named_columns_join" };
//= printers["named_columns_join"] = function(value) { throw 'print "named_columns_join": unimplemented'; };
named_columns_join "named_columns_join"
  = $("USING"i _? left_paren _? join_column_list _? right_paren)

//= type join_column_list = { tag: "join_column_list" };
//= printers["join_column_list"] = function(value) { throw 'print "join_column_list": unimplemented'; };
join_column_list "join_column_list"
  = column_name_list

//= type correlation_specification = { tag: "correlation_specification" };
//= printers["correlation_specification"] = function(value) { throw 'print "correlation_specification": unimplemented'; };
correlation_specification "correlation_specification"
  = $(("AS"i _?)? correlation_name (_? left_paren _? derived_column_list _? right_paren)?)

//= type correlation_name = { tag: "correlation_name" };
//= printers["correlation_name"] = function(value) { throw 'print "correlation_name": unimplemented'; };
correlation_name "correlation_name"
  = identifier

//= type derived_column_list = { tag: "derived_column_list" };
//= printers["derived_column_list"] = function(value) { throw 'print "derived_column_list": unimplemented'; };
derived_column_list "derived_column_list"
  = column_name_list

//= type translation_name = { tag: "translation_name" };
//= printers["translation_name"] = function(value) { throw 'print "translation_name": unimplemented'; };
translation_name "translation_name"
  = qualified_name

//= type form_of_use_conversion_name = { tag: "form_of_use_conversion_name" };
//= printers["form_of_use_conversion_name"] = function(value) { throw 'print "form_of_use_conversion_name": unimplemented'; };
form_of_use_conversion_name "form_of_use_conversion_name"
  = qualified_name

//= type collate_clause = { tag: "collate_clause" };
//= printers["collate_clause"] = function(value) { throw 'print "collate_clause": unimplemented'; };
collate_clause "collate_clause"
  = $("COLLATE"i _? collation_name)

//= type collation_name = { tag: "collation_name" };
//= printers["collation_name"] = function(value) { throw 'print "collation_name": unimplemented'; };
collation_name "collation_name"
  = qualified_name

//= type explicit_table = { tag: "explicit_table" };
//= printers["explicit_table"] = function(value) { throw 'print "explicit_table": unimplemented'; };
explicit_table "explicit_table"
  = $("TABLE"i _? table_name)

//= type qualifier = { tag: "qualifier" };
//= printers["qualifier"] = function(value) { throw 'print "qualifier": unimplemented'; };
qualifier "qualifier"
  = table_name
  / correlation_name

//= type cast_target = { tag: "cast_target" };
//= printers["cast_target"] = function(value) { throw 'print "cast_target": unimplemented'; };
cast_target "cast_target"
  = domain_name
  / data_type

//= type data_type = { tag: "data_type" };
//= printers["data_type"] = function(value) { throw 'print "data_type": unimplemented'; };
data_type "data_type"
  = $(character_string_type (_? "CHARACTER"i _? "SET"i _? character_set_name)?)
  / national_character_string_type
  / bit_string_type
  / numeric_type
  / datetime_type
  / interval_type

//= type interval_type = { tag: "interval_type" };
//= printers["interval_type"] = function(value) { throw 'print "interval_type": unimplemented'; };
interval_type "interval_type"
  = $("INTERVAL"i _? interval_qualifier)

//= type datetime_type = { tag: "datetime_type" };
//= printers["datetime_type"] = function(value) { throw 'print "datetime_type": unimplemented'; };
datetime_type "datetime_type"
  = "DATE"i
  / $("TIME"i (_? left_paren _? time_precision _? right_paren)? (_? "WITH"i _? "TIME"i _? "ZONE"i)?)
  / $("TIMESTAMP"i (_? left_paren _? timestamp_precision _? right_paren)? (_? "WITH"i _? "TIME"i _? "ZONE"i)?)

//= type numeric_type = { tag: "numeric_type" };
//= printers["numeric_type"] = function(value) { throw 'print "numeric_type": unimplemented'; };
numeric_type "numeric_type"
  = exact_numeric_type
  / approximate_numeric_type

//= type approximate_numeric_type = { tag: "approximate_numeric_type" };
//= printers["approximate_numeric_type"] = function(value) { throw 'print "approximate_numeric_type": unimplemented'; };
approximate_numeric_type "approximate_numeric_type"
  = $("FLOAT"i (_? left_paren _? precision _? right_paren)?)
  / "REAL"i
  / $("DOUBLE"i _? "PRECISION"i)

//= type precision = { tag: "precision" };
//= printers["precision"] = function(value) { throw 'print "precision": unimplemented'; };
precision "precision"
  = unsigned_integer

//= type exact_numeric_type = { tag: "exact_numeric_type" };
//= printers["exact_numeric_type"] = function(value) { throw 'print "exact_numeric_type": unimplemented'; };
exact_numeric_type "exact_numeric_type"
  = $("NUMERIC"i (_? left_paren _? precision (_? comma _? scale)? _? right_paren)?)
  / $("DECIMAL"i (_? left_paren _? precision (_? comma _? scale)? _? right_paren)?)
  / $("DEC"i (_? left_paren _? precision (_? comma _? scale)? _? right_paren)?)
  / "INTEGER"i
  / "INT"i
  / "SMALLINT"i

//= type scale = { tag: "scale" };
//= printers["scale"] = function(value) { throw 'print "scale": unimplemented'; };
scale "scale"
  = unsigned_integer

//= type bit_string_type = { tag: "bit_string_type" };
//= printers["bit_string_type"] = function(value) { throw 'print "bit_string_type": unimplemented'; };
bit_string_type "bit_string_type"
  = $("BIT"i (_? left_paren _? length _? right_paren)?)
  / $("BIT"i _? "VARYING"i (_? left_paren _? length _? right_paren)?)

//= type length = { tag: "length" };
//= printers["length"] = function(value) { throw 'print "length": unimplemented'; };
length "length"
  = unsigned_integer

//= type national_character_string_type = { tag: "national_character_string_type" };
//= printers["national_character_string_type"] = function(value) { throw 'print "national_character_string_type": unimplemented'; };
national_character_string_type "national_character_string_type"
  = $("NATIONAL"i _? "CHARACTER"i (_? left_paren _? length _? right_paren)?)
  / $("NATIONAL"i _? "CHAR"i (_? left_paren _? length _? right_paren)?)
  / $("NCHAR"i (_? left_paren _? length _? right_paren)?)
  / $("NATIONAL"i _? "CHARACTER"i _? "VARYING"i (_? left_paren _? length _? right_paren)?)
  / $("NATIONAL"i _? "CHAR"i _? "VARYING"i (_? left_paren _? length _? right_paren)?)
  / $("NCHAR"i _? "VARYING"i (_? left_paren _? length _? right_paren)?)

//= type character_string_type = { tag: "character_string_type" };
//= printers["character_string_type"] = function(value) { throw 'print "character_string_type": unimplemented'; };
character_string_type "character_string_type"
  = $("CHARACTER"i (_? left_paren _? length _? right_paren)?)
  / $("CHAR"i (_? left_paren _? length _? right_paren)?)
  / $("CHARACTER"i _? "VARYING"i (_? left_paren _? length _? right_paren)?)
  / $("CHAR"i _? "VARYING"i (_? left_paren _? length _? right_paren)?)
  / $("VARCHAR"i (_? left_paren _? length _? right_paren)?)

//= type domain_name = { tag: "domain_name" };
//= printers["domain_name"] = function(value) { throw 'print "domain_name": unimplemented'; };
domain_name "domain_name"
  = qualified_name

//= type column_reference = { tag: "column_reference" };
//= printers["column_reference"] = function(value) { throw 'print "column_reference": unimplemented'; };
column_reference "column_reference"
  = $((catalog_name period)? (schema_name period)? column_name)

//= type group_by_clause = { tag: "group_by_clause" };
//= printers["group_by_clause"] = function(value) { throw 'print "group_by_clause": unimplemented'; };
group_by_clause "group_by_clause"
  = $("GROUP"i _? "BY"i _? grouping_column_reference_list)

//= type grouping_column_reference_list = { tag: "grouping_column_reference_list" };
//= printers["grouping_column_reference_list"] = function(value) { throw 'print "grouping_column_reference_list": unimplemented'; };
grouping_column_reference_list "grouping_column_reference_list"
  = $(grouping_column_reference (_? comma _? grouping_column_reference)*)

//= type grouping_column_reference = { tag: "grouping_column_reference" };
//= printers["grouping_column_reference"] = function(value) { throw 'print "grouping_column_reference": unimplemented'; };
grouping_column_reference "grouping_column_reference"
  = $(column_reference (_? collate_clause)?)

//= type unsigned_value_specification = { tag: "unsigned_value_specification" };
//= printers["unsigned_value_specification"] = function(value) { throw 'print "unsigned_value_specification": unimplemented'; };
unsigned_value_specification "unsigned_value_specification"
  = unsigned_literal

//= type unsigned_literal = { tag: "unsigned_literal" };
//= printers["unsigned_literal"] = function(value) { throw 'print "unsigned_literal": unimplemented'; };
unsigned_literal "unsigned_literal"
  = unsigned_numeric_literal
  / general_literal

//= type unsigned_numeric_literal = { tag: "unsigned_numeric_literal" };
//= printers["unsigned_numeric_literal"] = function(value) { throw 'print "unsigned_numeric_literal": unimplemented'; };
unsigned_numeric_literal "unsigned_numeric_literal"
  = exact_numeric_literal
  / approximate_numeric_literal

//= type exact_numeric_literal = { tag: "exact_numeric_literal" };
//= printers["exact_numeric_literal"] = function(value) { throw 'print "exact_numeric_literal": unimplemented'; };
exact_numeric_literal "exact_numeric_literal"
  = $(unsigned_integer (_? period (_? unsigned_integer)?)?)
  / $(period _? unsigned_integer)

//= type approximate_numeric_literal = { tag: "approximate_numeric_literal" };
//= printers["approximate_numeric_literal"] = function(value) { throw 'print "approximate_numeric_literal": unimplemented'; };
approximate_numeric_literal "approximate_numeric_literal"
  = $(mantissa "E" exponent)

//= type exponent = { tag: "exponent" };
//= printers["exponent"] = function(value) { throw 'print "exponent": unimplemented'; };
exponent "exponent"
  = signed_integer

//= type signed_integer = { tag: "signed_integer" };
//= printers["signed_integer"] = function(value) { throw 'print "signed_integer": unimplemented'; };
signed_integer "signed_integer"
  = $((sign _?)? unsigned_integer)

//= type mantissa = { tag: "mantissa" };
//= printers["mantissa"] = function(value) { throw 'print "mantissa": unimplemented'; };
mantissa "mantissa"
  = exact_numeric_literal

//= type general_literal = { tag: "general_literal" };
//= printers["general_literal"] = function(value) { throw 'print "general_literal": unimplemented'; };
general_literal "general_literal"
  = character_string_literal
  / national_character_string_literal
  / bit_string_literal
  / hex_string_literal
  / datetime_literal
  / interval_literal

//= type bit_string_literal = { tag: "bit_string_literal" };
//= printers["bit_string_literal"] = function(value) { throw 'print "bit_string_literal": unimplemented'; };
bit_string_literal "bit_string_literal"
  = $("B" quote bit* quote (separator+ quote bit* quote)*)

//= type bit = { tag: "bit" };
//= printers["bit"] = function(value) { throw 'print "bit": unimplemented'; };
bit "bit"
  = "0"
  / "1"

//= type quote = { tag: "quote" };
//= printers["quote"] = function(value) { throw 'print "quote": unimplemented'; };
quote "quote"
  = "'"

//= type separator = { tag: "separator" };
//= printers["separator"] = function(value) { throw 'print "separator": unimplemented'; };
separator "separator"
  = (comment / space / newline)+

//= type comment = { tag: "comment" };
//= printers["comment"] = function(value) { throw 'print "comment": unimplemented'; };
comment "comment"
  = $(comment_introducer comment_character* newline)

//= type comment_introducer = { tag: "comment_introducer" };
//= printers["comment_introducer"] = function(value) { throw 'print "comment_introducer": unimplemented'; };
comment_introducer "comment_introducer"
  = $(minus_sign minus_sign minus_sign*)

//= type national_character_string_literal = { tag: "national_character_string_literal" };
//= printers["national_character_string_literal"] = function(value) { throw 'print "national_character_string_literal": unimplemented'; };
national_character_string_literal "national_character_string_literal"
  = $("N" quote character_representation* quote (separator+ quote character_representation* quote)*)

//= type character_representation = { tag: "character_representation" };
//= printers["character_representation"] = function(value) { throw 'print "character_representation": unimplemented'; };
character_representation "character_representation"
  = nonquote_character
  / quote_symbol

//= type quote_symbol = { tag: "quote_symbol" };
//= printers["quote_symbol"] = function(value) { throw 'print "quote_symbol": unimplemented'; };
quote_symbol "quote_symbol"
  = $(quote quote)

//= type hex_string_literal = { tag: "hex_string_literal" };
//= printers["hex_string_literal"] = function(value) { throw 'print "hex_string_literal": unimplemented'; };
hex_string_literal "hex_string_literal"
  = $("X" quote hexit* quote (separator+ quote hexit* quote)*)

//= type hexit = { tag: "hexit" };
//= printers["hexit"] = function(value) { throw 'print "hexit": unimplemented'; };
hexit "hexit"
  = digit
  / "A"
  / "B"
  / "C"
  / "D"
  / "E"
  / "F"
  / "a"
  / "b"
  / "c"
  / "d"
  / "e"
  / "f"

//= type interval_literal = { tag: "interval_literal" };
//= printers["interval_literal"] = function(value) { throw 'print "interval_literal": unimplemented'; };
interval_literal "interval_literal"
  = $("INTERVAL"i (_? sign)? _? interval_string _? interval_qualifier)

//= type interval_string = { tag: "interval_string" };
//= printers["interval_string"] = function(value) { throw 'print "interval_string": unimplemented'; };
interval_string "interval_string"
  = $(quote (year_month_literal / day_time_literal) quote)

//= type day_time_literal = { tag: "day_time_literal" };
//= printers["day_time_literal"] = function(value) { throw 'print "day_time_literal": unimplemented'; };
day_time_literal "day_time_literal"
  = day_time_interval
  / time_interval

//= type time_interval = { tag: "time_interval" };
//= printers["time_interval"] = function(value) { throw 'print "time_interval": unimplemented'; };
time_interval "time_interval"
  = $(hours_value (colon minutes_value (colon seconds_value)?)?)
  / $(minutes_value (colon seconds_value)?)
  / seconds_value

//= type colon = { tag: "colon" };
//= printers["colon"] = function(value) { throw 'print "colon": unimplemented'; };
colon "colon"
  = ":"

//= type seconds_value = { tag: "seconds_value" };
//= printers["seconds_value"] = function(value) { throw 'print "seconds_value": unimplemented'; };
seconds_value "seconds_value"
  = $(seconds_integer_value (_? period (_? seconds_fraction)?)?)

//= type seconds_fraction = { tag: "seconds_fraction" };
//= printers["seconds_fraction"] = function(value) { throw 'print "seconds_fraction": unimplemented'; };
seconds_fraction "seconds_fraction"
  = unsigned_integer

//= type seconds_integer_value = { tag: "seconds_integer_value" };
//= printers["seconds_integer_value"] = function(value) { throw 'print "seconds_integer_value": unimplemented'; };
seconds_integer_value "seconds_integer_value"
  = unsigned_integer

//= type minutes_value = { tag: "minutes_value" };
//= printers["minutes_value"] = function(value) { throw 'print "minutes_value": unimplemented'; };
minutes_value "minutes_value"
  = datetime_value

//= type datetime_value = { tag: "datetime_value" };
//= printers["datetime_value"] = function(value) { throw 'print "datetime_value": unimplemented'; };
datetime_value "datetime_value"
  = unsigned_integer

//= type hours_value = { tag: "hours_value" };
//= printers["hours_value"] = function(value) { throw 'print "hours_value": unimplemented'; };
hours_value "hours_value"
  = datetime_value

//= type day_time_interval = { tag: "day_time_interval" };
//= printers["day_time_interval"] = function(value) { throw 'print "day_time_interval": unimplemented'; };
day_time_interval "day_time_interval"
  = $(days_value (space hours_value (colon minutes_value (colon seconds_value)?)?)?)

//= type days_value = { tag: "days_value" };
//= printers["days_value"] = function(value) { throw 'print "days_value": unimplemented'; };
days_value "days_value"
  = datetime_value

//= type year_month_literal = { tag: "year_month_literal" };
//= printers["year_month_literal"] = function(value) { throw 'print "year_month_literal": unimplemented'; };
year_month_literal "year_month_literal"
  = years_value
  / $((years_value minus_sign)? months_value)

//= type months_value = { tag: "months_value" };
//= printers["months_value"] = function(value) { throw 'print "months_value": unimplemented'; };
months_value "months_value"
  = datetime_value

//= type years_value = { tag: "years_value" };
//= printers["years_value"] = function(value) { throw 'print "years_value": unimplemented'; };
years_value "years_value"
  = datetime_value

//= type datetime_literal = { tag: "datetime_literal" };
//= printers["datetime_literal"] = function(value) { throw 'print "datetime_literal": unimplemented'; };
datetime_literal "datetime_literal"
  = date_literal
  / time_literal
  / timestamp_literal

//= type time_literal = { tag: "time_literal" };
//= printers["time_literal"] = function(value) { throw 'print "time_literal": unimplemented'; };
time_literal "time_literal"
  = $("TIME"i _? time_string)

//= type time_string = { tag: "time_string" };
//= printers["time_string"] = function(value) { throw 'print "time_string": unimplemented'; };
time_string "time_string"
  = $(quote time_value time_zone_interval? quote)

//= type time_zone_interval = { tag: "time_zone_interval" };
//= printers["time_zone_interval"] = function(value) { throw 'print "time_zone_interval": unimplemented'; };
time_zone_interval "time_zone_interval"
  = $(sign _? hours_value _? colon _? minutes_value)

//= type time_value = { tag: "time_value" };
//= printers["time_value"] = function(value) { throw 'print "time_value": unimplemented'; };
time_value "time_value"
  = $(hours_value colon minutes_value colon seconds_value)

//= type timestamp_literal = { tag: "timestamp_literal" };
//= printers["timestamp_literal"] = function(value) { throw 'print "timestamp_literal": unimplemented'; };
timestamp_literal "timestamp_literal"
  = $("TIMESTAMP"i _? timestamp_string)

//= type timestamp_string = { tag: "timestamp_string" };
//= printers["timestamp_string"] = function(value) { throw 'print "timestamp_string": unimplemented'; };
timestamp_string "timestamp_string"
  = $(quote date_value space time_value time_zone_interval? quote)

//= type date_value = { tag: "date_value" };
//= printers["date_value"] = function(value) { throw 'print "date_value": unimplemented'; };
date_value "date_value"
  = $(years_value minus_sign months_value minus_sign days_value)

//= type date_literal = { tag: "date_literal" };
//= printers["date_literal"] = function(value) { throw 'print "date_literal": unimplemented'; };
date_literal "date_literal"
  = $("DATE"i date_string)

//= type date_string = { tag: "date_string" };
//= printers["date_string"] = function(value) { throw 'print "date_string": unimplemented'; };
date_string "date_string"
  = $(quote date_value quote)

//= type character_string_literal = { tag: "character_string_literal" };
//= printers["character_string_literal"] = function(value) { throw 'print "character_string_literal": unimplemented'; };
character_string_literal "character_string_literal"
  = $((introducer character_set_name)? quote character_representation* quote (separator+ quote character_representation* quote)*)

//= type insert_statement = { tag: "insert_statement" };
//= printers["insert_statement"] = function(value) { throw 'print "insert_statement": unimplemented'; };
insert_statement "insert_statement"
  = $("INSERT"i _? "INTO"i _? table_name _? insert_columns_and_source)

//= type insert_columns_and_source = { tag: "insert_columns_and_source" };
//= printers["insert_columns_and_source"] = function(value) { throw 'print "insert_columns_and_source": unimplemented'; };
insert_columns_and_source "insert_columns_and_source"
  = $((left_paren _? insert_column_list _? right_paren _?)? query_expression)
  / $("DEFAULT"i _? "VALUES"i)

//= type insert_column_list = { tag: "insert_column_list" };
//= printers["insert_column_list"] = function(value) { throw 'print "insert_column_list": unimplemented'; };
insert_column_list "insert_column_list"
  = column_name_list

//= type rollback_statement = { tag: "rollback_statement" };
//= printers["rollback_statement"] = function(value) { throw 'print "rollback_statement": unimplemented'; };
rollback_statement "rollback_statement"
  = $("ROLLBACK"i (_? "WORK"i)?)

//= type update_statement_searched = { tag: "update_statement_searched" };
//= printers["update_statement_searched"] = function(value) { throw 'print "update_statement_searched": unimplemented'; };
update_statement_searched "update_statement_searched"
  = $("UPDATE"i _? table_name _? "SET"i _? set_clause_list (_? "WHERE"i _? search_condition)?)

//= type set_clause_list = { tag: "set_clause_list" };
//= printers["set_clause_list"] = function(value) { throw 'print "set_clause_list": unimplemented'; };
set_clause_list "set_clause_list"
  = $(set_clause (_? comma _? set_clause)*)

//= type set_clause = { tag: "set_clause" };
//= printers["set_clause"] = function(value) { throw 'print "set_clause": unimplemented'; };
set_clause "set_clause"
  = $(object_column _? equals_operator _? update_source)

//= type object_column = { tag: "object_column" };
//= printers["object_column"] = function(value) { throw 'print "object_column": unimplemented'; };
object_column "object_column"
  = column_name

//= type update_source = { tag: "update_source" };
//= printers["update_source"] = function(value) { throw 'print "update_source": unimplemented'; };
update_source "update_source"
  = value_expression
  / null_specification
  / "DEFAULT"i

//= type table_definition = { tag: "table_definition" };
//= printers["table_definition"] = function(value) { throw 'print "table_definition": unimplemented'; };
table_definition "table_definition"
  = $("CREATE"i (_? ("GLOBAL"i / "LOCAL"i) _? "TEMPORARY"i)? _? "TABLE"i _? table_name _? table_element_list (_? "ON"i _? "COMMIT"i _? ("DELETE"i / "PRESERVE"i) _? "ROWS"i)?)

//= type table_element_list = { tag: "table_element_list" };
//= printers["table_element_list"] = function(value) { throw 'print "table_element_list": unimplemented'; };
table_element_list "table_element_list"
  = $(left_paren _? table_element (_? comma _? table_element)* _? right_paren)

//= type table_element = { tag: "table_element" };
//= printers["table_element"] = function(value) { throw 'print "table_element": unimplemented'; };
table_element "table_element"
  = column_definition
  / table_constraint_definition

//= type table_constraint_definition = { tag: "table_constraint_definition" };
//= printers["table_constraint_definition"] = function(value) { throw 'print "table_constraint_definition": unimplemented'; };
table_constraint_definition "table_constraint_definition"
  = $((constraint_name_definition _?)? table_constraint (_? constraint_check_time)?)

//= type constraint_check_time = { tag: "constraint_check_time" };
//= printers["constraint_check_time"] = function(value) { throw 'print "constraint_check_time": unimplemented'; };
constraint_check_time "constraint_check_time"
  = $("INITIALLY"i _? "DEFERRED"i)
  / $("INITIALLY"i _? "IMMEDIATE"i)

//= type constraint_name_definition = { tag: "constraint_name_definition" };
//= printers["constraint_name_definition"] = function(value) { throw 'print "constraint_name_definition": unimplemented'; };
constraint_name_definition "constraint_name_definition"
  = $("CONSTRAINT"i _? constraint_name)

//= type constraint_name = { tag: "constraint_name" };
//= printers["constraint_name"] = function(value) { throw 'print "constraint_name": unimplemented'; };
constraint_name "constraint_name"
  = qualified_name

//= type table_constraint = { tag: "table_constraint" };
//= printers["table_constraint"] = function(value) { throw 'print "table_constraint": unimplemented'; };
table_constraint "table_constraint"
  = unique_constraint_definition
  / referential_constraint_definition
  / check_constraint_definition

//= type unique_constraint_definition = { tag: "unique_constraint_definition" };
//= printers["unique_constraint_definition"] = function(value) { throw 'print "unique_constraint_definition": unimplemented'; };
unique_constraint_definition "unique_constraint_definition"
  = $(unique_specification _? left_paren _? unique_column_list _? right_paren)

//= type unique_specification = { tag: "unique_specification" };
//= printers["unique_specification"] = function(value) { throw 'print "unique_specification": unimplemented'; };
unique_specification "unique_specification"
  = "UNIQUE"i
  / $("PRIMARY"i _? "KEY"i)

//= type unique_column_list = { tag: "unique_column_list" };
//= printers["unique_column_list"] = function(value) { throw 'print "unique_column_list": unimplemented'; };
unique_column_list "unique_column_list"
  = column_name_list

//= type referential_constraint_definition = { tag: "referential_constraint_definition" };
//= printers["referential_constraint_definition"] = function(value) { throw 'print "referential_constraint_definition": unimplemented'; };
referential_constraint_definition "referential_constraint_definition"
  = $("FOREIGN"i _? "KEY"i _? left_paren _? referencing_columns _? right_paren _? references_specification)

//= type referencing_columns = { tag: "referencing_columns" };
//= printers["referencing_columns"] = function(value) { throw 'print "referencing_columns": unimplemented'; };
referencing_columns "referencing_columns"
  = reference_column_list

//= type reference_column_list = { tag: "reference_column_list" };
//= printers["reference_column_list"] = function(value) { throw 'print "reference_column_list": unimplemented'; };
reference_column_list "reference_column_list"
  = column_name_list

//= type references_specification = { tag: "references_specification" };
//= printers["references_specification"] = function(value) { throw 'print "references_specification": unimplemented'; };
references_specification "references_specification"
  = $("REFERENCES"i _? referenced_table_and_columns (_? "MATCH"i _? match_type)? (_? referential_triggered_action)?)

//= type match_type = { tag: "match_type" };
//= printers["match_type"] = function(value) { throw 'print "match_type": unimplemented'; };
match_type "match_type"
  = "FULL"i
  / "PARTIAL"i

//= type referential_triggered_action = { tag: "referential_triggered_action" };
//= printers["referential_triggered_action"] = function(value) { throw 'print "referential_triggered_action": unimplemented'; };
referential_triggered_action "referential_triggered_action"
  = $(update_rule (_? delete_rule)?)
  / $(delete_rule (_? update_rule)?)

//= type delete_rule = { tag: "delete_rule" };
//= printers["delete_rule"] = function(value) { throw 'print "delete_rule": unimplemented'; };
delete_rule "delete_rule"
  = $("ON"i _? "DELETE"i _? referential_action)

//= type referential_action = { tag: "referential_action" };
//= printers["referential_action"] = function(value) { throw 'print "referential_action": unimplemented'; };
referential_action "referential_action"
  = "CASCADE"i
  / $("SET"i _? "NULL"i)
  / $("SET"i _? "DEFAULT"i)
  / $("NO"i _? "ACTION"i)

//= type update_rule = { tag: "update_rule" };
//= printers["update_rule"] = function(value) { throw 'print "update_rule": unimplemented'; };
update_rule "update_rule"
  = $("ON"i _? "UPDATE"i _? referential_action)

//= type referenced_table_and_columns = { tag: "referenced_table_and_columns" };
//= printers["referenced_table_and_columns"] = function(value) { throw 'print "referenced_table_and_columns": unimplemented'; };
referenced_table_and_columns "referenced_table_and_columns"
  = $(table_name (_? left_paren _? reference_column_list _? right_paren)?)

//= type check_constraint_definition = { tag: "check_constraint_definition" };
//= printers["check_constraint_definition"] = function(value) { throw 'print "check_constraint_definition": unimplemented'; };
check_constraint_definition "check_constraint_definition"
  = $("CHECK"i _? left_paren _? search_condition _? right_paren)

//= type column_definition = { tag: "column_definition" };
//= printers["column_definition"] = function(value) { throw 'print "column_definition": unimplemented'; };
column_definition "column_definition"
  = $(column_name _? (data_type / domain_name) (_? default_clause)? (_? column_constraint_definition)* (_? collate_clause)?)

//= type column_constraint_definition = { tag: "column_constraint_definition" };
//= printers["column_constraint_definition"] = function(value) { throw 'print "column_constraint_definition": unimplemented'; };
column_constraint_definition "column_constraint_definition"
  = $((constraint_name_definition _?)? column_constraint (_? constraint_attributes)?)

//= type constraint_attributes = { tag: "constraint_attributes" };
//= printers["constraint_attributes"] = function(value) { throw 'print "constraint_attributes": unimplemented'; };
constraint_attributes "constraint_attributes"
  = $(constraint_check_time (_? ("NOT"i _?)? "DEFERRABLE"i)?)
  / $(("NOT"i _?)? "DEFERRABLE"i (_? constraint_check_time)?)

//= type column_constraint = { tag: "column_constraint" };
//= printers["column_constraint"] = function(value) { throw 'print "column_constraint": unimplemented'; };
column_constraint "column_constraint"
  = $("NOT"i _? "NULL"i)
  / unique_specification
  / references_specification
  / check_constraint_definition

//= type default_clause = { tag: "default_clause" };
//= printers["default_clause"] = function(value) { throw 'print "default_clause": unimplemented'; };
default_clause "default_clause"
  = $("DEFAULT"i _? default_option)

//= type default_option = { tag: "default_option" };
//= printers["default_option"] = function(value) { throw 'print "default_option": unimplemented'; };
default_option "default_option"
  = literal
  / datetime_value_function
  / "USER"i
  / "CURRENT_USER"i
  / "SESSION_USER"i
  / "SYSTEM_USER"i
  / "NULL"i

//= type literal = { tag: "literal" };
//= printers["literal"] = function(value) { throw 'print "literal": unimplemented'; };
literal "literal"
  = signed_numeric_literal
  / general_literal

//= type signed_numeric_literal = { tag: "signed_numeric_literal" };
//= printers["signed_numeric_literal"] = function(value) { throw 'print "signed_numeric_literal": unimplemented'; };
signed_numeric_literal "signed_numeric_literal"
  = $((sign _?)? unsigned_numeric_literal)

//= type identifier_body = { tag: "identifier_body" };
//= printers["identifier_body"] = function(value) { throw 'print "identifier_body": unimplemented'; };
identifier_body "identifier_body"
  = $(identifier_start (underscore / identifier_part)*)

//= type identifier_part = { tag: "identifier_part" };
//= printers["identifier_part"] = function(value) { throw 'print "identifier_part": unimplemented'; };
identifier_part "identifier_part"
  = identifier_start
  / digit

_
  = separator

eof
  = !.

space
  = [ ]

identifier_start
  = [a-zA-Z_]

nonquote_character
  = ch:. & { return ch !== "'"; }

newline
  = [\n]

nondoublequote_character
  = ch:. & { return ch !== '"'; }

regular_identifier
  = text:identifier_body & { return !isKeyword(text) }

comment_character
  = ch:. & { return ch !== '\n' }
