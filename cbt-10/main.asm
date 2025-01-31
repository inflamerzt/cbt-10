.include "m88PAdef.inc"

.equ	A	= 24			; объем массива (в словах по 2байта, значения от 2 до 120)
.equ	B	= 80			; порог для ускорения счета
.equ	C	= 615			; K для счетчика ((кол.сек для накопления имп.,кол.которых равно фону в мкр/ч)*100)

.DSEG
Timeout_high:	.byte	1
Timeout_low:	.byte	1
Counter_high:	.byte	1
Counter_low:	.byte	1
Time_syper_high:.byte	1
Time_high:		.byte	1
Time_low:		.byte	1
Time2000_high:	.byte	1
Time2000_low:	.byte	1
SECUNDS:		.byte	1
MINUTES:		.byte	1
HOURS:			.byte	1
Anim_high:		.byte	1
Anim_low:		.byte	1
Anim:			.byte	1

Alfa_Low:		.byte	1
Alfa_High:		.byte	1
Alfa_syper_High:.byte	1
Beta_Low:		.byte	1
Beta_High:		.byte	1
Beta_syper_High:.byte	1
Gama_Low:		.byte	1
Gama_High:		.byte	1
Gama_syper_High:.byte	1

Battery_Low:	.byte	1
Battery_High:	.byte	1

Uroven_Zvuka:	.byte	1
Schetchik_Zvuka:.byte	1
Uroven_Zv_Buf:	.byte	1
Uroven_Zvuka_N:	.byte	1

Timer_K:		.byte	1

Porog_K:		.byte	1

Podsvetka_K:	.byte	1

Zvuk_Opov_K:	.byte	1


Ax:				.byte	1
Bx:				.byte	1
Cx_low:			.byte	1
Cx_high:		.byte	1

Do_r26:			.byte	1
Do_r27:			.byte	1
Do_r28:			.byte	1
Do_r29:			.byte	1
Now_r26:		.byte	1
Now_r27:		.byte	1
Now_r28:		.byte	1
Now_r29:		.byte	1
RAID:			.byte	250
MetkaRAID:		.byte	1


NOP_byte:		.byte	1


.CSEG
.ORG $0000
	rjmp	reset

.ORG $0002		; INT1 External Interrupt Request 1
	rjmp	INT_Shelchok

.ORG $0003		; PCINT0 Handler
	reti

.ORG $0004		; PCINT1 Handler
	reti

.ORG $000C		; TIMER1_COMPB Timer/Counter1 Compare Match B
	rjmp	Dergati_IRF840

INT_Shelchok:
	set							; установить флаг T
	in		r3, SREG
	adiw	r26, 1
	breq	adiw_high_bytes
	out		SREG, r3
	reti
adiw_high_bytes:
	adiw	r28, 1
	out		SREG, r3
	reti

;---------------------------------------------------------------

Dergati_IRF840:
	reti
	push	r23
	push	r24
	push	r25
	in		r23, SREG

	lds		r24, Counter_low
	lds		r25, Counter_high

	sbic 	PORTD, DDD1			; пропустить, если на COPе ноль
	rjmp	zakritie_IRF840

	sbiw	r24, 1
	brne	end_IRF840

	sbi		PORTD, DDD0			; подтяжка DIOD
	rcall	pause_20mksec
	sbi		PORTD, DDD1			; подтяжка COP
	lds		r24, Timeout_low
	lds		r25, Timeout_high
	rjmp	end_IRF840
zakritie_IRF840:
	cbi		PORTD,DDD0			; к земле DIOD
	cbi		PORTD,DDD1			; к земле COP
	sbi		PORTD,DDD2			; подтяжка VT
	rcall	pause_20mksec
	sbic 	PINC, PINC5			; пропустить, если на OOC ноль
	rjmp	ne_delenie_K_na_2
	cpi		r24, 20
	cpc		r25, r0
	brlo	delenie_K_na_2
	lsr		r25
	ror		r24
	rjmp	delenie_K_na_2
ne_delenie_K_na_2:
	sbrc	r25, 3
	rjmp	delenie_K_na_2
	lsl		r24
	rol		r25
delenie_K_na_2:
	sts		Timeout_low, r24
	sts		Timeout_high, r25
	cbi		PORTD,DDD2			; к земле VT
end_IRF840:
	sts		Counter_low, r24
	sts		Counter_high, r25

	lds		r24, Time2000_low
	lds		r25, Time2000_high
	sbiw	r24, 1
	breq	plus_1sec
	rjmp	ne_plus_1sec
plus_1sec:

	ldi		r24, 0b11000000
	or		r1, r24

	lds		r24, Now_r26
	lds		r25, Now_r27
	sts		Do_r26, r24
	sts		Do_r27, r25
	lds		r24, Now_r28
	lds		r25, Now_r29
	sts		Do_r28, r24
	sts		Do_r29, r25
	sts		Now_r26, r26
	sts		Now_r27, r27
	sts		Now_r28, r28
	sts		Now_r29, r29

	lds		r24, SECUNDS
	inc		r24
	cpi		r24, 60
	brlo	ne_sbros_sec
	clr		r24
	sts		SECUNDS, r24
	lds		r24, MINUTES
	inc		r24
	cpi		r24, 60
	brlo	ne_sbros_min
	clr		r24
	sts		MINUTES, r24
	lds		r24, HOURS
	inc		r24
	cpi		r24, 100
	brlo	ne_sbros_hour
	ldi		r24, 0b00000100
	mov		r1, r24
	ldi		r24, 59
	sts		SECUNDS, r24
	sts		MINUTES, r24
	ldi		r24, 99
ne_sbros_hour:
	sts		HOURS, r24
	rjmp	prig_sbros
ne_sbros_min:
	sts		MINUTES, r24
	rjmp	prig_sbros
ne_sbros_sec:
	sts		SECUNDS, r24
prig_sbros:

	lds		r24, Time_low
	lds		r25, Time_high
	adiw	r24, 1
	brne	ne_adiw_high_byte
	sts		Time_low, r24
	sts		Time_high, r25
	lds		r24, Time_syper_high
	inc		r24
	sts		Time_syper_high, r24
	rjmp	adiw_high_byte
ne_adiw_high_byte:
	sts		Time_low, r24
	sts		Time_high, r25
adiw_high_byte:
	ldi		r24, low(2000)
	ldi		r25, high(2000)
ne_plus_1sec:
	sts		Time2000_low, r24
	sts		Time2000_high, r25

	lds		r24, Schetchik_Zvuka
	dec		r24
	brne	ne_Shelchok
	brbc	6, ne_Shelchok
	ldi		r24, 0b10000000
	or		r1, r24
	andi	r23, 0b10111111		; сбросить флаг Т
	lds		r24, Uroven_Zvuka
	sts		Schetchik_Zvuka, r24
ne_Shelchok:
	lds		r24, Schetchik_Zvuka
	dec		r24
	breq	ne_Pisk
	sts		Schetchik_Zvuka, r24
	sbic 	PORTB, DDB7
	rjmp	pisk_inv
	sbi		PORTB, DDB7			; подтяжка PISK1
	cbi		PORTB, DDB6			; к земле PISK2
	rjmp	ne_Pisk
pisk_inv:
	sbi		PORTB, DDB6			; подтяжка PISK2
	cbi		PORTB, DDB7			; к земле PISK1
ne_Pisk:

	lds		r24, Anim_low
	lds		r25, Anim_high

	sbiw	r24, 1
	brne	ne_time_Anim
	ldi		r24, low(500)
	ldi		r25, high(500)
	sts		Anim_low, r24
	sts		Anim_high, r25
	ldi		r24, 0b00100000
	or		r1, r24
	rjmp	prig_Anim
ne_time_Anim:
	sts		Anim_low, r24
	sts		Anim_high, r25
prig_Anim:

	out		SREG, r23
	pop		r25
	pop		r24
	pop		r23
	reti

;--------------------начало----------------------

reset:
	ldi		r24, low(RAMEND)
	out		SPL, r24
	ldi		r24, high(RAMEND)
	out		SPH, r24

	ldi		r24, 0b10000000
	ldi		r25, 0b00000011		; Clock Division Factor = 8	F = 1 MHz
	sts		CLKPR, r24
	sts		CLKPR, r25

	clr		r0					; служебный ноль
	ldi		r24, 0b11001000
	mov		r1, r24				; флаги

;	r26, r27, r28, r29 и r3 - зарезервированы, не трогать вообще!

;--------------------настройка портов----------------------

	ldi		r24, 0b11101100
	out		DDRB, r24
	ldi		r24, 0b10100111
	out		DDRD, r24

;	sbi		DDRD, DDD5			; выход LED
	ldi		r24, 0
;	out		OCR0A, r24
	out		OCR0B, r24
	ldi		r24, 0b00100011
	out		TCCR0A, r24
	ldi		r24, 0b00000001
	out		TCCR0B, r24

	sbi		DDRC, DDC4			; выход ZARIAD
	cbi		PORTC,DDC4			; к земле ZARIAD
;	sbi		DDRD, DDD0			; выход DIOD
;	sbi		DDRD, DDD1			; выход COP
;	sbi		DDRD, DDD2			; выход VT

;	sbi		DDRB, DDB7			; выход PISK1
;	sbi		DDRB, DDB6			; выход PISK2

;	sbi		DDRD, DDD7			; выход RES
;	sbi		DDRB, DDB5			; выход CLK
;	sbi		DDRB, DDB3			; выход DO
;	sbi		DDRB, DDB2			; так нужно

;--------------------------инит всего--------------------------------

	ldi		r25, 0
	rcall	EEPROM_Read
	cpi		r24, 124
	brne	EEPROM_error

	ldi		r30, low(Cx_high+1)
	ldi		r31, high(Cx_high+1)
	ldi		r25, 11
cikl_EEPROM_Read:
	rcall	EEPROM_Read
	st		-Z, r24
	dec		r25
	brne	cikl_EEPROM_Read
	rjmp	EEPROM_OK

EEPROM_error:
	ldi		r24, 20
	sts		Timer_K, r24

	ldi		r24, 5
	sts		Porog_K, r24

	ldi		r24, 15
	sts		Podsvetka_K, r24

	ldi		r24, 0
	sts		Zvuk_Opov_K, r24

	ldi		r24, A
	sts		Ax, r24
	ldi		r24, B
	sts		Bx, r24
	ldi		r24, low(C)
	ldi		r25, high(C)
	sts		Cx_low, r24
	sts		Cx_high, r25

	ldi		r24, 3
	sts		Uroven_Zvuka_N, r24

EEPROM_OK:
	ldi		r24, 5
	sts		Uroven_Zvuka, r24
	sts		Uroven_Zv_Buf, r24

	rcall	Global_Obnulenie

	ldi		r24, low(320)
	ldi		r25, high(320)
	rcall	Timeout_zapis

	rcall	SPI_init
	rcall	LCD_init
	rcall	timer_init
	rcall	INT_init
	sei

;---------------------------анимация-------------------------

	ldi		r18, 100
	rcall	shym
	sbic 	PINB, PINB4			; зарядка
	rjmp	Zaryadka_start
	ldi		r18, 250
	rcall	shym
	ldi		r18, 20
	rcall	ZASTAVKA

	rcall	Nastroiki

	rcall	Zabelenie
	sbic 	PINB, PINB4			; зарядка
	rjmp	Zaryadka
	ldi		r30, low(Batter*2)
	ldi		r31, high(Batter*2)
	ldi		r19, 0
	ldi		r20, 0
	rcall	IMAGE
start_nachalo:
	rcall	Alfa_Zabelenie
	rcall	Timer_IMG
	ldi		r30, low(CPS*2)
	ldi		r31, high(CPS*2)
	ldi		r19, 81
	ldi		r20, 4
	rcall	IMAGE
	ldi		r30, low(MkrH*2)
	ldi		r31, high(MkrH*2)
	ldi		r19, 71
	ldi		r20, 7
	rcall	IMAGE
	ldi		r30, low(RAD_0*2)
	ldi		r31, high(RAD_0*2)
	ldi		r19, 0				; X
	ldi		r20, 2				; Y
	rcall	IMAGE_Z
	rcall	PLAV_IMG

;---------------------------поехали!-------------------------

here:

	sbic 	PINB, PINB4			; зарядка
	rjmp	Zaryadka

	sbrs	r1, 5
	rjmp	ne_obnovlenie_Anim
	ldi		r24, 0b11011111
	and		r1, r24

	lds		r24, Anim
	sbrc	r1, 4
	rjmp	veseliy_rodger

	cpi		r24, 0
	brne	ne_RAD_0
ne_RAD_3:
	ldi		r30, low(RAD_0*2)
	ldi		r31, high(RAD_0*2)
	ldi		r24, 1
	rjmp	go_Anim
ne_RAD_0:
	cpi		r24, 1
	brne	ne_RAD_1
	ldi		r30, low(RAD_1*2)
	ldi		r31, high(RAD_1*2)
	ldi		r24, 2
	rjmp	go_Anim
ne_RAD_1:
	cpi		r24, 2
	brne	ne_RAD_2
	ldi		r30, low(RAD_2*2)
	ldi		r31, high(RAD_2*2)
	ldi		r24, 3
	rjmp	go_Anim
ne_RAD_2:
	cpi		r24, 3
	brne	ne_RAD_3
	ldi		r30, low(RAD_3*2)
	ldi		r31, high(RAD_3*2)
	ldi		r24, 0
	rjmp	go_Anim

veseliy_rodger:

	lds		r23, Zvuk_Opov_K
	sbrc	r23, 0
	sts		Schetchik_Zvuka, r0

	cpi		r24, 0
	brne	ne_RODGER
ne_RODGER_inv:
	ldi		r30, low(RODGER*2)
	ldi		r31, high(RODGER*2)
	ldi		r24, 1
	rjmp	go_Anim
ne_RODGER:
	cpi		r24, 1
	brne	ne_RODGER_inv
	ldi		r30, low(RODGER_inv*2)
	ldi		r31, high(RODGER_inv*2)
	ldi		r24, 0

go_Anim:
	sts		Anim, r24
	ldi		r19, 0				; X
	ldi		r20, 2				; Y
	rcall	IMAGE_Z

ne_obnovlenie_Anim:

	sbrs	r1, 6
	rjmp	ne_obnovlenie_time
	ldi		r24, 0b10111111
	and		r1, r24

	sbrc	r1, 2
	rjmp	ne_Regim_Nakopleniy

	sbrs	r1, 3
	rjmp	Regim_Nakopleniy

	cli
	lds		r16, Now_r26
	lds		r17, Now_r27
	lds		r18, Now_r28
	lds		r19, Now_r29
	lds		r20, Do_r26
	lds		r21, Do_r27
	lds		r22, Do_r28
	lds		r23, Do_r29
	sei
	sub		r16, r20
	sbc		r17, r21
	sbc		r18, r22
	sbc		r19, r23

	lds		r24, MetkaRAID
	inc		r24
	lds		r30, Ax
	cp		r24, r30
	brlo	ne_sbros_metki
	ldi		r24, 0
ne_sbros_metki:
	sts		MetkaRAID, r24
	lsl		r24
	ldi		r30, low(RAID)
	ldi		r31, high(RAID)
	add		r30, r24
	adc		r31, r0
	st		Z+, r16
	st		Z+, r17

	clr		r8
	clr		r9
	clr		r10
	clr		r11
	lds		r23, Ax
	ldi		r24, 0
cikl_usredneniy:
	inc		r24
	ld		r17, -Z
	ld		r16, -Z
	add		r8, r16
	adc		r9, r17
	adc		r10, r0
	lds		r16, Bx
	cp		r8, r16
	cpc		r9, r0
	cpc		r10, r0
	brsh	bolshe_Bx_cp
	cpi		r30, low(RAID)
	ldi		r16, high(RAID)
	cpc		r31, r16
	brsh	ne_sbros_RAID
	lds		r18, Ax
	lsl		r18
	ldi		r30, low(RAID)
	ldi		r31, high(RAID)
	add		r30, r18
	adc		r31, r0
ne_sbros_RAID:
	dec		r23
	brne	cikl_usredneniy
bolshe_Bx_cp:
	push	r24
;	ldi		r24, low(Cx)
;	ldi		r25, high(Cx)
;	mov		r12, r24
;	mov		r13, r25
	lds		r12, Cx_low
	lds		r13, Cx_high
	clr		r14
	clr		r15
;	r8 - Low1	множитель1 / ответ
;	r9 - Low2	множитель1 / ответ
;	r10 - High1	множитель1 / ответ
;	r11 - High2	множитель1 / ответ
;	r12 - Low1	множитель2 / ответ
;	r13 - Low2	множитель2 / ответ
;	r14 - High1	множитель2 / ответ
;	r15 - High2	множитель2 / ответ
	rcall	ymnogenie
	pop		r4
	clr		r5
	clr		r6
	clr		r7
;	r4 - Low1	делитель
;	r5 - Low2	делитель
;	r6 - High1	делитель
;	r7 - High2	делитель
;	r8 - Low1	делимое / ответ
;	r9 - Low2	делимое / ответ
;	r10 - High1	делимое / ответ
;	r11 - High2	делимое / ответ
;	r12 - Low3	делимое / ответ
;	r13 - Low4	делимое / ответ
;	r14 - High3	делимое / ответ
;	r15 - High4	делимое / ответ
	rcall	delenie
	mov		r16, r8
	mov		r17, r9
	mov		r18, r10

	rcall	Proverka_vihoda_za_3byta

	rcall	proveka_Poroga

;	r16 - младший байт
;	r17 - средний байт
;	r18 - старший байт
;	r19 - X
;	r20 - Y
;	r21 - запятая
	ldi		r19, 10				; X
	ldi		r20, 6				; Y
	ldi		r21, 5				; запятая
	rcall	chislo_XXXXXXX

	ldi		r24, low(1000)
	ldi		r25, high(1000)
	mov		r12, r24
	mov		r13, r25
	clr		r14
	clr		r15
;	r8 - Low1	множитель1 / ответ
;	r9 - Low2	множитель1 / ответ
;	r10 - High1	множитель1 / ответ
;	r11 - High2	множитель1 / ответ
;	r12 - Low1	множитель2 / ответ
;	r13 - Low2	множитель2 / ответ
;	r14 - High1	множитель2 / ответ
;	r15 - High2	множитель2 / ответ
	rcall	ymnogenie
;	ldi		r24, low(Cx)
;	ldi		r25, high(Cx)
;	mov		r4, r24
;	mov		r5, r25
	lds		r4, Cx_low
	lds		r5, Cx_high
	clr		r6
	clr		r7
;	r4 - Low1	делитель
;	r5 - Low2	делитель
;	r6 - High1	делитель
;	r7 - High2	делитель
;	r8 - Low1	делимое / ответ
;	r9 - Low2	делимое / ответ
;	r10 - High1	делимое / ответ
;	r11 - High2	делимое / ответ
;	r12 - Low3	делимое / ответ
;	r13 - Low4	делимое / ответ
;	r14 - High3	делимое / ответ
;	r15 - High4	делимое / ответ
	rcall	delenie
	mov		r16, r8
	mov		r17, r9
	mov		r18, r10
	rcall	Proverka_vihoda_za_3byta
;	r16 - младший байт
;	r17 - средний байт
;	r18 - старший байт
;	r19 - X
;	r20 - Y
;	r21 - запятая
	ldi		r19, 20				; X
	ldi		r20, 3				; Y
	ldi		r21, 4				; запятая
	rcall	chislo_XXXXXXX
	rjmp	ne_Regim_Nakopleniy

Regim_Nakopleniy:

	rcall	HourMinSec_mer

ne_Regim_Nakopleniy:

	rcall	Battery_mer
	rcall	Toko_mer

ne_obnovlenie_time:

	sbrc	r1, 2
	rjmp	ne_obnovlenie_CPS_mkR

	sbrs	r1, 7
	rjmp	ne_obnovlenie_CPS_mkR
	ldi		r24, 0b01111111
	and		r1, r24

	sbrc	r1, 3
	rjmp	ne_obnovlenie_CPS_mkR

	ldi		r21, 0x40
	ldi		r22, 0x42
	ldi		r23, 0x0F
	rcall	Podschet_CPX
;	r16 - младший байт
;	r17 - средний байт
;	r18 - старший байт
;	r19 - X
;	r20 - Y
;	r21 - запятая
	ldi		r19, 20				; X
	ldi		r20, 3				; Y
	ldi		r21, 4				; запятая
	rcall	chislo_XXXXXXX

	lds		r8, Cx_low
	lds		r9, Cx_high
	clr		r10
	clr		r11
;	r8 - Low1	множитель1 / ответ
;	r9 - Low2	множитель1 / ответ
;	r10 - High1	множитель1 / ответ
;	r11 - High2	множитель1 / ответ
	ldi		r24, low(1000)
	ldi		r25, high(1000)
	mov		r12, r24
	mov		r13, r25
	clr		r14
	clr		r15
;	r12 - Low1	множитель2 / ответ
;	r13 - Low2	множитель2 / ответ
;	r14 - High1	множитель2 / ответ
;	r15 - High2	множитель2 / ответ
	rcall	ymnogenie
	mov		r21, r8
	mov		r22, r9
	mov		r23, r10
;	ldi		r21, D3x
;	ldi		r22, D2x
;	ldi		r23, D1x
	rcall	Podschet_CPX

	rcall	Proverka_vihoda_za_3byta

	rcall	proveka_Poroga
;	r16 - младший байт
;	r17 - средний байт
;	r18 - старший байт
;	r19 - X
;	r20 - Y
;	r21 - запятая
	ldi		r19, 10				; X
	ldi		r20, 6				; Y
	ldi		r21, 5				; запятая
	rcall	chislo_XXXXXXX

ne_obnovlenie_CPS_mkR:


	sbic 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_ne_nagata
	ldi		r24, 101
knopka_2_nagata:
	dec		r24
	brne	ne_LED
	in		r24, DDRD
	sbrs	r24, 5
	rjmp	vkl_LED
	cbi		DDRD, DDD5			; вход LED
	cbi		PORTD,DDD6			; к земле LED_DIOD
	rjmp	prig_LED
vkl_LED:
	sbi		DDRD, DDD5			; выход LED
	sbi		PORTD,DDD6			; подтяжка LED_DIOD
prig_LED:
	rcall	pause_10ms
	sbis 	PINC, PINC3
	rjmp	prig_LED
	rcall	pause_10ms
	rjmp	knopka_2_ne_nagata
ne_LED:
	rcall	pause_10ms
	sbis 	PINC, PINC3
	rjmp	knopka_2_nagata
	rcall	pause_10ms

	sbrs	r1, 2
	rjmp	perekl_na_STOP2
	ldi		r24, 0b11111011
	and		r1, r24
	ldi		r24, 0b01000000
	or		r1, r24
	ldi		r30, low(PLAV*2)
	ldi		r31, high(PLAV*2)
	sbrs	r1, 3
	ldi		r30, low(SUMMA*2)
	sbrs	r1, 3
	ldi		r31, high(SUMMA*2)
	ldi		r19, 82
	ldi		r20, 0
	rcall	IMAGE_Z
	rcall	Global_Obnulenie
	rcall	HourMinSec_mer
	rjmp	knopka_1_ne_nagata

perekl_na_STOP2:
	lds		r24, Uroven_Zv_Buf
	sts		Uroven_Zvuka, r24
	ldi		r24, 0b11101111
	and		r1, r24
	ldi		r24, 0b00000100
	or		r1, r24
	rcall	PAUSA_IMG

knopka_2_ne_nagata:


	sbic 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_ne_nagata
	ldi		r24, 101
knopka_1_nagata:
	dec		r24
	breq	GO_Sleep
	rcall	pause_10ms
	sbis 	PINC, PINC2
	rjmp	knopka_1_nagata
	rcall	pause_10ms

	rcall	Global_Obnulenie

	sbrc	r1, 3
	rjmp	perekl_na_regim_Nakopleniy
	sbrs	r1, 1
	rjmp	Alfaizmerenie
	ldi		r24, 0b11001000
	mov		r1, r24
	rcall	PLAV_IMG
	rjmp	knopka_1_ne_nagata
perekl_na_regim_Nakopleniy:
	ldi		r24, 0b11000000
	mov		r1, r24
	rcall	SUMMA_IMG
	rjmp	knopka_1_ne_nagata

GO_Sleep:
	sts		TCCR1B, r0
	sts		TIMSK1, r0
	sts		EICRA, r0
	out		EIMSK, r0
	cbi		PORTB,DDB6			; к земле PISK2
	cbi		PORTB,DDB7			; к земле PISK1
	cbi		PORTD,DDD0			; к земле DIOD
	cbi		PORTD,DDD1			; к земле COP
	sbi		PORTD,DDD2			; подтяжка VT
	rcall	pause_20mksec
	rcall	pause_20mksec
	cbi		PORTD,DDD2			; к земле VT
	ldi		r24, 0xE2
	rcall	SPI_Write_CMD
	out		TCCR0B, r0
	cbi		DDRD, DDD5			; вход LED
	cbi		PORTD,DDD6			; к земле LED_DIOD
	cbi		DDRD, DDD6			; вход LED_DIOD

	ldi		r25, 0
	ldi		r24, 124
	rcall	EEPROM_Write

	ldi		r30, low(Cx_high+1)
	ldi		r31, high(Cx_high+1)
	ldi		r25, 11
cikl_EEPROM_Write:
	ld		r24, -Z
	rcall	EEPROM_Write
	dec		r25
	brne	cikl_EEPROM_Write

knopka_1_nagata_sleep:
	rcall	pause_10ms
	sbis 	PINC, PINC2
	rjmp	knopka_1_nagata_sleep
	rcall	pause_10ms

	ldi		r24, 0b00000101		; Sleep Enable / Power-down
	out		SMCR, r24
	ldi		r24, 0b00000011		; PCIE1..0 PCINT14..0
	sts		PCICR, r24
	ldi		r24, 0b00000100		; PCINT10 Pin Change Enable Mask
	sts		PCMSK1, r24
	ldi		r24, 0b00010000		; PCINT4 Pin Change Enable Mask
	sts		PCMSK0, r24
	sleep
	nop
	out		SMCR, r0
	sts		PCICR, r0
	sts		PCMSK1, r0
	nop
	cli
	rjmp	reset

knopka_1_ne_nagata:

	rjmp	here

;--------------------------Альфа измерение------------------------

Alfaizmerenie:
	rcall	Alfa_Zabelenie
	rcall	Timer_IMG
	ldi		r30, low(CPS*2)
	ldi		r31, high(CPS*2)
	ldi		r19, 82
	ldi		r20, 3
	rcall	IMAGE
	ldi		r30, low(Summa_ravno*2)
	ldi		r31, high(Summa_ravno*2)
	ldi		r19, 0
	ldi		r20, 2
	rcall	IMAGE
	rcall	SUMMA_IMG

	lds		r24, Uroven_Zv_Buf
	sts		Uroven_Zvuka, r24

	ldi		r24, 0b11000001
	mov		r1, r24

shere:

	sbic 	PINB, PINB4			; зарядка
	rjmp	Zaryadka

	sbrs	r1, 6
	rjmp	ne_obnovlenie_time_Alfa
	ldi		r24, 0b10111111
	and		r1, r24

	rcall	Battery_mer
	rcall	Toko_mer

	sbrc	r1, 1
	rjmp	ne_obnovlenie_time_Alfa

	rcall	HourMinSec_mer

ne_obnovlenie_time_Alfa:

	sbrc	r1, 1
	rjmp	ne_obnovlenie_CPS_mkR_Alfa

	sbrs	r1, 7
	rjmp	ne_obnovlenie_CPS_mkR_Alfa
	ldi		r24, 0b01111111
	and		r1, r24

	ldi		r21, 0x40
	ldi		r22, 0x42
	ldi		r23, 0x0F
	rcall	Podschet_CPX
;	r16 - младший байт
;	r17 - средний байт
;	r18 - старший байт
;	r19 - X
;	r20 - Y
;	r21 - запятая

	sbrs	r1, 0
	rjmp	ne_etap_1

	sts		Alfa_Low, r16
	sts		Alfa_High, r17
	sts		Alfa_syper_High, r18
	ldi		r19, 20				; X
	ldi		r20, 2				; Y
	ldi		r21, 4				; запятая
	rcall	chislo_XXXXXXX
	rjmp	ne_obnovlenie_CPS_mkR_Alfa

ne_etap_1:

	sbrs	r1, 3
	rjmp	ne_etap_2

	sts		Beta_Low, r16
	sts		Beta_High, r17
	sts		Beta_syper_High, r18
	ldi		r19, 20				; X
	ldi		r20, 4				; Y
	ldi		r21, 4				; запятая
	rcall	chislo_XXXXXXX
	lds		r16, Alfa_Low
	lds		r17, Alfa_High
	lds		r18, Alfa_syper_High
	lds		r19, Beta_Low
	lds		r20, Beta_High
	lds		r21, Beta_syper_High
	sub		r16, r19
	sbc		r17, r20
	sbc		r18, r21
	brsh	ne_fatal_menshe
	clr		r16
	clr		r17
	clr		r18
ne_fatal_menshe:
	ldi		r19, 20				; X
	ldi		r20, 2				; Y
	ldi		r21, 4				; запятая
	rcall	chislo_XXXXXXX
	rjmp	ne_obnovlenie_CPS_mkR_Alfa

ne_etap_2:

	sts		Gama_Low, r16
	sts		Gama_High, r17
	sts		Gama_syper_High, r18
	ldi		r19, 20				; X
	ldi		r20, 6				; Y
	ldi		r21, 4				; запятая
	rcall	chislo_XXXXXXX
	lds		r16, Beta_Low
	lds		r17, Beta_High
	lds		r18, Beta_syper_High
	lds		r19, Gama_Low
	lds		r20, Gama_High
	lds		r21, Gama_syper_High
	sub		r16, r19
	sbc		r17, r20
	sbc		r18, r21
	brsh	ne_fatal_menshe_2
	clr		r16
	clr		r17
	clr		r18
ne_fatal_menshe_2:
	ldi		r19, 20				; X
	ldi		r20, 4				; Y
	ldi		r21, 4				; запятая
	rcall	chislo_XXXXXXX

ne_obnovlenie_CPS_mkR_Alfa:

	sbic 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_ne_nagata_Alfa
	ldi		r24, 101
knopka_1_nagata_Alfa:
	dec		r24
	brne	ne_GO_Sleep
	rjmp	GO_Sleep
ne_GO_Sleep:
	rcall	pause_10ms
	sbis 	PINC, PINC2
	rjmp	knopka_1_nagata_Alfa
	rcall	pause_10ms
	ldi		r24, 0b11001000
	mov		r1, r24
	rcall	Global_Obnulenie
	rjmp	start_nachalo

knopka_1_ne_nagata_Alfa:

	sbic 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_ne_nagata_Alfa
	ldi		r24, 101
knopka_2_nagata_Alfa:
	dec		r24
	brne	ne_LED_Alfa
	sbis	DDRD, DDD5
	rjmp	vkl_LED_Alfa
	cbi		DDRD, DDD5			; вход LED
	cbi		PORTD,DDD6			; к земле LED_DIOD
	rjmp	prig_LED_Alfa
vkl_LED_Alfa:
	sbi		DDRD, DDD5			; выход LED
	sbi		PORTD,DDD6			; подтяжка LED_DIOD
prig_LED_Alfa:
	rcall	pause_10ms
	sbis 	PINC, PINC3
	rjmp	prig_LED_Alfa
	rcall	pause_10ms
	rjmp	knopka_2_ne_nagata_Alfa
ne_LED_Alfa:
	rcall	pause_10ms
	sbis 	PINC, PINC3
	rjmp	knopka_2_nagata_Alfa
	rcall	pause_10ms

	sbrs	r1, 1
	rjmp	ne_na_PAUSE
	ldi		r24, 0b11111101
	and		r1, r24

	rcall	SUMMA_IMG
	rjmp	menyem_regim

ne_na_PAUSE:

	sbrs	r1, 2
	rjmp	na_PAUSE
	ldi		r24, 0b00000010
	or		r1, r24

	ldi		r30, low(Result*2)
	ldi		r31, high(Result*2)
	ldi		r19, 23
	ldi		r20, 0
	rcall	IMAGE_Z
	rjmp	knopka_2_ne_nagata_Alfa

na_PAUSE:
	lds		r24, Uroven_Zv_Buf
	sts		Uroven_Zvuka, r24
	ldi		r24, 0b11101111
	and		r1, r24
	ldi		r24, 0b00000010
	or		r1, r24

	rcall	PAUSA_IMG
	rjmp	knopka_2_ne_nagata_Alfa
menyem_regim:

	rcall	Global_Obnulenie

	sbrs	r1, 0
	rjmp	ne_poschet_Alfa
	ldi		r24, 0b11001000
	mov		r1, r24

	ldi		r30, low(CPS*2)
	ldi		r31, high(CPS*2)
	ldi		r19, 82
	ldi		r20, 5
	rcall	IMAGE
	ldi		r30, low(Alfa*2)
	ldi		r31, high(Alfa*2)
	ldi		r19, 0
	ldi		r20, 2
	rcall	IMAGE
	ldi		r30, low(Summa_ravno*2)
	ldi		r31, high(Summa_ravno*2)
	ldi		r19, 0
	ldi		r20, 4
	rcall	IMAGE

	rjmp	knopka_2_ne_nagata_Alfa

ne_poschet_Alfa:

	sbrs	r1, 3
	rjmp	Alfaizmerenie
	ldi		r24, 0b11000100
	mov		r1, r24

	ldi		r30, low(CPS*2)
	ldi		r31, high(CPS*2)
	ldi		r19, 82
	ldi		r20, 7
	rcall	IMAGE
	ldi		r30, low(Beta*2)
	ldi		r31, high(Beta*2)
	ldi		r19, 0
	ldi		r20, 4
	rcall	IMAGE
	ldi		r30, low(Gamma*2)
	ldi		r31, high(Gamma*2)
	ldi		r19, 0
	ldi		r20, 6
	rcall	IMAGE

knopka_2_ne_nagata_Alfa:

	rjmp	shere

;-----------------------------Зарядка------------------------------

Zaryadka:
	ldi		r18, 4
	rcall	shym
Zaryadka_start:
	out		TCCR0B, r0
	cbi		DDRD, DDD5			; вход LED
	cbi		PORTD,DDD6			; к земле LED_DIOD
	sbi		PORTC,DDC4			; подтяжка ZARIAD
	cbi		DDRB, DDB7			; вход PISK1
	cbi		DDRB, DDB6			; вход PISK2
	rcall	Global_Obnulenie
	rcall	Zabelenie
	ldi		r30, low(Batter*2)
	ldi		r31, high(Batter*2)
	ldi		r19, 0
	ldi		r20, 0
	rcall	IMAGE

	ldi		r24, 0b01000000
	mov		r1, r24

Zaryad:
	sbis 	PINB, PINB4			; зарядка
	rjmp	Zaryad_end
	sbrs	r1, 6
	rjmp	Zaryad
	ldi		r24, 0b10111111
	and		r1, r24

	ldi		r24, low(40960)
	ldi		r25, high(40960)
	rcall	Timeout_zapis

	rcall	Battery_mer
	rcall	HourMinSec_mer

	lds		r22, Battery_Low
	lds		r23, Battery_High
	ldi		r24, low(421)
	ldi		r25, high(421)
	cp		r22, r24
	cpc		r23, r25
	brlo	Zaryad

Zaryad_end:
	ldi		r23, 20
	rcall	pause
	cbi		PORTC,DDC4			; к земле ZARIAD
	sbi		DDRB, DDB7			; выход PISK1
	sbi		DDRB, DDB6			; выход PISK2

	rjmp	GO_Sleep

;-----------------------------Установки------------------------------

Nastroiki:
	sbic 	PINC, PINC2			; кнопка 1
	ret

	ldi		r30, low(RC*2)
	ldi		r31, high(RC*2)
	rcall	IMAGE_Z_

	rcall	knopka_1_nagata_end

;------------------RC-генератор------------------

vihod_iz_RC:

	ldi		r30, low(RC*2)
	ldi		r31, high(RC*2)
	rcall	IMAGE_Z_

	rcall	knopka_1_nagata_end

knopka_1_2_ne_nagata_start_RC:
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_start_RC
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_start_RC
	rjmp	knopka_1_2_ne_nagata_start_RC

knopka_1_nagata_start_RC:
	rcall	knopka_1_nagata_end
	rcall	Zabelenie
	lds		r16, Timer_K
	rcall	ppm

knopka_1_2_ne_nagata_RC:
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_RC
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_RC
	rjmp	knopka_1_2_ne_nagata_RC

knopka_1_nagata_RC:
	ldi		r24, 101
knopka_1_nagata_RC_1sec:
	dec		r24
	breq	vihod_iz_RC
	rcall	pause_10ms
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_RC_1sec
	rcall	pause_10ms
	lds		r16, Timer_K
	inc		r16
	rjmp	na_zapis_RC

knopka_2_nagata_RC:
	rcall	knopka_2_nagata_end
	lds		r16, Timer_K
	dec		r16
na_zapis_RC:
	cpi		r16, 255
	brne	RC_ne_men_0
	ldi		r16, 0
RC_ne_men_0:
	cpi		r16, 41
	brne	RC_ne_bol_40
	ldi		r16, 40
RC_ne_bol_40:
	cli
	sts		Timer_K, r16
	rcall	Timer_Konst
	sei
	rcall	ppm
	rjmp	knopka_1_2_ne_nagata_RC

ppm:
	cpi		r16, 20
	brlo	menshe_20
	subi	r16, 20
	rcall	chislo_0X_
	ldi		r30, low(Plus*2)
	ldi		r31, high(Plus*2)
	rjmp	bolshe_20
menshe_20:
	ldi		r24, 20
	sub		r24, r16
	mov		r16, r24
	rcall	chislo_0X_
	ldi		r30, low(Minus*2)
	ldi		r31, high(Minus*2)
bolshe_20:
	ldi		r19, 30
	ldi		r20, 3
	rcall	IMAGE
	ret

knopka_2_nagata_start_RC:
	rcall	knopka_2_nagata_end_ret

;------------------Громкость щелчков------------------

vihod_iz_Grom_Shek:

	ldi		r30, low(Grom_Shek*2)
	ldi		r31, high(Grom_Shek*2)
	rcall	IMAGE_Z_

	rcall	knopka_1_nagata_end

knopka_1_2_ne_nagata_start_Grom_Shek:
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_start_Grom_Shek
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_start_Grom_Shek
	rjmp	knopka_1_2_ne_nagata_start_Grom_Shek

knopka_1_nagata_start_Grom_Shek:
	rcall	knopka_1_nagata_end
;	rcall	Zabelenie

	ldi		r19, 0
	ldi		r20, 4
	ldi		r21, 95
	ldi		r22, 5
	rcall	clear_lcd

	lds		r16, Uroven_Zvuka_N
;	rcall	chislo_0X_
	ldi		r19, 31
	ldi		r20, 5
	rcall	chislo_0X

knopka_1_2_ne_nagata_Grom_Shek:
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Grom_Shek
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_Grom_Shek
	rjmp	knopka_1_2_ne_nagata_Grom_Shek

knopka_1_nagata_Grom_Shek:
	ldi		r24, 101
knopka_1_nagata_Grom_Shek_1sec:
	dec		r24
	breq	vihod_iz_Grom_Shek
	rcall	pause_10ms
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Grom_Shek_1sec
	rcall	pause_10ms
	lds		r24, Uroven_Zvuka_N
	inc		r24
	rjmp	na_zapis__Grom_Shek

knopka_2_nagata_Grom_Shek:
	rcall	knopka_2_nagata_end
	lds		r24, Uroven_Zvuka_N
	dec		r24
na_zapis__Grom_Shek:
	cpi		r24, 255
	brne	Uroven_Zvuka_N_ne_men_0
	ldi		r24, 0
Uroven_Zvuka_N_ne_men_0:
	cpi		r24, 10
	brne	Uroven_Zvuka_N_ne_bol_9
	ldi		r24, 9
Uroven_Zvuka_N_ne_bol_9:
	sts		Uroven_Zvuka_N, r24
	ldi		r30, low(UZ_COD*2)
	ldi		r31, high(UZ_COD*2)
	add		r30, r24
	adc		r31, r0
	lpm		r16, Z
	sts		Uroven_Zvuka, r16
	sts		Uroven_Zv_Buf, r16
	mov		r16, r24
;	rcall	chislo_0X_
	ldi		r19, 31
	ldi		r20, 5
	rcall	chislo_0X
	rjmp	knopka_1_2_ne_nagata_Grom_Shek

knopka_2_nagata_start_Grom_Shek:
	rcall	knopka_2_nagata_end_ret

;------------------------ВКЛ/ВЫКЛ звук------------------------------

vihod_iz_Zvuk_Opov:

	rcall	Zabelenie
	ldi		r30, low(Zvuk_Opov*2)
	ldi		r31, high(Zvuk_Opov*2)
	ldi		r19, 20  // Х
	ldi		r20, 4  // Y
	rcall	IMAGE

	rcall	knopka_1_nagata_end

knopka_1_2_ne_nagata_start_Zvuk_Opov:
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_start_Zvuk_Opov
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_start_Zvuk_Opov
	rjmp	knopka_1_2_ne_nagata_start_Zvuk_Opov

knopka_1_nagata_start_Zvuk_Opov:
	rcall	knopka_1_nagata_end
	rcall	Zabelenie
	lds		r16, Zvuk_Opov_K
	rcall	Vkl_Vblkl

knopka_1_2_ne_nagata_Zvuk_Opov:
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Zvuk_Opov
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_Zvuk_Opov
	rjmp	knopka_1_2_ne_nagata_Zvuk_Opov

knopka_1_nagata_Zvuk_Opov:
	rcall	pause_10ms
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Zvuk_Opov
	rcall	pause_10ms
	rjmp	vihod_iz_Zvuk_Opov

knopka_2_nagata_Zvuk_Opov:
	rcall	knopka_2_nagata_end
	lds		r16, Zvuk_Opov_K
	inc		r16
	sts		Zvuk_Opov_K, r16
	rcall	Vkl_Vblkl

	rjmp	knopka_1_2_ne_nagata_Zvuk_Opov

Vkl_Vblkl:
	ldi		r19, 29   //
	ldi		r20, 4   //
	ldi		r21, 37
	ldi		r22, 1
	rcall	clear_lcd
	ldi		r30, low(Vkl*2)
	ldi		r31, high(Vkl*2)
	sbrs	r16, 0
	ldi		r30, low(Vblkl*2)
	sbrs	r16, 0
	ldi		r31, high(Vblkl*2)
	ldi		r19, 30  //
	sbrs	r16, 0
	ldi		r19, 29
	ldi		r20, 4  //
	rcall	IMAGE
	ret

knopka_2_nagata_start_Zvuk_Opov:
	rcall	knopka_2_nagata_end_ret

;------------------------Фоновый порог------------------

vihod_iz_Fon_Porog:

	ldi		r30, low(Fon_Porog*2)
	ldi		r31, high(Fon_Porog*2)
	rcall	IMAGE_Z_

	rcall	knopka_1_nagata_end

knopka_1_2_ne_nagata_start_Fon_Porog:
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_start_Fon_Porog
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_start_Fon_Porog
	rjmp	knopka_1_2_ne_nagata_start_Fon_Porog

knopka_1_nagata_start_Fon_Porog:
	rcall	knopka_1_nagata_end
	rcall	Zabelenie
	lds		r16, Porog_K
	rcall	chislo_0X_
	ldi		r30, low(CIFRA_0*2)
	ldi		r31, high(CIFRA_0*2)
	ldi		r19, 55
	ldi		r20, 3
	rcall	IMAGE
	ldi		r30, low(Mkr*2)
	ldi		r31, high(Mkr*2)
	ldi		r19, 65
	ldi		r20, 4
	rcall	IMAGE

knopka_1_2_ne_nagata_Fon_Porog:
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Fon_Porog
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_Fon_Porog
	rjmp	knopka_1_2_ne_nagata_Fon_Porog

knopka_1_nagata_Fon_Porog:
	ldi		r24, 101
knopka_1_nagata_Fon_Porog_1sec:
	dec		r24
	breq	vihod_iz_Fon_Porog
	rcall	pause_10ms
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Fon_Porog_1sec
	rcall	pause_10ms
	lds		r16, Porog_K
	inc		r16
	rjmp	na_zapis_Fon_Porog

knopka_2_nagata_Fon_Porog:
	rcall	knopka_2_nagata_end
	lds		r16, Porog_K
	dec		r16
na_zapis_Fon_Porog:
	cpi		r16, 0
	brne	Fon_Porog_ne_men_1
	ldi		r16, 1
Fon_Porog_ne_men_1:
	cpi		r16, 251
	brne	Fon_Porog_ne_bol_250
	ldi		r16, 250
Fon_Porog_ne_bol_250:
	sts		Porog_K, r16
	rcall	chislo_0X_
	rjmp	knopka_1_2_ne_nagata_Fon_Porog

knopka_2_nagata_start_Fon_Porog:
	rcall	knopka_2_nagata_end_ret

;---------------------Подсветка---------------------------------

vihod_iz_Podsvetka:

	ldi		r30, low(Podsvetka*2)
	ldi		r31, high(Podsvetka*2)
	rcall	IMAGE_Z_

	rcall	knopka_1_nagata_end

knopka_1_2_ne_nagata_start_Podsvetka:
	rcall	pause_1ms
	rcall	Toko_mer
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_start_Podsvetka
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_start_Podsvetka
	rjmp	knopka_1_2_ne_nagata_start_Podsvetka

knopka_1_nagata_start_Podsvetka:
	rcall	knopka_1_nagata_end
	ldi		r19, 0
	ldi		r20, 4
	ldi		r21, 96
	ldi		r22, 5
	rcall	clear_lcd
	lds		r16, Podsvetka_K
	ldi		r19, 31
	ldi		r20, 5
	rcall	chislo_0X

knopka_1_2_ne_nagata_Podsvetka:
	rcall	pause_1ms
	rcall	Toko_mer
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Podsvetka
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_Podsvetka
	rjmp	knopka_1_2_ne_nagata_Podsvetka

knopka_1_nagata_Podsvetka:
	ldi		r24, 101
knopka_1_nagata_Podsvetka_1sec:
	dec		r24
	breq	vihod_iz_Podsvetka
	rcall	pause_10ms
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Podsvetka_1sec
	rcall	pause_10ms
	lds		r16, Podsvetka_K
	inc		r16
	rjmp	na_zapis_Podsvetka

knopka_2_nagata_Podsvetka:
	rcall	knopka_2_nagata_end
	lds		r16, Podsvetka_K
	dec		r16
na_zapis_Podsvetka:
	cpi		r16, 0
	brne	Podsvetka_ne_men_1
	ldi		r16, 1
Podsvetka_ne_men_1:
	cpi		r16, 16
	brne	Podsvetka_ne_bol_15
	ldi		r16, 15
Podsvetka_ne_bol_15:
	sts		Podsvetka_K, r16
	ldi		r19, 31
	ldi		r20, 5
	rcall	chislo_0X
	rjmp	knopka_1_2_ne_nagata_Podsvetka

knopka_2_nagata_start_Podsvetka:
	rcall	knopka_2_nagata_end_ret

	rjmp	vihod_iz_Nastroiki

;---------------------Настройки датчика---------------------------------

vihod_iz_Nastroiki:
	rcall	Zabelenie
	ldi		r30, low(Nastroiki_datchika*2)
	ldi		r31, high(Nastroiki_datchika*2)
	ldi		r19, 0				; X
	ldi		r20, 3				; Y
	rcall	IMAGE

	rcall	knopka_1_nagata_end

knopka_1_2_ne_nagata_start_Nastroiki:
	rcall	pause_1ms
	rcall	Toko_mer
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_start_Nastroiki
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_start_Nastroiki
	rjmp	knopka_1_2_ne_nagata_start_Nastroiki

knopka_1_nagata_start_Nastroiki:
	rcall	knopka_1_nagata_end
	rcall	Zabelenie
	lds		r16, Ax
	clr		r17
	ldi		r19, 31
	ldi		r20, 1
;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XXX_
	lds		r16, Bx
	clr		r17
	ldi		r19, 31
	ldi		r20, 3
;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XXX_
	lds		r16, Cx_low
	lds		r17, Cx_high
	ldi		r19, 15
	ldi		r20, 5
;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XXXXX
	ldi		r30, low(Strelka*2)
	ldi		r31, high(Strelka*2)
	ldi		r19, 60				; X
	ldi		r20, 1				; Y
	rcall	IMAGE

knopka_1_2_ne_nagata_Nastroika_Ax:
	rcall	pause_1ms
	rcall	Toko_mer
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Nastroika_Ax
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_Nastroika_Ax
	rjmp	knopka_1_2_ne_nagata_Nastroika_Ax

knopka_1_nagata_Nastroika_Ax:
	ldi		r24, 101
knopka_1_nagata_Nastroika_Ax_1sec:
	dec		r24
	breq	vihod_iz_Nastroiki
	rcall	pause_10ms
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Nastroika_Ax_1sec
	rcall	pause_10ms
	lds		r16, Ax
	inc		r16
	rjmp	na_zapis_Nastroika_Ax

knopka_2_nagata_Nastroika_Ax:
	ldi		r24, 101
knopka_2_nagata_Nastroika_Ax_1sec:
	dec		r24
	breq	Nastroika_Bx
	rcall	pause_10ms
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_Nastroika_Ax_1sec
	rcall	pause_10ms
;	rcall	knopka_2_nagata_end
	lds		r16, Ax
	dec		r16
na_zapis_Nastroika_Ax:
	cpi		r16, 1
	brne	Nastroika_Ax_ne_men_1
	ldi		r16, 2
Nastroika_Ax_ne_men_1:
	cpi		r16, 120
	brlo	Nastroika_Ax_ne_bol_120
	ldi		r16, 120
Nastroika_Ax_ne_bol_120:
	sts		Ax, r16
	clr		r17
	ldi		r19, 31
	ldi		r20, 1
;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XXX_
	rjmp	knopka_1_2_ne_nagata_Nastroika_Ax

knopka_2_nagata_start_Nastroiki:
	rcall	knopka_2_nagata_end_ret

	rjmp	vihod_iz_RC


Nastroika_Ax:
	ldi		r19, 60
	ldi		r20, 5
	ldi		r21, 4
	ldi		r22, 2
	rcall	clear_lcd
	ldi		r30, low(Strelka*2)
	ldi		r31, high(Strelka*2)
	ldi		r19, 60				; X
	ldi		r20, 1				; Y
	rcall	IMAGE
Nastroika_Ax_:
	rcall	pause_10ms
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	Nastroika_Ax_
	rjmp	knopka_1_2_ne_nagata_Nastroika_Ax


Nastroika_Bx:
	ldi		r19, 60
	ldi		r20, 1
	ldi		r21, 4
	ldi		r22, 2
	rcall	clear_lcd
	ldi		r30, low(Strelka*2)
	ldi		r31, high(Strelka*2)
	ldi		r19, 60				; X
	ldi		r20, 3				; Y
	rcall	IMAGE
Nastroika_Bx_:
	rcall	pause_10ms
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	Nastroika_Bx_

knopka_1_2_ne_nagata_Nastroika_Bx:
	rcall	pause_1ms
	rcall	Toko_mer
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Nastroika_Bx
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_Nastroika_Bx
	rjmp	knopka_1_2_ne_nagata_Nastroika_Bx

knopka_1_nagata_Nastroika_Bx:
	ldi		r24, 101
knopka_1_nagata_Nastroika_Bx_1sec:
	dec		r24
	breq	vihod_iz_Nastroiki_Bx_Cx
	rcall	pause_10ms
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Nastroika_Bx_1sec
	rcall	pause_10ms
	lds		r16, Bx
	inc		r16
	rjmp	na_zapis_Nastroika_Bx

vihod_iz_Nastroiki_Bx_Cx:
	rjmp	vihod_iz_Nastroiki

knopka_2_nagata_Nastroika_Bx:
	ldi		r24, 101
knopka_2_nagata_Nastroika_Bx_1sec:
	dec		r24
	breq	Nastroika_Cx
	rcall	pause_10ms
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_Nastroika_Bx_1sec
	rcall	pause_10ms
;	rcall	knopka_2_nagata_end
	lds		r16, Bx
	dec		r16
na_zapis_Nastroika_Bx:
	cpi		r16, 0
	brne	Nastroika_Bx_ne_men_1
	ldi		r16, 1
Nastroika_Bx_ne_men_1:
;	cpi		r16, 120
;	brlo	Nastroika_Bx_ne_bol_120
;	ldi		r16, 120
;Nastroika_Bx_ne_bol_120:
	sts		Bx, r16
	clr		r17
	ldi		r19, 31
	ldi		r20, 3
;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XXX_
	rjmp	knopka_1_2_ne_nagata_Nastroika_Bx


Nastroika_Cx:
	ldi		r19, 60
	ldi		r20, 3
	ldi		r21, 4
	ldi		r22, 2
	rcall	clear_lcd
	ldi		r30, low(Strelka*2)
	ldi		r31, high(Strelka*2)
	ldi		r19, 60				; X
	ldi		r20, 5				; Y
	rcall	IMAGE
Nastroika_Cx_:
	rcall	pause_10ms
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	Nastroika_Cx_

knopka_1_2_ne_nagata_Nastroika_Cx:
	rcall	pause_1ms
	rcall	Toko_mer
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_Nastroika_Cx
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_Nastroika_Cx
	rcall	pause_100ms
	rjmp	knopka_1_2_ne_nagata_Nastroika_Cx

knopka_1_nagata_Nastroika_Cx:
	ldi		r24, 101
knopka_1_2_nagata_Nastroika_Cx_1sec:
	rcall	pause_10ms
	sbic 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_2_ne_nagata_Nastroika_Cx_1sec
	sbic 	PINC, PINC3			; кнопка 2
	rjmp	knopka_1_2_ne_nagata_Nastroika_Cx_1sec
	dec		r24
;	breq	vihod_iz_Nastroiki_Bx_Cx
	breq	Nastroika_Ax_jmp
	rjmp	knopka_1_2_nagata_Nastroika_Cx_1sec
knopka_1_2_ne_nagata_Nastroika_Cx_1sec:

	rcall	pause_10ms
	lds		r26, Cx_low
	lds		r27, Cx_high
	adiw	r26, 1
	rjmp	na_zapis_Nastroika_Cx

Nastroika_Ax_jmp:
	rjmp	Nastroika_Ax

knopka_2_nagata_Nastroika_Cx:
	ldi		r24, 101
knopka_2_1_nagata_Nastroika_Cx_1sec:
	rcall	pause_10ms
	sbic 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_1_ne_nagata_Nastroika_Cx_1sec
	sbic 	PINC, PINC2			; кнопка 1
	rjmp	knopka_2_1_ne_nagata_Nastroika_Cx_1sec
	dec		r24
	breq	Nastroika_Ax_jmp
	rjmp	knopka_2_1_nagata_Nastroika_Cx_1sec
knopka_2_1_ne_nagata_Nastroika_Cx_1sec:

	rcall	pause_10ms
;	rcall	knopka_2_nagata_end
	lds		r26, Cx_low
	lds		r27, Cx_high
	sbiw	r26, 1
na_zapis_Nastroika_Cx:
	cpi		r16, 0
	brne	Nastroika_Cx_ne_men_1
	ldi		r16, 1
Nastroika_Cx_ne_men_1:
;	cpi		r16, 120
;	brlo	Nastroika_Bx_ne_bol_120
;	ldi		r16, 120
;Nastroika_Bx_ne_bol_120:
	sts		Cx_low, r26
	sts		Cx_high, r27
	mov		r16, r26
	mov		r17, r27
	ldi		r19, 15
	ldi		r20, 5
;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XXXXX
	rjmp	knopka_1_2_ne_nagata_Nastroika_Cx


;-----------------------------------------------------------

knopka_2_ne_nagata_end:
	sbic 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_ne_nagata_end
knopka_2_nagata_end:
	rcall	pause_10ms
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_end
	rcall	pause_10ms
	ret

knopka_2_nagata_end_ret:
	ldi		r24, 101
knopka_2_nagata_1sec:
	dec		r24
	breq	vihod_iz_Nastroek
	rcall	pause_10ms
	sbis 	PINC, PINC3			; кнопка 2
	rjmp	knopka_2_nagata_1sec
	rcall	pause_10ms
	ret
vihod_iz_Nastroek:
	pop		r24
	pop		r24
	ret

knopka_1_ne_nagata_end:
	sbic 	PINC, PINC2			; кнопка 1
	rjmp	knopka_2_ne_nagata_end
knopka_1_nagata_end:
	rcall	pause_10ms
	sbis 	PINC, PINC2			; кнопка 1
	rjmp	knopka_1_nagata_end
	rcall	pause_10ms
	ret

IMAGE_Z_:
	ldi		r19, 0
	ldi		r20, 0
	rcall	IMAGE_Z
	ret

chislo_0X_:
	ldi		r19, 31
	ldi		r20, 3
	rcall	chislo_0X
	ret

;-----------------------------Куски------------------------------

Proverka_vihoda_za_3byta:
	cp		r11, r0
	breq	ne_vihod_za_3byta
	ldi		r16, 0xFF
	ldi		r17, 0xFF
	ldi		r18, 0xFF
ne_vihod_za_3byta:
	ret

Podschet_CPX:
	cli
	push	r26
	push	r27
	push	r28
	push	r29
	lds		r24, Time2000_low
	lds		r25, Time2000_high
	push	r24
	push	r25
	lds		r12, Time_low
	lds		r13, Time_high
	lds		r14, Time_syper_high
	sei
	ldi		r24, low(1000)
	ldi		r25, high(1000)
	mov		r8, r24
	mov		r9, r25
	clr		r10
	clr		r11
	clr		r15
;	r8 - Low1	множитель1 / ответ
;	r9 - Low2	множитель1 / ответ
;	r10 - High1	множитель1 / ответ
;	r11 - High2	множитель1 / ответ
;	r12 - Low1	множитель2 / ответ
;	r13 - Low2	множитель2 / ответ
;	r14 - High1	множитель2 / ответ
;	r15 - High2	множитель2 / ответ
	rcall	ymnogenie
	ldi		r24, low(1000)
	ldi		r25, high(1000)
	mov		r4, r24
	mov		r5, r25
	pop		r25
	pop		r24
	lsr		r25
	ror		r24
	sub		r4, r24
	sbc		r5, r25
	sbc		r6, r0
	sbc		r7, r0
	add		r4, r8
	adc		r5, r9
	adc		r6, r10
	adc		r7, r11
	pop		r11
	pop		r10
	pop		r9
	pop		r8
	mov		r12, r21
	mov		r13, r22
	mov		r14, r23
	clr		r15
;	r8 - Low1	множитель1 / ответ
;	r9 - Low2	множитель1 / ответ
;	r10 - High1	множитель1 / ответ
;	r11 - High2	множитель1 / ответ
;	r12 - Low1	множитель2 / ответ
;	r13 - Low2	множитель2 / ответ
;	r14 - High1	множитель2 / ответ
;	r15 - High2	множитель2 / ответ
	rcall	ymnogenie
;	r4 - Low1	делитель
;	r5 - Low2	делитель
;	r6 - High1	делитель
;	r7 - High2	делитель
;	r8 - Low1	делимое / ответ
;	r9 - Low2	делимое / ответ
;	r10 - High1	делимое / ответ
;	r11 - High2	делимое / ответ
;	r12 - Low3	делимое / ответ
;	r13 - Low4	делимое / ответ
;	r14 - High3	делимое / ответ
;	r15 - High4	делимое / ответ
	rcall	delenie
	mov		r16, r8
	mov		r17, r9
	mov		r18, r10
	ret

Battery_mer:
	rcall	ADC7_start
	rcall	opros_ADIF
	lds		r10, ADCL
	lds		r11, ADCH
	rcall	ADC7_stop
	clr		r8
	clr		r9
	clr		r12
	clr		r13
	clr		r14
	clr		r15
	ldi		r24, 0x24
	mov		r4, r24
	ldi		r24, 0xCB
	mov		r5, r24
	ldi		r24, 0x01
	mov		r6, r24
	clr		r7
;	r4 - Low1	делитель
;	r5 - Low2	делитель
;	r6 - High1	делитель
;	r7 - High2	делитель
;	r8 - Low1	делимое / ответ
;	r9 - Low2	делимое / ответ
;	r10 - High1	делимое / ответ
;	r11 - High2	делимое / ответ
;	r12 - Low3	делимое / ответ
;	r13 - Low4	делимое / ответ
;	r14 - High3	делимое / ответ
;	r15 - High4	делимое / ответ
	rcall	delenie
	sts		Battery_Low, r8
	sts		Battery_High, r9
	mov		r16, r8
	mov		r17, r9
	ldi		r19, 0
	ldi		r20, 1
;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XXX

	mov		r17, r8
	mov		r18, r9
	sbic 	PINB, PINB4			; зарядка
	rjmp	ne_otkl
	ldi		r24, high(299)
	cpi		r17, low(299)
	cpc		r18, r24
	brsh	ne_otkl
	rjmp	GO_Sleep
ne_otkl:

	subi	r17, 230
	sbc		r18, r0
	brsh	ne_menshe_230
	clr		r17
	clr		r18
ne_menshe_230:
	ldi		r16, 21
nabiraem_K:
	dec		r16
	cpi		r16, 1
	breq	hvatit_k
	subi	r17, 10
	sbc		r18, r0
	brsh	nabiraem_K
hvatit_k:
;	r16 - байт штриха от 1 до 19
	rcall	Battery
	ret

Toko_mer:
	in		r24, DDRD
	sbrs	r24, 5
	ret
	rcall	ADC6_start
	rcall	opros_ADIF
	lds		r22, ADCL
	lds		r23, ADCH
	rcall	ADC6_stop
	in		r24, OCR0B
	swap	r22
	andi	r22, 0x0F
	lds		r21, Podsvetka_K
	cp		r22, r21
	cpc		r23, r0
	breq	tok_norma
	brsh	tok_menshe
	cpi		r24, 255
	breq	tok_norma
	inc		r24
	rjmp	tok_norma
tok_menshe:
	cpi		r24, 0
	breq	tok_norma
	dec		r24
tok_norma:
	out		OCR0A, r24
	out		OCR0B, r24
	ret

HourMinSec_mer:
	lds		r16, HOURS
	ldi		r19, 26				; X
	ldi		r20, 0				; Y
;	r16 - байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XX

	lds		r16, MINUTES
	ldi		r19, 46				; X
	ldi		r20, 0				; Y
;	r16 - байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XX

	lds		r16, SECUNDS
	ldi		r19, 66				; X
	ldi		r20, 0				; Y
;	r16 - байт
;	r19 - X
;	r20 - Y
	rcall	chislo_XX
	ret


Timeout_zapis:
	cli
	sts		Timeout_low, r24
	sts		Timeout_high, r25
	sts		Counter_low, r24
	sts		Counter_high, r25
	sei
	ret

proveka_Poroga:
	cli
	push	r1
	lds		r24, Porog_K
	ldi		r25, 100
	mul		r24, r25
	mov		r19, r0
	mov		r20, r1
	pop		r1
	clr		r0
	sei
	clr		r23
	clr		r24
	clr		r25
	ldi		r22, 10
cikl_x10:
	add		r23, r19
	adc		r24, r20
	adc		r25, r0
	dec		r22
	brne	cikl_x10
	cp		r16, r23
	cpc		r17, r24
	cpc		r18, r25
	brsh	porog_srabotal
	lds		r24, Uroven_Zv_Buf
	sts		Uroven_Zvuka, r24
	ldi		r24, 0b11101111
	and		r1, r24
	rjmp	porog_ne_srabotal
porog_srabotal:
	ldi		r24, 1
	lds		r23, Zvuk_Opov_K
	sbrc	r23, 0
	sts		Uroven_Zvuka, r24
	ldi		r24, 0b00010000
	or		r1, r24
porog_ne_srabotal:
	ret

;---------------простое умножение------------------------

;	r8 - Low1	множитель1 / ответ
;	r9 - Low2	множитель1 / ответ
;	r10 - High1	множитель1 / ответ
;	r11 - High2	множитель1 / ответ

;	r12 - Low1	множитель2 / ответ
;	r13 - Low2	множитель2 / ответ
;	r14 - High1	множитель2 / ответ
;	r15 - High2	множитель2 / ответ

ymnogenie:
	push	r4
	push	r5
	push	r6
	push	r7
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21
	push	r22
	push	r23
	push	r24
	mov		r16, r8
	mov		r17, r9
	mov		r18, r10
	mov		r19, r11
	ldi		r20, 0
	ldi		r21, 0
	ldi		r22, 0
	ldi		r23, 0
	mov		r4, r12
	mov		r5, r13
	mov		r6, r14
	mov		r7, r15
	ldi		r24, 0
	mov		r8, r24
	mov		r9, r24
	mov		r10, r24
	mov		r11, r24
	mov		r12, r24
	mov		r13, r24
	mov		r14, r24
	mov		r15, r24
	ldi		r24, 32
	rjmp	prigok2
mul_cikl:
	lsl		r16
	rol		r17
	rol		r18
	rol		r19
	rol		r20
	rol		r21
	rol		r22
	rol		r23
	lsr		r7
	ror		r6
	ror		r5
	ror		r4
	dec		r24
	breq	mul_end
prigok2:
	sbrs	r4, 0				; пропустить, если бит 0 установлен
	rjmp	mul_cikl
	add		r8, r16
	adc		r9, r17
	adc		r10, r18
	adc		r11, r19
	adc		r12, r20
	adc		r13, r21
	adc		r14, r22
	adc		r15, r23
	rjmp	mul_cikl
mul_end:
	pop		r24
	pop		r23
	pop		r22
	pop		r21
	pop		r20
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	ret

;---------------простое деление------------------------

;	r4 - Low1	делитель
;	r5 - Low2	делитель
;	r6 - High1	делитель
;	r7 - High2	делитель

;	r8 - Low1	делимое / ответ
;	r9 - Low2	делимое / ответ
;	r10 - High1	делимое / ответ
;	r11 - High2	делимое / ответ
;	r12 - Low3	делимое / ответ
;	r13 - Low4	делимое / ответ
;	r14 - High3	делимое / ответ
;	r15 - High4	делимое / ответ

delenie:
	push	r0
	push	r30
	push	r2
	push	r25
	push	r16
	push	r17
	push	r18
	push	r19
	push	r20
	push	r21
	push	r22
	push	r23
	push	r24
	cp		r4, r0
	cpc		r5, r0
	cpc		r6, r0
	cpc		r7, r0
	brne	del_ne_nol
	inc		r4
del_ne_nol:
	ldi		r24, 0
	mov		r0, r24
	mov		r30, r24
	mov		r2, r24
	mov		r25, r24
	ldi		r16, 0
	ldi		r17, 0
	ldi		r18, 0
	ldi		r19, 0
	ldi		r20, 0
	ldi		r21, 0
	ldi		r22, 0
	ldi		r23, 0
	ldi		r24, 32
	rjmp	propysk
sdvig:
	lsl		r4
	rol		r5
	rol		r6
	rol		r7
propysk:
	inc		r24
	sbrs	r7, 7				; пропустить, если бит 7 установлен
	rjmp	sdvig
sub_go:
	cp		r8, r0
	cpc		r9, r30
	cpc		r10, r2
	cpc		r11, r25
	cpc		r12, r4
	cpc		r13, r5
	cpc		r14, r6
	cpc		r15, r7
	brlo	menshe
	sub		r8, r0
	sbc		r9, r30
	sbc		r10, r2
	sbc		r11, r25
	sbc		r12, r4
	sbc		r13, r5
	sbc		r14, r6
	sbc		r15, r7
	sec
	rjmp	odin
menshe:
	clc
odin:
	rol		r16
	rol		r17
	rol		r18
	rol		r19
	rol		r20
	rol		r21
	rol		r22
	rol		r23
	lsr		r7
	ror		r6
	ror		r5
	ror		r4
	ror		r25
	ror		r2
	ror		r30
	ror		r0
	dec		r24
	brne	sub_go
	mov		r8, r16
	mov		r9, r17
	mov		r10, r18
	mov		r11, r19
	mov		r12, r20
	mov		r13, r21
	mov		r14, r22
	mov		r15, r23
	pop		r24
	pop		r23
	pop		r22
	pop		r21
	pop		r20
	pop		r19
	pop		r18
	pop		r17
	pop		r16
	pop		r25
	pop		r2
	pop		r30
	pop		r0
	ret

;------------------отображение значка напряжения------------------

Battery:
	ldi		r24, 0x10			; X
	rcall	SPI_Write_CMD
	ldi		r24, 0x03			; X
	rcall	SPI_Write_CMD
	ldi		r24, 0xB0			; Y
	rcall	SPI_Write_CMD
	ldi		r23, 18
cikl_shtriha:
	ldi		r24, 0b10000001
	dec		r16
	brne	ne_shtrih
	ldi		r24, 0b10111101
	ldi		r16, 1
ne_shtrih:
	rcall	SPI_Write_DATA
	dec		r23
	brne	cikl_shtriha
	ret

;------------------отображение напряжения------------------

;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
chislo_XXX:
	ldi		r18, 100
	rcall	perebor_mini
	ldi		r18, 10
	ldi		r24, 7
	add		r19, r24
	rcall	perebor_mini
	ldi		r18, 1
	ldi		r24, 5
	add		r19, r24
	rcall	perebor_mini
	ret

perebor_mini:
	ldi		r30, low(MINI_CIFRA_0*2)
	ldi		r31, high(MINI_CIFRA_0*2)
	rjmp	prig_perebor_mini
ne_menshe_100_mini:
	adiw	r30, 8
	sub		r16, r18
	sbc		r17, r0
prig_perebor_mini:
	cp		r16, r18
	cpc		r17, r0
	brsh	ne_menshe_100_mini
	rcall	IMAGE
	ret

;------------------отображение 2х и 7ми значного числа------------------

;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
chislo_XXXXX:
	push	r15
	ldi		r18, 0
	ldi		r25, 0xFF
	mov		r15, r25
	rjmp	na_XXXXX

;	r16 - Low байт
;	r17 - High байт
;	r19 - X
;	r20 - Y
chislo_XXX_:
	push	r15
	ldi		r18, 0
	ldi		r25, 0xFF
	mov		r15, r25
	rjmp	na_XXX

;	r16 - байт
;	r19 - X
;	r20 - Y
chislo_XX:
	push	r15
	ldi		r17, 0
	ldi		r18, 0
	ldi		r25, 0xFF
	mov		r15, r25
	rjmp	na_XX

chislo_0X:
	push	r15
	ldi		r17, 0
	ldi		r18, 0
	ldi		r25, 0
	mov		r15, r25
	rjmp	na_XXX

;	r16 - младший байт
;	r17 - средний байт
;	r18 - старший байт
;	r19 - X
;	r20 - Y
;	r21 - запятая

chislo_XXXXXXX:
	push	r15
	mov		r15, r21
	ldi		r25, 0
	ldi		r21, 0x80
	ldi		r22, 0x96
	ldi		r23, 0x98
	cp		r16, r21
	cpc		r17, r22
	cpc		r18, r23
	brlo	vse_ok
	ldi		r16, 0x7F
	ldi		r17, 0x96
	ldi		r18, 0x98
vse_ok:
	ldi		r21, 0x40
	ldi		r22, 0x42
	ldi		r23, 0x0F
	rcall	perebor
	ldi		r21, 0xA0
	ldi		r22, 0x86
	ldi		r23, 0x01
	rcall	perebor
na_XXXXX:
	ldi		r21, low(10000)
	ldi		r22, high(10000)
	ldi		r23, 0
	rcall	perebor
	ldi		r21, low(1000)
	ldi		r22, high(1000)
	ldi		r23, 0
	rcall	perebor
na_XXX:
	ldi		r21, 100
	ldi		r22, 0
	ldi		r23, 0
	rcall	perebor
na_XX:
	ldi		r21, 10
	ldi		r22, 0
	ldi		r23, 0
	rcall	perebor
	ldi		r21, 1
	ldi		r22, 0
	ldi		r23, 0
	ldi		r25, 0xFF
	rcall	perebor
	pop		r15
	ret

perebor:
	dec		r15
	brne	ne_zapitay_0
	ldi		r25, 0xFF
ne_zapitay_0:
	ldi		r30, low(CIFRA_0*2)
	ldi		r31, high(CIFRA_0*2)
	rjmp	prig_perebor
ne_menshe_100:
	ldi		r25, 0xFF
	adiw	r30, 18
	sub		r16, r21
	sbc		r17, r22
	sbc		r18, r23
prig_perebor:
	cp		r16, r21
	cpc		r17, r22
	cpc		r18, r23
	brsh	ne_menshe_100
	cpi		r25, 0
	brne	ne_zatirka_cifr
	ldi		r30, low(ne_CIFRA*2)
	ldi		r31, high(ne_CIFRA*2)
ne_zatirka_cifr:
	rcall	IMAGE
	ldi		r24, 8
	cp		r15, r0
	brne	ne_zapitay_1
	ldi		r30, low(ZAPITAY*2)
	ldi		r31, high(ZAPITAY*2)
	add		r19, r24
	rcall	IMAGE
	ldi		r24, 4
ne_zapitay_1:
	add		r19, r24
	ret

;----------------------------------------------------------

Timer_IMG:
	ldi		r30, low(Timer*2)
	ldi		r31, high(Timer*2)
	ldi		r19, 27
	ldi		r20, 0
	rcall	IMAGE
	ret

SUMMA_IMG:
	ldi		r30, low(SUMMA*2)
	ldi		r31, high(SUMMA*2)
	ldi		r19, 82
	ldi		r20, 0
	rcall	IMAGE_Z
	ret

PLAV_IMG:
	ldi		r30, low(PLAV*2)
	ldi		r31, high(PLAV*2)
	ldi		r19, 82
	ldi		r20, 0
	rcall	IMAGE_Z
	ret

PAUSA_IMG:
	ldi		r30, low(PAUSA*2)
	ldi		r31, high(PAUSA*2)
	ldi		r19, 82
	ldi		r20, 0
	rcall	IMAGE_Z
	ret

;------------------вывод картинки----------------------

IMAGE:
	push	r20
	push	r21
	push	r22
	push	r23
	lpm		r21, Z+				; ширина X
	lpm		r22, Z+				; высота Y
	ori		r20, 0xB0			; Y
cikle_imageY:
	mov		r24, r19			; X high
	swap	r24
	andi	r24, 0b00001111
	ori		r24, 0x10
	rcall	SPI_Write_CMD
	mov		r24, r19			; X low
	andi	r24, 0b00001111
	rcall	SPI_Write_CMD
	mov		r24, r20			; Y
	inc		r20
	rcall	SPI_Write_CMD
	mov		r23, r21
cikle_imageX:
	lpm		r24, Z+
	rcall	SPI_Write_DATA
	dec		r23
	brne	cikle_imageX
	dec		r22
	brne	cikle_imageY
	pop		r23
	pop		r22
	pop		r21
	pop		r20
	ret

IMAGE_Z:
	push	r18
	push	r20
	push	r21
	push	r22
	push	r23
	ldi		r18, 1
	lpm		r21, Z+				; ширина X
	lpm		r22, Z+				; высота Y
	ori		r20, 0xB0			; Y
cikle_imageY_Z:
	mov		r24, r19			; X high
	swap	r24
	andi	r24, 0b00001111
	ori		r24, 0x10
	rcall	SPI_Write_CMD
	mov		r24, r19			; X low
	andi	r24, 0b00001111
	rcall	SPI_Write_CMD
	mov		r24, r20			; Y
	inc		r20
	rcall	SPI_Write_CMD
	mov		r23, r21
cikle_imageX_Z:
	dec		r18
	brne	hello_nuli
	ldi		r18, 1
	lpm		r24, Z+
	cpi		r24, 0
	brne	ne_nuli
	lpm		r18, Z+
hello_nuli:
	clr		r24
ne_nuli:
	rcall	SPI_Write_DATA
	dec		r23
	brne	cikle_imageX_Z
	dec		r22
	brne	cikle_imageY_Z
	pop		r23
	pop		r22
	pop		r21
	pop		r20
	pop		r18
	ret

;------------------------функции отображения анимаций----------------------

ZASTAVKA:
	ldi		r16, 1
	ldi		r17, 0
	ldi		r18, 1
zastava:
	rcall	Toko_mer
	ldi		r30, low(RAD_BIG*2)
	ldi		r31, high(RAD_BIG*2)
	ldi		r20, 0xB0			; Y
	ldi		r21, 9
cikle_zasY:
	ldi		r24, 0x10			; X
	rcall	SPI_Write_CMD
	ldi		r24, 0x00			; X
	rcall	SPI_Write_CMD
	mov		r24, r20
	inc		r20
	rcall	SPI_Write_CMD
	ldi		r22, 96
cikle_zasX:
	dec		r18
	brne	hello_nuli_Z
	ldi		r18, 1
	lpm		r24, Z+
	cpi		r24, 0
	brne	ne_nuli_Z
	lpm		r18, Z+
hello_nuli_Z:
	clr		r24
ne_nuli_Z:
	lsr		r16
	rol		r17
	eor		r16, r17
	or		r24, r16
	rcall	SPI_Write_DATA
	dec		r22
	brne	cikle_zasX
	dec		r21
	brne	cikle_zasY
	dec		r18
	brne	zastava
	ret

shym:
	ldi		r16, 1
	ldi		r17, 0
cikl_slychaino:
	rcall	Toko_mer
	ldi		r19, 40
slychaino:
	lsr		r16
	rol		r17
	eor		r16, r17
	mov		r24, r16
	rcall	SPI_Write_DATA
	dec		r19
	brne	slychaino
	dec		r18
	brne	cikl_slychaino
	ret

Alfa_Zabelenie:
	ldi		r19, 0
	ldi		r20, 2
	ldi		r21, 96
	ldi		r22, 7
	rcall	clear_lcd
	ret

Zabelenie:
	ldi		r19, 0
	ldi		r20, 0
	ldi		r21, 96
	ldi		r22, 9
	rcall	clear_lcd
	ret

;	r19 - X
;	r20 - Y
;	r21 - nширина X
;	r22 - высота Y
clear_lcd:
	push	r20
	push	r21
	push	r22
	push	r23
	ori		r20, 0xB0			; Y
cikle_clearY:
	mov		r24, r19			; X high
	swap	r24
	andi	r24, 0b00001111
	ori		r24, 0x10
	rcall	SPI_Write_CMD
	mov		r24, r19			; X low
	andi	r24, 0b00001111
	rcall	SPI_Write_CMD
	mov		r24, r20			; Y
	inc		r20
	rcall	SPI_Write_CMD
	mov		r23, r21
cikle_clearX:
	clr		r24
	rcall	SPI_Write_DATA
	dec		r23
	brne	cikle_clearX
	dec		r22
	brne	cikle_clearY
	pop		r23
	pop		r22
	pop		r21
	pop		r20
	ret

;--------------------Настройка экранчика----------------------

LCD_init:
	cbi		PORTD,DDD7			; к земле RES
	rcall	pause_100ms
	sbi		PORTD,DDD7			; подтяжка RES
	rcall	pause_10ms

	ldi		r30, low(LCD_init_data*2)
	ldi		r31, high(LCD_init_data*2)
	ldi		r16, 5
cikl_lcd_init:
	lpm		r24, Z+
	rcall	SPI_Write_CMD
	dec		r16
	brne	cikl_lcd_init
;	ldi		r24, 0xC8			; mirror Y axis (about X axis)
;	rcall	SPI_Write_CMD
;	ldi		r24, 0xA0			; Инвертировать экран по горизонтали
;	rcall	SPI_Write_CMD
	ret

LCD_init_data:
.db 0xA4, 0x2F, 0xAF, 0xA6, 0xA0, 0xC8, 0xA0, 0x00

;------------------------SPI------------------------

SPI_init:
	ldi		r24, 0b01010000		; Master Mode(MSTR), Enable SPI(SPE)
	out		SPCR, r24
	mov		r2, r24
	ldi		r24, 0b00000001		; double speed bit(SPI2X)
	out		SPSR, r24
	ret

;------------------Отправка байта по SPI----------------------

; r24-передоваемый байт

SPI_Write_CMD:
	out		SPCR, r0
	cbi		PORTB,DDB3			; к земле DO
	sbi		PORTB,DDB5			; подтяжка CLK
	cbi		PORTB,DDB5			; к земле CLK
	out		SPCR, r2			; Master Mode(MSTR), Enable SPI(SPE)
	out		SPDR, r24
	rcall	clk_18
	in		r24, SPSR
	ret

SPI_Write_DATA:
	out		SPCR, r0
	sbi		PORTB,DDB3			; подтяжка DO
	sbi		PORTB,DDB5			; подтяжка CLK
	cbi		PORTB,DDB5			; к земле CLK
	out		SPCR, r2			; Master Mode(MSTR), Enable SPI(SPE)
	out		SPDR, r24
	rcall	clk_18
	in		r24, SPSR
	ret

pause_20mksec:
	rjmp	clk_18
clk_18:
	sts		NOP_byte, r0
	sts		NOP_byte, r0
	rjmp	pause_10mksec
pause_10mksec:
	sts		NOP_byte, r0
	ret

;--------------------Настройка АЦП----------------------

ADC7_start:
	sbi		DDRC, DDC1
	sbi		DDRC, DDC0
	ldi		r24, 0b11000111		; ADC7 1.1V ADLAR = 0
	sts		ADMUX, r24
	ldi		r24, 0b11000100		; 62,5 kHz	однократное преобразование
	sts		ADCSRA, r24
	ret

ADC7_stop:
	cbi		DDRC, DDC1
	cbi		DDRC, DDC0
	sts		ADMUX, r0
	sts		ADCSRA, r0
	ret

ADC6_start:
	ldi		r24, 0b11000110		; ADC6 1.1V ADLAR = 0
	sts		ADMUX, r24
	ldi		r24, 0b11000100		; 62,5 kHz	однократное преобразование
	sts		ADCSRA, r24
	ret

ADC6_stop:
	sts		ADMUX, r0
	sts		ADCSRA, r0
	ret

opros_ADIF:
	ldi		r24, 200
cikl_delay:
	dec		r24
	brne	cikl_delay
	ret

;--------------------Настройка INT----------------------

INT_init:
	ldi		r24, 0b00001000
	sts		EICRA, r24
	ldi		r24, 0b00000010
	out		EIMSK, r24
	ret

;--------------------Настройка таймера----------------------

timer_init:
	lds		r16, Timer_K
	rcall	Timer_Konst
	ldi		r24, 0b00001001		; CTC and clk/1
	sts		TCCR1B, r24
	ldi		r24, 0b00000100		; OCIE1B
	sts		TIMSK1, r24
	sts		TCNT1H, r0
	sts		TCNT1L, r0
	ret

Timer_Konst:
	ldi		r25, high(480)
	ldi		r24, low(480)
	add		r24, r16
	adc		r25, r0
	sts		OCR1AH, r25
	sts		OCR1BH, r25
	sts		OCR1AL, r24
	sts		OCR1BL, r24
	ret

;------------------обнуление всего------------------

Global_Obnulenie:
	cli
	ldi		r24, low(2000)
	ldi		r25, high(2000)
	sts		Time2000_low, r24
	sts		Time2000_high, r25
	sts		Time_low, r0
	sts		Time_high, r0
	sts		Time_syper_high, r0
	sts		SECUNDS, r0
	sts		MINUTES, r0
	sts		HOURS, r0
	ldi		r24, low(500)
	ldi		r25, high(500)
	sts		Anim_low, r24
	sts		Anim_high, r25
	ldi		r24, 1
	sts		Schetchik_Zvuka, r24
	ldi		r26, 0
	ldi		r27, 0
	ldi		r28, 0
	ldi		r29, 0

	ldi		r30, low(Do_r26)
	ldi		r31, high(Do_r26)
;	ldi		r24, (9+Ax*2)
	lds		r24, Ax
	lsl		r24
	ldi		r25, 9
	add		r24, r25
cikl_zanuleniy:
	st		Z+, r0
	dec		r24
	brne	cikl_zanuleniy

	reti

;---------------EEPROM------------------------

EEPROM_Write:	
	sbic	EECR, EEPE				; Ждем готовности памяти к записи. Крутимся в цикле
	rjmp	EEPROM_Write 			; до тех пор пока не очистится флаг EEWE
	cli								; Затем запрещаем прерывания.
	out 	EEARL, r25 				; Загружаем адрес нужной ячейки
	out 	EEARH, r0	  			; старший и младший байт адреса
	out 	EEDR, r24 				; и сами данные, которые нам нужно загрузить
	sbi 	EECR, EEMPE				; взводим предохранитель
	sbi 	EECR, EEPE				; записываем байт
;	sei 							; разрешаем прерывания
	reti 							; возврат из процедуры

EEPROM_Read:	
	sbic 	EECR, EEPE				; Ждем пока будет завершена прошлая запись.
	rjmp	EEPROM_Read				; также крутимся в цикле.
	out 	EEARL, r25				; загружаем адрес нужной ячейки
	out  	EEARH, r0 				; его старшие и младшие байты
	sbi 	EECR, EERE 				; Выставляем бит чтения
	in 		r24, EEDR 				; Забираем из регистра данных результат
	ret

;------------------задержка ~0,01 сек------------------

pause_100ms:
	ldi		r23, 10
	rjmp	pause

pause_10ms:
	ldi		r23, 1
	rjmp	pause

pause_1ms:
	push	r24
	push	r25
	ldi		r23, 1
	ldi		r24, low(1000)
	ldi		r25, high(1000)
	rjmp	cikl_pause_t

pause:
	push	r24
	push	r25
cikl_pause_10ms:
	ldi		r24, low(2500)
	ldi		r25, high(2500)
cikl_pause_t:
	sbiw	r24, 1
	brne	cikl_pause_t
	dec		r23
	brne	cikl_pause_10ms
	pop		r25
	pop		r24
	ret

;----------------------------------DATA----------------------------------

UZ_COD:
.db 1, 2, 3, 5, 10, 20, 50, 100, 175, 250

MINI_CIFRA_0:
.db 5, 1
.db 0x00,0x7C,0x82,0x82,0x7C,0x00

MINI_CIFRA_1:
.db 5, 1
.db 0x00,0x08,0x04,0xFE,0x00,0x00

MINI_CIFRA_2:
.db 5, 1
.db 0x00,0xC4,0xA2,0x92,0x8C,0x00

MINI_CIFRA_3:
.db 5, 1
.db 0x00,0x44,0x82,0x92,0x6C,0x00

MINI_CIFRA_4:
.db 5, 1
.db 0x00,0x30,0x28,0x24,0xFE,0x00

MINI_CIFRA_5:
.db 5, 1
.db 0x00,0x4E,0x8A,0x8A,0x72,0x00

MINI_CIFRA_6:
.db 5, 1
.db 0x00,0x7C,0x92,0x92,0x64,0x00

MINI_CIFRA_7:
.db 5, 1
.db 0x00,0x02,0xC2,0x3A,0x06,0x00

MINI_CIFRA_8:
.db 5, 1
.db 0x00,0x6C,0x92,0x92,0x6C,0x00

MINI_CIFRA_9:
.db 5, 1
.db 0x00,0x4C,0x92,0x92,0x7C,0x00

ne_CIFRA:
.db	8, 2
.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

CIFRA_0:
.db	8, 2
.db 0x00, 0xFC, 0xFE, 0x06, 0x06, 0xFE, 0xFC, 0x00, 0x00, 0x3F, 0x7F, 0x60, 0x60, 0x7F, 0x3F, 0x00

CIFRA_1:
.db	8, 2
.db 0x00, 0x18, 0x1C, 0xFE, 0xFE, 0x00, 0x00, 0x00, 0x00, 0x60, 0x60, 0x7F, 0x7F, 0x60, 0x60, 0x00

CIFRA_2:
.db	8, 2
.db 0x00, 0x06, 0x86, 0x86, 0x86, 0xFE, 0xFC, 0x00, 0x00, 0x7F, 0x7F, 0x61, 0x61, 0x61, 0x60, 0x00

CIFRA_3:
.db	8, 2
.db 0x00, 0x06, 0x86, 0x86, 0x86, 0xFE, 0x7C, 0x00, 0x00, 0x60, 0x61, 0x61, 0x61, 0x7F, 0x3E, 0x00

CIFRA_4:
.db	8, 2
.db 0x00, 0xFE, 0xFE, 0x80, 0x80, 0xFE, 0xFE, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x7F, 0x7F, 0x00

CIFRA_5:
.db	8, 2
.db 0x00, 0xFE, 0xFE, 0x86, 0x86, 0x86, 0x06, 0x00, 0x00, 0x61, 0x61, 0x61, 0x61, 0x7F, 0x3F, 0x00

CIFRA_6:
.db	8, 2
.db 0x00, 0xFC, 0xFE, 0x86, 0x86, 0x8E, 0x0C, 0x00, 0x00, 0x3F, 0x7F, 0x61, 0x61, 0x7F, 0x3F, 0x00

CIFRA_7:
.db	8, 2
.db 0x00, 0x06, 0x06, 0x06, 0x06, 0xFE, 0xFE, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7F, 0x7F, 0x00

CIFRA_8:
.db	8, 2
.db 0x00, 0x7C, 0xFE, 0x86, 0x86, 0xFE, 0x7C, 0x00, 0x00, 0x3E, 0x7F, 0x61, 0x61, 0x7F, 0x3E, 0x00

CIFRA_9:
.db	8, 2
.db 0x00, 0x7C, 0xFE, 0x86, 0x86, 0xFE, 0xFC, 0x00, 0x00, 0x30, 0x71, 0x61, 0x61, 0x7F, 0x3F, 0x00

ZAPITAY:
.db	4, 2
.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x60, 0x00

RAD_BIG:
.db 0x00,   25, 0x80, 0xC0, 0xE0, 0xF0, 0xF0, 0xE0, 0xC0, 0x00,   30, 0xC0, 0xE0, 0xF0, 0xF0, 0xE0
.db 0xC0, 0x80, 0x00,   45, 0xC0, 0xF0, 0xF8, 0xFC, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
.db 0xFF, 0xFF, 0xFC, 0xF8, 0xE0, 0xC0, 0x00,   21, 0xC0, 0xE0, 0xF8, 0xFC, 0xFF, 0xFF
.db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE, 0xFC, 0xF8, 0xF0, 0xC0, 0x00,   35, 0x80, 0xF0
.db 0xFC, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
.db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFC, 0xF8, 0x60, 0x00,    5, 0x80, 0x80, 0x80, 0x00,    5, 0x60
.db 0xF8, 0xFC, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
.db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFC, 0xF0, 0x80, 0x00,   31, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F
.db 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F
.db 0x7F, 0x07, 0x01, 0xC0, 0xF0, 0xFC, 0xFE, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFE
.db 0xFE, 0xFC, 0xF0, 0xC0, 0x01, 0x07, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F
.db 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x00,   55, 0x03, 0x0F
.db 0x1F, 0x3F, 0x7F, 0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F, 0x7F, 0x3F, 0x1F, 0x0F, 0x03, 0x00
.db   79, 0xC0, 0xF0, 0xF8, 0xFC, 0xFC, 0xFC, 0xF8, 0xF8, 0xF8, 0xF8, 0xF8, 0xFC, 0xFC, 0xFC, 0xF8
.db 0xF0, 0xC0, 0x00,   74, 0x80, 0xE0, 0xF0, 0xFC, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF 
.db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFC, 0xF0, 0xE0, 0x80, 0x00 
.db   67, 0x18, 0x3E, 0x3F, 0x7F, 0x7F, 0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF 
.db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F, 0x7F, 0x7F, 0x3F, 0x3E, 0x18
.db 0x00,   75, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00,   43,    0

RAD_0:
.db 19, 3
.db 0x00,   19, 0x60, 0x78, 0x7C, 0x7E, 0x7F, 0x7C, 0xB0, 0xC0, 0xE0, 0xC0, 0xB0, 0x7C, 0x7F, 0x7E
.db 0x7C, 0x78, 0x60, 0x00,    7, 0x40, 0x70, 0xFD, 0xFF, 0xFD, 0x70, 0x40, 0x00,    8

RAD_1:
.db 19, 3
.db 0x00,    9, 0x80, 0x80, 0x00,    8, 0xE0, 0xF0, 0xE0, 0xE0, 0xC0, 0xC0, 0x80, 0xC0, 0xE0, 0xDF
.db 0xBF, 0x3F, 0x1F, 0x1E, 0x0C, 0x08, 0x00,    3, 0x03, 0x07, 0x03, 0x03, 0x01, 0x01, 0x00,    1
.db 0x01, 0x03, 0xFD, 0xFE, 0x7E, 0x7C, 0x3C, 0x18, 0x08, 0x00,    4,    0

RAD_2:
.db 19, 3
.db 0x00,    7, 0x80, 0x80, 0x80, 0x00,   14, 0x01, 0x87, 0xDF, 0xFF, 0xDF, 0x87, 0x01, 0x00,    7
.db 0x03, 0x0F, 0x1F, 0x3F, 0x7F, 0x1F, 0x06, 0x01, 0x03, 0x01, 0x06, 0x1F, 0x7F, 0x3F, 0x1F, 0x0F
.db 0x03, 0x00,    3,    0

RAD_3:
.db 19, 3
.db 0x00,    6, 0x80, 0x80, 0x00,   12, 0x08, 0x0C, 0x1E, 0x1F, 0x3F, 0xBF, 0xDF, 0xE0, 0xC0, 0x80
.db 0xC0, 0xC0, 0xE0, 0xE0, 0xF0, 0xE0, 0x00,    3, 0x08, 0x18, 0x3C, 0x7C, 0x7E, 0xFE, 0xFD, 0x03
.db 0x01, 0x00,    1, 0x01, 0x01, 0x03, 0x03, 0x07, 0x03, 0x00,    3,    0

RODGER:
.db 19, 3
.db 0x00,   25, 0x3C, 0xE6, 0x66, 0xFE, 0x66, 0xE6, 0x3C, 0x00,   10, 0x22, 0x63, 0x24, 0x15, 0x18
.db 0x09, 0x18, 0x15, 0x24, 0x63, 0x22, 0x00,    5

RODGER_inv:
.db 19, 3
.db 0x00,   19, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xC3, 0x19, 0x99, 0x01, 0x99, 0x19, 0xC3, 0xFF
.db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xDD, 0x9C, 0xDB, 0xEA, 0xE7, 0xF6, 0xE7
.db 0xEA, 0xDB, 0x9C, 0xDD, 0xFF, 0xFF, 0xFF, 0xFF, 0x00,    1

PAUSA:
.db 14, 2
.db 0x00,    3, 0xF8, 0x08, 0xF8, 0x00,    1, 0xF8, 0x08, 0xF8, 0x00,    7, 0x1F, 0x10, 0x1F, 0x00
.db    1, 0x1F, 0x10, 0x1F, 0x00,    4

PLAV:
.db 14, 2
.db 0x00,    1, 0x40, 0x20, 0x10, 0x10, 0x20, 0x40, 0x80, 0x80, 0x40, 0x20, 0x00,    4, 0x04, 0x02
.db 0x01, 0x01, 0x02, 0x04, 0x08, 0x08, 0x04, 0x02, 0x00,    3

SUMMA:
.db 14, 2
.db 0x00,    2, 0x10, 0x30, 0x50, 0x90, 0x10, 0x10, 0x10, 0x10, 0x10, 0x30, 0x00,    4, 0x40, 0x60
.db 0x50, 0x48, 0x45, 0x42, 0x40, 0x40, 0x40, 0x60, 0x00,    2

CPS:
.db 14, 1
.db 0x3E, 0x41, 0x41, 0x22, 0x00, 0x7F, 0x09, 0x09, 0x06, 0x00, 0x26, 0x49, 0x49, 0x32

MkrH:
.db 20, 2
.db 0x00, 0x00, 0xfc, 0x40, 0x40, 0x3c, 0x00, 0x7f, 0x09, 0x09, 0x76, 0x00, 0x60, 0x1c, 0x03, 0x00 
.db 0x7f, 0x08, 0x04, 0x78, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 
.db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

Batter:
.db 23, 2
.db 0x3C, 0xE7, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81
.db 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0xFF, 0x00, 0x7C, 0x82, 0x82, 0x7C, 0x00, 0x80, 0x00, 0x7C
.db 0x82, 0x82, 0x7C, 0x00, 0x7C, 0x82, 0x82, 0x7C, 0x00, 0x0C, 0x30, 0xC0, 0x30, 0x0C, 0x00, 0x00

Timer:
.db 54, 2
.db 0xFC, 0xFE, 0x06, 0x06, 0xFE, 0xFC, 0x00, 0x00, 0xFC, 0xFE, 0x06, 0x06, 0xFE, 0xFC, 0x00, 0x00
.db 0x60, 0x60, 0x00, 0x00, 0xFC, 0xFE, 0x06, 0x06, 0xFE, 0xFC, 0x00, 0x00, 0xFC, 0xFE, 0x06, 0x06
.db 0xFE, 0xFC, 0x00, 0x00, 0x60, 0x60, 0x00, 0x00, 0xFC, 0xFE, 0x06, 0x06, 0xFE, 0xFC, 0x00, 0x00
.db 0xFC, 0xFE, 0x06, 0x06, 0xFE, 0xFC, 0x3F, 0x7F, 0x60, 0x60, 0x7F, 0x3F, 0x00, 0x00, 0x3F, 0x7F
.db 0x60, 0x60, 0x7F, 0x3F, 0x00, 0x00, 0x06, 0x06, 0x00, 0x00, 0x3F, 0x7F, 0x60, 0x60, 0x7F, 0x3F
.db 0x00, 0x00, 0x3F, 0x7F, 0x60, 0x60, 0x7F, 0x3F, 0x00, 0x00, 0x06, 0x06, 0x00, 0x00, 0x3F, 0x7F
.db 0x60, 0x60, 0x7F, 0x3F, 0x00, 0x00, 0x3F, 0x7F, 0x60, 0x60, 0x7F, 0x3F

Alfa:
.db 16, 2
.db 0xC0, 0xE0, 0x20, 0x60, 0xC0, 0xE0, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x80, 0x80
.db 0x07, 0x0F, 0x08, 0x0C, 0x07, 0x0F, 0x0C, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x02, 0x02

Beta:
.db 16, 2
.db 0x00, 0xF8, 0xFC, 0x46, 0x66, 0xFC, 0xFC, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x80, 0x80
.db 0x00, 0xFF, 0x7F, 0x08, 0x18, 0x0C, 0x0F, 0x03, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x02, 0x02

Gamma:
.db 16, 2
.db 0x60, 0x30, 0x70, 0xE0, 0x80, 0xE0, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x80, 0x80
.db 0x00, 0x00, 0x00, 0x7F, 0x3F, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x02, 0x02

Summa_ravno:
.db 16, 2
.db 0x18, 0x38, 0x78, 0xF8, 0xD8, 0x98, 0x18, 0x38, 0x38, 0x00, 0x00, 0x00, 0x80, 0x80, 0x80, 0x80
.db 0x30, 0x38, 0x3C, 0x3E, 0x37, 0x33, 0x31, 0x38, 0x38, 0x00, 0x00, 0x00, 0x02, 0x02, 0x02, 0x02

Result:
.db 73, 2
.db 0x00,   18, 0xF0, 0x20, 0x10, 0x10, 0x00,    1, 0xE0, 0x90, 0x90, 0x90, 0xE0, 0x00,    1, 0x60
.db 0x90, 0x90, 0x90, 0x20, 0x00,    1, 0xF0, 0x00,    3, 0xF0, 0x00,    1, 0xF0, 0x00,    4, 0x10
.db 0x10, 0xF0, 0x10, 0x10, 0x00,   40, 0x07, 0x00,    4, 0x03, 0x04, 0x04, 0x04, 0x00,    2, 0x02
.db 0x04, 0x04, 0x04, 0x03, 0x00,    1, 0x03, 0x04, 0x04, 0x04, 0x03, 0x00,    1, 0x07, 0x04, 0x04
.db 0x04, 0x00,    3, 0x07, 0x00,   24

RC:
.db 96, 9
.db 0x00 ,   230, 0xFF , 0xFF , 0x83 , 0x83 , 0x86 , 0xCE , 0x7C , 0x38 , 0x00 ,    2 , 0xE0 , 0xF8 , 0x1C , 0x06 
.db 0x03 , 0x03 , 0x07 , 0x07 , 0x00 ,   78 , 0x0F , 0x0F , 0x01 , 0x01 , 0x03 , 0x03 , 0x06 , 0x0C , 0x0C , 0x00 
.db    1 , 0x03 , 0x07 , 0x0E , 0x0C , 0x0C , 0x0E , 0x06 , 0x03 , 0x00 ,    147, 0xFC , 0xFC , 0x0C , 0x0C , 0x0C 
.db 0x0C , 0x0C , 0xF0 , 0xF8 , 0x9C , 0x4C , 0x6C , 0x3C , 0x98 , 0x00 ,    2 , 0xFC , 0xFC , 0x60 , 0x60 , 0x60 
.db 0xFC , 0xFC , 0x00 ,     1, 0xF0 , 0xF8 , 0x9C , 0x4C , 0x6C , 0x3C , 0x98 , 0x00 ,    2 , 0xFE , 0xFE , 0x08 
.db 0x0C , 0x0C , 0xFC , 0xF8 , 0x00 ,    1 , 0xF0 , 0xF8 , 0x1C , 0x0C , 0x0C , 0xFC , 0xFC , 0x00 ,    2 , 0x0C 
.db 0x0C , 0xFC , 0xFC , 0x0C , 0x0C , 0x00 ,    2 , 0xF0 , 0xF8 , 0x1C , 0x0C , 0x8C , 0xFC , 0xF8 , 0x00 ,    2 
.db 0xFE , 0xFE , 0x08 , 0x0C , 0x0C , 0xFC , 0xF8 , 0x00 ,   22 , 0x03 , 0x03 , 0x00 ,     5, 0x01 , 0x01 , 0x03 
.db 0x03 , 0x03 , 0x03 , 0x01 , 0x00 ,    2 , 0x03 , 0x03 , 0x00 ,    3 , 0x03 , 0x03 , 0x00 ,     1, 0x01 , 0x01 
.db 0x03 , 0x03 , 0x03 , 0x03 , 0x01 , 0x00 ,    2 , 0x7F , 0x7F , 0x03 , 0x03 , 0x03 , 0x01 , 0x00 ,    2 , 0x01 
.db 0x03 , 0x03 , 0x03 , 0x03 , 0x01 , 0x03 , 0x02 , 0x00 ,    3 , 0x03 , 0x03 , 0x00 ,    4 , 0x01 , 0x03 , 0x03 
.db 0x03 , 0x03 , 0x01 , 0x00 ,    3 , 0x7F , 0x7F , 0x03 , 0x03 , 0x03 , 0x01 , 0x00 ,   107, 0

Grom_Shek:
.db 96, 8
.db 0x00,   44, 0x80, 0xC0, 0xE0, 0xF0, 0xF0, 0x00,    5, 0x80, 0x80, 0x00,   73, 0xF8, 0xF8, 0x18
.db 0x18, 0x18, 0x18, 0x18, 0xF8, 0xFC, 0x0E, 0x07, 0x03, 0x01, 0x00,    1, 0xFF, 0xFF, 0x00,    2
.db 0x18, 0x38, 0xF0, 0xC1, 0x03, 0x07, 0x1E, 0xF8, 0xE0, 0x00,   69, 0x0F, 0x0F, 0x0C, 0x0C, 0x0C
.db 0x0C, 0x0C, 0x0F, 0x1F, 0x38, 0x70, 0xE0, 0xC0, 0x80, 0xFF, 0xFF, 0x00,    2, 0x18, 0x1C, 0x0F
.db 0x83, 0xC0, 0xE0, 0x78, 0x1F, 0x07, 0x00,   81, 0x01, 0x03, 0x07, 0x07, 0x00,    5, 0x01, 0x01
.db 0x00,   93, 0x30 , 0x30 , 0x00 ,   58 , 0xFF , 0xFF , 0x03 , 0x03 , 0x03 , 0x03 , 0x03 , 0x00 ,    1 , 0x03 
.db 0x0F , 0x3E , 0xF8 , 0xE0 , 0x78 , 0x1F , 0x07 , 0x00 ,     1, 0x1F , 0x3F , 0x30 , 0x30 , 0x10 , 0xFF , 0xFF 
.db 0x00 ,    3 , 0xFF , 0xFF , 0x18 , 0x18 , 0x18 , 0xFF , 0xFF , 0x00 ,     2, 0xFF , 0xFF , 0x00 ,    2 , 0x38 
.db 0x7E , 0xC7 , 0xC3 , 0xC3 , 0xC3 , 0x66 , 0x00 ,    2 , 0x03 , 0x03 , 0xFF , 0xFF , 0x03 , 0x03 , 0x00 ,    1
.db 0xFF , 0xFF , 0xD8 , 0xD8 , 0xD8 , 0xF8 , 0x70 , 0x00 ,    42, 0x18 , 0x1E , 0x07 , 0x01 , 0x00 ,    167, 0x00

Zvuk_Opov:
.db 59, 2
.db 0x06 , 0x06 , 0xFE , 0xFE , 0x06 , 0x06 , 0x00 , 0x00 , 0xFF , 0xFF , 0x84 , 0x86 , 0x86 , 0xFE , 0x7C , 0x00
.db 0x00 , 0xFE , 0xFE , 0x80 , 0x60 , 0x30 , 0x18 , 0xFE , 0xFE , 0x00 , 0x00 , 0xFE , 0xFE , 0xA2 , 0xBE , 0xDC
.db 0xC0 , 0x00 , 0x00 , 0xF8 , 0xFC , 0x8E , 0x86 , 0xC6 , 0xFE , 0x7C , 0x00 , 0x00 , 0xFE , 0xFE , 0x06 , 0x06
.db 0x06 , 0x06 , 0x06 , 0xF8 , 0xFC , 0x8E , 0x86 , 0x86 , 0xFE , 0xFE , 0x00 , 0x00 , 0x00 , 0x01 , 0x01 , 0x00
.db 0x00 , 0x00 , 0x00 , 0x3F , 0x3F , 0x01 , 0x01 , 0x01 , 0x00 , 0x00 , 0x00 , 0x00 , 0x01 , 0x01 , 0x00 , 0x00
.db 0x00 , 0x00 , 0x01 , 0x01 , 0x00 , 0x00 , 0x01 , 0x01 , 0x01 , 0x01 , 0x01 , 0x00 , 0x00 , 0x00 , 0x00 , 0x01
.db 0x01 , 0x01 , 0x01 , 0x00 , 0x00 , 0x00 , 0x00 , 0x01 , 0x01 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x01
.db 0x01 , 0x01 , 0x01 , 0x00 , 0x01 , 0x01 


Fon_Porog:
.db 96, 8
.db 0x00,   38, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0x60, 0x20, 0x20, 0x20, 0x20, 0x20, 0x60, 0xE0
.db 0xE0, 0xE0, 0xE0, 0xE0, 0xE0, 0x00,   77, 0xFF, 0xFF, 0xFF, 0xFF, 0xBF, 0x9F, 0x78, 0x43, 0xF3
.db 0xC0, 0xF3, 0x43, 0x78, 0x9F, 0xBF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00,   77, 0x1F, 0x1F, 0x1F, 0x1F
.db 0x1B, 0x13, 0x1B, 0x1D, 0x1C, 0x1E, 0x1C, 0x1D, 0x1B, 0x13, 0x1B, 0x1F, 0x1F, 0x1F, 0x1F, 0x00
.db   87, 0x80 , 0x80 , 0x00 ,    7 , 0x60 , 0x60 , 0x00 ,   66 , 0xFF , 0xFF , 0x03 , 0x03 , 0x03 , 0xFF , 0xFF
.db 0x00 ,    3 , 0x7C , 0xFE , 0xC7 , 0xC3 , 0xE3 , 0x7F , 0x3E , 0x00 ,    2 , 0xFF , 0xFF , 0xC2 , 0xC3 , 0xC3 
.db 0x7F , 0x3E , 0x00 ,    2 , 0xFF , 0xFF , 0x00 ,    3 , 0xFF , 0xFF , 0x03 , 0x03 , 0x03 , 0x03 , 0x03 , 0x00 
.db   53 , 0x80 , 0x80 , 0x00 ,    20, 0x0F , 0x0F , 0x00 ,   65 , 0x03 , 0x03 , 0xFF , 0xFF , 0x03 , 0x03 , 0x00 
.db    1 , 0xFF , 0xFF , 0xC2 , 0xC3 , 0xC3 , 0x7F , 0x3E , 0x00 ,    2 , 0xFF , 0xFF , 0x40 , 0x30 , 0x18 , 0x0C 
.db 0xFF , 0xFF , 0x00 ,    2 , 0xFF , 0xFF , 0xD1 , 0xDF , 0xEE , 0x60 , 0x00 ,    2 , 0x7C , 0xFE , 0xC7 , 0xC3 
.db 0xE3 , 0x7F , 0x3E , 0x00 ,    2 , 0xFF , 0xFF , 0x03 , 0x03 , 0x03 , 0x03 , 0x03 , 0x00 ,     1, 0xFF , 0xFF 
.db 0x40 , 0x30 , 0x18 , 0x0C , 0xFF , 0xFF , 0x00 ,    44, 0x0F , 0x0F , 0x00 ,    69 

Podsvetka:
.db 96, 8
.db 0x00 ,   35 , 0x30 , 0x70 , 0xE0 , 0xC0 , 0x80 , 0x00,      7, 0x7F , 0x7F , 0x00 ,    6 , 0x80 , 0xC0 , 0xE0 
.db 0x70 , 0x30 , 0x00 ,   67 , 0x80 , 0x80 , 0x80 , 0x80 , 0x80 , 0x80 , 0x80 , 0x01 , 0x03 , 0xC3 , 0xF0 , 0x38 
.db 0x1C , 0x0C , 0x06 , 0x06 , 0x06 , 0x06 , 0x06 , 0x0C , 0x1C , 0x38 , 0xF0 , 0xC3 , 0x03 , 0x01 , 0x00 ,   70
.db 0x01 , 0x01 , 0x01 , 0x01 , 0x01 , 0x01 , 0x01,  0x00 ,     1, 0x80 , 0x87 , 0x1F , 0x38 , 0x70 , 0x60 , 0xC0 
.db 0xC0 , 0xC0 , 0xC0 , 0xC0 , 0x60 , 0x70 , 0x38 , 0x1F , 0x87 , 0x80 , 0x00 ,     1, 0x03 , 0x03 , 0x03 , 0x03 
.db 0x03 , 0x03 , 0x03 , 0x00 ,   67 , 0x18 , 0x1C , 0x0E , 0x07 , 0x03 , 0x01 , 0x00 ,    5 , 0xFC , 0xFC , 0x00 
.db    6 , 0x01 , 0x03 , 0x07 , 0x0E , 0x1C , 0x18 , 0x00 ,  146 , 0xF0 , 0xF0 , 0x30 , 0x30 , 0x30 , 0xF0 , 0xF0 
.db 0x00 ,    3 , 0xF3 , 0xF3 , 0x00 ,     3, 0xF0 , 0xF0 , 0x30 , 0x30 , 0xF0 , 0xF0 , 0x00 ,    2 , 0x80 , 0xE0 
.db 0x70 , 0x30 , 0x30 , 0x30 , 0x60 , 0x00 ,    2 , 0xF0 , 0xF0 , 0x10 , 0xF0 , 0xE0 , 0x00 ,    3 , 0xF3 , 0xF3 
.db 0x00 ,     3, 0x30 , 0x30 , 0xF0 , 0xF0 , 0x30 , 0x30 , 0x00 ,     1, 0xF0 , 0xF0 , 0xC0 , 0xC0 , 0xE0 , 0x30 
.db 0x10 , 0x00 ,    1 , 0xC0 , 0xE0 , 0x70 , 0x30 , 0x30 , 0xF0 , 0xF0 , 0x00 ,    29 , 0x0F , 0x0F , 0x00 ,    3 
.db 0x0F , 0x0F , 0x00 ,     3, 0x0F , 0x0F , 0x00 ,    2 , 0x3C , 0x3F , 0x0F , 0x0C , 0x0C , 0x0F , 0x3F , 0x3C 
.db 0x00 ,    1 , 0x03 , 0x07 , 0x0C , 0x0C , 0x0C , 0x0C , 0x06 , 0x00 ,    2 , 0x0F , 0x0F , 0x0D , 0x0D , 0x0E 
.db 0x06 , 0x00 ,    2 , 0x0F , 0x0F , 0x00 ,    5 , 0x0F , 0x0F , 0x00 ,    3 , 0x0F , 0x0F , 0x00 ,     2, 0x03 
.db 0x0F , 0x0C , 0x00 ,    1 , 0x07 , 0x0F , 0x0C , 0x0C , 0x0C , 0x07 , 0x0F , 0x08 , 0x00 ,    20,  0x00 , 0

Vkl:
.db 36, 1
.db 0x03 , 0x87 , 0x8C , 0xD8 , 0x70 , 0x38 , 0x1F , 0x07 , 0x00 , 0x00 , 0xFF , 0xFF , 0xD1 , 0xDF , 0xEE , 0x60
.db 0x00 , 0xE0 , 0xF8 , 0x1F , 0x0F , 0x78 , 0xC0 , 0x70 , 0x1F , 0x0F , 0xF8 , 0xC0 , 0x00 , 0xFF , 0xFF , 0x0C
.db 0x0C , 0x3E , 0xF3 , 0xC1

Vblkl:
.db 36, 1
.db 0xFF , 0xFF , 0xD1 , 0xDF , 0xEE , 0x60 , 0x00 , 0x00 , 0xFF , 0xFF , 0x40 , 0x30 , 0x18 , 0x0C , 0xFF , 0xFF
.db 0x00 , 0xE0 , 0xF8 , 0x0F , 0x0F , 0x78 , 0xC0 , 0x70 , 0x1F , 0x07 , 0xF8 , 0xC0 , 0x00 , 0xFF , 0xFF , 0x0C
.db 0x0C , 0x3E , 0xF3 , 0xC1

Mkr:
.db 18, 2
.db 0xfc, 0x40, 0x40, 0x3c, 0x00, 0x7f, 0x09, 0x09, 0x76, 0x00, 0x60, 0x1c, 0x03, 0x00, 0x7f, 0x08
.db 0x04, 0x78, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 
.db 0x00, 0x00, 0x00, 0x00

Minus:
.db 6, 2
.db 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01

Plus:
.db 6, 2
.db 0x80, 0x80, 0xE0, 0xE0, 0x80, 0x80, 0x01, 0x01, 0x07, 0x07, 0x01, 0x01

Nastroiki_datchika:
.db 96, 4
.db 0xFF , 0xFF , 0x18 , 0x18 , 0x18 , 0xFF , 0xFF , 0x00 , 0x7C , 0xFE , 0xC7 , 0xC3 , 0xC3 , 0x7F , 0xFF , 0x00
.db 0xC0 , 0xFF , 0x7F , 0x03 , 0x03 , 0x03 , 0xFF , 0xFF , 0x00 , 0x7C , 0xFE , 0xC7 , 0xC3 , 0xC3 , 0x7F , 0xFF
.db 0x00 , 0xFF , 0xFF , 0xC0 , 0xFF , 0xFF , 0xC0 , 0xFF , 0xFF , 0x00 , 0x03 , 0x03 , 0xFF , 0xFF , 0x03 , 0x03
.db 0x00 , 0x07 , 0x3F , 0xF8 , 0xE0 , 0x78 , 0x1F , 0x07 , 0x00 , 0xFF , 0xFF , 0xD1 , 0xDF , 0xEE , 0x60 , 0x00
.db 0x7C , 0xFE , 0xC7 , 0xC3 , 0xC3 , 0x7F , 0xFF , 0x80 , 0x00 , 0xFF , 0xFF , 0x18 , 0x18 , 0x18 , 0xFF , 0xFF
.db 0x00 , 0xFF , 0xFF , 0x18 , 0x18 , 0x18 , 0xFF , 0xFF , 0x00 , 0x80 , 0xDC , 0x5E , 0x73 , 0x33 , 0xFF , 0xFF
.db 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x18 , 0x1E , 0x07 , 0x01 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0xC0 , 0xF0 , 0x38 , 0x18 , 0x18 , 0x18 , 0x30 , 0x00 , 0xE0 , 0xF0 , 0x38 , 0x98 , 0xD8 , 0x78 , 0x30
.db 0x00 , 0x00 , 0xF8 , 0xF8 , 0xC0 , 0xC0 , 0xC0 , 0xF8 , 0xF8 , 0x00 , 0xC0 , 0xF0 , 0x38 , 0x18 , 0x18 , 0x18
.db 0x30 , 0x00 , 0x00 , 0xE0 , 0xF0 , 0x38 , 0x18 , 0x18 , 0xF8 , 0xF0 , 0x00 , 0x00 , 0xFC , 0xFC , 0x10 , 0x18
.db 0x18 , 0xF8 , 0xF0 , 0x00 , 0xE0 , 0xF0 , 0x38 , 0x18 , 0x18 , 0xF8 , 0xF8 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x01 , 0x03 , 0x06 , 0x06 , 0x06 , 0x06 , 0x03 , 0x00 , 0x03 , 0x03 , 0x07 , 0x06 , 0x06 , 0x06 , 0x03
.db 0x00 , 0x00 , 0x07 , 0x07 , 0x00 , 0x00 , 0x00 , 0x07 , 0x07 , 0x00 , 0x01 , 0x03 , 0x06 , 0x06 , 0x06 , 0x06
.db 0x03 , 0x00 , 0x00 , 0x03 , 0x07 , 0x06 , 0x06 , 0x07 , 0x03 , 0x01 , 0x00 , 0x00 , 0xFF , 0xFF , 0x06 , 0x06
.db 0x06 , 0x03 , 0x01 , 0x00 , 0x03 , 0x07 , 0x06 , 0x06 , 0x06 , 0x03 , 0x07 , 0x04 , 0x00 , 0x00 , 0x00 , 0x00
.db 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00 , 0x00

Strelka:
.db 4, 2
.db 0x00, 0x80, 0xC0, 0xE0, 0x01, 0x03, 0x07, 0x0F
