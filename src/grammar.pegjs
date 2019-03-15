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
expression
  = select_expression
  / binary_expression

expression_primary
  = literal
  / ident:identifier { return { tag: 'ident', name: ident }; }

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
//=   left: value_expression,
//=   right: value_expression,
//= };
//= printers["binary_expression"] = function(value) { throw 'print "binary_expression": unimplemented'; };
binary_expression "binary_expression"
  = or_expression

or_expression "or_expression"
  = head:and_expression tail:(_ OR _ and_expression)*
    { return makeBinary(head, tail); }

and_expression "and_expression"
  = head:comparison_expression_1 tail:(_ AND _ comparison_expression_1)*
    { return makeBinary(head, tail); }

comparison_expression_1 "comparison_expression_1"
  = head:comparison_expression_2 tail:(_ ("=" / "==" / "!=" / "<>" / IS / IS _ NOT / IN / LIKE / MATCH / OVERLAPS) _ comparison_expression_2)*
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

digit
  = [0-9]

separator "separator"
  = (comment / space / newline)+ { return void 0; }

identifier_start
  = [a-zA-Z_]

nondoublequote_character
  = !double_quote .


comment_character
  = !newline .

// ------------------------------------------------------------------------------
// Identifiers
// ------------------------------------------------------------------------------
identifier "identifier"
  = regular_identifier
  / double_quote body:delimited_identifier_body double_quote { return unesc2(body); }
  
regular_identifier "regular_identifier"
  = !keyword identifier_body

identifier_body "identifier_body"
  = $(identifier_start (underscore / identifier_part)*)

identifier_part "identifier_part"
  = identifier_start
  / digit
  
delimited_identifier_body "delimited_identifier_body"
  = delimited_identifier_part+

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
select_expression "select_expression"
  = SELECT (_ set_quantifier)? _ select_list:select_list _ table:table_expression
    { return { tag: 'select_expression', select_list: select_list, table: table }; }

select_list "select_list"
  = asterisk { return null; }
  / $(select_sublist (_ comma _ select_sublist)*)

//= type select_sublist = { tag: "select_sublist" };
select_sublist "select_sublist"
  = derived_column
  / qualifier period asterisk

//= type derived_column = [expression, as_clause|null];
derived_column "derived_column"
  = expr:expression alias:(_ as_clause)? { return [expr, alias ? alias[1] : null ]; }

//= type as_clause = column_name;
as_clause "as_clause"
  = (AS _)? name:column_name { return name; }

//= type column_name = identifier;
column_name "column_name"
  = identifier

table_expression "table_expression"
  = from:from_clause where:(_ where_clause)? group_by:(_ group_by_clause)? having:(_ having_clause)?
    { return { tag: "table_expression", from: from, where: where ? where[1] : null, group_by: group_by ? group_by[1] : null, having: having ? having[1] : null }; }

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

//= type table_value_constructor = expression[];
table_value_constructor "table_value_constructor"
  = VALUES _ xs:table_value_constructor_list { return xs; }

//= type table_value_constructor_list = { tag: "table_value_constructor_list" };
table_value_constructor_list "table_value_constructor_list"
  = head:comma_separated_expressions tail:(_ comma _ comma_separated_expressions)* { return tail.reduce((acc, tuple) => (acc.push(tuple[3], acc)), [head]); }

comma_separated_expressions
  = left_paren _ head:expression tail:(_ comma _ expression)* (_ comma)? _ right_paren { return tail.reduce((acc, tuple) => (acc.push(tuple[3], acc)), [head]); }

//= type set_quantifier = 'DISTINCT'|'ALL';
set_quantifier "set_quantifier"
  = DISTINCT
  / ALL

//= type qualifier = { tag: "qualifier" };
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

//= type collation_name = collation_name;
collation_name "collation_name"
  = qualified_name

//= type column_reference = [identifier|null, identifier|null, identifier];
column_reference "column_reference"
  = catalog:(catalog_name period)? schema:(schema_name period)? column:column_name
    { return [calatog ? calatog[0] : null, schema ? schema[0] : null, column ? column[0] : null]; }

catalog_name = identifier
schema_name = identifier

//= type table_reference = join;
table_reference "table_reference"
  = join

//= type join = join;
join "join"
  = left:table_reference_primary right:(_ (CROSS _ JOIN / NATURAL? (_ join_type)? _ JOIN) _ table_reference_primary (_ join_specification)?)*
    { return { tag: "join", left: left, right: right }; }

table_reference_primary
  = left_paren _ table:join _ right_paren { return table; }
  / $(table_name (_ correlation_specification)?)
  / $(derived_table _ correlation_specification)

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
// Literals
// ------------------------------------------------------------------------------
literal "literal"
  = numeric_literal
  / string_literal

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

signed_integer "unsigned_integer"
  = text:$(sign? digit+) { return parseInt(text); }

// ------------------------------------------------------------------------------
// Keywords
// ------------------------------------------------------------------------------
keyword
  = DELETE / SELECT / OR / AND / IN / NOT / IS / LIKE / MATCH / OVERLAPS / FROM / JOIN / CROSS / WHERE / ORDER / LIMIT / OFFSET / GROUP / DISTINCT / ALL / AS / HAVING / VALUES / BY / COLLATE / NATURAL / ON /USING/INNER/UNION/OUTER/LEFT/RIGHT/FULL
  
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
