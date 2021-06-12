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
	in Term
		return node, env
	in TermList
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
		return eval_tuple(node, env, stack_trace)
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
		# TODO: Only allow parsing an Assignment from a program level (which covers function bodies)
		# => Would mean I don't need to pass the env back down the stack ever.
		value, env = eval_node_under(node, env, stack_trace)
		# TODO: Remove debug stuff (below)
		puts "----"
		puts "  Value: #{value}"
		env_str = ""
		env.each {|k,v| env_str += "\n\t #{k} : #{v.to_s}"} 
		puts "  Environment: #{env_str}"
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
		in [Term, Term]
			return add_two_terms(left, right), env
		in [Term, TermList]
			return add_term_and_term_list(left, right), env
		in [TermList, Term]
			return add_term_and_term_list(right, left), env
		else
			throw_error("Operator '#{node.operator.value}' not implemented for left: #{left.type}, right: #{right.type}.", node, stack_trace) 
		end
	when "-"
		case [left, right]
		in [Term, Term]
			return subtract_two_terms(left, right), env
		in [Term, TermList]
			return subtract_term_list_from_term(left, right), env
		in [TermList, Term]
			return subtract_term_from_term_list(right, left), env
		else
			throw_error("Operator '#{node.operator.value}' not implemented for left: #{left.type}, right: #{right.type}.", node, stack_trace) 
		end
	when "*"
		case [left, right]
		in [Term, Term]
			return multiply_two_terms(left, right), env
		in [Term, TermList]
			return multiply_term_and_term_list(left, right), env
		in [TermList, Term]
			return multiply_term_and_term_list(left, right), env
		in [TermList, TermList]
			return multiply_term_list_and_term_list(left, right), env
		else
			throw_error("Operator '#{node.operator.value}' not implemented for left: #{left.type}, right: #{right.type}.", node, stack_trace) 
		end
	when "/"
		case [left, right]
		in [Term, Term]
			return divide_two_terms(left, right), env
		in [Term, TermList]
			return divide_term_by_term_list(left, right), env
		in [TermList, Term]
			return divide_term_list_by_term(left, right), env
		else
			throw_error("Operator '#{node.operator.value}' not implemented for left: #{left.type}, right: #{right.type}.", node, stack_trace) 
		end
	else
		throw_error("Operator '#{node.operator.value}' not implemented.", node, stack_trace) 
	end

end


def eval_unary_operation(node, env, stack_trace)

	case node.operator.value
	when "!"
		value, _ = eval_node_under(node.right, env, stack_trace)
		if value.type == "Boolean"
			return Boolean.new(value.line, value.col, !value.value), env
		else
			throw_error("'!' operator called on a non-Boolean value.", node, stack_trace)
		end
	when "-"
		value, _ = eval_node_under(node.right, env, stack_trace)
		case value
		in Term
			return flip_sign_on_term(value), env
		else
			puts "ERROR ----- Line: #{__LINE__} -- NOT IMPLEMENTED: Got: #{value}"
			# TODO !!!!!!!!!!!!!
		end
	else
		throw_error("UnaryOperator '#{node.operator}' is not implemented.", node, stack_trace)
	end

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


# eval_tuple
#
# Evaluate each node in the tuple. If more than one, return a tuple storing the evaluated 
# values. Otherwise, return the evaluated node.
def eval_tuple(node, env, stack_trace)

	evaluated_nodes = []
	node.values.each{ |sub_node|
		sub_node_value, _ = eval_node_under(sub_node, env, stack_trace) 
		evaluated_nodes.append(sub_node_value)
	}
	if evaluated_nodes.length == 1
		return evaluated_nodes[0], env
	else
		return Tuple.new(node.line, node.col, evaluated_nodes)
	end
end


##############################################################
#                     Operations Helpers                     #
##############################################################

# add_two_terms
#
# If both terms are imaginary or both not, and both have the same lit_var_list, then create a new term that
# is the sum of their real components. Otherwise, create a term list with the two terms.
def add_two_terms(left, right)
	# If both imaginary or both real, with the same literal variables, then simply add together.
	if left.literal_variables == right.literal_variables and left.imaginary == right.imaginary 
			return Term.new(left.line, left.col, magnitude: left.magnitude + right.magnitude, imaginary: left.imaginary, lit_var_list: left.literal_variables)
	end
	return TermList.new(left.line, left.col, [left, right])  # Else, create a TermList.
end


# add_term_and_term_list
#
# Adds a Term into a TermList.
def add_term_and_term_list(term, term_list)

	term_added = false
	new_terms = term_list.terms.map { |tl_term|
		if (not term_added) and tl_term.literal_variables == term.literal_variables and tl_term.imaginary == term.imaginary
			term_added = true
			puts ">> term added to a term in term list."
			Term.new(term.line, term.col, magnitude: tl_term.magnitude + term.magnitude, imaginary: term.imaginary, lit_var_list: term.literal_variables)
		else
			tl_term
		end
	}
	if not term_added
		new_terms.append(term)
	end

	return TermList.new(term.line, term.col, new_terms)	
end


# divide_two_terms
#
# Go from `left / right` to `left * right^-1` and then call multiply_two_terms. Note that 1 / i =  -i,
# hence the if right.imaginary then magnitude: -1.0 / right.magnitude.
def divide_two_terms(left, right)

	# Change the exponent's sign on each literal variable.
	new_lit_var_list = right.literal_variables.map { |element|  # Form [base variable, exponent]
		new_lit_var_list.append([element[0], flip_sign_on_term(element[1])])
	}
	if right.imaginary
		new_right = Term.new(right.line, right.col, magnitude: -1.0 / right.magnitude, imaginary: true, lit_var_list: new_lit_var_list)
	else
		new_right = Term.new(right.line, right.col, magnitude: 1.0 / right.magnitude, lit_var_list: new_lit_var_list)
	end
	multiply_two_terms(left, new_right)
end


##############################################
##      ######  ######  ####    ######      ##
##        ##    ##  ##  ##  ##  ##  ##      ##
##        ##    ##  ##  ##  ##  ##  ##      ##
##        ##    ##  ##  ##  ##  ##  ##      ##
##        ##    ######  ####    ######      ##
##############################################
#
#
# => Add a fraction that wraps Terms and TermLists (would term lists ever need to be fractions? -> no.).
# => Add multiply term list by term list
# => Consider adding a 'simplify' method to the termList.


# divide_term_by_term_list
#
# 
#
def divide_term_by_term_list(left, right)
	raise "Not Implemented"
end

def divide_term_list_by_term(left, right)
	raise "Not Implemented"
end


# flip_sign_on_term
#
# Flips the sign on the magnitude of a Term.
def flip_sign_on_term term
	return Term.new(term.line, term.col, magnitude: term.magnitude * -1, imaginary: term.imaginary, lit_var_list: term.literal_variables)
end


# flip_sign_on_term_list
#
# Flips the sign on the magnitude of each Term in a TermList.
def flip_sign_on_term_list term_list
	new_terms = term_list.map { |term|
		new_terms.append(flip_sign_on_term term)
	}
	return TermList.new(term_list.line, term_list.col, new_terms)
end


# multiply_two_terms
#
# This combines the literal variables (and their exponents) as appropriate, and then multiplies the
# magnitudes and checks if and i^2 term would exist (converts it in a negative real number).
def multiply_two_terms(left, right)

	# Get new list of the literal varibles (with exponents added together as needed).
	combined_lit_var_list = left.literal_variables + right.literal_variables
	new_lit_var_list = []
	index = 0
	while combined_lit_var_list[index] != nil
		if combined_lit_var_list[index + 1] and combined_lit_var_list[index][0] == combined_lit_var_list[index + 1][0]
			combined_lit_var_list[index + 1][1] = add_two_terms(combined_lit_var_list[index][1], combined_lit_var_list[index + 1][1])
		else
			new_lit_var_list.append(combined_lit_var_list[index])
		end
		index += 1
	end

	# Merge the real and imaginary components.
	if left.imaginary == right.imaginary
		if left.imaginary # Both terms are imaginary
			return Term.new(left.line, left.col, magnitude: left.magnitude * right.magnitude * -1, lit_var_list: new_lit_var_list)
		else  # Neither are imaginary
			return Term.new(left.line, left.col, magnitude: left.magnitude * right.magnitude, lit_var_list: new_lit_var_list)
		end
	else  # One term is imaginary
		return Term.new(left.line, left.col, magnitude: left.magnitude * right.magnitude, imaginary: true, lit_var_list: new_lit_var_list)
	end
end


# multiply_term_and_term_list
#
# Multiplies the term into each term in the TermList.
def multiply_term_and_term_list(term, term_list)

	puts "   line: #{__LINE__} -- term: #{term}"
	puts "   line: #{__LINE__} -- term_list: #{term_list}"
	new_terms = term_list.terms.map {|tl_term|
		multiply_two_terms(tl_term, term)
	}
	return TermList.new(term_list.line, term_list.col, new_terms)
end

# multiply_term_list_and_term_list
#
# 
def multiply_term_list_and_term_list(tl_left, tl_right)

	puts "   line: #{__LINE__} -- tl_left:  #{tl_left}"
	puts "   line: #{__LINE__} -- tl_right: #{tl_right}"

	new_terms = []
	tl_left.terms.each {|term|
		new_tl = multiply_term_and_term_list(term, tl_right)
		puts "       line: #{__LINE__} -- result: #{new_tl}"
		new_terms += new_tl.terms
	}
	return TermList.new(tl_left.line, tl_left.col, new_terms)
end


# subtract_two_terms
#
# Flips the sign on the magnitude of the second term and then adds the two terms. This is because
# a - b = a + (-b) is true.
def subtract_two_terms(left, right)
	add_two_terms(left, flip_sign_on_term(right))
end

# subtract_term_from_term_list
#
# For cases where [a + b + c] - d. Flips the sign on the term, and then adds to Term to the TermList.
def subtract_term_from_term_list(term, term_list)
	add_term_and_term_list(flip_sign_on_term(term), term_list)
end

# subtract_term_list_from_term
#
# For cases where a - [b + c + d]. Flips the sign on the TermList, and then the Term and the TermList.
def subtract_term_list_from_term(term_list, term)
	add_term_and_term_list(term, flip_sign_on_term_list(term_list))
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

