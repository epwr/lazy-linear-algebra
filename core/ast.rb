#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    Defines the Abstract Syntax Tree for LAL. 


# UnitNode
#
# Default node.
class UnitNode
	def initialize (line, col)
		@type = "UnitNode"
		@line = line
		@col = col
	end

	attr_reader :type, :line, :col
end


# Program
#
# Holds a list of nodes to evaluate.
class Program < UnitNode
	def initialize (line, col, ast_list)
		super(line, col)
		@type = 'Program'
		@ast_list = ast_list
	end

	include Enumerable
	def each &block
		@ast_list.each(&block)
	end 
end


# Assignment
#
# Holds an identifer on the left, and a node to evaluate on the right.
class Assignment < UnitNode
	def initialize (line, col, left, right)
		super(line, col)
		@type = 'Assignment'
		@left = left
		@right = right
	end
	attr_reader :left, :right

	def to_s
		"<Assignment : #{@left} = #{@right}>"
	end
end


# UnaryOperation
#
# An operation that affects only the next node.
class UnaryOperation < UnitNode
	def initialize (line, col, operator, right)
		super(line, col)
		@type = 'UnaryOperation'
		@operator = operator
		@right = right
	end
	attr_reader :operator, :right

	def to_s
		"<UnaryOperation : #{@operator} => #{@right}>"
	end
end


# Operation
#
# A binary operation.
class Operation < UnitNode
	def initialize (line, col, left, operator, right)
		super(line, col)
		@type = 'Operation'
		@left = left
		@operator = operator
		@right = right
	end
	attr_reader :left, :operator, :right
	attr_writer :left

	def to_s
		"<Operation : #{@left} #{@operator.value} #{@right}>"
	end
end


# Operator
#
# Held by both UnaryOperation and Operation, to be checked by the interpreter
# to decide which operation to perform.
class Operator < UnitNode
	def initialize (line, col, value)
		super(line, col)
		@type = 'Operator'
		@value = value
	end
	attr_reader :value

	def to_s
		"<Operator : #{@value}>"
	end
end


# TermList
#
# An array of terms that should be summed together, but cannot be due
# to containing different literal variables, or one being a real term
# and the being an imaginary term. 
class TermList < UnitNode
	def initialize (line, col, terms)
		super(line, col)
		@type = 'TermList'
		@terms = terms.filter {|term| term.magnitude != 0}
		# TODO: finish merge_like_terms and call here. 
		@terms.sort
	end
	attr_reader :terms

	def to_s
		str = "<TermList : "
		@terms.each {|t| str += t.to_s + " + "}
		@terms.length >= 1 ? str = str[0..-4]: ""
		return str + ">"
	end
	
	def to_terminal_str
		str = ""
		@terms.each {|t| str += t.to_terminal_str + " + "}
		str = str[0..-4]
		if @terms.length > 1 
			str = "(" + str + ")"
		end
		return str
	end


	def == other
		if other.type == "Term" and @terms.length == 0 and other.magnitude == 0
			return true
		elsif other.type == "Term" and @terms.length == 1 and @terms[0] == other
			return true
		elsif @type != other.type or @terms.length != other.terms.length
			return false
		end

		for i in (0..@terms.length - 1)
			if i == -1 # if a list is empty
				return true
			elsif @terms[i] != other.terms[i]
				return false
			end
		end	
		return true
	end

	def merge_like_terms
		# TODO: finish and call in the initialize method.
		raise "ast l: #{__LINE__} > method not implemented."
	end
end


# Term
#
# Contains a magnitude along either the real or the imaginary number line, and can
# hold a literal variable which allows solving things with unknowns. The magnitude 
# can be negative to point in the negative direction of the number line. Yes, this
# means this is not actually a magnitude, but it works well in theory and practice
# (and naming is hard).
class Term < UnitNode
	def initialize (line, col, magnitude: 1, imaginary: false, literal_variable: nil, lit_var_list: nil)	
		super(line, col)
		@type = 'Term'
		@magnitude = magnitude
		@imaginary = imaginary
		# literal_variables is a 2D Array of [literal varible, exponent (should be a Term or TermList)]
		if lit_var_list
			@literal_variables = lit_var_list.sort
		elsif literal_variable
			@literal_variables = [[literal_variable, Term.new(-1,-1)]]  # Term.new(-1,-1) is == 1
		else
			@literal_variables = []
		end
	end
	attr_reader :magnitude, :imaginary, :literal_variables, :lit_var_list

	def to_s
		if @magnitude == 0
			return "<Term : 0>"
		elsif @magnitude == 1 and (not @imaginary) and @literal_variables == []
			return "<Term : 1>"
		else
			lit_var_str = ""
			if @literal_variables != []
				@literal_variables.each {|e|
					lit_var_str += "#{e[0]}^ #{e[1].to_s}"
				}	
			end
			return "<Term : #{@magnitude == 1 ? "" : @magnitude}#{@imaginary ? "i" : ""}#{lit_var_str}>"
		end
	end

	def to_terminal_str
		if @magnitude == 0
			return "0"
		elsif @magnitude == 1 and (not @imaginary) and @literal_variables == []
			return "1"
		else
			lit_var_str = ""
			if @literal_variables != []
				@literal_variables.each {|e|
					exponent = e[1].to_terminal_str
					if exponent.length > 1
						exponent = "(" + exponent + ")"
					end
					lit_var_str += "#{e[0]}^#{exponent}"
				}	
			end
			return "#{@magnitude == 1 ? "" : @magnitude}#{@imaginary ? "i" : ""}#{lit_var_str}"
		end
	end

	def same_literal_variables? other
		if @literal_variables.length != other.literal_variables.length
			return false
		end
		
		for i in (0..@literal_variables.length - 1)
			if @literal_variables[i][0] != other.literal_variables[i][0] or @literal_variables[i][1] != other.literal_variables[i][1] 
				return false
			end
		end
		return true
	end

	def == other
		if other == nil
			return false
		elsif other.type == "TermList"
			return other == self
		elsif @type != other.type or @magnitude != other.magnitude or @imaginary != other.imaginary or @literal_variables.length != other.literal_variables.length
			return false
		elsif @literal_variables.length == 0
			return true
		end

		for i in (0..@literal_variables.length - 1)
			if i == -1 # if list empty
				return true
			elsif @literal_variables[i][0] != other.literal_variables[i][0] or @literal_variables[i][1] != other.literal_variables[i][1] 
				return false
			end
		end	
	end

	include Comparable
	def <=> other
		if (self.literal_variables <=> other.literal_variables) == 0
			if (self.magnitude <=> other.magnitude) == 0
				if self.imaginary == other.imaginary
					return 0
				elsif self.imaginary == true
					return 1
				else 
					return -1
				end
			else
				return self.magnitude <=> other.magnitude
			end
		else
			return (self.literal_variables <=> other.literal_variables) 
		end
	end
end


# Fraction
#
# A simple fraction object. Can hold a Term or a TermList in either the
# numerator or the denominator. 
class Fraction < UnitNode
	def initialize (line, col, numerator: 1, denominator: 1)
		super(line, col)
		@type = 'Fraction'
		@numerator = numerator
		@denominator = denominator

		# TODO: Check denominator is not zero (empty TL, zero mag Term)

		# TODO: basic simplifying. 
		# => if numerator == 0, return Term.mag = 0
		# => if term/term, remove like parts.
		# => Longterm Goal: if denominator is TermList, have a GCD to identidfy what can be cancelled.
	end
	attr_reader :numerator, :denominator

	def to_s
		"<Fraction : #{@numerator} / #{@denominator}>"
	end

	def to_terminal_str
		return "#{@numerator.to_terminal_str} / #{@denominator.to_terminal_str}>"
	end

	def == other
		if other.type != "Fraction"
			return false
		end
		return (@numerator == other.numerator and @denominator == other.denominator)
	end
end

# IfThenElse
#
# An If statement. Only if_true or if_false will be evaluated (each is only one non-Program node).
class IfThenElse < UnitNode
	def initialize (line, col, condition, true_exp, false_exp=nil)
		super(line, col)
		@type = 'IfThenElse'
		@condition = condition
		@true_exp = true_exp
		@false_exp = false_exp
	end
	attr_reader :condition, :true_exp, :false_exp

	def to_s
		"<IfThenElse : if: #{@condition} then: #{@true_exp} else: #{@false_exp}>"
	end
end

# Boolean
#
# A boolean node. Is as expected.
class Boolean < UnitNode
	def initialize (line, col, value)
		super(line, col)
		@type = 'Boolean'
		if value
			@value = true
		else
			@value = false
		end
	end

	def to_s
		"<Boolean : #{@value}>"
	end
end

# Reference
#
# Looks up a name in the current environment.
class Reference < UnitNode
	def initialize (line, col, name)
		super(line, col)
		@type = 'Reference'
		@name = name
	end
	attr_reader :name

	def to_s
		"<Reference : #{@name}>"
	end
end

# Tuple
#
# A tuple of multiple different nodes (can hold different types of nodes).
class Tuple < UnitNode
	def initialize (line, col, values)
		super(line, col)
		@type = 'Tuple'
		@values = values
	end
	attr_reader :values

	def to_s
		"<Tuple : ( #{@values.each {|x| x.to_s + ", "}} )>"
	end
end

# Matrix
#
# A 2d array of Terms, TermLists, and Fractions. Must be rectangular.
class Matrix < UnitNode
	def initialize (line, col, values)
		super(line, col)
		@type = 'Matrix'
		@values = values
		
		@rows = values.length
		@cols = values[0].length  # Matrices must be rectangular.

		values.each { |row|
			if row.length != @cols
				raise "PARSING ERROR: At line: #{@line}, col: #{@col} >> Matrix created with inconsistent row length. "
			end
		}
	end
	attr_reader :values, :cols, :rows

	def to_s
		m_str = "<Matrix : \n\t[\t" 
		@values.each { |row|
			m_str += "\t"
			row.each{|element| 
				m_str += element.to_s
				m_str += ", "
			}
			m_str +="\n\t\t"
		}
		m_str += " ]>"
		return m_str
	end
end

# ReturnStatement
#
# Allows the interpreter to interupt a Program's flow, and return the evaluated node (value holds
# a node to be evaluated).
class ReturnStatement < UnitNode
	def initialize (line, col, value)
		super(line, col)
		@type = 'ReturnStatement'
		@value = value
	end

	def to_s
		"<ReturnStatement : #{value}>"
	end
end


# Lambda
#
# Creates a Closure when evaluated.
class Lambda < UnitNode
	def initialize (line, col, args, body)
		super(line, col)
		@type = 'Function'
		@args = args
		@body = body
		@env  = {}
	end
	attr_reader :args, :body, :env
	attr_writer :env

	def to_s
		str = "<Lambda : Arg = ("
		if @args
			@args.each {|x| str += " #{x}"}
		end
		str += " ), Body = ( #{@body} )>"
		str
	end
end


# Closure
#
# Created by evaluating a lambda. Stores an environment and a Program (as body)
class Closure < UnitNode
	def initialize (line, col, arg_ids, env, body)
		super(line, col)
		@type = 'Closure'
		@arg_ids = arg_ids  # Allows the passed parameters to be associated with particular names in the environment.
		@env = env
		@body = body
	end
	attr_reader :env, :arg_ids, :body

	def to_s
		"<Closure : #{@arg_ids}>"
	end
end

# BuiltInClosure
#
# Not Implemented. Allows functions implemented by the interpreter.
class BuiltInClosure < UnitNode
	def initialize (line, col, value)
		super(line, col)
		@type = 'Closure'
		@value = value
	end

	def to_s
		"<Closure : #{value}>"
	end
end

# Call
#
# When evaluated, looks up fnc_name in the environment. Expects to find a closure, and
# calls the closure with the given args.
class Call < UnitNode
	def initialize (line, col, fnc_name, args)
		super(line, col)
		@type = 'Call'
		@fnc_name = fnc_name
		@args = args
	end
	attr_reader :fnc_name, :args

	def to_s
		"<Call : #{@name} with: #{@args}>"
	end
end
