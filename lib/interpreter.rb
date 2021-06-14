#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
# 		Takes a program (list of AST), typically created by the parser, and evaluates it.

require_relative "./ast.rb"

##############################################
##      ######  ######  ####    ######      ##
##        ##    ##  ##  ##  ##  ##  ##      ##
##        ##    ##  ##  ##  ##  ##  ##      ##
##        ##    ##  ##  ##  ##  ##  ##      ##
##        ##    ######  ####    ######      ##
##############################################
#
# => Get Unit Tests set up.
# => Add Matrix stuff (see pg. 139 of main notebook)
# => Add Calls and Lambdas


def eval_program(program)
	value, env = eval_program_under(program, {}, [])
	return value
end

private

##############################################################
#                       Generic Evals                        #
##############################################################

def eval_program_under(program, env, stack_trace)

	value = nil
	program.each {|node| 
		# TODO: Add in dealing with a return statement.
		# TODO: Only allow parsing an Assignment from a program level (which covers function bodies)
		# => Would REQUIRE having Programs as true_exp and false_exp in ifThenElses.
		# => Would mean I don't need to pass the env back down the stack ever.
		value, env = eval_node_under(node, env, stack_trace)
		# TODO: Remove debug stuff (below)
		puts "----"
		puts "  Value: #{value}"
		env_str = ""
		env.each {|k,v| env_str += "\n\t #{k} : #{v.to_s}"} 
		puts "  Environment: #{env_str}"
		puts "---------------------------------------------------------"
	}
	
	return value, env
end

def eval_node_under(node, env, stack_trace)
	
	case node
	in Program
		eval_program_under(node, env, stack_trace + [StackTraceElement.new(node.line, node.col)])
	in Term
		return node, env
	in TermList
		return node, env
	in Assignment
		# TODO: Move to eval_program_under, and throw error here.
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

def eval_operation(node, env, stack_trace)

	# Evaluate both sides of operation (discard returned environment)
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
			return add_term_and_term_list(left, right), env
		in [TermList, TermList]
			return add_term_list_and_term_list(left, right), env
		in [Fraction, Term]
			return add_fraction_and_term(left, right), env
		in [Term, Fraction]
			return add_fraction_and_term(right, left), env
		in [Fraction, TermList]
			return add_fraction_and_term_list(left, right), env
		in [TermList, Fraction]
			return add_fraction_and_term_list(right, left), env
		in [Fraction, Fraction]
			return add_fraction_and_fraction(left, right), env	
		else
			throw_error("Operator '#{node.operator.value}' not implemented for left: #{left.type}, right: #{right.type}.", node, stack_trace) 
		end
	when "-"
		puts "inter l: #{__LINE__} -- Note: Using a subtraction."  # TODO: Does this ever get used now that I've inverted a - b to a + (-b)?
		case [left, right]
		in [Term, Term]
			return subtract_two_terms(left, right), env
		in [Term, TermList]
			return subtract_term_list_from_term(right, left), env
		in [TermList, Term]
			return subtract_term_from_term_list(right, left), env
		in [TermList, TermList]
			return subtract_term_list_from_term_list(left, right), env
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
		in [Fraction, Term]
			return multiply_fraction_and_term(left, right), env
		in [Term, Fraction]
			return multiply_fraction_and_term(right, left), env
		in [Fraction, TermList]
			return multiply_fraction_and_term_list(left, right), env
		in [TermList, Fraction]
			return multiply_fraction_and_term_list(right, left), env
		in [Fraction, Fraction]
			return multiply_fraction_and_fraction(left, right), env	
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
		in [TermList, TermList]
			return divide_term_list_by_term_list(left, right), env
		in [Fraction, Term]
			return divide_fraction_by_term(left, right), env
		in [Term, Fraction]
			return divide_term_by_fraction(right, left), env
		in [Fraction, TermList]
			return divide_fraction_by_term_list(left, right), env
		in [TermList, Fraction]
			return divide_term_list_by_fraction(right, left), env
		in [Fraction, Fraction]
			return divide_fraction_by_fraction(left, right), env	
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
		in TermList
			return flip_sign_on_term_list(value), env
		in Fraction
			return flip_sign_on_fraction(value), env
		else
			throw_error("UnaryOperator '#{node.operator.value}' not implemented for: #{value.type}.", node, stack_trace) 
		end
	else
		throw_error("UnaryOperator '#{node.operator.value}' is not implemented.", node, stack_trace)
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


# add_fraction_and_fraction
#
#
def add_fraction_and_fraction(frac1, frac2)
	
	puts "i l: #{__LINE__} > add_fraction_and_fraction"
	puts "i l: #{__LINE__} > frac1: #{frac1}"
	puts "i l: #{__LINE__} > frac2: #{frac1}"

	if frac1.denominator != frac2.denominator
		new_frac1_numerator = multiply_unknown_terms_or_term_lists(frac1.numerator, frac2.denominator)
		new_frac2_numerator = multiply_unknown_terms_or_term_lists(frac2.numerator, frac1.denominator)
		new_numerator = add_unknown_terms_or_term_lists(new_frac1_numerator, new_frac2_numerator)
		new_denominator = multiply_unknown_terms_or_term_lists(frac1.denominator, frac2.denominator)
		return Fraction.new(frac1.line, frac1.col, numerator: new_numerator, denominator: new_denominator)
	end
	new_numerator = add_unknown_terms_or_term_lists(frac1.numerator, frac2.numerator)
	return Fraction.new(frac1.line, frac1.col, numerator: new_numerator, denominator: frac1.denominator)
end


# add_fraction_and_term_list
#
# Adds a term list into the numerator of a fraction.
def add_fraction_and_term_list(fraction, term_list)
	term_list_as_numerator = multiply_unknown_terms_or_term_lists(fraction.denominator, term_list)
	new_numerator = add_unknown_terms_or_term_lists(fraction.numerator, term_list_as_numerator)
	return Fraction.new(frac1.line, frac1.col, numerator: new_numerator, denominator: fraction.denominator)
end


# add_fraction_and_term	
#
# Adds a term into the numerator of a fraction.
def add_fraction_and_term(fraction, term)
	term_as_numerator = multiply_unknown_terms_or_term_lists(fraction.denominator, term)
	new_numerator = add_unknown_terms_or_term_lists(fraction.numerator, term_as_numerator)
	return Fraction.new(frac1.line, frac1.col, numerator: new_numerator, denominator: fraction.denominator)
end


# add_two_terms
#
# If both terms are imaginary or both not, and both have the same lit_var_list, then create a new term that
# is the sum of their real components. Otherwise, create a term list with the two terms.
def add_two_terms(left, right)
	# If both imaginary or both real, with the same literal variables, then simply add together.
	if left.literal_variables == right.literal_variables and left.imaginary == right.imaginary 
			return Term.new(left.line, left.col, magnitude: left.magnitude + right.magnitude, imaginary: left.imaginary, lit_var_list: left.literal_variables.clone)
	end
	return TermList.new(left.line, left.col, [left, right])  # Else, create a TermList.
end


# add_term_and_term_list
#
# Adds a Term into a TermList.
def add_term_and_term_list(term, term_list)

	term_added = false
	new_terms = term_list.terms.map { |tl_term|
		if (not term_added) and tl_term.same_literal_variables? term and tl_term.imaginary == term.imaginary
			term_added = true
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


# add_term_list_and_term_list
#
# Adds two TermLists together.
def add_term_list_and_term_list(tl_left, tl_right)

	tl_left.terms.each {|term|
		tl_right = add_term_and_term_list(term, tl_right)
	}	
	return tl_right
end


# add_unknown_terms_or_term_lists
#
# Checks if the arguments are Terms or TermLists and adds them using the appropriate function.
def add_unknown_terms_or_term_lists(left, right)
	case [left, right]
	in Term, Term
		return add_two_terms(left, right)
	in TermList, Term
		return add_term_and_term_list(right, left)
	in Term, TermList
		return add_term_and_term_list(left, right)
	in TermList, TermList
		return add_term_list_and_term_list(left, right)
	else
		throw_error("When multiplying #{left} and #{right} found something that is not a Term or a TermList (#{__LINE__})", left, [])  # TODO: Add stack trace (make a global)
	end
end


# divide_fraction_by_fraction
#
# Returns frac1 / frac2
def divide_fraction_by_fraction(frac1, frac2)
	if frac1 == frac2
		return Term.new(frac1.line, frac1.col, magnitude: 1)
	elsif frac1.numerator == frac2.numerator
		return Fraction.new(frac1.line, frac1.col, numerator: frac2.denominator, denominator: frac1.denominator)
	elsif frac1.denominator == frac2.denominator
		return Fraction.new(frac1.line, frac1.col, numerator: frac1.numerator, denominator: frac2.numerator)
	else		
		return multiply_fraction_and_fraction(frac1, invert_fraction(frac2))
	end
end


# divide_fraction_by_term_list
#
# Returns fraction / term_list
def divide_fraction_by_term_list(fraction, term_list)
	tl_fraction = Fraction.new(term_list.line, term_list.col, denominator: term_list)
	return multiply_fraction_and_fraction(fraction, tl_fraction)
end


# divide_fraction_by_term
#
# Returns fraction / term
def divide_fraction_by_term(fraction, term)
	term_fraction = Fraction.new(term.line, term.col, denominator: term)
	return multiply_fraction_and_fraction(fraction, term_fraction)
end


# divide_term_list_by_fraction
#
# Returns term_list / fraction (or term_list * fraction^-1)
def divide_term_list_by_fraction
	tl_fraction = Fraction.new(term_list.line, term_list.col, numerator: term_list)
	return multiply_fraction_and_fraction(invert_fraction(fraction), tl_fraction)
end


# divide_term_by_fraction
#
# Returns term / fraction (or term * fraction^-1)
def divide_term_by_fraction(term, fraction)
	term_fraction = Fraction.new(term.line, term.col, numerator: term)
	return multiply_fraction_and_fraction(invert_fraction(fraction), term_fraction)
end


# divide_two_terms
#
# Go from `left / right` to `left * right^-1` and then call multiply_two_terms. Note that 1 / i =  -i,
# hence the if right.imaginary then magnitude: -1.0 / right.magnitude.
def divide_two_terms(left, right)

	# Change the exponent's sign on each literal variable.
	new_lit_var_list = right.literal_variables.map { |element|  # Form [base variable, exponent]
		[element[0], flip_sign_on_term(element[1])]
	}
	if right.imaginary
		new_right = Term.new(right.line, right.col, magnitude: -1.0 / right.magnitude, imaginary: true, lit_var_list: new_lit_var_list)
	else
		new_right = Term.new(right.line, right.col, magnitude: 1.0 / right.magnitude, lit_var_list: new_lit_var_list)
	end
	return multiply_two_terms(left, new_right)
end


# divide_term_by_term_list
#
# Creates a fraction with the term as the numerator and the term_list as the denominator.
def divide_term_by_term_list(term, term_list)
	return Fraction.new(term.line, term.col, numerator: term, denominator: term_list)
end


# divide_term_list_by_term
#
# Creates a fraction with the term_list as the numerator and the term as the denominator.
def divide_term_list_by_term(term_list, term)
	return Fraction.new(term.line, term.col, numerator: term_list, denominator: term)
end


# divide_term_list_by_term_list
#
# Creates a fraction with the tl_left as the numerator and the tl_right as the denominator.
def divide_term_list_by_term_list(tl_left, tl_right)
	return Fraction.new(tl_left.line, tl_left.col, numerator: tl_left, denominator: tl_right)
end

# invert_fraction
#
# Inverts a fraction. Used when dividing by a fraction.
def invert_fraction fraction
	return Fraction.new(fraction.line, fraction.col, numerator: fraction.denominator, denominator: fraction.numerator)
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
	new_terms = []
	term_list.terms.each { |term|
		new_terms.append(flip_sign_on_term term)
	}
	return TermList.new(term_list.line, term_list.col, new_terms)
end


# flip_sign_on_fraction
#
# Returns a new fraction with the numerators' sign inverted.
def flip_sign_on_fraction fraction
	case fraction.numerator
	in Term
		return Fraction.new(fraction.line, fraction.col, numerator: flip_sign_on_term(fraction.numerator), denominator: fraction.denominator)
	in TermList
		return Fraction.new(fraction.line, fraction.col, numerator: flip_sign_on_term_list(fraction.numerator), denominator: fraction.denominator)
	else
		throw_error("When flipping sign on #{fraction}, found something that is not a Term or a TermList (#{__LINE__})", fraction, [])  # TODO: Add stack trace (make a global)
	end
end


# multiply_fraction_and_fraction
#
# Multiplies two fractions.
def multiply_fraction_and_fraction(left, right)
	new_numerator = multiply_unknown_terms_or_term_lists(left.numerator, right.numerator)
	new_denominator = multiply_unknown_terms_or_term_lists(left.denominator, right.denominator)
	return Fraction.new(left.line, left.col, numerator: new_numerator, denominator: new_denominator)
end


# multiply_fraction_and_term_list
#
#
def multiply_fraction_and_term_list(fraction, term_list)
	new_numerator = multiply_unknown_terms_or_term_lists(fraction.numerator, term_list)
	return Fraction.new(fraction.line, fraction.col, numerator: new_numerator, denominator: new_denominator)
end


# multiply_fraction_and_term
#
#
def multiply_fraction_and_term(fraction, term)
	new_numerator = multiply_unknown_terms_or_term_lists(fraction.numerator, term)
	return Fraction.new(fraction.line, fraction.col, numerator: new_numerator, denominator: new_denominator)
end


# multiply_two_terms
#
# This combines the literal variables (and their exponents) as appropriate, and then multiplies the
# magnitudes and checks if and i^2 term would exist (converts it in a negative real number).
def multiply_two_terms(left, right)

	# Get new list of the literal varibles (with exponents added together as needed).
	combined_lit_var_list = left.literal_variables.clone + right.literal_variables.clone
	new_lit_var_list = []

	index = 0
	while combined_lit_var_list[index] != nil
		if combined_lit_var_list[index + 1] and combined_lit_var_list[index][0] == combined_lit_var_list[index + 1][0]

			new_lit_var_list.append([combined_lit_var_list[index][0], add_two_terms(combined_lit_var_list[index][1], combined_lit_var_list[index + 1][1])])
			index += 1
			# TODO: I think this would break with more than 2 terms with the same literal_variables. Not sure how that would happen though.
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

	new_terms = term_list.terms.map {|tl_term|
		multiply_two_terms(tl_term, term)
	}
	return TermList.new(term_list.line, term_list.col, new_terms)
end

# multiply_term_list_and_term_list
#
# Multiplies two TermLists together.
def multiply_term_list_and_term_list(tl_left, tl_right)

	new_terms = []
	tl_left.terms.each {|term|
		new_tl = multiply_term_and_term_list(term, tl_right)
		new_terms += new_tl.terms
	}
	new_tl = TermList.new(tl_left.line, tl_left.col, new_terms)
	return combine_redundant_terms_in_term_list(new_tl)
end


# multiply_unknown_terms_or_term_lists
#
# Checks if the arguments are Terms or TermLists and multiplies them using the appropriate function.
def multiply_unknown_terms_or_term_lists(left, right)
	case [left, right]
	in Term, Term
		return multiply_two_terms(left, right)
	in TermList, Term
		return multiply_term_and_term_list(right, left)
	in Term, TermList
		return multiply_term_and_term_list(left, right)
	in TermList, TermList
		return multiply_term_list_and_term_list(left, right)
	else
		throw_error("When multiplying #{left} and #{right} found something that is not a Term or a TermList (#{__LINE__})", left, [])  # TODO: Add stack trace (make a global)
	end
end


# subtract_fraction_from_fraction
#
# Returns the answer of: frac2 - frac1
def subtract_fraction_from_fraction(frac1, frac2)
	return add_fraction_and_fraction(frac2, flip_sign_on_fraction(frac1))
end


# subtract_fraction_from_term_list
#
# Return the answer of: term_list - fraction
def subtract_fraction_from_term_list(fraction, term_list)
	return add_fraction_and_term_list(flip_sign_on_fraction(fraction), term_list)
end


# subtract_fraction_from_term
#
# Return the answer of: term - fraction
def subtract_fraction_from_term(fraction, term)
	return add_fraction_and_term(flip_sign_on_fraction(fraction), term)
end


# subtract_two_terms
#
# Flips the sign on the magnitude of the second term and then adds the two terms. This is because
# a - b = a + (-b) is true.
def subtract_two_terms(left, right)
	add_two_terms(left, flip_sign_on_term(right))
end


# subtract_term_from_fraction
#
# Return the answer of: fraction - term
def subtract_term_from_fraction
	return add_fraction_and_term(fraction, flip_sign_on_fraction(term))
end


# subtract_term_from_term_list
#
# For cases where [a + b + c] - d. Flips the sign on the term, and then adds to Term to the TermList.
def subtract_term_from_term_list(term, term_list)
	add_term_and_term_list(flip_sign_on_term(term), term_list)
end


# subtract_term_list_from_fraction
#
# Return the answer of: fraction - term_list
def subtract_term_list_from_fraction
	return add_fraction_and_term_list(fraction, flip_sign_on_fraction(term_list))
end


# subtract_term_list_from_term
#
# For cases where a - [b + c + d]. Flips the sign on the TermList, and then the Term and the TermList.
def subtract_term_list_from_term(term_list, term)
	add_term_and_term_list(term, flip_sign_on_term_list(term_list))
end


# subtract_term_list_from_term_list
#
# For cases where tl_right - tl_left. Flips the sign on the TermList, and then the Term and the TermList.
def subtract_term_list_from_term_list(tl_left, tl_right)
	add_term_and_term_list(flip_sign_on_term_list(tl_left), tl_right)
end






##############################################################
#                   Other Helper Functions                   #
##############################################################


# combine_redundant_terms_in_term_list
#
# Merges any terms with the same imaginary and literal_variables values
def combine_redundant_terms_in_term_list term_list

	terms_to_combine = []
	term_list.terms.each{ |term|
		found_terms = term_list.terms.select{ |x| term.same_literal_variables? x}
		terms_to_combine.append(found_terms)
	}

	terms_to_combine = terms_to_combine.uniq # Remove duplicate elements of the array

	new_terms = []
	terms_to_combine.each {|array_of_terms|
		# Reduce similar terms to a single term.
		new_term = array_of_terms.reduce(Term.new(array_of_terms[0].line, array_of_terms[0].col, magnitude: 0)){ |sum_term, term|
			case sum_term
			in Term
				add_two_terms(term, sum_term)
			in TermList
				add_term_and_term_list(term, sum_term)
			else
				throw_error("When reducing a TermList, found a value that is not Term or TermList", term_list, [])  # TODO: Add stack trace (make a global)
			end
		}
		new_terms.append(new_term)
	}

	# Reduce new_terms to a single TermList
	new_term_list = new_terms.reduce(Term.new(term_list.line, term_list.col, magnitude: 0)){ |sum_term, term|
		case [sum_term, term]
		in Term, Term
			add_two_terms(term, sum_term)
		in TermList, Term
			add_term_and_term_list(term, sum_term)
		in Term, TermList
			add_term_and_term_list(sum_term, term)
		in TermList, TermList
			add_term_list_and_term_list(sum_term, term)
		else
			throw_error("When reducing a TermList, found a value that is not Term or TermList", term_list, stack_trace)
		end
	}
	return new_term_list
end


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

