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
	value, env = eval_program_under(program, {}, [])
	return value
end

private

##############################################################
#                       Generic Evals                        #
##############################################################



def eval_node_under(node, env, stack_trace)
	
	case node
	in Program
		eval_program_under(node, env, stack_trace + [StackTraceElement.new(node.line, node.col)])
	in Scalar
		return node, env
	in Assignment
		right, _ = eval_node_under(node.right, env, stack_trace)
		env[node.left.name] = right
		return UnitNode.new(node.line, node.col), env
	in Operation
		return eval_operation(node, env, stack_trace)
	in Reference
		if env[node.name]
			return env[node.name], env
		else
			throw_error("'#{node.name}' is not defined.", node, stack_trace)
		end
	in Matrix
		return node, env
	in LiteralVariable
		return node, env
	in Operator
		puts "Found Operator -> Not Implemented."
		# TODO: Implement -- Maybe this is an error?
	in UnaryOperation
		puts "-- #{node}"
		return eval_unary_operation(node, env, stack_trace)
	in Lambda
		node.env = env.clone  # Lexical Scope
		return node, env
	in Call
		return eval_call(node, env, stack_trace)
	in IfThenElse
		return eval_if_then_else(node, env, stack_trace)
	in Boolean
		return node, env
	in Tuple
		return node, env
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

	value = nil
	program.each {|node| 
		# TODO: Add in dealing with a return statement.
		value, env = eval_node_under(node, env, stack_trace)
		puts "----"
		puts "  Value: #{value}"
		puts "  Environment: #{env}"
		puts "----"
	}
	
	return value, env
end


def eval_operation(node, env, stack_trace)

	# Evaluate both sides of operation (discard environment return statement.)
	left, _ = eval_node_under(node.left, env, stack_trace)
	right, _ = eval_node_under(node.right, env, stack_trace)

	# TODO: Add more operations.
	case node.operator.value
	when "+"
		case [left, right]
		in [Scalar, Scalar]
			return Scalar.new(node.line, node.col, left.value + right.value), env
		else
			throw_error("Operator '#{node.operator.value}' not implemented for left: #{left}, right: #{right}.", node, stack_trace) 
		end
	else
		throw_error("Operator '#{node.operator.value}' not implemented.", node, stack_trace) 
	end

end


def eval_unary_operation(node, env, stack_trace)

	case 
	puts "Found UnaryOperation -> eval_unary_operation is Not Implemented. #{node}"
	# TODO: Implement

end


def eval_if_then_else(node, env, stack_trace)

	condition = eval_node_under(node.condition, env, stack_trace)
	case condition
	in Boolean
		if condition.value 
			return eval_node_under(node.true_exp, env, stack_trace), env
		else
			if condition.false_exp  # is not empty
				return eval_node_under(node.false_exp, env, stack_trace), env
			else  # Don't do anything (return UnitNode)
				return UnitNode(node.line, node.col), env
			end
		end
	else
		throw_error("If statement's condition does not evaluate to a Boolean.", node, stack_trace)
	end
end


def eval_call(node, env, stack_trace)

	puts "Found Call -> eval_call is Not Implemented."
	# TODO: Implement
	# => Create a new stack trace
	# => lookup lambda
	# => Eval args (use current env)
	# => Call eval_program_under (with lambda's environment extended with args)

end

##############################################################
#                   Other Helper Functions                   #
##############################################################

# StackTraceElement
#
# Used to track where in the program an error was caused.
class StackTraceElement
	def initialize(line, col, fnc_name, *args)
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

