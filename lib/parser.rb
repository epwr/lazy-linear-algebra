#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    Provides the funcitonality to parse a TokenStream into an Abstract Syntax Tree - assuming
#    the token stream is syntactically correct. 

require_relative './ast.rb'
require_relative './errors.rb'
require_relative './operator_priorities.rb'


class Parser

	def initialize token_stream
		@program = []
		@tokens = token_stream
	end

	def run
		error_free = true
		program = []
		while @tokens.peak and @tokens.peak.type != "EOF" # Not EOF
			begin
				program.append(parse_next)  # TODO: Revert comment (remove next 4 lines)
				#next_ast = parse_next
				#puts "#{next_ast}"
				#puts ""
				#program.append(next_ast)
			rescue => e
				puts "........PARSER ERROR......."
				puts e.message
				puts e.backtrace
				puts "..................."
				error_free = false
			end
		end

		if error_free
			return Program.new(0,0, program)
		else
			return false
		end
	end

	# MAIN PARSING FUNCTIONS
	# => These turn tokens into AST Nodes (see AST.rb)

	def parse_next no_binary_operators=false

		cur_tok = @tokens.next
		if (not cur_tok) or cur_tok.type == "EOF"  # TODO: Do I use the EOF Token at all?
			puts "-- Line: #{__LINE__} -- Reached end of file (token stream returned nil)."
			puts "          cur_tok: #{cur_tok}"
			puts "          @tokens.peak: #{@tokens.peak}"
			return nil
		end

		# Parsing on current token (high priority - typically keywords that have precedence for program structure)
		if is_if_statement cur_tok  # Keywords have highest priority 
			return parse_if_statement cur_tok
		elsif is_set_statement cur_tok  
			return parse_set_statement cur_tok
		elsif is_lambda cur_tok  
			return parse_lambda cur_tok
		elsif is_return_statement cur_tok
			return parse_return_statement cur_tok
		elsif is_tuple cur_tok
			return parse_tuple cur_tok
		
		# Look ahead parsing
		elsif is_operation and not no_binary_operators  # When parsing unary ops, don't parse binary ops.
			return parse_operation cur_tok
		elsif is_call
			return parse_call cur_tok
		
		# Parsing on current token.
		elsif is_unary_operation cur_tok
			return parse_unary_operation cur_tok
		elsif is_matrix cur_tok
			return parse_matrix cur_tok
		else
			return parse_single_token cur_tok
		end
	end

	def parse_single_token cur_tok

		case cur_tok.type
		when "Digit"
			if cur_tok.value.include? "."
				return Term.new(cur_tok.line, cur_tok.col, magnitude: cur_tok.value.to_f)
			else
				return Term.new(cur_tok.line, cur_tok.col, magnitude: cur_tok.value.to_i)
			end
		when "Identifier"
			return Reference.new(cur_tok.line, cur_tok.col, cur_tok.value)
		when "Keyword"
			if cur_tok.value == "true" or cur_tok.value == "false"
				return Boolean.new(cur_tok.line, cur_tok.col, cur_tok.value == "true")
			else
				throw_error("Misplaced keyword.", cur_tok)
			end
		when "Operator"
			return Operator.new(cur_tok.line, cur_tok.col, cur_tok.value)
		when "Punctuation"
			throw_error("Misplaced Punctuation.", cur_tok)
		when "String"
			throw_error("Strings are not implemented in this parser.", cur_tok)
		when "EOF"
			throw_error("EOF occured when parsing single token (the lexer & parser aren't talking to each other properly).", cur_tok)
		else
			throw_error("parse_single_token failed to identify the type of the token (the lexer & parser aren't talking to each other properly).", cur_tok)
		end
	end

	# SPECIFIC TYPE PARSING FUNCTIONS

	def parse_call cur_tok
		# TODO: Instead of Error (below) return false from is_call to allow 2 (3 + 1) == 2 * (3 + 1)
		if cur_tok.type != 'Identifier'
			throw_error("Trying to call something that is not an Identifier.", cur_tok)
		end
		Call.new(cur_tok.line, cur_tok.col, parse_single_token(cur_tok), splitter("(", ")", ","))
	end

	def parse_operation(cur_tok, cur_tok_is_ast=false)

		if not cur_tok_is_ast
			left_ast = parse_single_token cur_tok
		else
			left_ast = cur_tok
		end

		if @tokens.peak.value == "-" # Turn (left - right) into (left + (- right))
			op = Operator.new(@tokens.peak.line, @tokens.peak.col, "+")
			minus = @tokens.next  # Must eat the '-' operator before parse_next (but save for later)
			right_ast = parse_next
			right_ast = UnaryOperation.new(right_ast.line, right_ast.col, minus, right_ast)
		#elsif @tokens.peak.value == "*" # Turn (left / right) into (left * (1 / right)) -- helps enforce order of operations
		#	op = Operator.new(@tokens.peak.line, @tokens.peak.col, "+")
		#	minus = @tokens.next  # Must eat the '-' operator before parse_next (but save for later)
		#	right_ast = parse_next
		#	right_ast = UnaryOperation.new(right_ast.line, right_ast.col, minus, right_ast)
		else	
			op = parse_single_token @tokens.next
			right_ast = parse_next
		end 

		if not right_ast
			throw_error("EOF occured while parsing the right side of an operator.", op)
		elsif op.value == "="
			return Assignment.new(cur_tok.line, cur_tok.col, left_ast, right_ast)
		elsif right_ast.type == "Operation"
			if get_operator_priority(op) <= get_operator_priority(right_ast.operator)
				return Operation.new(cur_tok.line, cur_tok.col, left_ast, op, right_ast)
			else
				# Put this Operation in the left slot of the right_ast (because this AST node's priority is higher).
				right_ast.left = Operation.new(cur_tok.line, cur_tok.col, left_ast, op, right_ast.left)
				return right_ast
			end
		end
		return Operation.new(cur_tok.line, cur_tok.col, left_ast, op, right_ast)
	end

	def parse_unary_operation cur_tok

		# Check if UnaryOperation or a Term.
		if cur_tok and cur_tok.type == "Operator" and cur_tok.value == "`" and @tokens.peak and @tokens.peak.type == "Identifier"
			if @tokens.peak.value == "i"
				@tokens.next
				cur_ast = Term.new(cur_tok.line, cur_tok.col, imaginary: true)  # No magnitude as default = 1
			else
				cur_ast = Term.new(cur_tok.line, cur_tok.col, literal_variable: @tokens.next.value)  # No magnitude as default = 1
			end
		else
			cur_ast = UnaryOperation.new(cur_tok.line, cur_tok.col, parse_single_token(cur_tok), parse_next(true))
		end

		# Use look ahead to see if the UnaryOperation needs to be a child node of a different ast.
		# This is the case when is_operation is true.
		if is_operation  
			return parse_operation(cur_ast, true)
		else
			return cur_ast  
		end
	end

	def parse_lambda cur_tok
		args = splitter("(", ")", ",")
		body = splitter("{", "}", nil)
		# TODO: Confirm Args are Identifiers (can be done in Lambda AST class)
		Lambda.new(cur_tok.line, cur_tok.col, args, Program.new(cur_tok.line, cur_tok.col, body))
	end

	def parse_if_statement cur_tok
		
		conditional = parse_next
		if not (@tokens.peak and @tokens.peak.type == "Keyword" and @tokens.peak.value == "then")
			throw_error("In If statement, expected 'then', got: #{@tokens.peak}.", tokens.peak)
		end
		@tokens.next  # Get rid of 'then'.

		if_true = parse_next
		if (@tokens.peak and @tokens.peak.type == "Keyword" and @tokens.peak.value == "end")
			@tokens.next 
			return IfThenElse.new(cur_tok.line, cur_tok.col, conditional, if_true)
		elsif not (@tokens.peak and @tokens.peak.type == "Keyword" and @tokens.peak.value == "else")
			throw_error("In If statement, expected 'else', got: #{@tokens.peak}.", tokens.peak)
		end
		@tokens.next  # Get rid of 'else'.
		
		if_false = parse_next
		if (@tokens.peak and @tokens.peak.type == "Keyword" and @tokens.peak.value == "end")
			@tokens.next
			return IfThenElse.new(cur_tok.line, cur_tok.col, conditional, if_true, if_false)
		else
			throw_error("In If statement, expected 'end', got: #{@tokens.peak}.", @tokens.peak)
		end
	end

	def parse_set_statement cur_tok
		# Set statements 
		operator = parse_single_token
		type1 	 = parse_single_token  # TODO: Fix this, for now the type of this symbol.
		type2 	 = parse_single_token  # TODO: Fix this, for now the type of this symbol.
		priority = parse_single_token
		function = parse_single_token

		SetOperatorInfo.new(cur_tok.line, cur_tok.col, operator, type1, type2, priority, function)
	end

	def parse_tuple cur_tok
		cur_ast = Tuple.new(cur_tok.line, cur_tok.col, splitter( nil, ")", ","))  # start=nil because "(" token has already been read.

		# Use look ahead to see if the tuple needs to be a child node of an operation.
		if is_operation  
			return parse_operation(cur_ast, true)
		else
			return cur_ast  
		end
	end

	def parse_matrix cur_tok

		rows = []
		while true
			row = []
			expecting_comma = false

			while true
				if expecting_comma
					if @tokens.is_end_of_line? or (@tokens.peak and @tokens.peak.type == "Punctuation" and @tokens.peak.value == "]")
						break
					end
					comma = @tokens.next
					if not (comma and comma.type == "Punctuation" and comma.value == ",")
						throw_error("Expected comma, got: #{comma}.", comma)
					end
					expecting_comma = false
				else
					if @tokens.is_end_of_line?
						if row  
							throw_error("Expected token, got newline.", row[-1])
						else
							throw_error("Expected token, got newline. Line/col values of next token in file.", @tokens.peak)
						end
					end
					row.append(parse_next)
					expecting_comma = true
				end
			end
			rows.append(row)
			if (@tokens.peak and @tokens.peak.type == "Punctuation" and @tokens.peak.value == "]")
				@tokens.next  # Remove '[' token
				break
			end
		end
		# TODO: Check that all rows are the same length. (maybe add the ability to right-pad with 0s?)

		# Use look ahead to see if the Matrix should be inside an operation.
		# This is the case when is_operation is true.
		cur_ast = Matrix.new(cur_tok.line, cur_tok.col, rows)
		if is_operation  
			return parse_operation(cur_ast, true)
		else
			return cur_ast  
		end
	end

	def parse_return_statement cur_tok
		return ReturnStatement.new(cur_tok.line, cur_tok.col, parse_next)
	end

	# IS FUNCTIONS

	# LOOK AHEAD
	def is_call
		not @tokens.is_end_of_line? and @tokens.peak and @tokens.peak.value == "("
	end

	def is_operation
		not @tokens.is_end_of_line? and @tokens.peak and @tokens.peak.type == "Operator" 
	end

	def is_lambda cur_tok
		cur_tok.type == "Keyword" and cur_tok.value == "lambda"
	end

	# CURRENT TOKEN
	def is_unary_operation cur_tok  # An operator that only operates on the subsequent token.
		cur_tok.type == "Operator"
	end

	def is_if_statement cur_tok
		cur_tok.type == "Keyword" and cur_tok.value == "if"
	end

	def is_set_statement cur_tok
		cur_tok.type == "Keyword" and cur_tok.value == "set"
	end

	def is_boolean cur_tok
		return (cur_tok.type == "Keyword" and (cur_tok.value == "true" or cur_tok.value == "false"))
	end

	def is_identifier cur_tok
		return cur_tok.type == "Identifier"
	end

	def is_scalar cur_tok
		return cur_tok.type == "Digit"
	end

	def is_tuple cur_tok
		return (cur_tok.type == "Punctuation" and cur_tok.value == "(")
	end

	def is_return_statement cur_tok
		return (cur_tok.type == "Keyword" and cur_tok.value == "return")
	end

	def is_matrix cur_tok
		return (cur_tok.type == "Punctuation" and cur_tok.value == "[")
	end

	# HELPERS

	def splitter (start, stop, separator)

		if not ((start == nil) or (@tokens.peak and @tokens.peak.type == "Punctuation" and @tokens.peak.value == start))
			throw_error("You should not be here splitter() expected #{start} and got #{@tokens.peak}.", @tokens.peak)
		end

		vars = []
		if start != nil
			@tokens.next
		end
		if @tokens.peak and @tokens.peak.type == "Punctuation" and @tokens.peak.value == stop
			@tokens.next
			return nil  # No arguments, not error
		end
		while true
			next_ast_node = parse_next
			if is_operation
				next_ast_node = parse_operation(next_ast_node, true)  # Place tuple in left side of operation.
			end

			if not next_ast_node 
				throw_error("Closing token '#{stop}' not found, reached EOF.", vars[0]) 
			else
				vars.append(next_ast_node)
			end
			if @tokens.peak and @tokens.peak.type == "Punctuation" and @tokens.peak.value == stop
				@tokens.next
				break
			elsif not ((@tokens.peak and @tokens.peak.type == "Punctuation" and @tokens.peak.value == separator) or separator == nil)
				throw_error("Expected seperator '#{separator}', found: #{@tokens.peak}", @tokens.peak)
			end

			if not separator == nil
				@tokens.next  # Remove separator token
			end
		end

		return vars
	end

	def throw_error msg, cur_tok
		raise "PARSING ERROR: At line: #{cur_tok.line}, col: #{cur_tok.col}, token: #{cur_tok} >> " + msg
	end

end