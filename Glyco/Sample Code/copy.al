sequence(effects:
    copy(destination: 5, source: immediate(10))
    sequence(effects:
		copy(destination: 15, source: location(20))
    )
)
