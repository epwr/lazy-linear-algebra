#!/usr/bin/ruby
#
# Author: Eric Power
#
# Description:
#    A place to manage the priorities of different operator priorities. Provides get_operator_priority()
#    which accepts an Operator (AST Node) and returns its priority (which is set in this file).


# get_operator_priority
#
# Called by the parser to determine which operations have a higher priority.
# Placed in its own file to simplify managing it.
def get_operator_priority operator

	op_priorities = {
		">*<" => 	30,  	# Inner Product
		"<*>" => 	30,  	# Outer Product
		"*." => 	30,  	# Dot Product
		"*+" => 	30,  	# Cross Product
		"*!" => 	30,  	# Tensor Product
		"/" => 		21,  	# Division
		"*" => 		20,  	# Product
		"+" => 		10, 	# Addition
		"-" => 		10, 	# Subtraction
		"||" => 	5,  	# Logical Or
		"&&" => 	5,  	# Logical And
	}	

	return op_priorities[operator.value]
end