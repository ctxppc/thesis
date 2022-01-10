(
	
		do(
			
				set( arg0_0, to: immediate( 0))
				set( arg1_1, to: immediate( 1))
				set( arg2_2, to: immediate( 30))
				call(
					 fib,
					
						location( arg0_0)
						location( arg1_1)
						location( arg2_2)
				)
		),
	procedures: (
		 fib,
		
			( prev_0,  word)
			( curr_1,  word)
			( iter_2,  word),
		
			if(
				
					do(
						
							set( lhs_3, to: location( iter_2))
							set( rhs_4, to: immediate( 0)),
						then: relation( location( lhs_3),  le,  location( rhs_4))
					),
				then:
					do(
						
							set( result, to: location( curr_1))
							return( location( result))
					),
				else:
					do(
						
							set( arg0_5, to: location( curr_1))
							do(
								
									set( lhs_3, to: location( prev_0))
									set( rhs_4, to: location( curr_1))
									compute( location( lhs_3),  add,  location( rhs_4), to: arg1_6)
							)
							do(
								
									set( lhs_3, to: location( iter_2))
									set( rhs_4, to: immediate( 1))
									compute( location( lhs_3),  sub,  location( rhs_4), to: arg2_7)
							)
							call(
								 fib,
								
									location( arg0_5)
									location( arg1_6)
									location( arg2_7)
							)
					)
			)
	)
)