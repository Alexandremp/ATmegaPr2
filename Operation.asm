		
		.def CONTL = r24
		.def CONTH = r25
		.def vari = r17
		.def seg=r16
		.def cont_1s = r20				;cont_1s =r20
		.def STATE = r18
		.equ ZERO=0xC0
		.equ ONE=0xF9
		.equ TWO=0xA4
		.equ THREE=0xB0
		.equ FOUR=0x99
		.equ FIVE=0x92
		.equ SIX=0x82
		.equ SEVEN=0xF8
		.equ EIGHT=0x80
		.equ NINE=0x90

		.equ START=0
		.equ RUNNING=1
		.equ STOP=2
		.cseg
		
		.org 0x00
			jmp main

		.org 0x02               ;when you click sw1
			jmp INT_int0
		
		.org 0x04		;when you click sw2	
			jmp INT_int1
			
		.org 0x16
			jmp int_tc0
			
		.org 0x46

		ini:		
				    ldi vari, 0b11000000
					out DDRD,vari					
					out PORTD,vari

					ser vari
					out DDRC,vari
					out PORTC,vari


					ldi vari,249
					out OCR0,vari

					ldi vari,0b00001101
					out TCCR0,vari

					ldi vari,0b00000010
					out TIMSK,vari
					
					ldi vari,0b00001010
					sts EICRA, vari
					
					ldi vari, 0b00000001
					out EIMSK, vari		
					ldi cont_1s,100			
					sei
					ret

					
					
					
		main:		ldi r21,	LOW(RAMEND)
	  				out SPL, 	r21
	  				ldi r21,	HIGH(RAMEND)
	  				out SPH,	r21

	  				call ini
					cpi STATE, START	// Flag start on?
					brne FlagStopON
					
		FlagStartON:	ldi seg,9			//SEG=9
						ldi cont_1s,100		//count_1s=500
						ldi STATE,RUNNING
						set				//CLEAN FLAG
						call display		//Display


		FlagStopON:		cpi STATE, STOP	//Flag stop on?
						brne Flag_1sON		

		Flashes_point: ldi vari,0b11111110
					 out PORTC,vari
					 call int_tc0
					 ser vari
					 out PORTC,vari
						
		Flag_1sON:	
					dec seg
					breq Flag_1sON
		
					call display

		PER_SEG:			
					cpi seg,0 
					brne FlagStartON
					ldi r22,3
					ser vari
		Flashes_display:	 
						out PORTC,vari
						;delay2
						call display
						dec r22
						cpi r22,0
						brne Flashes_display
						jmp FlagStartON
					
		
		INT_int0:
					push vari			;save records
					in vari, SREG		        ;save records
					push vari			;save records
					
					ldi ESTADO,START		;ACTIVATE A FLAG START
					ldi vari,0xFF			;CLEANS EIFR
					out EIFR,vari			;cLEANS EIFR
					
					sbr vari,0b00000001			;Deactivates INT0
					out EIMSK,vari
					cbr vari,0b00000011			;Activates INT1
					out EIMSK,vari
					pop vari			;retrieve records	
					out SREG,vari		        ;retrieve records
					pop vari			;retrieve records
					reti
					
		INT_int1:		
					push vari			;save records
					in vari, SREG		        ;save records
					push vari			;save records
					
					ldi STATE,STOP		;ACTIVATE STOP FLAG
					ldi vari,0xFF			;CLEANS EIFR
					out EIFR,vari			;CLEANS EIFR
					
					sbr vari,0b00000011			;Deactivate INT1
					out EIMSK,vari
					cbr vari,0b00000001			;Activate INT0
					out EIMSK,vari
					pop vari			;save records	
					out SREG,vari		;save records
					pop vari			;save records
					reti	
		int_tc0:						//500ms pass 
				push r17
		decv:		dec cont_1s		;check if 500ms have passed
					cpi cont_1s,0
					brne decv
					ldi cont_1s,250  ;reloads the interrupt counter
					set	
				pop r17	
					reti
						
		





		display:
					nine_:	    
								cpi  r16, 9
								brne eight_
								ldi  r17, NINE
								jmp  exit
					eight_:
								cpi  r16, 8
								brne seven_
								ldi  r17, EIGHT
								jmp  exit
					seven_:
								cpi  r16, 7
								brne six_
								ldi  r17, SEVEN
								jmp  exit
					six_:
					 			cpi  r16, 6
								brne five_
								ldi  r17, SIX
								jmp  exit
					five_:
								cpi  r16, 5
								brne four_
								ldi  r17, FIVE
								jmp  exit
					four_:
								cpi  r16, 4
								brne three_
								ldi  r17, FOUR
								jmp  exit
					three_:
								cpi  r16, 3
								brne two_
								ldi  r17, THREE
								jmp  exit
					two_:
								cpi  r16, 2
								brne one_
								ldi  r17, TWO
								jmp  exit
					one_:
								cpi  r16, 1
								brne zero_
								ldi  r17, ONE
								jmp  exit
					zero_:
								cpi  r16, 0
								brne exit
								ldi  r17, ZERO
								jmp  exit

					exit:
								out PORTC,	r17
								ret
