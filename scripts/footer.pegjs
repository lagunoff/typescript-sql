_
  = separator

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
  = text:identifier_body & { return text !== 'FROM' && text !== 'WHERE' && text !== 'JOIN' && text !== 'CROSS' && text !== 'MAX' }

comment_character
  = ch:. & { return ch !== '\n' }