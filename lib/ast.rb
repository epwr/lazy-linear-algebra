#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    Defines the Abstract Syntax Tree for LAL. 

class Node
	def initialize (line, col)
		@line = line
		@col = col
	end

	attr_reader :type, :line, :col
end

# Program
#    Holds a list of expressions to evaluate.
class Program < Node
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

class Assignment < Node
	def initialize (line, col, left, right)
		super(line, col)
		@type = 'Assignment'
		@left = left
		@right = right
	end

	def to_s
		"<Assignment : #{@left} = #{@right}>"
	end
end

class UnaryOperation < Node
	def initialize (line, col, operator, right)
		super(line, col)
		@type = 'UnaryOperation'
		@operator = operator
		@right = right
	end

	def to_s
		"<UnaryOperation : #{@operator} => #{@right}>"
	end
end

class Operation < Node
	def initialize (line, col, expression)
		super(line, col)
		@type = 'Operation'
		@expression = expression
	end
	attr_reader :expression

	def to_s
		"<Operation : #{@expression.each {|x| x.to_s + ", "}}>"
	end
end

class Operator < Node
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

class Scalar < Node
	# TODO: Extend to complex numbers - somehow. Not sure how to parse that.
	def initialize (line, col, value)
		super(line, col)
		@type = 'Scalar'
		@value = value
	end
	attr_reader :value

	def to_s
		return "<Scalar : #{@value}>"
	end
end

class Lambda < Node
	def initialize (line, col, args, body)
		super(line, col)
		@type = 'Function'
		@args = args
		@body = body
	end

	def to_s
		str = "<Lambda : Arg = ("
		if @args
			@args.each {|x| str += " #{x}"}
		end
		str += " ), Body = ( #{@body} )>"
		str
	end
end

class Call < Node
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

class IfThenElse < Node
	def initialize (line, col, condition, true_exp, false_exp=nil)
		super(line, col)
		@type = 'IfThenElse'
		@condition = condition
		@true_exp = true_exp
		@false_exp = false_exp
	end

	def to_s
		"<IfThenElse : if: #{@condition} then: #{@true_exp} else: #{@false_exp}>"
	end
end

class Boolean < Node
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

class Reference < Node
	def initialize (line, col, name)
		super(line, col)
		@type = 'Reference'
		@name = name
	end

	def to_s
		"<Reference : #{@name}>"
	end
end

class Tuple < Node
	def initialize (line, col, values)
		super(line, col)
		@type = 'Tuple'
		@values = values
	end

	def to_s
		"<Tuple : ( #{@values.each {|x| x.to_s + ", "}} )>"
	end
end

class Matrix < Node
	def initialize (line, col, values)
		super(line, col)
		@type = 'Matrix'
		@values = values
	end

	def to_s
		"<Matrix : [ #{@values.each {|x| "#{x}, "}} ]>"
	end
end

class LiteralVariable < Node
	def initialize (line, col, value)
		super(line, col)
		@type = 'LiteralVariable'
		@value = value
	end

	def to_s
		"<LiteralVariable : #{value}>"
	end
end

class ReturnStatement < Node
	def initialize (line, col, value)
		super(line, col)
		@type = 'ReturnStatement'
		@value = value
	end

	def to_s
		"<ReturnStatement : #{value}>"
	end
end

class SetOperatorInfo < Node
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
