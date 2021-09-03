# Lazy Linear Algebra

_Lazy Linear Algebra_ (LLA) is a custom programming language, implemented from scratch in Ruby 3.0.1. My favorite parts of it are that:

- It provides some visually appealing syntax for linear algebra.
- It provides a REPL (which can import a file).
- It handles both real and imaginary numbers.
- It allows for 'literal variables', meaning it knows that ``2 * `a + 3 * `a`` is ``5 * `a`` (the \` symbol indicates a literal variable).

Check out the _Features_ section for more details on these, and other, features, or jump straight to the _Examples_ section to see this in action.

## The Project

This project spawned from the monotony of performing the basic linear algebra required by a course on Quantum Computing. If you aren't familiar with Quantum Computing, there's a lot of fairly simple matrix multiplication, which takes a long time to do by hand. So I obviously started using WolframAlpha to do most of the calculations. But WolframAlpha has an issue: it's matrix notation is very verbose. A 4x4 identity matrix is written as {{1, 0, 0, 0}, {0, 1, 0, 0}, {0, 0, 1, 0}, {0, 0, 0, 1}}. Try writing out a few of those in the one line search field on WolframAlpha, and it starts to get messy. I looked around a bit for a better solution, but decided that I wanted to create my own language to do this. 

I gave myself three goals for this project:

1. **Learn how programming languages are created:** I had taken a course on programming languages, and while I found it really interesting I was a little disappointed that we didn't get to actually write our own programming language.
2. **Experiment with Ruby 3's Pattern Matching:** I have used SML before, and fell in love with its pattern matching syntax and semantics. When I heard that Ruby was implementing pattern matching in it's 3.0.0 release, I wanted to try it out. 
3. **Create a tool to perform Linear Algebra with a simple notation:** This was fairly straightforward - make doing the work in my Quantum Computing course easier. 
4. **Write everything from scratch:** This would force me to learn how each piece works, rather than just learning how to chain a few libraries together.

With that in mind, I created the Lazy Linear Algebra language. It is far from a perfect language, but by getting it to it's current state I fulfilled each of my goals with the project. Maybe at some point in the future I'll come back to this. You can check out the _Next Steps_ and _Eventual Refactor_ sections for notes on what I would add to or change in the language.

## Features

When I wrote LLA, I knew that some functionality was not a priority. For example, the lexer knows about strings, but neither the parser or the interpreter will handle them. But other things I knew would be important, for instance:

| Feature | Description |
| :-- | :-- |
| Literal Variables | LLA let's you put your variables into your expression, and everything still evaluautes properly. You dont need to do the algebra by hand, if your trying to multiply a matrix that has `2 * &#96;psi` as an element, LLA will handle it for you. |
| Complex Numbers | LLA handles complex numbers, and can add, multiply and divide them properly. `&#96;i` is treated different than literal vairables. `3 / &#96;i` is equivalent to `-3&#96;i`, but obviously `3 / &#96;a` is not equivalent to `-3&#96;a`. |
| Tensor Multiplication | A commmon operation for Quantum Computing is the tensor multiplication of two matrices (or vectors). LLA has it covered. |
| Importing a File | I knew I'd mostly use LLA in the REPL, so I wanted to be able to easily import a bunch of bindings from a saved file. The implementation's REPL makes this really easy (importing a file into another file is still on the TODO list). |

## Examples

#### Creating a Matrix
	
We can easily assign a matrix to an identifier. For example, let's create the 4 by 4 identity matrix and assign it to `I_4`:

	I_4 = [ 1, 0, 0, 0
			0, 0, 0, 0
			0, 0, 0, 0 
			0, 0, 0, 0
	]

It's worth noting that matrices are the only time where the newline matters: anywhere else newlines are ignored. Looking back, I probably wouldn't do it this way again - incosistency isn't great. But I really like how the syntax for creating matrices looks, and I wanted to be able to have multi line expressions without requiring semi-colons after everything.

Also, you don't need to line anything up - I just like to. A 2x2 identity matrix can be written as:

	I_2 = 
	[ 
	1,         0
	   0,1]

### Calculating a Quantum State

Let's see how we can use LLA to do some quantum calculations. If you aren't familiar with quantum computing, this might be a little weird (and an explanation is wayyy out of scope for this README), but we multiply matrices to represent quantum circuits.

First, let's define matrices for _ket zero_ (a state), the CNOT gate, and the Hadamard gate:

	k0 = [ 1, 
		   0 
	]

	CNOT = [ 1, 0, 0, 0
			 0, 1, 0, 0
			 0, 0, 0, 1 
			 0, 0, 1, 0
	]

	H = (1 / `sqrt-2) * [ 1,  1 
					      1, -1 
					    ]

_NOTE:_ Because I am lazy, I haven't implemented a square-root function (or any exponential stuff - we didn't do anything in our quantum computing class that needed this). So, instead, I just use a literal variable to represent the square root of 2. We'll see that this works quite well.

So, let's say we want to find out the state after taking to qubits (initialize to _ket zero_), apply a Hadamard gate to each, and then apply a CNOT gate to the system to entangle them. 

	CNOT * (H *! H) * (k0 *! k0)

If we run this, the REPL would print out:

	|  sqrt-2^(-2)    |
	|  sqrt-2^(-2)    |
	|  sqrt-2^(-2)    |
	|  sqrt-2^(-2)    |

Now, I now that `1 / (sqrt(2))^2` is `1 / 2`. So, I know the probability for measuring each state is `1 / 2`.

## Implemented Operations

For Binary Operations, we have:

| Operator | Description |
| --- | :-- |
| `a + b` | Adds `a` and `b` for numbers and matrices. |
| `a - b` | Subtracts `a` and `b` for numbers and matrices. |
| `a * b` | Multiplies `a` and `b` for numbers and matrices. |
| `a / b` | Divides `a` by `b` (for numbers). |
| `a *! b` | Tensor multiplication of matrices. |

For Unary Operations, we have:

| Operator | Description |
| --- | :-- |
| `!a` | Returns the opposite of a Boolean. |
| `-a` | Returns -1 * a number or a matrix. |
| `~a` | Returns the transpose of a matrix. |
	

## Next Steps (Medium Term)

If and when I want to some more work into this (but don't want to do a full refactor), I would focus on:

- Implement more operations.
- Allow recusive calls (when creating a closure, add a reference to itself in the environment)
- Fix it so that -\`i is read as -(\`i) (negative i), not -\`(i) (the -\` operation on the identifier i). 
- Add an `import` keyword (and the functionality).
- Only allow assignment nodes at the base level of a program node.
- Allow return statements in program nodes.
- Add ability to get i-th element out of tuples (and matrices). Maybe tuple?1, tuple?2, etc.
- Add lexing/parsing of Dirac Notation (eg. |00> == [ 1 \n 0 ] *! [ 1 \n 0 ])
- Add Strings into parser (already in the lexer, should just be editing parse_single_token and adding parse_string).


## Eventual Refactor/Rewrite

At some point, I would like to either refactor this codebase, or just rewrite it using existing tools to do the lexing/parsing. Some things I would want out of it:

- Change the syntax to fix the whole 'matrices care about new lines, but nothing else does' oddity.
- Change terms to Fractions, and Create FractionSums. Add exponents to both. (should allow for fully recursive terms). 
- Is there a way to allow users to create / change operations? Maybe custom operations always have a set priority, and you can use tuples to get around it.
- Allow recursion.
- Add the idea of a user thrown error, and catching them.
- Allow the sqrt(2) to be treated as a number.

