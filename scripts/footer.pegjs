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