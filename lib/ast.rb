#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    Defines the Abstract Syntax Tree for LAL. 

class UnitNode
	def initialize (line, col)
		@type = "UnitNode"
		@line = line
		@col = col
	end

	attr_reader :type, :line, :col
end

# Program
#    Holds a list of expressions to evaluate.
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
		@terms = terms
	end
	attr_reader :terms

	def to_s
		str = "<TermList : "
		@terms.each {|t| str += t.to_s + " + "}
		@terms.length >= 1 ? str = str[0..-6] + ">" : ""
		return str + ">"
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
end

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

class Call < UnitNode
	def initialize (line, col, fnc_name, args)
		super(line, col)
		@type = 'Call'
		@name = fnc_name
		@args = args
	end

	def to_s
		"<Call : #{@name} with: #{@args}>"
	end
end

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

class Matrix < UnitNode
	def initialize (line, col, values)
		super(line, col)
		@type = 'Matrix'
		@values = values
	end

	def to_s
		"<Matrix : [ #{@values.each {|x| "#{x}, "}} ]>"
	end
end

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

class SetOperatorInfo < UnitNode
	def initialize (line, col, operator, type1, type2, priority, function)
		super(line, col)
		@type = 'SetOperatorInfo'
		@operator = operator
		@type1 = type1
		@type2 = type2
		@priority = priority
		@function = function
	end

	def to_s
		"<SetOperatorInfo : (#{@type1.type}) #{@operator.value} (#{@type2.type}) as (priority: #{priority.value}, function: #{@function.name}) >"
	end
end
