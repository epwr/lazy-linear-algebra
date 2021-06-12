# Power Language

This project is building a simple programming language. I'm doing it for three reasons:

1. To learn how programming languages are implemented (at a basic level)
2. To have a tool that will perform linear algebra, with a simple and fast notation.
3. To experiment with Ruby 3 (specifically with the new pattern matching functionality that I'm very excited about)
	a. This was a battle. The Lexer and Parser use a fairly OO approach. The interpreter uses a much more functional programming approach to make use of the pattern matching. Merging these styles was a mistake. I made it work, but phew. If I did it again, I'd use OO and double dispatch to get everything working properly.

## Next Steps

	1. Build the interpreter. At least to the point of matrix multiplication.
	3. Create a semi-interactable tool. Maybe just able to pipe in files (and pipe out result). Maybe a proper REPL.

## Resources 

Implementing a programming language in JS: [lisperator.net/pltut](http://lisperator.net/pltut)
