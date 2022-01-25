(
	do(
		allocateVector(word, count: 10, into: seq)
		setElement(word, of: seq, at: immediate(0), to: immediate(1))
		setElement(word, of: seq, at: immediate(1), to: immediate(1))
		call(updateFibSeqAt, immediate(2) immediate(9) location(seq))
	),
	procedures:
		(updateFibSeqAt, (index, word) (max, word) (elems, capability),
			if(
				relation(location(word), eq, location(max)),
				then: do(
					getElement(word, of: elems, at: location(max), to: result)
					return(word, location(result))
				), else: do(
					
					compute(location(index), sub, immediate(1), to: prevIndex)
					getElement(word, of: elems, at: location(prevIndex), to: first)
					getElement(word, of: elems, at: location(index), to: second)
					compute(location(first), add, location(second), to: sum)
					
					compute(location(index), add, immediate(1), to: nextIndex)
					call(updateFibSeqAt, location(nextIndex) location(max) location(elems))
					
				)
			)
		)
)
