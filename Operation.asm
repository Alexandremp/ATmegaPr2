		
		.def CONTL = r24
		.def CONTH = r25
		.def vari = r17
		.def seg=	r16
		.def cont_1s = r20				;cont_1s =r20
		.def ESTADO = r18
		.equ ZERO=0xC0
		.equ UM=0xF9
		.equ DOIS=0xA4
		.equ TRES=0xB0
		.equ QUATRO=0x99
		.equ CINCO=0x92
		.equ SEIS=0x82
		.equ SETE=0xF8
		.equ OITO=0x80
		.equ NOVE=0x90

		.equ START=0
		.equ RUNNING=1
		.equ STOP=2
		.cseg
		
		.org 0x00
			jmp main

		.org 0x02       ;quando clicas no sw1
			jmp INT_int0
		
		.org 0x04		;quando clicas no sw2	
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
					cpi ESTADO, START	// Flag start on?
					brne FlagStopON
					
		FlagStartON:	ldi seg,9			//SEG=9
						ldi cont_1s,100		//count_1s=500
						ldi ESTADO,RUNNING
						set				//LIMPAR A FLAG
						call display		//Display


		FlagStopON:		cpi ESTADO, STOP	//Flag stop on?
						brne Flag_1sON		

		Pisca_ponto: ldi vari,0b11111110
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
		Pisca_display:	 
						out PORTC,vari
						;delay2
						call display
						dec r22
						cpi r22,0
						brne Pisca_display
						jmp FlagStartON
					
		
		INT_int0:
					push vari			;guardar registos
					in vari, SREG		;guardar registos
					push vari			;guardar registos
					
					ldi ESTADO,START		;ATIVA A FLAG START
					ldi vari,0xFF			;LIMPA EIFR
					out EIFR,vari			;LIMPA EIFR
					
					sbr vari,0b00000001			;Desativar INT0
					out EIMSK,vari
					cbr vari,0b00000011			;Ativar INT1
					out EIMSK,vari
					pop vari			;recupera registos	
					out SREG,vari		;recupera registos
					pop vari			;recupera registos
					reti
					
		INT_int1:		
					push vari			;guardar registos
					in vari, SREG		;guardar registos
					push vari			;guardar registos
					
					ldi ESTADO,STOP		;ATIVA A FLAG STOP
					ldi vari,0xFF			;LIMPA EIFR
					out EIFR,vari			;LIMPA EIFR
					
					sbr vari,0b00000011			;Desativar INT1
					out EIMSK,vari
					cbr vari,0b00000001			;Ativar INT0
					out EIMSK,vari
					pop vari			;recupera registos	
					out SREG,vari		;recupera registos
					pop vari			;recupera registos
					reti	
		int_tc0:						//passam 500ms 
				push r17
		decv:		dec cont_1s		;verifica se passaram 500ms
					cpi cont_1s,0
					brne decv
					ldi cont_1s,250  ;recarrega o contador de interrupções
					set	
				pop r17	
					reti
						
		





		display:
					nove_:	    
								cpi  r16, 9
								brne oito_
								ldi  r17, NOVE
								jmp  saida
					oito_:
								cpi  r16, 8
								brne sete_
								ldi  r17, OITO
								jmp  saida
					sete_:
								cpi  r16, 7
								brne seis_
								ldi  r17, SETE
								jmp  saida
					seis_:
					 			cpi  r16, 6
								brne cinco_
								ldi  r17, SEIS
								jmp  saida
					cinco_:
								cpi  r16, 5
								brne quatro_
								ldi  r17, CINCO
								jmp  saida
					quatro_:
								cpi  r16, 4
								brne tres_
								ldi  r17, QUATRO
								jmp  saida
					tres_:
								cpi  r16, 3
								brne dois_
								ldi  r17, TRES
								jmp  saida
					dois_:
								cpi  r16, 2
								brne um_
								ldi  r17, DOIS
								jmp  saida
					um_:
								cpi  r16, 1
								brne zero_
								ldi  r17, UM
								jmp  saida
					zero_:
								cpi  r16, 0
								brne saida
								ldi  r17, ZERO
								jmp  saida

					saida:
								out PORTC,	r17
								ret
