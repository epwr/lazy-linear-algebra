# Notes About This Parser

## Next Steps:

	- Add Error throwing and catching (and maybe warnings? eg. if matrix is not rectangular).
	- Add ability to get i-th element out of tuple (and matrix). (maybe tuple?1, tuple?2, etc.)
	- Write some stuff up about the language. InputStream > Lexer > Parser (building AST). Talk about the structure of each part.
	- Implement Priorities to Operations (eg. build AST based on priorities - have lots so that I can add operations in the future as needed). Ensure that ((2 + 3) * 4) is still parsed properly.
	- Add Dirac Notation (parses into a matrix I think?)
	- Add Strings (in parse_single_token -- should be straightforward on the parser end).

## Notes for a Refactor / Reuse

For the AST, I would:
    - Have the concept of a literal and subclass it for matrix/scalar/literal variables.
    - Have a broader idea of Operation and subclass for assignment/if/lambda/unary/etc

For the lexer:
	- I would consider not having a 'is_end_of_line?' method. This is a hack used to allow the matrix literal to use the newline as the symbol for a new row, but I don't use the newline anywhere else. I if were to continue to work on this language, I would want to think through the syntax a little more to ensure this strange case.
	


