program(
	sequence(
		assign(location(0), to: constant(10))
		assign(location(1), to: location(location(0)))
		return(location(location(1)))
	),
	procedures:
)
