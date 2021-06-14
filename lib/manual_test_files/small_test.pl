a = 2
b = 3

(a + b) * (2 * `a + 1)   				# <TermList : <Term : 10a^ <Term : 1>> + <Term : 5>>
3 * (2 + 2 * `a - 3 * `b)				# <TermList : <Term : 6a^ <Term : 1>> + <Term : -9b^ <Term : 1>> + <Term : 6>>

(2 * `a + 3 * `b) + (2 * `a + 3 * `b)	# <TermList : <Term : 4a^ <Term : 1>> + <Term : 6b^ <Term : 1>>>
(2 * `a + 3 * `b) - (2 * `a + 3 * `b)	# <TermList : >
(2 * `a + 3 * `b) * (2 * `a + 3 * `b)	# <TermList : <Term : 9b^ <Term : 2>> + <Term : 12a^ <Term : 1>b^ <Term : 1>> + <Term : 4a^ <Term : 2>>>
(2 * `a + 3 * `b) / (2 * `a + 3 * `b)	#  <Fraction : <TermList : <Term : 2a^ <Term : 1>> + <Term : 3b^ <Term : 1>>> / <TermList : <Term : 2a^ <Term : 1>> + <Term : 3b^ <Term : 1>>>>

1 / (2 * `a) + 2 / (2 * `a) 			# <Term : 1.5a^ <Term : -1>>
1 / (2 * `a) - 2 / (2 * `a)				# <Term : -0.5a^ <Term : -1>>
1 / (2 * `a) * 2 / (2 * `a)				# <Term : 0.5a^ <Term : -2>>
1 / (2 * `a)  * 1 / (2 / (2 * `a))  	# <Term : 0.5a^ <Term : 0>>

1 / (2 * `a + 3) + 1 / (2 * `a + 3)		# <Fraction : <Term : 2> / <TermList : <Term : 2a^ <Term : 1>> + <Term : 3>>>
1 / (2 * `a + 3) - 1 / (2 * `a + 3)		# <Fraction : <Term : 0> / <TermList : <Term : 2a^ <Term : 1>> + <Term : 3>>>
1 / (2 * `a + 3) * 1 / (2 * `a + 3)		# <Fraction : <Term : 1> / <TermList : <Term : 12a^ <Term : 1>> + <Term : 4a^ <Term : 2>> + <Term : 9>>>
(1 / (2 * `a + 3)) / (1 / (2 * `a + 3))	# <Term : 1>
