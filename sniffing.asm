;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;																										 ;
; RF Secure Channel Eveasdropping Using 8051 														     ;
; 																										 ;
; Authors : Mohamed Rashad - Asmaa Nasrallah - Nabila Hosny	- Yara Mohsen								 ;
;																										 ;
; Sniffing Module (Eve) :																				 ;
; RF -> UART -> Decrypt -> UART -> USB -> GUI 															 ;
;																										 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ORG 000

main : 					
    CLR SM0				; Clear Serial Mode Zero
	SETB SM1			; Set Serial Mode One (8-bit data, 1 stop bit, 1 start bit)
	SETB REN			; Reception enable bit
	MOV A, PCON			; move PCON to ACC for edit
	SETB ACC.7			; Set mode to double UART baud rate
	MOV PCON, A			; Put value in PCON

	MOV TMOD, #20H		; Timer mode 2 (8-bit auto reload)
	MOV TH1, #243		; Set Baud Rate 
	MOV TL1, #243		; Set Baud Rate
	SETB TR1			; Start Timer 1
    MOV R1, #30H		; Store 30 Hex in R1 
		
again:
	JNB RI, $			; Wait till receiving byte ends
	CLR RI				; Clear RI to indicate success of transmission
	MOV A, SBUF			; -> Read from RF to 8051
brute :
	MOV R2 , #00H		; Brute Force Initiate 
    SUBB A,R2			; -> Decryption via shift cipher
    MOV SBUF, A			; -> Send from 8051 to PC
    INC R2				; Try Again
	CJNE R2,#1AH, brute ; Check for carriage return    
	CJNE A, #0DH, skip 	; Check for carriage return
	JMP finish			; Finish
	
skip:
	MOV @R1, A			; Move R1 to A
	INC R1				; Increment R1
	JMP again			; Jump Back to UART Label 
	
finish:					
	JMP $ 				; Stay Here Forever

