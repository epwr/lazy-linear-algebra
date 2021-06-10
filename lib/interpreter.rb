#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
# 		Takes a program (list of AST), typically created by the parser, and evaluates it.

require_relative "./ast.rb"

# NOTES:
# => Need to evaluate step by step (with a print_details() call between each step)
# => In normal mode, this step by step is silent.
# => How to set this up? Evaluate deepest nodes? But need to recusively check best step by looking horizontally.
# 		=> Maybe draw a few ASTs and see how I would want to evaluate them manually. Look for algorithm.


def eval_program(program)
	eval_node_under(program, {}, [])
end

private

##############################################################
#                       Generic Evals                        #
##############################################################

def eval_node_under(node, env, stack_trace)
	case base_node
	
	in Program
		eval_program_under(node, env, stack_trace + [StackTraceElement.new(node.line, node.col)])
		# TODO: Implement
	in Scalar
		puts "Found Scalar -> Not Implemented."
		# TODO: Implement
	in Assignment
		puts "Found Assignment -> Not Implemented."
		# TODO: Implement
	in Operation
		puts "Found Operation -> Not Implemented."
		# TODO: Implement
	in Reference
		puts "Found Reference -> Not Implemented."
		# TODO: Implement
	in Matrix
		puts "Found Matrix -> Not Implemented."
		# TODO: Implement
	in LiteralVariable
		puts "Found LiteralVariable -> Not Implemented."
		# TODO: Implement
	
	in Operator
		puts "Found Operator -> Not Implemented."
		# TODO: Implement
	in UnaryOperation
		puts "Found UnaryOperation -> Not Implemented."
		# TODO: Implement
	in Lambda
		puts "Found Lambda -> Not Implemented."
		# TODO: Implement
	in Call
		puts "Found Call -> Not Implemented."
		# TODO: Implement
	in IfThenElse
		puts "Found IfThenElse -> Not Implemented."
		# TODO: Implement
	in Boolean
		puts "Found Boolean -> Not Implemented."
		# TODO: Implement
	in Tuple
		puts "Found Tuple -> Not Implemented."
		# TODO: Implement
	else
		# TODO: Throw error.
		# TODO: Check if ReturnStatement or Assignment. Shouldn't be, but if it is... what to do?
		puts "Error: Somehow you got to the 'else' case in eval_node_under() with: #{base_node}"
	end
end

##############################################################
#                    Specific Node Evals                     #
##############################################################

def eval_program_under(program, env, stack_trace)

	program.each {|base_node| 
		case base_node
		in Assignment
			puts "Found Assignment -> Not Implemented."
			# TODO: Implement
		in ReturnStatement
			return 
			# TODO: Implement
		else
			eval_node_under(base_node, env, stack_trace)
		end
	}
end




##############################################################
#                   Other Helper Functions                   #
##############################################################

# StackTraceElement
#
# Used to track where in the program an error was caused.
class StackTraceElement
	def initialize(line, col, *args)
		@line, @col, @fnc_name, @args = line, col, fnc_name, *args
	end

	def to_s
		"line: #{@line}, col: #{col}), with args: (#{@args})"
	end
end


# throw_error
#
# Throws runtime errors by printing them along with the stack_trace. Does not
# allow catching/throwing errors by the user.
#
# TODO: Consider implementing a throw/catch system.
def throw_error(msg, cur_ast_node, stack_trace) 

	puts "Error: #{msg}"
	puts ""
	puts "Occured with: #{cur_ast_node}"
	puts ""
	puts "At:"
	stack_trace.each_with_index { |element, index|
		puts " " * index + element.to_s
	}
end