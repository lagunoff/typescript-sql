{
  function makeBinary(head, tail) {
    return !tail ? head : tail.reduce(function(acc, tuple){
      return { tag: 'binary', op: tuple[1], left: acc, right: tuple[3] };
    }, head);
  }

  function unesc(str) {
    return str.replace(/''/, '\'');
  }

  function unesc2(str) {
    return str.replace(/""/, '"');
  }
}

start
  = stmts:(_ stmt _ ";" _ / _ stmt _ eof)* { return stmts.map(x => x[1]); }

stmt
  = expression

// ------------------------------------------------------------------------------
// Expressions
// ------------------------------------------------------------------------------

//= type expression = select_expression|delete_expression|insert_expression|update_expression|expression_primary;
expression
  = select_expression
  / delete_expression
  / insert_expression
  / update_expression
  / binary_expression

//= type expression_primary = unary_expression|set_function|{ tag: 'literal', value: literal }|values_expression|{ tag: 'ident', name: identifier }|{ tag: 'tuple', left: expression, right: expression };
expression_primary
  = unary_expression
  / set_function
  / value:literal { return { tag: 'literal', value: value }; }
  / value:signed_integer { return { tag: 'literal', value: value }; }
  / values_expression
  / ident:identifier { return { tag: 'ident', name: ident }; }
  / left_paren _ expr:expression tail:(_ comma _ expression)* _ right_paren
    { return !tail.length ? expr : { tag: 'tuple', left: expr, right: tail.length < 2 ? tail[0][3] : tail.reduce((acc, tuple) => ({ tag: 'tuple', left: tuple[3], right: acc }))}; }

// ------------------------------------------------------------------------------
// ||
// * /
// + -
// < <= > >=
// = == != <> IS (IS NOT) IN LIKE MATCH OVERLAPS
// AND
// OR
// ------------------------------------------------------------------------------

//= type binary_expression = {
//=   tag: "binary_expression",
//=   op: "||"|"*"|"/"|"+"|"-"|"<"|"<="|">"|">="|"="|"<>"|"IS"|"IS_NOT"|"IN"|"LIKE"|"MATCH"|"AND"|"OR"|"OVERLAPS",
//=   left: expression,
//=   right: expression,
//= };
binary_expression "binary_expression"
  = or_expression

or_expression "or_expression"
  = head:and_expression tail:(_ OR _ and_expression)*
    { return makeBinary(head, tail); }

and_expression "and_expression"
  = head:comparison_expression_1 tail:(_ AND _ comparison_expression_1)*
    { return makeBinary(head, tail); }

comparison_expression_1 "comparison_expression_1"
  = head:comparison_expression_2 tail:(_ ("==" / "=" / "!=" / "<>" / IS / IS _ NOT / IN / LIKE / MATCH / OVERLAPS) _ comparison_expression_2)*
    { return makeBinary(head, tail); }

comparison_expression_2 "comparison_expression_2"
  = head:plus_minus_expression tail:(_ ("<" / "<=" / ">" / ">=") _ plus_minus_expression)*
    { return makeBinary(head, tail); }

plus_minus_expression "plus_minus_expression"
  = head:asterisk_solidus_expression tail:(_ (plus_sign / minus_sign) _ asterisk_solidus_expression)*
    { return makeBinary(head, tail); }

asterisk_solidus_expression "asterisk_solidus_expression"
  = head:concatenation_expression tail:(_ (asterisk / solidus) _ concatenation_expression)*
    { return makeBinary(head, tail); }

concatenation_expression "concatenation_expression"
  = head:expression_primary tail:(_ (concatenation_operator) _ expression_primary)*
    { return makeBinary(head, tail); }

//= type values_expression = { tag: 'values', exprs: expression[] }; 
values_expression "values_expression"
  = VALUES _ exprs:comma_separated_expressions { return { tag: 'values', exprs: exprs }; }

//= type unary_expression = { tag: "unary", op: "+"|"-"|"NOT", expr: expression };
unary_expression "unary_expression"
  = op:sign _ expr:expression { return { tag: 'unary', op: op, expr: expr }; }
  / op:NOT _ expr:expression { return { tag: 'unary', op: op, expr: expr }; }


// ------------------------------------------------------------------------------
// Set functions
// ------------------------------------------------------------------------------

//= type set_function =
//=   | { tag: "count_asterisk" }
//=   | { tag: "general_set_function", type: set_function_type, quantifier: set_quantifier, expr: expression }
//= ;
set_function "set_function"
  = COUNT _ left_paren _ asterisk _ right_paren
    { return { tag: "count_asterisk" }; }
  / type:set_function_type _ left_paren quantifier:(_ set_quantifier)? _ expr:expression _ right_paren
    { return { tag: "general_set_function", type: type, quantifier: quantifier ? quantifier[1] : null, expr: expr }; }

//= type set_function_type = { tag: "set_function_type" };
set_function_type "set_function_type"
  = AVG / MAX / MIN / SUM / COUNT


// ------------------------------------------------------------------------------
// Identifiers
// ------------------------------------------------------------------------------

//= type identifier = string;
identifier "identifier"
  = regular_identifier
  / double_quote body:delimited_identifier_body double_quote { return unesc2(body); }
  
regular_identifier "regular_identifier"
  = !keyword body:identifier_body { return body; }

identifier_body "identifier_body"
  = $(identifier_start (underscore / identifier_part)*)

identifier_part "identifier_part"
  = identifier_start
  / digit
  
delimited_identifier_body "delimited_identifier_body"
  = $(delimited_identifier_part+)

delimited_identifier_part "delimited_identifier_part"
  = nondoublequote_character
  / doublequote_symbol
 
doublequote_symbol "doublequote_symbol"
  = $(double_quote double_quote)
  
// ------------------------------------------------------------------------------
// Comments
// ------------------------------------------------------------------------------

comment "comment"
  = $(comment_introducer comment_character* (newline / eof)) { return ''; }

comment_introducer "comment_introducer"
  = $(minus_sign minus_sign minus_sign*)

// ------------------------------------------------------------------------------
// Select expression
// ------------------------------------------------------------------------------
//= type select_expression = { tag: "select", columns: select_list } & table_expression;
select_expression "select_expression"
  = SELECT (_ set_quantifier)? _ columns:select_list _ table:table_expression
    { return { tag: "select", columns: columns, ...table }; }

//= type select_list = null|select_sublist[];
select_list "select_list"
  = asterisk { return null; }
  / select_sublist (_ comma _ select_sublist)*

//= type select_sublist = derived_column|{ tag: 'qualified_asterisk', qualifier: qualifier };
select_sublist "select_sublist"
  = derived_column
  / qualifier:qualifier period asterisk { return { tag: 'qualified_asterisk', qualifier: qualifier }; }

//= type derived_column = [expression, as_clause|null];
derived_column "derived_column"
  = expr:expression alias:(_ as_clause)? { return [expr, alias ? alias[1] : null ]; }

//= type as_clause = column_name;
as_clause "as_clause"
  = (AS _)? name:column_name { return name; }

//= type column_name = identifier;
column_name "column_name"
  = identifier

//= type table_expression = { from: from_clause, where: where_clause|null, group_by: group_by_clause|null, having: having_clause|null }
table_expression "table_expression"
  = from:from_clause where:(_ where_clause)? group_by:(_ group_by_clause)? having:(_ having_clause)?
    { return { from: from, where: where ? where[1] : null, group_by: group_by ? group_by[1] : null, having: having ? having[1] : null }; }

//= type from_clause = table_reference;
from_clause "from_clause"
  = FROM _ head:table_reference tail:(_ comma _ table_reference)*
  { return tail ? tail.reduce(function(acc, x) { acc.push(x[3]); return acc; }, [head]) : [head]; };

//= type where_clause = expression;
where_clause "where_clause"
  = WHERE _ expr:expression { return expr; }

//= type having_clause = { tag: "having_clause" };
having_clause "having_clause"
  = HAVING _ expr:expression { return expr; } 

comma_separated_expressions
  = head:expression tail:(_ comma _ expression)*  { return tail.reduce((acc, tuple) => (acc.push(tuple[3], acc)), [head]); }

//= type set_quantifier = 'DISTINCT'|'ALL';
set_quantifier "set_quantifier"
  = DISTINCT
  / ALL

//= type qualifier = table_name|correlation_name;
qualifier "qualifier"
  = table_name
  / correlation_name

//= type table_name = qualified_name;
table_name "table_name"
  = qualified_name

//= type qualified_name = { tag: "qualified_name", catalog: identifier|null, schema: identifier|null, ident: identifier };
qualified_name "qualified_name"
  = catalog:identifier period schema:identifier period ident:identifier
    { return { tag: "qualified_name", catalog: catalog, schema: schema, ident: ident }; }
  / schema:identifier period ident:identifier
    { return { tag: "qualified_name", catalog: null, schema: schema, ident: ident }; }
  / ident:identifier
    { return { tag: "qualified_name", catalog: null, schema: null, ident: ident }; }
  
//= type correlation_name = identifier;
correlation_name "correlation_name"
  = identifier
  
//= type group_by_clause = grouping_column_reference_list;
group_by_clause "group_by_clause"
  = GROUP _ BY _ list:grouping_column_reference_list { return list; }

//= type grouping_column_reference_list = grouping_column_reference[];
grouping_column_reference_list "grouping_column_reference_list"
  = head:grouping_column_reference tail:(_ comma _ grouping_column_reference)*
  { return tail ? tail.reduce((acc, tuple) => (acc.push(tuple[3], acc)), [head]) : [head]; }

//= type grouping_column_reference = [column_reference, collate_clause|null];
grouping_column_reference "grouping_column_reference"
  = column:column_reference collate:(_ collate_clause)?
  { return [column, collate ? collate[1] : null]; }

//= type collate_clause = collation_name;
collate_clause "collate_clause"
  = COLLATE _ name:collation_name { return name; }

//= type collation_name = qualified_name;
collation_name "collation_name"
  = qualified_name

//= type column_reference = [identifier|null, identifier|null, identifier];
column_reference "column_reference"
  = catalog:(catalog_name period)? schema:(schema_name period)? column:column_name
    { return [calatog ? calatog[0] : null, schema ? schema[0] : null, column ? column[0] : null]; }

catalog_name = identifier
schema_name = identifier

//= type table_reference = table_reference_primary|join;
table_reference "table_reference"
  = join

//= type join = { tag: 'join', type: join_kw, left: table_reference, right: table_reference, spec: join_specification|null };
join "join"
  = left:table_reference_primary right:(_ join_kw _ table_reference_primary (_ join_specification)?)*
    { return right.length ? right.reduce((acc, tuple) => ({ tag: "join", type: tuple[1], left: acc, right: tuple[3], spec: tuple[4] ? tuple[4][1] : null }), left) : left; }
    
//= type join_kw = join_type|'CROSS';
join_kw
  = CROSS _ JOIN { return 'CROSS'; }
  / NATURAL? ty:(_ join_type)? _ JOIN { return ty ? ty[1] : 'LEFT'; }

//= type table_reference_primary =
//=   | { tag: 'table_name', table: table_name, correlation: correlation_specification|null }
//=   | { tag: 'expression', expr: expression, correlation: correlation_specification|null }
//= ;
table_reference_primary
  = left_paren _ table:table_reference _ right_paren
    { return table; }
  / table:table_name correlation:(_ correlation_specification)?
    { return { tag: 'table_name', table: table, correlation: correlation ? correlation[1] : null }; }
  / expr:derived_table correlation:(_ correlation_specification)?
    { return { tag: 'expression', expr: expr, correlation: correlation ? correlation[1] : null }; }

//= type correlation_specification = { tag: "correlation_specification" };
correlation_specification "correlation_specification"
  = $((AS _)? identifier (_ left_paren _ column_name_list _ right_paren)?)

//= type derived_table = expression;
derived_table "derived_table"
  = expression

//= type join_specification = { tag: "join_specification" };
join_specification "join_specification"
  = join_condition
  / named_columns_join

//= type join_condition = expression;
join_condition "join_condition"
  = ON _ expr:expression { return expr; }

//= type named_columns_join = column_name_list[];
named_columns_join "named_columns_join"
  = USING _ left_paren _ list:column_name_list _ right_paren { return list; }

//= type column_name_list = column_name[];
column_name_list "column_name_list"
  = head:column_name tail:(_ comma _ column_name)*
    { return tail ? tail.reduce((acc, tuple) => (acc.push(tuple[3]), acc), [head]) : [head]; }
    
//= type join_type = 'INNER'|'UNION'|outer_join_type;
join_type "join_type"
  = INNER
  / $(outer_join_type (_ OUTER)?)
  / UNION

//= type outer_join_type = 'LEFT'|'RIGHT'|'FULL';
outer_join_type "outer_join_type"
  = LEFT
  / RIGHT
  / FULL

// ------------------------------------------------------------------------------
// Delete expression
// ------------------------------------------------------------------------------

//= type delete_expression = { tag: 'delete', table: table_name, where: expression };
delete_expression "delete_expression"
  = DELETE _ FROM _ table:table_name where:(_ WHERE _ expression)?
    { return { tag: 'delete', table: table, where: where ? where[3] : null }; }

// ------------------------------------------------------------------------------
// Insert expression
// ------------------------------------------------------------------------------

//= type insert_expression = { tag: "insert", table: table_name } & insert_columns_and_source;
insert_expression "insert_expression"
  = INSERT _ INTO _ table:table_name _ columns:insert_columns_and_source
    { return { tag: "insert", table: table, ...columns }; }

//= type insert_columns_and_source = { columns: insert_column_list|null, expr: expression };
insert_columns_and_source "insert_columns_and_source"
  = columns:(left_paren _ insert_column_list _ right_paren _)? expr:expression { return { columns: columns ? columns[2] : null, expr: expr }; }

//= type insert_column_list = { tag: "insert_column_list" };
insert_column_list "insert_column_list"
  = column_name_list

// ------------------------------------------------------------------------------
// Update expression
// ------------------------------------------------------------------------------

//= type update_expression = { tag: "update", table: table_name, set: set_clause_list, where: expression|null };
update_expression "update_expression"
  = UPDATE _ table:table_name _ SET _ set:set_clause_list where:(_ WHERE _ expression)?
    { return { tag: "update", table: table, set: set, where: where ? where[3] : null }; }

//= type set_clause_list = set_clause[];
set_clause_list "set_clause_list"
  = head:set_clause tail:(_ comma _ set_clause)*
    { return tail.reduce((acc, tuple) => (acc.push(tuple[3]), acc), [head]); }

//= type set_clause = { column: column_name, value: update_source };
set_clause "set_clause"
  = column:column_name _ equals_operator _ value:update_source
    { return { column: column, value: value }; }

//= type update_source = { tag: "expression", value: expression } | { tag: 'default' };
update_source "update_source"
  = DEFAULT { return { tag: 'default' }; }
  / value:expression { return { tag: 'expression', value: value }; }

// ------------------------------------------------------------------------------
// Literals
// ------------------------------------------------------------------------------

//= type literal = string_literal|numeric_literal;
literal "literal"
  = numeric_literal
  / string_literal

//= type string_literal = string;
string_literal "string_literal"
  = quote head:$(character_representation*) quote tail:(separator+ quote $(character_representation*) quote)*
    { return tail ? tail.reduce(function(acc, x) { return acc + unesc(x[2]); }, unesc(head)) : unesc(head); }

character_representation "character_representation"
  = nonquote_character
  / quote_symbol

nonquote_character
  = !quote .
  
quote_symbol "quote_symbol"
  = quote quote

//= type numeric_literal = number;
numeric_literal "numeric_literal"
  = approximate_numeric_literal
  / exact_numeric_literal

exact_numeric_literal "exact_numeric_literal"
  = t:$(unsigned_integer (period (unsigned_integer)?)?) { return Number(t); }
  / t:$(period unsigned_integer) { return Number('0' + t); }

approximate_numeric_literal "approximate_numeric_literal"
  = m:mantissa "E" e:exponent { return m * Math.pow(10, e); }

exponent "exponent"
  = signed_integer

mantissa "mantissa"
  = exact_numeric_literal

unsigned_integer "unsigned_integer"
  = text:$(digit+) { return parseInt(text); }

//= type signed_integer = number;
signed_integer "unsigned_integer"
  = text:$(sign? digit+) { return parseInt(text); }


// ------------------------------------------------------------------------------
// Symbols
// ------------------------------------------------------------------------------
left_paren "left_paren" = "("
right_paren "right_paren" = ")"
quote "quote" = "'"
double_quote "double_quote" = "\""
underscore = "_"
minus_sign = "-"
plus_sign = "+"
sign = minus_sign / plus_sign
period = "."
asterisk = "*"
solidus = "/"
comma = ","
concatenation_operator = "||"
newline = [\n]
_ = separator?
eof = !.
space = [ ]
equals_operator = "="
digit = [0-9]
separator "separator" = (comment / space / newline)+ { return void 0; }
identifier_start = [a-zA-Z_]
nondoublequote_character = !double_quote .
comment_character = !newline .


// ------------------------------------------------------------------------------
// Keywords
// ------------------------------------------------------------------------------
keyword
  = DELETE / SELECT / OR / AND / IN / NOT / IS / LIKE / MATCH / OVERLAPS / FROM / JOIN / CROSS / WHERE / ORDER / LIMIT / OFFSET / GROUP / DISTINCT / ALL / AS / HAVING / VALUES / BY / COLLATE / NATURAL / ON /USING/INNER/UNION/OUTER/LEFT/RIGHT/FULL/INSERT/INTO/DEFAULT/UPDATE/SET/AVG / MAX / MIN / SUM / COUNT
  
DELETE "DELETE" = "DELETE"i !identifier_start { return "DELETE"; }
SELECT "SELECT" = "SELECT"i !identifier_start { return "SELECT"; }
FROM "FROM" = "FROM"i !identifier_start { return "FROM"; }
JOIN "JOIN" = "JOIN"i !identifier_start { return "JOIN"; }
CROSS "CROSS" = "CROSS"i !identifier_start { return "CROSS"; }
WHERE "WHERE" = "WHERE"i !identifier_start { return "WHERE"; }
ORDER "ORDER" = "ORDER"i !identifier_start { return "ORDER"; }
GROUP "GROUP" = "GROUP"i !identifier_start { return "GROUP"; }
LIMIT "LIMIT" = "LIMIT"i !identifier_start { return "LIMIT"; }
OFFSET "OFFSET" = "OFFSET"i !identifier_start { return "OFFSET"; }
OR "OR" = "OR"i !identifier_start { return "OR"; }
AND "AND" = "AND"i !identifier_start { return "AND"; }
IN = "IN"i !identifier_start { return "IN"; }
NOT = "NOT"i !identifier_start { return "NOT"; }
IS = "IS"i !identifier_start { return "IS"; }
LIKE "LIKE" = "LIKE"i !identifier_start { return "LIKE"; }
MATCH "MATCH" = "MATCH"i !identifier_start { return "MATCH"; }
OVERLAPS "OVERLAPS" = "OVERLAPS"i !identifier_start { return "OVERLAPS"; }
DISTINCT "DISTINCT" = "DISTINCT"i !identifier_start { return "DISTINCT"; }
ALL "ALL" = "ALL"i !identifier_start { return "ALL"; }
AS "AS" = "AS"i !identifier_start { return "AS"; }
HAVING "HAVING" = "HAVING"i !identifier_start { return "HAVING"; }
VALUES "VALUES" = "VALUES"i !identifier_start { return "VALUES"; }
BY "BY" = "BY"i !identifier_start { return "BY"; }
COLLATE "COLLATE" = "COLLATE"i !identifier_start { return "COLLATE"; }
NATURAL "NATURAL" = "NATURAL"i !identifier_start { return "NATURAL"; }
ON "ON" = "ON"i !identifier_start { return "ON"; }
USING "USING" = "USING"i !identifier_start { return "USING"; }
INNER "INNER" = "INNER"i !identifier_start { return "INNER"; }
UNION "UNION" = "UNION"i !identifier_start { return "UNION"; }
OUTER "OUTER" = "OUTER"i !identifier_start { return "OUTER"; }
LEFT "LEFT" = "LEFT"i !identifier_start { return "LEFT"; }
RIGHT "RIGHT" = "RIGHT"i !identifier_start { return "RIGHT"; }
FULL "FULL" = "FULL"i !identifier_start { return "FULL"; }
INSERT "INSERT" = "INSERT"i !identifier_start { return "INSERT"; }
INTO "INTO" = "INTO"i !identifier_start { return "INTO"; }
DEFAULT "DEFAULT" = "DEFAULT"i !identifier_start { return "DEFAULT"; }
UPDATE "UPDATE" = "UPDATE"i !identifier_start { return "UPDATE"; }
SET "SET" = "SET"i !identifier_start { return "SET"; }
AVG "AVG" = "AVG"i !identifier_start { return "AVG"; }
MAX "MAX" = "MAX"i !identifier_start { return "MAX"; }
MIN "MIN" = "MIN"i !identifier_start { return "MIN"; }
SUM "SUM" = "SUM"i !identifier_start { return "SUM"; }
COUNT "COUNT" = "COUNT"i !identifier_start { return "COUNT"; }

//= export function parse(input: string): expression[];
//= export interface SyntaxError extends Error {}

