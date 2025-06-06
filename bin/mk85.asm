COMMENT *

; Elektronika MK-85 ROM disassembly
; all numbers are hexadecimal unless stated otherwise

; 01.03.2025 Головейко Александр
;
; Оригинальный файл https://calculators.pdp-11.ru/mk85src.zip 
; Устранены ошибки оригинального файла исходника
; для получения bin файла точь в точь 
; как оригинальный bin файл в этом же архиве.
;
; Это файл можно скомпилировать и открыть в калькуляторе командой
; mk85m.exe -asmfn "mk85.asm" -romfn "mk85.rom"
; где
; -asmfn "mk85.asm" файл для компиляции
; -romfn "mk85.rom" выходной bin файл ROM
;
; Для получения дополнительной справки выполни mk85m.exe -help
;
; Версию эмулятора микрокомпьтера "Электроника МК85" для работы с коммандной строкой ищи на
; https://github.com/MatrexAl/mk85emsl




RAM

8000-805F	;60 bytes, display memory
8060-812B	;66 words, system stack
		;also used as error handler buffer (starts from 8060, 40 bytes)
		;also used as buffer for compared strings
		;(starts from 8060, 10 bytes)
812C-814D	;expression evaluator stack, holds codes of operators, grows
		;downwards
		;also used as buffer for concatenated strings
		;(starts from 812F, 1F bytes)
		;also the string returned by the ANS key
814E-816C	;1F bytes, string variable $
816D-81AC	;40 bytes, input line buffer
81AD-81B3	;7 bytes, user defined character
81B4-81C3	;8 words, first GOSUB stack for return addresses,
		;holds 8 entries, grows upwards
81C4-81D3	;8 words, second GOSUB stack for BASIC line beginning
		;addresses, holds 8 entries, grows upwards
81D4-8223	;28 words, FOR stack, holds 4 entries, grows upwards
8224-822B	;4 words, variable ANS
822C-823F	;A words, addresses of ends of BASIC programs 0-9
8240
8242-8243	;1 word, code of the parsed command/function/operator
8244-8247	;2 words, local temporary variables
8248-8249	;1 word, expression evaluator stack pointer, copied to r5
824A
824C
824E-824F	;1 word, RAN# seed
8250-8251	;1 word, number of variables, initialised to 1A
8252-8253	;1 word, top of the RAM
8254-8255	;1 word, pointer to BASIC line / position of an error
8256-8257	;1 word, mode
8258-8259	;1 word, indirect jump address (where to resume execution
		;after STOP), also local temporary variable
825A-825B	;1 word, BASIC program counter
		;also local temporary variable
825C-825D	;1 word, address of the beginning of current BASIC line
825E-825F	;1 word, previous keyboard state
8260-8261	;1 word, pointer to the input line buffer 816D
8262-8263	;1 word, keyboard mode
8264-8265	;1 word, flags
8266		;1 byte, keyboard timer
8267		;1 byte, number printing precision (negative)
8268		;1 byte, selected program
8269		;1 byte, cursor position
826A		;1 byte, counter of failed attempts to identify an apparently
		;pressed key
826B-87FF	;BASIC programs and variables area

variable 8256 (mode):
bit 15 - direct mode/program execution
bit 14 - INPUT mode
bit 9 - [MODE] off/on
bit 8 - AUTO mode
bit 7 - run/wrt
bit 6 - [EXT] off/on
bit 5 - [S] off/on
bit 4 - [F] off/on
bit 3 - TRACE mode
bit 2,1 - DEG 00, RAD 01, GRA 10
bit 0 - STOP mode

variable 8264 (flags):

bit 8 - set when the STOP key pressed
bit 7 - clr when the screen clearing required
bit 6 - set when delay between scrollings required
bit 5 - set when calculation result on the display (in direct mode)
bit 0 - short/long delay between scrollings

REGISTERS
r2 - BASIC program counter (pointer used by the parser)
r4 - program counter of the FORTH-like stack-based FP engine
r5 - expression evaluator stack pointer

PORTS
80-DF	O	;60 bytes, LCD RAM, only bits 4-0 are significant
E0	O	;1 byte, bits 3-0 - cursor position, bit 4 - cursor form
E8	O	;1 byte, related to LCD controller
100	I	;1 word, bits 8-2 - keyboard matrix columns
102	O	;1 word, bits 3-1 - keyboard matrix rows
104	I/O	;1 word, the CPU control register,
		;bit 3 - selects fast CPU clock when set
		;bit 10 - stops the CPU clock when cleared
106		;1 word, apparently not used

*




; Vectors
0000:	.dw	0B40,00E0	;reset vector
0004:	.dw	0B40,00E0	;memory access violation trap
0008:	.dw	0B40,00E0	;illegal opcode trap
000C:	.asciz	"DRAW "		;keyword typed with [F]+ANS
0012:	.asciz	"DRAWC "	;keyword typed with [S]+ANS
0019:	.asciz	"READY P"

; key codes in mode [S] mapped to the keyword table 0676
0021:	.db	' ', 'A', 'B', 'C'
	.db	'D', 'F', 'G', 'H'
	.db	'J', 'K', 'L', 'M'
	.db	'N', 'S', 'V', 'X'
	.db	'Z', 0

; key codes in mode [F] mapped to the keyword table 06DA
0033:	.db	' ', '=', 7B,  'A'
	.db	'B', 'C', 'D', 'E'
	.db	'F', 'G', 'H', 'I'
	.db	'J', 'K', 'L', 'M'
	.db	'N', 'O', 'P', 'Q'
	.db	'R', 'S', 'T', 'U'
	.db	'V', 'W', 'X', 'Y'
	.db	'Z', 0

; table of keyboard row patterns
0051:	.db	06	;W, Mode, AC
	.db	0A	;S, <-, Del
	.db	12	;F, [S], /
	.db	22	;Q, U, 9
	.db	42	;C, H, 6
	.db	0C	;E, ->, Init
	.db	14	;G, [F], 7
	.db	24	;X, I, *
	.db	44	;A, J, -
	.db	18	;Z, Y, 8
	.db	28	;D, O, 4
	.db	48	;R, K, 1
	.db	30	;B, P, 5
	.db	50	;T, L, 2
	.db	60	;V, ANS, 3
	.db	82	;none, M, +
	.db	84	;none, N, 0
	.db	88	;none, space, dot
	.db	90	;none, =, EXE
	.db	A0	;none, EE, none
0065:	.db	0

; key tables
; space bar, dot, operators and exponent - basic mode
0066:	.db	' ', '.', '-', '+'
	.db	'*', '/', 7B,  '='
; key codes in mode [S] for letter keys in the table 00BA
006E:	.db	'#', ':', ';', ','
	.db	'!', '$', '(', '?'
	.db	22,  ')'

; interrupt vector for the STOP key, enters the HALT-mode
0078:	.dw	00F4, 01E0

007C:	.dw	0000, 0000

0080:	.asciz	"Программу разработал Подоров А.Н."



; key tables
; space bar, dot, operators and exponent
00A2:	.db	1E,  '.', BB,  BD	;[MODE] on, [EXT] off
	.db	BE,  BF,  A0,  BC
00AA:	.db	' ', '^', 5F,  7E	;[S] on
	.db	'>', '<', 7C,  5C
00B2:	.db	1F,  '.', 9B,  9D	;[MODE] on, [EXT] on
	.db	9E,  9F,  80,  9C

; letter keys supported in the [S] mode, mapped to key codes in table 006E
00BA:	.db	'E', 'I', 'O', 'P'
	.db	'Q', 'R', 'T', 'U'
	.db	'W', 'Y', 0

; graphic characters (letter keys in mode [EXT] on, [S] on)
00C5:	.db	0B,  0C,  0D,  0E
	.db	40,  10,  11,  12
	.db	19,  13,  14,  15
	.db	16,  17,  18,  1A
	.db	25,  1B,  1C,  5B
	.db	26,  0F,  27,  1D
	.db	5D,  7F,  0

00E0:	.dw	03E8, 0064, 000A, 0001	;powers of ten
00E8:	.dw	0AC8, 0AE6, 0B04, 0B22	;segment tables for the 7-segm. digits

00F0:	.db FF, FF, FF, FF

; STOP key interrupt service routine, executed in the HALT-mode
00F4:	bisb	#1,8265    
00FA:	go			;exit from the HALT-mode back to the USER-mode

00FC:	.db 00, 00, 00, 00, 55, 55, 55, 55, 55, 55

; input line editor
0108:	tstb	8265
010C:	bmi	0116
010E:	movb	#C,@#E0		;hide cursor
0114:	br	013E
; show the cursor
0116:	cmpb	#B,8269		;cursor position
011C:	bcc	0124
011E:	movb	#B,8269
0124:	movb	8269,r0
0128:	mov	8260,r1		;pointer to the input line buffer
012C:	tstb	(r1)+		;find the end of the line
012E:	bne	012C
0130:	cmp	r1,#81A7	;6 bytes or less to the end of the buffer?
0134:	bcc	013A		;skip if yes
0136:	add	#10,r0		;cursor shaped as underscore
013A:	movb	r0,@#E0		;cursor position register
013E:	tst	825E		;previous keyboard state
0142:	bne	014A
0144:	bic	#0400,@#104	;stop the CPU clock until key pressed
; keyscan routine
014A:	mov	#20,r0
014E:	bitb	#1FC,@#100	;keyboard matrix columns
0154:	bne	016A		;branch if key pressed
0156:	sob	r0,014E
; the CPU clock was somehow restarted (or perhaps failed to be stopped), but
; no pressed key was detected
0158:	incb	826A		;counter of failed attempts to identify the
				;pressed key
015C:	cmpb	#14,826A
0162:	bcc	016A
0164:	bis	#1000,@#104	;power off when over 20 (decimal) consecutive
				;failed attempts to identify the pressed key
016A:	jsr	pc,0770		;code of pressed key in r0
016E:	tstb	r0
0170:	beq	013E		;no key pressed
0172:	cmpb	#A,r0
0176:	bcs	0180
; key codes 04 to 0A (EXE, arrows, DEL, RAM_init)
0178:	dec	r0
017A:	asl	r0
017C:	jmp	@045C(r0)
;
0180:	cmpb	r0,#30		;'0'
0184:	bcs	01A6
0186:	cmpb	#39,r0		;'9'
018A:	bcs	01A6
018C:	bit	#0220,r2
0190:	beq	0226		;[MODE] off, [S] off
0192:	bit	#0200,r2
0196:	bne	019C		;[MODE] on
; [S] key followed by number 0-9
0198:	jmp	044C		;select program r0
; [MODE] key followed by number 0-9
019C:	sub	#30,r0
01A0:	asl	r0
01A2:	jmp	@02D8(r0)
;
01A6:	bit	#0040,r2
01AA:	bne	0226		;[EXT] on
01AC:	bit	#0030,r2
01B0:	bne	022C		;[S] or [F] on
01B2:	tstb	8264
01B6:	bmi	0216
01B8:	bitb	#20,8264	;flags, calculation result on the display?
01BE:	beq	0226
; the display shows a result of previous calculation, which can be used as
; first argument of subsequent calculations
01C0:	bicb	#7F,8264
; any binary operator which would use this argument?
01C6:	cmpb	#2B,r0		;'+'
01CA:	beq	01E4
01CC:	cmpb	#2D,r0		;'-'
01D0:	beq	01E4
01D2:	cmpb	#2A,r0		;'*'
01D6:	beq	01E4
01D8:	cmpb	#2F,r0		;'/'
01DC:	beq	01E4
01DE:	cmpb	#5E,r0		;'^'
01E2:	bne	0226
01E4:	mov	r0,-(sp)	;save the operator
; display the previous calculation result again using full precision
01E6:	mov	#822C,r1	;variable ANS
01EA:	mov	-(r1),-(sp)
01EC:	mov	-(r1),-(sp)
01EE:	mov	-(r1),-(sp)
01F0:	mov	-(r1),-(sp)
01F2:	mov	#00F6,-(sp)	;10 (decimal) digits printing precision
01F6:	mov	#816D,-(sp)	;destination address = input line buffer
01FA:	jsr	pc,28CC		;convert FP number on stack to decimal ASCII
01FE:	bisb	#80,8265
0204:	mov	#816D,r4	;input line buffer
0208:	jsr	pc,1248		;display string
020C:	dec	r4
020E:	mov	r4,8260		;pointer to the input line buffer
0212:	mov	(sp)+,r0	;restore the operator
0214:	br	0226
; test for the "E-" sequence which will be replaced with a single character 7D
0216:	cmpb	#2D,r0		;'-'
021A:	bne	0226
021C:	mov	8260,r3		;pointer to the input line buffer
0220:	cmpb	#7B,-(r3)	;'E', exponent
0224:	beq	02BA
; mode [EXT]
0226:	mov	#0065,r3	;empty table, r3 points to byte 00
022A:	br	0260
; mode [S]
022C:	mov	#0021,r1	;table of key codes
0230:	mov	#0676,r3	;table of corresponding keywords
0234:	bit	#0020,r2	;r2 = mode
0238:	bne	0242		;branch if mode [S]
; mode [F]
023A:	mov	#0033,r1	;table of key codes
023E:	mov	#06DA,r3	;table of corresponding keywords
; scan the r1 table for key code r0
0242:	mov	r1,r2
0244:	tstb	(r1)
0246:	beq	01B2		;not found
0248:	cmpb	r0,(r1)+
024A:	bne	0244
; find a corresponding entry in the r3 table
024C:	sub	r2,r1		;r1 = index of the entry
024E:	dec	r1
0250:	beq	0258
0252:	tstb	(r3)+
0254:	bne	0252
0256:	sob	r1,0252
; copy the keyword pointed to by r3 to the input line buffer
0258:	movb	(r3)+,r0
025A:	bne	0260
025C:	jmp	0108		;end of the keyword
0260:	tstb	8264
0264:	bmi	0270
0266:	mov	#816D,8260	;initialise pointer to the input line buffer
026C:	clrb	@8260		;clear the input line buffer
; put the character r0 to the input line buffer
0270:	cmp	8260,#81AC	;end of the input line buffer
0276:	bcc	025C		;branch if out of room
0278:	bisb	#80,8265
027E:	mov	8260,r1		;pointer to the input line buffer
0282:	sub	#816D,r1	;input line buffer
0286:	movb	r1,8269		;cursor position
028A:	movb	@8260,r1	;previous character in the input line buffer
028E:	movb	r0,@8260	;new character
0292:	inc	8260
0296:	tstb	r1		;previous character
0298:	bne	029E		;branch if new character overwrites an old one
; new characters are appended at the end of the line
029A:	clrb	@8260		;terminate the line
029E:	jsr	pc,097C		;display character r0
02A2:	cmp	8260,#B		;nonsense ???
02A8:	bcs	0258		;branch never made
02AA:	movb	@8260,r0
02AE:	bne	02B4
02B0:	mov	#20,r0		;space when appending characters
02B4:	jsr	pc,09F8		;print character r0
02B8:	br	0258
; replace the "E-" sequence with a single character 7D
02BA:	dec	8260		;pointer to the input line buffer
02BE:	mov	#7D,r0		;'E-'
02C2:	movb	r0,@8260
02C6:	inc	8260
; the above 4 instructions could be replaced with MOV #7D,R0 : MOVB R0,(R3)
02CA:	decb	8269		;cursor position
02CE:	jsr	pc,09F8		;print character r0
02D2:	incb	8269
02D6:	br	025C

02D8:	.dw	02EC		;MODE 0
	.dw	033A		;MODE 1
	.dw	03B4		;MODE 2
	.dw	03DC		;MODE 3
	.dw	03E8		;MODE 4
	.dw	0410		;MODE 5
	.dw	042E		;MODE 6
	.dw	03C6		;invalid mode
	.dw	03C6		;invalid mode
	.dw	03C6		;invalid mode

; MODE 0
02EC:	bic	#C7B1,8256
02F2:	bicb	#2,8008
02F8:	bisb	#1,8008
02FE:	movb	@#8008,@#88
0304:	mov	#8030,r1
0308:	mov	#6,r0
030C:	clrb	(r1)
030E:	clrb	8080(r1)
0312:	add	#8,r1
0316:	sob	r0,030C
0318:	mov	#0019,r4	;string "READY P"
031C:	clr	8264
0320:	movb	(r4)+,r0
0322:	beq	032A
0324:	jsr	pc,097C		;display character r0
0328:	br	0320
032A:	movb	8268,r0		;selected program
032E:	bis	#30,r0		;'0'
0332:	jsr	pc,097C		;display character r0
0336:	jmp	0B9C		;direct mode main loop

; MODE 1
033A:	bic	#C731,8256
0340:	bis	#0080,8256	;set write mode
0346:	bicb	#1,8008
034C:	bis	#2,8008
0352:	movb	@#8008,@#88
0358:	jsr	pc,0A5E		;display free memory using 7-segm. digits
; display "P 0123456789"
035C:	mov	#816D,r1	;input line buffer
0360:	movb	#50,(r1)+	;'P'
0364:	movb	#20,(r1)+	;space
0368:	mov	#822C,r5	;table of end addresses of BASIC programs
036C:	mov	#826B,r4	;address of BASIC programs
0370:	mov	#30,r3		;'0'
0374:	mov	#14,r0		;diamonds
0378:	cmp	r4,(r5)
037A:	bne	037E
037C:	mov	r3,r0
037E:	movb	r0,(r1)+
0380:	mov	(r5)+,r4
0382:	inc	r3
0384:	cmp	r5,#8240	;end of the table?
0388:	bcs	0374
038A:	clrb	(r1)
038C:	clr	8264
0390:	mov	#816D,r4	;input line buffer
0394:	movb	(r4)+,r0
0396:	beq	039E
0398:	jsr	pc,097C		;display character r0
039C:	br	0394
039E:	movb	8268,r0		;selected program
03A2:	add	#2,r0
03A6:	movb	r0,8269		;cursor position
03AA:	bisb	#80,8265
03B0:	jmp	0BA0		;direct mode main loop

; MODE 2 - trace on
03B4:	bis	#0008,8256
03BA:	movb	#1,8028
03C0:	movb	@#8028,@#A8
03C6:	bic	#0230,8256
03CC:	bicb	#6,8000
03D2:	movb	@#8000,@#80
03D8:	jmp	0108

; MODE 3 - trace off
03DC:	bic	#0008,8256
03E2:	clrb	8028
03E6:	br	03C0

; MODE 4
03E8:	bic	#0006,8256
03EE:	bisb	#10,8008
03F4:	clrb	8018
03F8:	clrb	8020
03FC:	movb	@#8008,@#88
0402:	movb	@#8018,@#98
0408:	movb	@#8020,@#A0
040E:	br	03C6

; MODE 5
0410:	bic	#0006,8256
0416:	bis	#0002,8256
041C:	bicb	#10,8008
0422:	movb	#1,8018
0428:	clrb	8020
042C:	br	03FC

; MODE 6
042E:	bic	#0006,8256
0434:	bis	#0004,8256
043A:	bicb	#10,8008
0440:	clrb	8018
0444:	movb	#1,8020
044A:	br	03FC

; select program r0
044C:	sub	#30,r0
0450:	movb	r0,8268		;selected program
0454:	tstb	8256		;mode
0458:	bpl	045E		;branch if run mode (bit 7 clr)
045A:	jmp	033A		;MODE 1
045E:	jmp	0E08		;RUN from line 1

0462:	.dw	09F6		;key code = 4, EXE, vector points to: rts pc
	.dw	0470		;key code = 5, arrow left
	.dw	04C4		;key code = 6, arrow right
	.dw	05C0		;key code = 7, AC
	.dw	050E		;key code = 8, DEL
	.dw	05D8		;key code = 9, ANS
	.dw	0626		;key code = A, RAM initialisation

; key code = 5, arrow left
0470:	tstb	8264
0474:	bpl	050A
0476:	tstb	8269		;cursor position
047A:	ble	050A
047C:	mov	8260,r0		;pointer to the input line buffer
0480:	sub	#816D,r0	;input line buffer
0484:	dec	8260
0488:	cmp	#B,r0
048C:	bcc	04BE
; scroll the display right
048E:	mov	#8058,r1	;pointer to the display buffer
0492:	mov	#B,r2		;counter of characters
; copy a character
0496:	mov	#7,r0		;counter of rows of a character
049A:	movb	-(r1),0008(r1)
049E:	movb	(r1),8088(r1)
04A2:	sob	r0,049A		;next row
04A4:	dec	r1		;skip unused byte
04A6:	sob	r2,0496		;next character
04A8:	mov	8260,r0		;pointer to the input line buffer
04AC:	movb	FFF5(r0),r0
04B0:	clrb	8269		;cursor position
04B4:	jsr	pc,09F8		;print character r0
04B8:	movb	#C,8269
04BE:	decb	8269
04C2:	br	050A

; key code = 6, arrow right
04C4:	tstb	8264
04C8:	bpl	050A
04CA:	tstb	@8260
04CE:	beq	050A
04D0:	inc	8260
04D4:	cmpb	8269,#B		;cursor position
04DA:	bcs	0506
; scroll the display left
04DC:	mov	#8000,r1	;pointer to the display buffer
04E0:	mov	#B,r2		;counter of characters
; copy a character
04E4:	inc	r1		;skip unused byte
04E6:	mov	#7,r0		;counter of rows of a character
04EA:	movb	0008(r1),(r1)
04EE:	movb	(r1)+,807F(r1)
04F2:	sob	r0,04EA		;next row
04F4:	sob	r2,04E4		;next character
04F6:	movb	@8260,r0
04FA:	bne	0500
04FC:	mov	#20,r0		;space
0500:	jsr	pc,09F8		;print character r0
0504:	br	050A
0506:	incb	8269		;cursor position
050A:	jmp	03C6

; key code = 8, DEL
050E:	tstb	8264
0512:	bpl	050A
0514:	movb	8269,r0		;cursor position
0518:	mov	8260,r1		;pointer to the input line buffer
051C:	tstb	(r1)
051E:	beq	050A
0520:	bit	#0020,r2
0524:	bne	057E
0526:	movb	0001(r1),(r1)+
052A:	bne	0526
052C:	mov	r0,r1
052E:	sub	#B,r0
0532:	neg	r0
0534:	mov	r0,r3
0536:	ble	0554
0538:	asl	r1
053A:	asl	r1
053C:	asl	r1
053E:	add	#8000,r1
0542:	inc	r1
0544:	mov	#7,r2
0548:	movb	0008(r1),(r1)
054C:	movb	(r1)+,807F(r1)
0550:	sob	r2,0548
0552:	sob	r0,0542
0554:	mov	8260,r1		;pointer to the input line buffer
0558:	add	r1,r3
055A:	tstb	(r1)+
055C:	bne	055A
055E:	dec	r1
0560:	mov	#20,r0
0564:	cmp	r3,r1
0566:	bcc	056A
0568:	movb	(r3),r0
056A:	movb	8269,r3		;cursor position
056E:	movb	#B,8269
0574:	jsr	pc,09F8		;print character r0
0578:	movb	r3,8269
057C:	br	050A

057E:	tstb	(r1)+
0580:	bne	057E
0582:	cmp	r1,#81AD
0586:	bcc	050A
0588:	movb	-(r1),0001(r1)
058C:	cmp	8260,r1		;pointer to the input line buffer
0590:	bcs	0588
0592:	movb	#20,(r1)
0596:	sub	#B,r0
059A:	bcc	05B6
059C:	neg	r0
059E:	mov	r0,r3
05A0:	mov	#8058,r1
05A4:	mov	#7,r2
05A8:	movb	-(r1),0008(r1)
05AC:	movb	(r1),8088(r1)
05B0:	sob	r2,05A8
05B2:	dec	r1
05B4:	sob	r3,05A4
05B6:	movb	#20,r0		;space
05BA:	jsr	pc,09F8		;print character r0
05BE:	br	050A

; key code = 7, AC
05C0:	mov	#816D,8260	;initialise pointer to the input line buffer
05C6:	clrb	@8260		;clear the input line buffer
05CA:	jsr	pc,0A32		;clear screen
05CE:	movb	#80,8265
05D4:	jmp	0BA0		;direct mode main loop

; key code = 9, ANS
05D8:	bit	#0030,r2	;r2 = mode
05DC:	beq	05EE		;[S] off, [F] off
05DE:	mov	#000C,r3	;keyword "DRAW "
05E2:	bit	#0020,r2	
05E6:	beq	0622		;[F] on
05E8:	mov	#0012,r3	;keyword "DRAWC "
05EC:	br	0622		;[S] on
; [S] off, [F] off
05EE:	mov	#822C,r1	;variable ANS
05F2:	mov	-(r1),-(sp)
05F4:	mov	-(r1),-(sp)
05F6:	mov	-(r1),-(sp)
05F8:	mov	-(r1),-(sp)
05FA:	mov	#00F6,-(sp)	;10 (decimal) digits printing precision
05FE:	mov	#812C,-(sp)	;destination address
0602:	jsr	pc,28CC		;convert FP number on stack to decimal ASCII
0606:	bicb	#7F,8264
060C:	mov	#812C,r3
0610:	bic	#0230,8256
0616:	bicb	#06,8000
061C:	movb	@#8000,@#80
0622:	jmp	0258

; RAM initialisation
0626:	jsr	pc,0662		;scan the RAM
062A:	mov	r0,8252		;top of the RAM
062E:	mov	#1A,8250	;number of variables
0634:	clr	8256		;mode
0638:	jsr	pc,1208		;clear all variables
; initialise the user defined character
063C:	mov	#81AD,r1	;user defined character buffer
0640:	mov	#7,r0
0644:	clrb	(r1)+
0646:	sob	r0,0644
; clear the GOSUB and FOR stacks, and the ANS variable
0648:	mov	#81B4,r1
064C:	mov	#3C,r0
0650:	clr	(r1)+
0652:	sob	r0,0650
; initialise the addresses of ends of BASIC programs 0-9
0654:	mov	#A,r0		;r1 = #822C
0658:	mov	#826B,(r1)+
065C:	sob	r0,0658
065E:	jmp	0B40		;restart the computer

; scan the RAM, returns the end address in r0
0662:	mov	#8000,r0	;start of the RAM
0666:	add	#0800,r0	;2kB chunks
066A:	mov	#A72E,(r0)	;arbitrary chosen test value
066E:	cmp	#A72E,(r0)	;A72E = 123456 octal
0672:	beq	0666
0674:	rts	pc

; table of keywords in mode [S] for keys in the table 0021
0676:	.asciz	"LETC "
	.asciz	"GOSUB "
	.asciz	"RUN "
	.asciz	"END"
	.asciz	" TO "
	.asciz	" STEP "
	.asciz	"NEXT "
	.asciz	"GOTO "
	.asciz	"IF "
	.asciz	" THEN "
	.asciz	"PRINT "
	.asciz	"INPUT "
	.asciz	"LIST "
	.asciz	"FOR "
	.asciz	"DEFM "
	.asciz	"STOP"
	.asciz	"RETURN"

; table of keywords in mode [F] for keys in the table 0033
06DA:	.asciz	"GETC("
	.asciz	"ASCI "
	.asciz	"CHR "
	.asciz	"SIN "
	.asciz	"FRAC "
	.asciz	"SGN "
	.asciz	"TAN "
	.asciz	"VAL "
	.asciz	"ASN "
	.asciz	"ACS "
	.asciz	"ATN "
	.asciz	"VAC"
	.asciz	"LOG "
	.asciz	"LN "
	.asciz	"EXP "
	.asciz	"CSR "
	.asciz	"RAN#"
	.asciz	"RND("
	.asciz	"AUTO "
	.asciz	"SET "
	.asciz	"MID("
	.asciz	"COS "
	.asciz	"LEN "
	.asciz	"CLEAR "
	.asciz	"INT "
	.asciz	"MODE "
	.asciz	"ABS "
	.asciz	"KEY"
	.asciz	"SQR "
	.db	0

; returns mode in r2 and code of pressed key in r0, r0=0 if no key pressed
0770:	jsr	pc,0820		;keyboard scan, returns key scan code in r0
0774:	mov	8256,r2		;mode
0778:	mov	r0,r1
077A:	bcc	081E		;return with r0=0 when key not pressed
077C:	bic	#6,@#8000	;[S] and [F] segments
0782:	movb	@#8000,@#80
0788:	cmp	#A,r0
078C:	bcc	0810		;branch if control keys
078E:	cmp	#14,r0
0792:	bcs	079A
; numeric keys (key scan codes 0B to 14)
0794:	add	#25,r0		;gives codes 30-39 for keys 0-9
0798:	br	0810
079A:	cmp	#1C,r0
079E:	bcs	07C4
; space bar, dot, operators and exponent (key scan codes 15-1C)
07A0:	movb	0051(r1),r0	;table 0066-006D
07A4:	bit	#0220,r2	;[MODE] off
07A8:	beq	0810		;basic mode
07AA:	movb	0095(r1),r0	;table 00AA-00B1
07AE:	bit	#0020,r2	;[S] on
07B2:	bne	0810
07B4:	movb	008D(r1),r0	;table 00A2-00A9
07B8:	bit	#0040,r2
07BC:	beq	0810		;[MODE] on, [EXT] off
07BE:	movb	009D(r1),r0	;table 00B2-00B9
07C2:	br	0810		;[MODE] on, [EXT] on
; letters (key scan codes 1D to 36)
07C4:	add	#24,r0		;gives codes 41-5A for keys A-Z
07C8:	bit	#0010,r2
07CC:	bne	0810		;[F] on
07CE:	bit	#0040,r2
07D2:	bne	07F8		;[EXT] on
07D4:	bit	#0020,r2
07D8:	beq	07EC		;[S] off
07DA:	mov	#00BA,r2	;table of supported letter keys
; search the table 00BA
07DE:	tstb	(r2)
07E0:	beq	0810
07E2:	cmpb	(r2)+,r0
07E4:	bne	07DE
07E6:	movb	FFB3(r2),r0	;table 006E, key codes in mode [S]
07EA:	br	0810
; [S] off
07EC:	bit	#0200,r2
07F0:	beq	0810		;[MODE] off, upper case letters
07F2:	add	#20,r0
07F6:	br	0810		;[MODE] on, lower case letters
; [EXT] on
07F8:	add	#40,r0		;Russian lower case letters
07FC:	bit	#220,r2
0800:	beq	0810		;[MODE] off, [S] off
0802:	add	#20,r0		;Russian upper case letters
0806:	bit	#0200,r2
080A:	bne	0810		;[MODE] on
; [EXT] on, [S] on
080C:	movb	00A8(r1),r0	;00C5, table of graphic characters
0810:	mov	8256,r2		;mode
0814:	bic	#0230,8256	;[MODE] off, [S] off, [F] off
081A:	bic	#FF00,r0
081E:	rts	pc

; keyboard scan
; if key pressed - returns Carry set and key scan code in r0
; if key not pressed or not identified - returns Carry clr and r0=0
0820:	mov	r2,-(sp)
0822:	mov	#10,r2
0826:	mov	@#104,-(sp)
082A:	bic	#0808,@#104
0830:	asr	r2		;r2 = 8, 4 or 2
0832:	mov	r2,@#102	;select the keyboard matrix row
0836:	mov	@#100,r1	;read the columns
083A:	beq	0896		;next row if no key pressed
; key debounce loop
083C:	mov	#4,r0
0840:	cmp	@#100,r1
0844:	bne	0896
0846:	sob	r0,0840
; key accepted
0848:	mov	(sp),@#104
084C:	asr	r1
084E:	mov	r2,r0
0850:	swab	r0
0852:	bis	r0,r1		;rows on bits 11-9, columns on bits 7-1
0854:	cmp	r1,825E		;previous keyboard state
0858:	bne	0886		;keyboard state changed
; still the same key pressed, test the keyboard timer for autorepeat
085A:	incb	8266		;keyboard timer
085E:	bitb	#8,8266
0864:	beq	08A4
0866:	bitb	#40,8266
086C:	beq	08A4
086E:	mov	(sp),@#104
0872:	bicb	#3F,8266
0878:	bic	#FDCF,8262	;mask bits: mode_on, [S], [F]
087E:	bis	8262,8256	;copy keyboard mode to mode
0884:	br	088A
; keyboard state changed
0886:	clrb	8266		;keyboard timer
088A:	mov	#0051,r0	;table of row patterns
088E:	cmpb	r1,(r0)+
0890:	beq	08B4		;pattern found
0892:	tstb	(r0)
0894:	bne	088E
; next column
0896:	cmpb	#2,r2
089A:	bne	082A
; key not pressed or not identified
089C:	clr	825E		;previous keyboard state
08A0:	clrb	8266		;keyboard timer
08A4:	clr	r0
08A6:	mov	(sp)+,@#104
08AA:	mov	(sp)+,r2
08AC:	mov	#E,@#102	;select all keyboard matrix rows
08B2:	rts	pc
; valid pattern found
08B4:	mov	r1,825E		;previous keyboard state
08B8:	clrb	826A		;clear the counter of failed attempts to
				;identify the pressed key
08BC:	mov	8256,8262	;copy mode to keyboard mode
08C2:	sub	#0052,r0	;r0 = index to the 0051 table (00 to 14)
08C6:	cmpb	#4,r2		;r2 = row
08CA:	bcs	08D6		;keys W, S, F ...
08CC:	beq	08D2		;keys Mode, <-, [S] ...
; keys AC, DEL, / ...
08CE:	add	#0014,r0
08D2:	add	#000F,r0
08D6:	movb	0946(r0),r0	;r0 = key scan code
08DA:	cmp	#16,r0		;scan code of the "dot" key? (mode ext)
08DE:	bne	08E8
08E0:	bit	#0200,8256	;mode
08E6:	bne	091A
08E8:	cmp	#3,r0		;scan code of the [F] key?
08EC:	bcs	08A6		;return with valid code
08EE:	beq	090E		;[F]
08F0:	cmp	#2,r0		;scan code of the [S] key?
08F4:	beq	0902		;[S]

; [MODE] off/on
08F6:	mov	#08FC,r1
08FA:	br	0926
08FC:	.dw	0200		;mode bit to be changed
	.dw	0030		;mode bit to be cleared
	.db	06, 06		;bit masks for display memory

; [S]
0902:	mov	#0908,r1
0906:	br	0926
0908:	.dw	0020, 0210
	.db	06, 02

; [F]
090E:	mov	#0914,r1
0912:	br	0926
0914:	.dw	0010, 0220
	.db	06, 04

; [EXT]
091A:	mov	#0920,r1
091E:	br	0926
0920:	.dw	0040, 0230
	.db	07, 01

; change mode according to table pointed to by r1
0926:	mov	(r1)+,r0
0928:	xor	r0,8256		;mode
092C:	bic	(r1)+,8256
0930:	bicb	(r1)+,@#8000
0934:	bit	r0,8256
0938:	beq	093E
093A:	bisb	(r1),@#8000
093E:	movb	@#8000,@#80
0944:	br	08A4		;no valid key scan code returned

; conversion tables: index to table 0051 -> key scan code
; row 08
0946:	.db	33, 2F, 22, 2D		;W, S, F, Q
	.db	1F, 21, 23, 34		;C, E, G, X
	.db	1D, 36, 20, 2E		;A, Z, D, R
	.db	1E, 30, 32		;B, T, V
; row 04
0955:	.db	01, 05, 02, 31		;Mode, <-, [S], U
	.db	24, 06, 03, 25		;H, ->, [F], I
	.db	26, 35, 2B, 27		;J, Y, O, K
	.db	2C, 28, 09, 29		;P, L, ANS, M
	.db	2A, 15, 1C, 1B		;N, space, = EE
; row 02
0969:	.db	07, 08, 1A, 14		;AC, DEL, /, 9
	.db	11, 0A, 12, 19		;6, Init, 7, *
	.db	17, 13, 0F, 0C		;-, 8, 4, 1
	.db	10, 0D, 0E, 18		;5, 2, 3, +
	.db	0B, 16, 04		;0, dot, EXE

; display character r0
097C:	mov	r2,-(sp)
097E:	tstb	8264		;does the screen need to be cleared?
0982:	bmi	098E		;branch if not
0984:	jsr	pc,0A32		;clear screen
0988:	bisb	#80,8264
; determine the cursor position from which scrolling is needed
098E:	mov	#B,r2
0992:	tstb	8265
0996:	bmi	099A
0998:	inc	r2
099A:	cmpb	8269,r2		;cursor position
099E:	bcs	09EC		;branch if scrolling not needed yet
09A0:	bitb	#40,8264	;delay between scrolling?
09A6:	beq	09C8		;branch if not
; delay
09A8:	mov	@#104,-(sp)
09AC:	bic	#0808,@#104
09B2:	mov	#0200,r1	;short delay
09B6:	bitb	#1,8264		;short or long delay?
09BC:	beq	09C2
09BE:	mov	#0E00,r1	;long delay
09C2:	sob	r1,09C2		;delay loop
09C4:	mov	(sp)+,@#104
; scrolling
09C8:	mov	#8000,r1
09CC:	dec	r2
09CE:	movb	r2,8269		;cursor position
09D2:	inc	r1
09D4:	movb	0008(r1),8080(r1)
09DA:	movb	0008(r1),(r1)+
09DE:	bit	#7,r1
09E2:	bne	09D4
09E4:	sob	r2,09D2
09E6:	bicb	#1,8264
; printing
09EC:	jsr	pc,09F8		;print character r0
09F0:	incb	8269		;cursor position
09F4:	mov	(sp)+,r2
09F6:	rts	pc

; print character r0 at position 8269
09F8:	bic	#FF00,r0
09FC:	dec	r0		;character codes start from 1
09FE:	mov	r0,-(sp)
0A00:	asl	r0
0A02:	asl	r0
0A04:	asl	r0
0A06:	sub	(sp)+,r0	;r0 = 7*r0
0A08:	add	#3AB0,r0	;font table, each entry occupies 7 bytes
0A0C:	cmp	#3D49,r0	;code 0x60 - user defined character
0A10:	bne	0A16
0A12:	mov	#81AD,r0	;user defined character
0A16:	movb	8269,r1		;cursor position
0A1A:	asl	r1
0A1C:	asl	r1
0A1E:	asl	r1
0A20:	add	#8001,r1	;address in the display memory
; copy 7 rows to LCD RAM and display memory
0A24:	movb	(r0),8080(r1)	;send pattern to LCD RAM
0A28:	movb	(r0)+,(r1)+	;write pattern to display memory
0A2A:	bit	#7,r1
0A2E:	bne	0A24
0A30:	rts	pc

; clear screen
0A32:	mov	r0,-(sp)
0A34:	mov	#80,r0
0A38:	inc	r0
0A3A:	clrb	7F80(r0)
0A3E:	clrb	(r0)+
0A40:	bit	#7,r0
0A44:	bne	0A3A
0A46:	cmp	r0,#E0
0A4A:	bcs	0A38
0A4C:	movb	#C,(r0)		;hide cursor
0A50:	mov	(sp)+,r0
0A52:	bisb	#1,8264		;long delay between scrollings
0A58:	clrb	8269		;cursor position
0A5C:	rts	pc

; display free memory using the four 7-segm. digits
0A5E:	mov	8250,r1		;number of variables
0A62:	asl	r1
0A64:	asl	r1
0A66:	asl	r1		;r1 = number of bytes occupied by the variables
0A68:	neg	r1
0A6A:	add	8252,r1		;top of the RAM
0A6E:	sub	823E,r1		;end of BASIC programs
; display r1 decimal using the four 7-segm. digits
0A72:	mov	#8030,r4
0A76:	mov	#6,r2
0A7A:	clrb	(r4)
0A7C:	clrb	8080(r4)
0A80:	add	#8,r4
0A84:	sob	r2,0A7A
0A86:	clr	r0
0A88:	div	00E0(r2),r0	;00E0 - table of powers of 10
; r0 = quotient, r1 = remainder
0A8C:	bne	0A98
0A8E:	tst	r4
0A90:	beq	0A98
0A92:	cmp	r2,#6
0A96:	bcs	0AB6
0A98:	mov	r0,r3
0A9A:	asl	r0
0A9C:	add	r3,r0
0A9E:	add	00E8(r2),r0	;addresses of segment tables
0AA2:	mov	0AC0(r2),r3
0AA6:	mov	#3,r4
0AAA:	bisb	(r0)+,(r3)
0AAC:	movb	(r3),8080(r3)
0AB0:	add	#8,r3
0AB4:	sob	r4,0AAA
0AB6:	cmpb	(r2)+,(r2)+	;= add #2,r2 ; next digit
0AB8:	cmp	r2,#6
0ABC:	blos	0A86
0ABE:	rts	pc

; addresses of the 7-segment fonts in the display memory
0AC0:	.dw	8030, 8038, 8040, 8050

; segments for the 1st digit
0AC8:	.db	1D, 03, 00	;0
	.db	10, 01, 00	;1
	.db	0E, 03, 00	;...
	.db	1A, 03, 00
	.db	13, 01, 00
	.db	1B, 02, 00
	.db	1F, 02, 00
	.db	11, 03, 00
	.db	1F, 03, 00
	.db	1B, 03, 00	;9

; segments for the 2nd digit
0AE6:	.db	14, 0F, 00
	.db	00, 06, 00
	.db	18, 0D, 00
	.db	08, 0F, 00
	.db	0C, 06, 00
	.db	0C, 0B, 00
	.db	1C, 0B, 00
	.db	04, 0E, 00
	.db	1C, 0F, 00
	.db	0C, 0F, 00

; segments for the 3rd digit
0B04:	.db	10, 1E, 01
	.db	00, 18, 00
	.db	00, 17, 01
	.db	00, 1D, 01
	.db	10, 19, 00
	.db	10, 0D, 01
	.db	10, 0F, 01
	.db	10, 18, 01
	.db	10, 1F, 01
	.db	10, 1D, 01

; segments for the 4th digit
; The third byte will be written to address E0, which sets the hardware
; cursor position. Value 0C means that no cursor will be shown.
0B22:	.db	1A, 07, 0C
	.db	00, 03, 0C
	.db	1C, 06, 0C
	.db	14, 07, 0C
	.db	06, 03, 0C
	.db	16, 05, 0C
	.db	1E, 05, 0C
	.db	02, 07, 0C
	.db	1E, 07, 0C
	.db	16, 07, 0C

; reset
0B40:	mov	#812C,sp
0B44:	mov	#0C80,@#104
0B4A:	clrb	@#E8
0B4E:	mov	#8000,r1
0B52:	clrb	(r1)
0B54:	clrb	8080(r1)
0B58:	add	#8,r1
0B5C:	movb	#11,(r1)
0B60:	movb	(r1),8080(r1)
0B64:	mov	#4,r0
0B68:	add	#8,r1
0B6C:	clrb	(r1)
0B6E:	clrb	8080(r1)
0B72:	sob	r0,0B68
0B74:	clrb	8268		;selected program
0B78:	clrb	8267		;number printing precision
0B7C:	clrb	826A
0B80:	clr	8256		;mode
0B84:	mov	#E,@#102	;select all keyboard matrix rows
0B8A:	cmp	#104,0100	;read columns, is it the key '+' or 'M' ?
0B90:	bne	0B98		;skip next instruction if not
0B92:	bis	#0008,@#104	;select fast clock
0B98:	jmp	02EC		;MODE 0

; direct mode main loop
0B9C:	clrb	8265
0BA0:	bicb	#DF,8264
0BA6:	mov	#812C,sp
0BAA:	bic	#0230,8256
0BB0:	bicb	#6,8000
0BB6:	movb	@#8000,@#80
0BBC:	jsr	pc,0108		;input line editor
0BC0:	tstb	8264
0BC4:	bmi	0BE0
0BC6:	tst	8256		;mode
0BCA:	bpl	0BD0		;branch if direct mode (bit 15 clr)
0BCC:	jmp	0E32		;continue program execution after STOP
0BD0:	bit	#0100,8256	;AUTO mode?
0BD6:	beq	0BA6		;branch if not
0BD8:	mov	8246,r5		;last line number
0BDC:	jmp	0F88		;auto numbering
;
0BE0:	jsr	pc,0A32		;clear screen
0BE4:	mov	r2,824C
0BE8:	clrb	8264
0BEC:	mov	#816D,r4	;input line buffer
0BF0:	mov	r4,r5
0BF2:	jsr	pc,26AC
0BF6:	mov	r2,8240
0BFA:	movb	(r2),r0
0BFC:	sub	#FFE5,r0	;E5-F1 - codes of direct mode commands
0C00:	bcs	0C0A
0C02:	asl	r0
0C04:	inc	r2
0C06:	jmp	@0DD2(r0)
;
0C0A:	tstb	8256		;mode
0C0E:	bmi	0CA6		;branch if wrt mode (bit 7 set)
; result of calculation in run mode
0C10:	clr	-(sp)
0C12:	jsr	pc,1D50		;evaluate expression
0C16:	tstb	r0
0C18:	beq	0C1E
0C1A:	jmp	165C
0C1E:	bit	#6000,(sp)
0C22:	bne	0C7E		;branch if string
; calculated expression evaluated to a number
; store the number in the variable ANS
0C24:	mov	sp,r0
0C26:	mov	#8224,r1	;variable ANS
0C2A:	mov	(r0)+,(r1)+
0C2C:	mov	(r0)+,(r1)+
0C2E:	mov	(r0)+,(r1)+
0C30:	mov	(r0)+,(r1)+
; display the number
0C32:	clr	-(sp)		;maximal printing precision
0C34:	mov	8256,r0		;mode
0C38:	bpl	0C4E		;branch if direct mode (bit 15 clr)
0C3A:	asr	r0
0C3C:	bcs	0C4E		;branch if STOP mode (bit 0 set)
0C3E:	add	#8000,(sp)
0C42:	movb	8267,(sp)	;number printing precision
0C46:	bne	0C52
0C48:	movb	#FFF6,(sp)	;10 (decimal) digits printing precision
0C4C:	br	0C52
0C4E:	movb	8267,(sp)	;number printing precision
0C52:	mov	#816D,-(sp)	;destination address = input line buffer
0C56:	jsr	pc,28CC		;convert FP number on stack to decimal ASCII
0C5A:	bisb	#20,8264	;flags, calculation result on the display
0C60:	clrb	8265
0C64:	bisb	#40,8264	;flags, delay between scrollings required
0C6A:	mov	#816D,r4	;input line buffer
0C6E:	jsr	pc,1248		;display string
0C72:	bit	#1000,824A
0C78:	beq	0BA0		;direct mode main loop
0C7A:	jmp	1738
;
; calculated expression evaluated to a string
0C7E:	mov	#816D,r2	;input line buffer
0C82:	mov	0002(sp),r3	;address of the string
0C86:	mov	0004(sp),r5	;length of the string
0C8A:	beq	0C9E		;branch if length is equal 0
; copy the string to the input line buffer
0C8C:	tstb	(sp)
0C8E:	bne	0C9A		;branch if not a string variable
0C90:	sub	#8,r3		;move the pointer to beginning of the variable
0C94:	movb	(r3)+,(r2)+	;copy the first character
0C96:	inc	r3
0C98:	br	0C9C
0C9A:	movb	(r3)+,(r2)+
0C9C:	sob	r5,0C9A
0C9E:	clrb	(r2)		;terminate the string in the input line buffer
0CA0:	add	#8,sp
0CA4:	br	0C60
;
; BASIC line number in wrt mode
0CA6:	jsr	pc,11D6		;fetch the line number to r0
0CAA:	bhi	0CB8
; number is equal 0 or has more than 4 digits
0CAC:	mov	r2,8254		;position of an error
0CB0:	mov	#32,r0		;error code 2
0CB4:	jmp	@1D4E		;= jump to 12D4, error handler
0CB8:	tstb	(r2)
0CBA:	bne	0CE8
0CBC:	bic	#0100,8256	;clear the AUTO mode
0CC2:	jsr	pc,1182		;return in r1 the address of BASIC line r0
0CC6:	beq	0CCC		;branch if line found, numbers match
0CC8:	jmp	1652
0CCC:	clr	r5
0CCE:	mov	r1,r3
0CD0:	tst	r0
0CD2:	beq	0CD6
0CD4:	cmpb	(r3)+,(r3)+
0CD6:	tstb	(r3)+
0CD8:	bne	0CD6
0CDA:	movb	(r3)+,(r1)+
0CDC:	cmp	r3,823E		;end of BASIC programs
0CE0:	bcs	0CDA
0CE2:	sub	r1,r3
0CE4:	neg	r3
0CE6:	br	0D7C
0CE8:	mov	r2,r3
0CEA:	tstb	(r3)+
0CEC:	bne	0CEA
0CEE:	cmpb	(r3)+,(r3)+
0CF0:	sub	r2,r3
0CF2:	mov	8250,r4		;number of variables
0CF6:	asl	r4
0CF8:	asl	r4
0CFA:	asl	r4		;r4 = number of bytes occupied by the variables
0CFC:	neg	r4
0CFE:	add	8252,r4		;top of the RAM
0D02:	sub	823E,r4		;end of BASIC programs
0D06:	mov	r0,8246
0D0A:	jsr	pc,1182		;return in r1 the address of BASIC line r0
0D0E:	bne	0D3E		;branch if no matching line number found
0D10:	mov	r1,8248		;expression evaluator stack pointer
0D14:	mov	r1,r5
0D16:	cmpb	(r5)+,(r5)+	;= add #2,r5
0D18:	tstb	(r5)+
0D1A:	bne	0D18
0D1C:	sub	r1,r5
0D1E:	sub	r3,r5
0D20:	bcc	0D26
0D22:	add	r5,r4
0D24:	bmi	0D46
0D26:	cmpb	(r1)+,(r1)+
0D28:	clr	r0
0D2A:	tst	r5
0D2C:	bne	0D34
0D2E:	movb	(r2)+,(r1)+
0D30:	bne	0D2E
0D32:	br	0D98
0D34:	tstb	(r1)
0D36:	beq	0D54
0D38:	movb	(r2)+,(r1)+
0D3A:	bne	0D34
0D3C:	br	0CCE
0D3E:	mov	r1,8248		;expression evaluator stack pointer
0D42:	cmp	r4,r3
0D44:	bcc	0D5E
0D46:	mov	#816D,8254	;position of error = input line buffer
0D4C:	mov	#31,r0		;error code 1
0D50:	jmp	@1D4E		;= jump to 12D4, error handler

0D54:	movb	(r2)+,(r1)+
0D56:	mov	r2,r3
0D58:	tstb	(r3)+
0D5A:	bne	0D58
0D5C:	sub	r2,r3
0D5E:	mov	823E,r5		;end of BASIC programs
0D62:	add	r5,r3
0D64:	cmp	r1,r5
0D66:	bcc	0D6C
0D68:	movb	-(r5),-(r3)
0D6A:	br	0D64
0D6C:	tst	r0
0D6E:	beq	0D76
; copy the line number
0D70:	movb	r0,(r5)+
0D72:	swab	r0
0D74:	movb	r0,(r5)+
; copy the line body
0D76:	movb	(r2)+,(r5)+
0D78:	bne	0D76
0D7A:	sub	r1,r3
; move end addresses of BASIC programs by r3
0D7C:	movb	8268,r1		;selected program
0D80:	asl	r1
0D82:	add	#822C,r1
0D86:	add	r3,(r1)+
0D88:	cmp	#823E,r1	;end of BASIC programs
0D8C:	bcc	0D86
0D8E:	mov	r3,r1
0D90:	jsr	pc,0A5E		;display free memory using 7-segm. digits
0D94:	tst	r5
0D96:	beq	0CC8
0D98:	mov	8248,r1		;expression evaluator stack pointer
0D9C:	bit	#0400,8256	;mode
0DA2:	beq	0DCE
0DA4:	bit	#0200,824C
0DAA:	beq	0DB8
0DAC:	mov	8242,r0
0DB0:	beq	0DCA
0DB2:	jsr	pc,1182		;return in r1 the address of BASIC line r0
0DB6:	br	0DCE
0DB8:	cmpb	(r1)+,(r1)+	;= add #2,r1 ; skip the line number
0DBA:	tstb	(r1)+		;search for the end of the line
0DBC:	bne	0DBA
0DBE:	movb	8268,r0		;selected program
0DC2:	asl	r0
0DC4:	cmp	r1,822C(r0)	;test if address within selected program
0DC8:	bcs	0DCE		;branch if yes
0DCA:	jmp	033A
0DCE:	jmp	0EB6

; direct mode commands
0DD2:	.dw	144E		;LETC
	.dw	14C4		;DEFM
	.dw	1598		;VAC
	.dw	15A0		;MODE
	.dw	1630		;SET
	.dw	1CB8		;DRAWC
	.dw	1CBE		;DRAW
	.dw	0DEC		;RUN
	.dw	0E7A		;LIST
	.dw	0F52		;AUTO
	.dw	0FAC		;CLEAR
	.dw	1006		;TEST
	.dw	1170		;WHO

; command RUN
0DEC:	tstb	(r2)
0DEE:	beq	0E08
0DF0:	jsr	pc,11D6		;fetch the line number to r0
0DF4:	ble	0E04
0DF6:	tstb	(r2)
0DF8:	beq	0DFE
0DFA:	jmp	1CAC		;ERR2
0DFE:	cmp	#270F,r0	;9999 decimal
0E02:	bcc	0E0C
0E04:	jmp	12C0		;ERR5
; RUN from line 1
0E08:	mov	#1,r0
0E0C:	jsr	pc,1182		;return in r1 the address of BASIC line r0
0E10:	bcc	0E16		;branch if line found
0E12:	jmp	02EC
; clear the GOSUB and FOR stacks
0E16:	mov	#81B4,r3
0E1A:	mov	#0038,r2
0E1E:	clr	(r3)+
0E20:	sob	r2,0E1E
0E22:	mov	r1,825C		;address of current BASIC line
0E26:	cmpb	(r1)+,(r1)+	;= add #2,r1 ; skip the line number
0E28:	mov	r1,825A
0E2C:	mov	#166A,8258	;address of main execution loop
0E32:	jsr	pc,0A32		;clear screen
0E36:	bicb	#3,8008		;clear WRT segment
0E3C:	incb	8008		;show RUN segment
0E40:	movb	@#8008,@#88
; clear the four 7-segment digits
0E46:	mov	#B0,r3
0E4A:	mov	#4,r1
0E4E:	clrb	(r3)
0E50:	add	#8,r3
0E54:	sob	r1,0E4E
0E56:	movb	#E,(r3)		;display a 7-segment 'P' character
0E5A:	movb	#6,@#D8
0E60:	bic	#07B1,8256	;mode
0E66:	bis	#8000,8256	;program execution mode
0E6C:	movb	#80,8265
0E72:	mov	825A,r2
0E76:	jmp	@8258

; command LIST
0E7A:	mov	#1,r0		;default line number
0E7E:	tstb	(r2)
0E80:	beq	0E9A
0E82:	jsr	pc,11D6		;fetch the line number to r0
0E86:	ble	0E96
0E88:	tstb	(r2)
0E8A:	beq	0E90
0E8C:	jmp	1CAC		;ERR2
0E90:	cmp	#270F,r0	;9999 decimal
0E94:	bcc	0E9A
0E96:	jmp	12C0		;ERR5
0E9A:	bis	#0400,8256	;mode
0EA0:	bic	#0100,8256	;clear the AUTO mode
0EA6:	jsr	pc,1182		;return in r1 the address of BASIC line r0
0EAA:	bcc	0EB6		;branch if line found
0EAC:	tstb	8256		;mode
0EB0:	bpl	0F4E		;branch if run mode (bit 7 clr)
0EB2:	jmp	033A
0EB6:	jsr	pc,11C8		;get a word from address r1 to r5
0EBA:	cmpb	(r1)+,(r1)+	;= add #2,r1 ; skip line number
0EBC:	mov	r1,-(sp)
0EBE:	mov	#816D,r4	;destination address = input line buffer
0EC2:	jsr	pc,2A22		;convert r5 to decimal ASCII (line number)
0EC6:	movb	#20,(r4)+	;space
0ECA:	mov	(sp)+,r5	;pointer to the BASIC line
0ECC:	jsr	pc,2732		;copy BASIC line to r4 expanding keywords
0ED0:	mov	r5,8248		;8248 used as local temporary variable
0ED4:	mov	#816D,r4	;input line buffer
0ED8:	clrb	8265
0EDC:	mov	#C,r5
0EE0:	tstb	8256		;mode
0EE4:	bmi	0EF8		;branch if write mode (bit 7 set)
0EE6:	clr	r5
0EE8:	mov	#8040,8264
0EEE:	tstb	8256		;mode
0EF2:	bmi	0EF8		;branch if write mode (bit 7 set)
0EF4:	clrb	8265
0EF8:	jsr	pc,1258		;test for STOP, EXE, AC keys
0EFC:	movb	(r4)+,r0
0EFE:	beq	0F0A
0F00:	jsr	pc,097C		;display character r0
0F04:	sob	r5,0EF8
0F06:	decb	8269		;cursor position
0F0A:	dec	r4
0F0C:	mov	r4,8260		;pointer to the input line buffer
0F10:	bit	#0400,8256	;mode
0F16:	bne	0F1C
0F18:	jmp	0B9C		;direct mode main loop
0F1C:	bit	#0100,8256	;AUTO mode?
0F22:	beq	0F34		;branch if not
0F24:	bic	#0400,8256	;mode
0F2A:	bisb	#80,8265
0F30:	jmp	0BA6
0F34:	tstb	8256		;mode
0F38:	bmi	0F2A		;branch if write mode (bit 7 set)
0F3A:	jsr	pc,10F8		;delay
0F3E:	mov	8248,r1		;pointer to the BASIC line
0F42:	movb	8268,r0		;selected program
0F46:	asl	r0
0F48:	cmp	r1,822C(r0)	;test if address within selected program
0F4C:	bcs	0EB6
0F4E:	jmp	02EC

; command AUTO
0F52:	tstb	8256		;mode
0F56:	bmi	0F5C		;branch if write mode (bit 7 clr)
0F58:	jmp	12B4		;ERR2
0F5C:	mov	#A,r0		;default line number increment step
0F60:	tstb	(r2)		;end of the statement?
0F62:	beq	0F7C		;branch if no increment step specified
0F64:	jsr	pc,11D6		;fetch the specified increment step to r0
0F68:	ble	0F78
0F6A:	tstb	(r2)		;end of the statement?
0F6C:	beq	0F72		;branch if no more arguments
0F6E:	jmp	1CAC		;ERR2
0F72:	cmp	#270F,r0	;9999 decimal
0F76:	bcc	0F7C
0F78:	jmp	12C0		;ERR5
0F7C:	mov	r0,8244
0F80:	mov	#2710,r0	;requested line number 10000
0F84:	jsr	pc,1182		;returns in r5 the last line number
0F88:	mov	r5,8246
0F8C:	add	8244,r5		;add the increment step
0F90:	mov	#816D,r4	;destination address = input line buffer
0F94:	jsr	pc,2A22		;convert r5 to decimal ASCII
0F98:	clrb	(r4)
0F9A:	bisb	#80,8265
0FA0:	clrb	8264
0FA4:	bis	#0500,8256	;mode
0FAA:	br	0ED4

; command CLEAR
0FAC:	tstb	8256		;mode
0FB0:	bmi	0FB6		;branch when write mode (bit 7 set)
0FB2:	jmp	12B4		;ERR2 when run mode
0FB6:	tstb	(r2)		;end of the statement?
0FB8:	beq	0FD4		;CLEAR - erase selected program
0FBA:	cmpb	#41,(r2)	;'A'
0FBE:	beq	0FC4		;CLEARA - erase all programs
; missing test for the end of the statement, which causes for example CLEARABC
; to be accepted
0FC0:	jmp	1CAC		;ERR2
; erase all programs - initialise all end addresses of programs to #826B
0FC4:	mov	#822C,r1
0FC8:	mov	#A,r0
0FCC:	mov	#826B,(r1)+
0FD0:	sob	r0,0FCC
0FD2:	br	1002
; erase selected program
0FD4:	movb	8268,r0		;selected program
0FD8:	asl	r0
0FDA:	add	#822C,r0
0FDE:	mov	(r0),r2		;r2 = end address of selected BASIC program
0FE0:	mov	#826B,r1
0FE4:	tstb	8268		;selected program
0FE8:	beq	0FEE
0FEA:	mov	FFFE(r0),r1	;r1 = start address of selected BASIC program
; move memory block starting from address r2, ending at address in variable
; 823E, to address r1 
0FEE:	cmp	r2,823E		;end of BASIC programs
0FF2:	bcc	0FF8
0FF4:	movb	(r2)+,(r1)+
0FF6:	br	0FEE
0FF8:	sub	r1,r2
; move end addresses of BASIC programs down by r2
0FFA:	sub	r2,(r0)+
0FFC:	cmp	#823E,r0	;end of BASIC programs
1000:	bcc	0FFA
1002:	jmp	033A

; command TEST
1006:	mov	#812C,sp
100A:	mov	#80,r1
100E:	mov	#60,r0
1012:	clrb	(r1)+
1014:	sob	r0,1012
1016:	movb	#C,(r1)
; test the ROM integrity
101A:	mov	#1159,r4	;string "defekt PZU" (bad ROM)
101E:	mov	#80,r0		;word counter
1022:	clr	r1		;starting address
1024:	clr	r2		;calculated checksum
1026:	add	(r1)+,r2
1028:	sob	r0,1026
102A:	add	#8,r1		;skip 0100-0107 address range
102E:	mov	#1F7C,r0
1032:	add	(r1)+,r2
1034:	sob	r0,1032
1036:	beq	103C		;ckecksum OK
1038:	jsr	pc,110E		;display string r4, then wait for EXE key
; test the RAM
103C:	jsr	pc,0662		;scan the RAM, returns end address in r0
1040:	mov	#1164,r4	;string "defekt OZU" (bad RAM)
1044:	mov	#4,r5		;four test patterns
1048:	mov	#1134,r2	;RAM test patterns
104C:	mov	sp,r1
104E:	mov	(r2)+,r3
; fill the RAM from the sp up to the end address with the test pattern
1050:	mov	r3,(r1)+
1052:	cmp	r1,r0
1054:	bcs	1050
; compare all RAM locations from the end address down to the sp against
; the test pattern
1056:	cmp	r3,-(r1)
1058:	beq	1060
105A:	mov	#1066,-(sp)	;return address
105E:	br	110E		;display string r4, then wait for EXE key
1060:	cmp	sp,r1
1062:	bcs	1056
1064:	sob	r5,104E		;next test pattern
; test the mode signs of the LCD
1066:	mov	#113C,r1	;table of LCD controller port addresses
106A:	mov	#114F,r2	;table of data bytes
106E:	mov	#1148,r3	;table of numbers of bytes sent to single port
1072:	movb	(r3)+,r4	;number of data bytes
1074:	movb	(r2)+,@0000(r1)	;write data byte to the LCD controller
1078:	jsr	pc,10F8		;delay between LCD test patterns
107C:	sob	r4,1074		;next data byte
107E:	clrb	@(r1)+		;clear the LCD controller port
1080:	tstb	(r3)		;end of the "numbers" table?
1082:	bne	1072		;next LCD controller port
; test the four 7-segment digits by displaying 1111,2222,3333,....,9999
1084:	clr	-(sp)
1086:	add	#0457,(sp)	;0x0457 = 1111decimal
108A:	mov	(sp),r1
108C:	jsr	pc,0A72		;display r1 decimal
1090:	jsr	pc,10F8		;delay between LCD test patterns
1094:	cmp	#270F,(sp)	;0x270F = 9999decimal
1098:	bne	1086		;next value
; test rows of the dot matrix area
109A:	mov	#8,r5		;8 rows
109E:	mov	#80,r1		;starting LCD port address
; activate all segments of the selected row
10A2:	mov	#C,r0
10A6:	movb	#1F,(r1)
10AA:	add	#8,r1
10AE:	sob	r0,10A6
10B0:	jsr	pc,10F8		;delay between LCD test patterns
; clear all segments of the selected row
10B4:	mov	#C,r0
10B8:	sub	#8,r1
10BC:	clrb	(r1)
10BE:	sob	r0,10B8
; next row
10C0:	inc	r1
10C2:	sob	r5,10A2
; test columns of the LCD
10C4:	mov	#C,r5		;number of 5x7 character fields
10C8:	mov	#81,r3
10CC:	mov	#01,r2
; patterns 01, 02, 04, 08, 10 activate consecutive columns,
; pattern 20 clears the character field (equivalent to 00, because three most
; significant bits are ignored)
10D0:	mov	r3,r1
10D2:	mov	#7,r0		;7 rows of the character field
10D6:	movb	r2,(r1)+
10D8:	sob	r0,10D6
10DA:	bit	#20,r2		;last column?
10DE:	bne	10E8
10E0:	jsr	pc,10F2		;delay
10E4:	asl	r2		;next column
10E6:	br	10D0
10E8:	add	#8,r3		;next character field
10EC:	sob	r5,10CC
10EE:	jmp	0626		;RAM initialisation

; delay between LCD column testing (ca. 0.35s)
10F2:	mov	#0400,r0
10F6:	br	10FC

; delay between LCD test patterns
10F8:	mov	#0E00,r0
10FC:	mov	@#104,-(sp)
1100:	bic	#0808,@#104
1106:	sob	r0,1106
1108:	mov	(sp)+,@#104
110C:	rts	pc

; display string r4, then wait for EXE key
110E:	clr	8264
1112:	jsr	pc,1248		;display string
; wait until EXE key pressed
1116:	bic	#0400,@#104	;stop the CPU clock until key pressed
111C:	jsr	pc,0770		;code of pressed key in r0
1120:	cmpb	#4,r0		;key code 4, EXE
1124:	bne	1116
1126:	mov	#80,r0
112A:	clrb	(r0)+
112C:	cmp	r0,#E0
1130:	bcs	112A
1132:	rts	pc

; RAM test patterns
1134:	.dw	FFFF, AAAA, 5555, 0000  

113C:	.dw	0080
	.dw	0088
	.dw	0098
	.dw	00A0
	.dw	00A8
	.dw	00D8
1148:	.db	03, 03, 01, 01, 01, 01, 00
114F:	.db	01, 02, 04	;EXT, [S], [F]
	.db	01, 02, 10	;RUN, WRT, DEG
	.db	01		;RAD
	.db	01		;GRA
	.db	01		;TR
	.db	08		;STOP

1159:	.asciz	"Дефект ПЗУ"	;bad ROM
1164:	.asciz	"Дефект ОЗУ"	;bad RAM
116F:	.even

; command WHO
1170:	mov	#0041,8264	;flags, long delay between scrollings required
1176:	mov	#0080,r4	;string "Programmu razrabotal Podorov A.N."
117A:	jsr	pc,1248		;display string
117E:	jmp	0BA0		;direct mode main loop

; expects requested BASIC line number in r0
; returns in r5 and 8242 nearest line number found (which may be greater or
; equal the requested line number), and in r1 address of this line
; Carry clr when line found, set when not found
; Zero set when line number exactly matches
; location 8248 (expression evaluator stack pointer) used as temporary
; variable
1182:	movb	8268,r5		;selected program
1186:	asl	r5
1188:	add	#822C,r5	;table of end addresses of BASIC programs
118C:	mov	#826B,r1	;address of BASIC program 0
1190:	tstb	8268		;selected program
1194:	beq	119A
1196:	mov	FFFE(r5),r1	;end address of previous BASIC program =
				;start address of current BASIC program
119A:	mov	(r5),8248	;end address of current BASIC program
119E:	clr	8242
11A2:	clr	r5
11A4:	cmp	r1,8248
11A8:	bcc	11BE
11AA:	jsr	pc,11C8		;get a word from address r1 to r5
11AE:	cmp	r5,r0
11B0:	bcc	11C2		;found line number greater or equal r0
11B2:	cmpb	(r1)+,(r1)+	;= add #2,r1 ;  skip the line number
11B4:	tstb	(r1)+		;search for the end of the line
11B6:	bne	11B4
11B8:	mov	r5,8242
11BC:	br	11A4
; line not found
11BE:	clear	cvzn
11C0:	sec
11C2:	rts	pc

; get the current BASIC line number to r5
11C4:	mov	825C,r1		;address of current BASIC line
; get a word from address r1 to r5, works with an odd address too
11C8:	movb	(r1)+,r5
11CA:	swab	r5
11CC:	clrb	r5
11CE:	bisb	(r1),r5
11D0:	swab	r5
11D2:	dec	r1
11D4:	rts	pc

; this routine converts integer decimal number in ASCII format to binary,
; source at address r2, result in r0
; returns Carry set when number of digits > 4
; returns Zero set when result = 0
11D6:	clr	r0
11D8:	mov	#5,r3
11DC:	movb	(r2)+,r1
11DE:	cmpb	r1,#30		;'0'
11E2:	bcs	1202
11E4:	cmpb	#39,r1		;'9'
11E8:	bcs	1202
11EA:	sub	#30,r1		;'0'
; r0 = 10dec * r0 + r1
11EE:	asl	r0
11F0:	add	r0,r1
11F2:	asl	r0
11F4:	asl	r0
11F6:	add	r1,r0
11F8:	beq	11DC
11FA:	sob	r3,11DC
11FC:	dec	r2
11FE:	sec
1200:	rts	pc
1202:	dec	r2
1204:	tst	r0
1206:	rts	pc

; clear all variables
1208:	mov	8250,r0		;number of variables
120C:	mov	8252,r1		;top of the RAM
1210:	clr	-(r1)
1212:	clr	-(r1)
1214:	clr	-(r1)
1216:	clr	-(r1)
1218:	sob	r0,1210
121A:	clrb	814E		;clear the special string variable $
121E:	rts	pc

; evaluate an expression to an integer number in r0
1220:	mov	#1000,-(sp)
1224:	jsr	pc,1D50		;evaluate expression
1228:	bit	#6000,(sp)
122C:	bne	1242
122E:	mov	r2,8242
1232:	jsr	r4,3AA8
1236:	.dw	2F72		;convert a FP number to 16-bit integer
	.dw	123A
123A:	mov	8242,r2
123E:	mov	(sp)+,r0
1240:	bcc	1246		;branch if conversion to integer succeeded
1242:	jmp	12C0		;ERR5
1246:	rts	pc

; display an ASCIIZ string from address r4
; printing can be interrupted with STOP, resumed with EXE, aborted with AC
1248:	jsr	pc,1258		;test for STOP, EXE, AC keys
124C:	movb	(r4)+,r0
124E:	beq	1256
1250:	jsr	pc,097C		;display character r0
1254:	br	1248
1256:	rts	pc

1258:	bitb	#1,8265		;STOP key pressed?
125E:	beq	128A		;branch if not
1260:	mov	r4,-(sp)
1262:	mov	r5,-(sp)
1264:	jsr	pc,0770		;code of pressed key in r0
1268:	bicb	#3,8265
126E:	cmpb	#7,r0		;key code 7, AC
1272:	beq	128C
1274:	cmpb	#4,r0		;key code 4, EXE
1278:	bne	1264
127A:	mov	(sp)+,r5
127C:	mov	(sp)+,r4
127E:	bit	#0200,r2	;mode on?
1282:	beq	128A
1284:	bisb	#2,8265
128A:	rts	pc
128C:	clrb	8050
1290:	clrb	8058
1294:	clrb	00D0
1298:	clrb	00D8
129C:	bic	#C631,8256	;mode
12A2:	mov	#812C,sp
12A6:	mov	#0BAA,-(sp)
12AA:	jmp	05C0

; ERR1 handler (out of memory)
12AE:	mov	#31,r0
12B2:	br	12CA
; ERR2 handler (syntax error)
12B4:	mov	#32,r0
12B8:	br	12CA
; ERR4 handler (GOTO/GOSUB to a non-existing line number)
12BA:	mov	#34,r0
12BE:	br	12CA
; ERR5 handler (argument error)
12C0:	mov	#35,r0
12C4:	br	12CA
; ERR7 handler (nesting error)
12C6:	mov	#37,r0
12CA:	mov	8240,8254	;position of error
12D0:	jmp	@1D4E		;= jump to 12D4, error handler

; error handler
12D4:	clr	8264
12D8:	mov	r0,r5
12DA:	mov	#144A,r4	;string "ERR"
12DE:	jsr	pc,1248		;display string
12E2:	mov	r5,r0
12E4:	jsr	pc,097C		;display character r0
12E8:	bit	#4000,8256	;mode
12EE:	bne	135C		;branch if INPUT mode on
12F0:	mov	8256,r0		;mode
12F4:	bpl	1340		;branch if program execution mode (bit 15 clr)
12F6:	asr	r0
12F8:	bcs	1340		;branch if STOP mode (bit 0 set)
12FA:	clrb	8050
12FE:	clrb	8058
1302:	clrb	00D0
1306:	clrb	00D8
130A:	incb	8269		;cursor position
130E:	mov	#50,r0		;'P'
1312:	jsr	pc,097C		;display character r0
1316:	movb	8268,r0		;selected program
131A:	add	#30,r0		;'0'
131E:	jsr	pc,097C		;display character r0
1322:	mov	#2D,r0		;'-'
1326:	jsr	pc,097C		;display character r0
132A:	jsr	pc,11C4		;get the current BASIC line number to r5
132E:	mov	#816D,r4	;destination address = input line buffer
1332:	jsr	pc,2A22		;convert r5 to decimal ASCII
1336:	clrb	(r4)
1338:	mov	#816D,r4
133C:	jsr	pc,1248		;display string
1340:	jsr	pc,0770		;code of pressed key in r0
1344:	cmpb	#7,r0		;key code 7, AC
1348:	bne	1354
134A:	bic	#8731,8256	;mode
1350:	jmp	05C0
1354:	cmpb	#9,r0		;key code 9, ANS
1358:	bne	1340
135A:	br	137E		;show the position of the error

135C:	jsr	pc,0770		;code of pressed key in r0
1360:	cmpb	#7,r0		;key code 7, AC
1364:	beq	136C
1366:	cmpb	#9,r0		;key code 9, ANS
136A:	bne	135C
136C:	mov	#812C,sp
1370:	mov	825A,r2
1374:	bic	#4000,8256	;INPUT mode off
137A:	jmp	1BB6

; show the position of the error
137E:	clrb	8264
1382:	clrb	8269		;cursor position
1386:	mov	#816D,r4	;input line buffer
138A:	mov	8256,r0		;mode
138E:	bpl	13CC		;branch if program execution mode (bit 15 clr)
1390:	asr	r0
1392:	bcs	13CC		;branch if STOP mode (bit 0 set)
1394:	jsr	pc,11C4		;get the current BASIC line number to r5
1398:	jsr	pc,2A22		;convert r5 to decimal ASCII
139C:	movb	#20,(r4)+	;add space after the line number
13A0:	mov	825C,r5		;address of current BASIC line
13A4:	cmpb	(r5)+,(r5)+	;= add #2,r5 ; skip the line number
13A6:	mov	8254,r1		;position of the error
13AA:	sub	r5,r1
13AC:	bicb	#1,8008		;segment RUN
13B2:	bisb	#2,8008		;segment WRT
13B8:	movb	@#8008,@#88
13BE:	bic	#87B1,8256	;mode
13C4:	bis	#0080,8256	;select write mode
13CA:	br	13DE
;
13CC:	mov	#8060,r5
13D0:	mov	r4,r2
13D2:	mov	r5,r3
13D4:	movb	(r2)+,(r3)+
13D6:	bne	13D4
13D8:	mov	8254,r1		;position of the error
13DC:	sub	r4,r1
13DE:	jsr	pc,2732		;copy BASIC line to r4 expanding keywords
13E2:	mov	#816D,r4	;input line buffer
13E6:	mov	r1,r5
13E8:	movb	(r4)+,r0
13EA:	beq	1416
13EC:	jsr	pc,097C		;display character r0
13F0:	dec	r5
13F2:	bpl	13E8
13F4:	cmpb	#B,8269		;cursor position
13FA:	bcs	141E
13FC:	movb	8269,r3
1400:	mov	r4,8242
1404:	cmpb	#B,8269
140A:	bcs	1424
140C:	movb	(r4)+,r0
140E:	beq	1424
1410:	jsr	pc,097C		;display character r0
1414:	br	1404
1416:	mov	#20,r0		;' '
141A:	jsr	pc,097C		;display character r0
141E:	mov	r4,8260		;pointer to the input line buffer
1422:	br	142E
1424:	movb	r3,8269		;cursor position
1428:	mov	8242,8260
142E:	decb	8269
1432:	dec	8260		;pointer to the input line buffer
1436:	bisb	#80,8265
143C:	tstb	8256		;mode
1440:	bpl	1446		;branch if run mode (bit 7 clr)
1442:	jsr	pc,0A5E		;display free memory using 7-segm. digits
1446:	jmp	0BA6

144A:	.asciz	"ERR"

; command LETC
144E:	mov	#1000,-(sp)
1452:	jsr	pc,1D50		;evaluate expression
1456:	mov	(sp)+,r0
1458:	bit	#4000,r0	;string expected
145C:	bne	1462
145E:	jmp	12C0		;ERR5
1462:	mov	r2,825A		;pointer to the BASIC line
1466:	mov	#81AD,r5	;user defined character
146A:	mov	(sp)+,r1	;address of the string
146C:	mov	(sp)+,r2	;length of the string
146E:	beq	14B2
1470:	cmp	#7,r2
1474:	bcs	145E		;ERR5 if more than 7 characters in the string
1476:	tstb	r0
1478:	bne	1484		;branch if not a string variable
147A:	sub	#8,r1		;move the pointer to beginning of the variable
147E:	movb	(r1)+,r0	;first character of a string variable
1480:	inc	r1		;skip the string variable identifier 60
1482:	br	1486
1484:	movb	(r1)+,r0
1486:	cmpb	r0,#30		;'0'
148A:	bcs	145E		;ERR5 if invalid character
148C:	cmpb	#39,r0		;'9'
1490:	bcs	1498
1492:	sub	#30,r0
1496:	br	14A2
1498:	cmpb	#56,r0		;'V'
149C:	bcs	145E		;ERR5 if invalid character
149E:	sub	#37,r0		;'A'-0A
; reverse the order of bits
14A2:	mov	#5,r3		;counter of bits
14A6:	clr	r4
14A8:	asr	r0
14AA:	rol	r4
14AC:	sob	r3,14A8		;next bit
14AE:	movb	r4,(r5)+	;row bit pattern of the user defined character
14B0:	sob	r2,1484		;next row
; clear the uninitialised rows of the user defined character
14B2:	cmp	#81B4,r5	;end of RAM space allocated for the character?
; It should be: cmp #81B3,r5 !
; This bug causes the first byte of the GOSUB stack to be overwritten.
; Therefore, LETC cannot be used within a subroutine.
14B6:	bcs	14BC
14B8:	clrb	(r5)+
14BA:	br	14B2
14BC:	tst	(sp)+		;drop the unused, fourth word of the string
14BE:	mov	825A,r2		;pointer to the BASIC line
14C2:	br	159C

; command DEFM
14C4:	tst	8256		;mode
14C8:	bpl	1522		;branch if program execution mode (bit 15 clr)
14CA:	cmpb	#2C,(r2)	;','
14CE:	bne	1526
; undocumented syntax: DEFM,variable_name
; returns maximal number of additional variables
14D0:	inc	r2
14D2:	mov	#2000,-(sp)
14D6:	jsr	pc,1D50		;evaluate expression
14DA:	bit	#2000,(sp)	;numeric variable?
14DE:	beq	1536		;ERR5 if wrong type of the argument
; end address of the variable on the stack
14E0:	mov	8250,r0		;number of variables
14E4:	asl	r0
14E6:	asl	r0
14E8:	asl	r0		;r0 = number of bytes occupied by the variables
14EA:	neg	r0
14EC:	add	8252,r0		;top of the RAM
14F0:	sub	823E,r0		;end of BASIC programs
; r0 = amount of free RAM
14F4:	ror	r0
14F6:	asr	r0
14F8:	asr	r0		;r0 = maximal number of additional variables
14FA:	mov	r2,8244
14FE:	mov	r0,-(sp)
1500:	jsr	r4,3AA8
1504:	.dw	2F18		;convert a 16-bit signed integer to FP
	.dw	1508
1508:	mov	8244,r2
; copy the value to the specified variable
150C:	mov	000A(sp),r1
1510:	sub	#8,r1		;move the pointer to beginning of the variable
1514:	mov	(sp)+,(r1)+
1516:	mov	(sp)+,(r1)+
1518:	mov	(sp)+,(r1)+
151A:	mov	(sp)+,(r1)+
151C:	add	#8,sp
1520:	br	159C		;= jmp 1652
;
; run mode
1522:	tstb	(r2)
1524:	beq	1556		;branch if no argument
; DEFM with an argument
1526:	jsr	pc,1220		;evaluate expression to integer number in r0
152A:	blt	1536
152C:	add	#1A,r0
1530:	bit	#F000,r0
1534:	beq	153A
1536:	jmp	12C0		;ERR5
153A:	mov	r0,r5
; test if there's enough memory for variables
153C:	asl	r0
153E:	asl	r0
1540:	asl	r0
1542:	neg	r0
1544:	add	8252,r0		;top of the RAM
1548:	cmp	r0,823E		;end of BASIC programs
154C:	bcc	1552
154E:	jmp	12AE		;ERR1
1552:	mov	r5,8250		;number of variables
1556:	tst	8256
155A:	bmi	158C		;branch if direct mode (bit 15 set)
155C:	clr	8264
1560:	mov	8250,r5		;number of variables
1564:	mov	#816D,r4	;destination address = input line buffer
1568:	jsr	pc,2A22		;convert r5 to decimal ASCII
156C:	clrb	(r4)		;terminate the number with 0
156E:	mov	#158E,r4	;string "***VAR: "
1572:	jsr	pc,1248		;display string
1576:	mov	#816D,r4	;number of variables as ASCIIZ string
157A:	jsr	pc,1248		;display string
157E:	tstb	8256		;mode
1582:	bpl	1588		;skip if run mode (bit 7 clr)
1584:	jsr	pc,0A5E		;display free memory using 7-segm. digits
1588:	clrb	8265
158C:	br	159C		;= jmp 1652

158E:	.asciz	"***VAR: "
	.db	0

; command VAC
1598:	jsr	pc,1208		;clear all variables
159C:	jmp	1652

; command MODE
15A0:	cmpb	(r2),#34
15A4:	bcs	15D2
15A6:	bne	15CC
15A8:	bic	#0006,8256	;mode
15AE:	clrb	8018
15B2:	clrb	8020
15B6:	bisb	#10,8008
15BC:	clrb	@#98
15C0:	clrb	@#A0
15C4:	movb	@#8008,@#88
15CA:	br	162C
15CC:	cmpb	#36,(r2)
15D0:	bcc	15DC
15D2:	dec	r2
15D4:	mov	r2,8254		;position of error
15D8:	jmp	12C0		;ERR5
15DC:	beq	1600
15DE:	bic	#0006,8256
15E4:	bis	#0002,8256
15EA:	clrb	8020
15EE:	movb	#01,8018	;show segment RAD
15F4:	clrb	@#A0
15F8:	movb	#01,0098
15FE:	br	1620
1600:	bic	#0006,8256
1606:	bis	#0004,8256
160C:	clrb	8018
1610:	movb	#01,8020	;show segment GRA
1616:	clrb	0098
161A:	movb	#01,00A0
1620:	bicb	#10,8008
1626:	movb	@#8008,@#88
162C:	inc	r2
162E:	br	159C

; command SET
1630:	clr	r0
1632:	cmpb	#4E,(r2)+	;'N'
1636:	beq	164C		;SET N
1638:	dec	r2
163A:	jsr	pc,1220		;evaluate expression to integer number in r0
163E:	ble	1646
1640:	cmp	#A,r0
1644:	bcc	164A
1646:	jmp	12C0		;ERR5
164A:	neg	r0
164C:	movb	r0,8267		;number printing precision
1650:	br	159C		;=jmp 1652

1652:	mov	8256,r0		;mode
1656:	bpl	165C		;branch if direct mode (bit 15 clr)
1658:	asr	r0
165A:	bcc	166A		;branch if not STOP mode (bit 0 clr)
165C:	mov	#816D,8260	;initialise pointer to the input line buffer
1662:	clrb	@8260		;clear the input line buffer
1666:	jmp	0BA0		;direct mode main loop

; main loop of the BASIC program execution
166A:	cmpb	#3A,(r2)	;":"
166E:	bne	1672
1670:	inc	r2
1672:	tstb	(r2)+
1674:	beq	1680
1676:	cmpb	#21,-(r2)	;"!"
167A:	bne	1688
167C:	tstb	(r2)+
167E:	bne	167C
; next BASIC line
1680:	mov	r2,825C		;address of current BASIC line
1684:	add	#2,r2		;skip the line number
1688:	bitb	#3,8265
168E:	beq	169A
1690:	mov	#169A,8258
1696:	jmp	179A
; test for the end of the program
169A:	movb	8268,r0		;selected program
169E:	asl	r0
16A0:	cmp	r2,822C(r0)
16A4:	bcc	170C		;END
16A6:	bit	#0008,8256	;trace mode
16AC:	beq	16B6		;branch if trace off
16AE:	mov	#16B6,8258
16B4:	br	179A
16B6:	mov	r2,8240
16BA:	movb	(r2),r0
16BC:	sub	#FFD7,r0
16C0:	bcs	16D4
16C2:	cmpb	#14,r0
16C6:	bcc	16CC
16C8:	jmp	1CAC		;ERR2
; commands (codes D7 to EB)
16CC:	asl	r0
16CE:	inc	r2
16D0:	jmp	@16E2(r0)
; functions (codes C0 to D6) and expressions
16D4:	clr	-(sp)
16D6:	jsr	pc,1D50		;evaluate expression
16DA:	tstb	r0
16DC:	bne	166A
16DE:	jmp	1CAC		;ERR2

16E2:	.dw	17FA		;CSR
	.dw	1874		;NEXT
	.dw	193C		;GOTO
	.dw	1910		;GOSUB
	.dw	198E		;RETURN
	.dw	19BE		;IF
	.dw	1AFC		;FOR
	.dw	1728		;PRINT
	.dw	1BB6		;INPUT
	.dw	12B4		;THEN, handled elsewhere, vector points to ERR2
	.dw	12B4		;TO, as above
	.dw	12B4		;STEP, as above
	.dw	1794		;STOP
	.dw	170C		;END
	.dw	144E		;LETC
	.dw	14C4		;DEFM
	.dw	1598		;VAC
	.dw	15A0		;MODE
	.dw	1630		;SET
	.dw	1CB8		;DRAWC
	.dw	1CBE		;DRAW

; command END
170C:	clrb	8050
1710:	clrb	8058
1714:	clrb	00D0
1718:	clrb	00D8
171C:	bic	#87B1,8256	;mode
1722:	clrb	8264
1726:	br	165C

; command PRINT
1728:	mov	#1000,-(sp)
172C:	jsr	pc,1D50		;evaluate expression
1730:	mov	r2,825A
1734:	jmp	0C1E

1738:	bitb	#1,8265		;STOP key pressed?
173E:	beq	1748		;branch if not
1740:	mov	#1748,8258
1746:	br	179A
1748:	mov	825A,r2
174C:	cmpb	#3B,(r2)+	;';'
1750:	bne	1776
1752:	bit	#0008,8256	;trace mode
1758:	beq	1768		;branch if trace off
175A:	bicb	#80,8264	;display should be cleared before printing
1760:	mov	#1768,8258
1766:	br	178E
1768:	tstb	(r2)
176A:	beq	1772
176C:	cmpb	#3A,(r2)	;':'
1770:	bne	1728
1772:	jmp	166A		;main execution loop
1776:	bicb	#80,8264	;display should be cleared before printing
177C:	mov	#166A,8258	;address of main execution loop
1782:	cmpb	#2C,-(r2)	;','
1786:	bne	17DE
1788:	mov	#1728,8258
178E:	inc	825A
1792:	br	17DE

; command STOP
1794:	mov	#166A,8258	;address of main execution loop
;
179A:	clrb	8264
179E:	mov	r2,825A
17A2:	tstb	8265
17A6:	bpl	17DE
17A8:	clrb	8265
17AC:	mov	#50,r0		;'P'
17B0:	jsr	pc,097C		;display character r0
17B4:	movb	8268,r0		;selected program
17B8:	add	#30,r0		;'0'
17BC:	jsr	pc,097C		;display character r0
17C0:	mov	#2D,r0		;'-'
17C4:	jsr	pc,097C		;display character r0
17C8:	jsr	pc,11C4		;get the current BASIC line number to r5
17CC:	mov	#816D,r4	;destination address = input line buffer
17D0:	jsr	pc,2A22		;convert r5 to decimal ASCII
17D4:	clrb	(r4)
17D6:	mov	#816D,r4
17DA:	jsr	pc,1248		;display string
17DE:	clrb	8050
17E2:	movb	#08,8058	;show the STOP segment
17E8:	clrb	00D0
17EC:	movb	#08,00D8
17F2:	inc	8256		;set STOP mode (set bit 0)
17F6:	jmp	0B9C		;to direct mode main loop

; command CSR
17FA:	clr	8258
17FE:	cmpb	#2C,(r2)	;','
1802:	bne	1818
1804:	inc	r2
1806:	inc	8258
180A:	movb	8269,r0		;cursor position
180E:	tstb	(r2)
1810:	beq	1838
1812:	cmpb	#3A,(r2)	;':'
1816:	beq	1838
1818:	jsr	pc,1220		;evaluate expression to integer number in r0
181C:	blt	1882
181E:	cmp	#B,r0
1822:	bcs	1882		;ERR5 if argument out of range
1824:	movb	r0,8269		;cursor position
1828:	cmpb	#2C,(r2)	;','
182C:	bne	1864
182E:	inc	r2
1830:	tst	8258
1834:	beq	1838
1836:	clr	r0
1838:	mov	r0,r1
183A:	asl	r1
183C:	asl	r1
183E:	asl	r1
1840:	add	#8000,r1
1844:	neg	r0
1846:	add	#C,r0
184A:	beq	185C
184C:	inc	r1
184E:	mov	#7,r3
1852:	clrb	8080(r1)
1856:	clrb	(r1)+
1858:	sob	r3,1852
185A:	sob	r0,184C
185C:	bisb	#80,8264
1862:	br	18FC		;=jmp 166A, main execution loop
1864:	tst	8258
1868:	beq	185C
186A:	mov	#8000,r1
186E:	tst	r0
1870:	beq	185C
1872:	br	184C

; command NEXT
1874:	mov	#2000,-(sp)
1878:	jsr	pc,1D50		;evaluate expression
187C:	bit	#2000,(sp)
1880:	bne	1886
1882:	jmp	12C0		;ERR5
1886:	mov	0002(sp),r3	;address of the variable
188A:	add	#8,sp
188E:	mov	#4,r0		;up to 4 stack entries
1892:	mov	#81E6,r1	;address of FOR stack + 12
; scan the FOR stack for matching control variable
1896:	cmp	r3,(r1)
1898:	beq	18A4		;matching variable found
189A:	add	#14,r1		;add size of FOR stack entry 
189E:	sob	r0,1896		;next FOR stack entry
18A0:	jmp	12C6		;ERR7 - no matching NEXT statement found
18A4:	mov	r1,8244
18A8:	mov	-(r1),825A	;address of the NEXT loop
; push the TO and STEP values on the stack
18AC:	mov	#8,r0
18B0:	mov	-(r1),-(sp)
18B2:	sob	r0,18B0
; push the contents of the control variable on the stack
18B4:	mov	-(r3),-(sp)
18B6:	mov	-(r3),-(sp)
18B8:	mov	-(r3),-(sp)
18BA:	mov	-(r3),-(sp)
18BC:	mov	r3,8246		;starting address of the control variable
18C0:	mov	r2,8258		;address after the NEXT statement
18C4:	tst	0008(sp)	;sign of the STEP value
18C8:	bmi	18E0
; STEP value positive
18CA:	jsr	r4,3AA8
18CE:	.dw	2B46		;FP add (value of control variable + STEP)
	.dw	1900		;copy the sum to the control variable
	.dw	2B42		;FP subtract (value of control variable - TO)
	.dw	18D6
18D6:	tst	(sp)
18D8:	blt	18F0
; perform the next FOR-NEXT iteration
18DA:	mov	825A,r2		;address of the NEXT loop
18DE:	br	18F8
; STEP value negative
18E0:	jsr	r4,3AA8
18E4:	.dw	2B46		;FP add (value of control variable + STEP)
	.dw	1900		;copy the sum to the control variable
	.dw	2B42		;FP subtract (value of control variable - TO)
	.dw	18EC
18EC:	tst	(sp)
18EE:	ble	18DA
; leave the FOR-NEXT loop
18F0:	mov	8258,r2		;address after the NEXT statement
18F4:	clr	@8244		;free the current FOR stack entry
18F8:	add	#8,sp		;drop the FP number from the stack
18FC:	jmp	166A		;main execution loop

; copy the FP number from the stack to the control variable
1900:	mov	8246,r1
1904:	mov	sp,r0
1906:	mov	(r0)+,(r1)+
1908:	mov	(r0)+,(r1)+
190A:	mov	(r0)+,(r1)+
190C:	mov	(r0)+,(r1)+
190E:	jmp	@(r4)+

; command GOSUB
1910:	mov	#81B4,r1	;first GOSUB stack for return addresses
1914:	tst	(r1)+		;look for free entry
1916:	beq	1922
1918:	cmp	#81C2,r1	;top of the first GOSUB stack
191C:	bcc	1914
191E:	jmp	12C6		;GOSUB stack overflow
1922:	tst	-(r1)		;make room for new entry on first GOSUB stack
1924:	mov	r1,8258		;save the first GOSUB stack pointer
1928:	mov	825C,0010(r1)	;push address of current BASIC line on second
				;GOSUB stack
192E:	jsr	pc,1940		;execute GOTO
1932:	mov	825A,@8258	;push old BASIC program counter on first GOSUB
				;stack
1938:	jmp	1680

; command GOTO
193C:	mov	#1680,-(sp)
1940:	cmpb	#23,(r2)	;'#'
1944:	bne	1962
; go to another program
1946:	inc	r2
1948:	jsr	pc,1220		;evaluate expression to integer number in r0
194C:	blt	1954
194E:	cmp	#9,r0
1952:	bcc	1958
1954:	jmp	12C0		;ERR5
1958:	movb	r0,8268		;selected program
195C:	cmpb	#2C,(r2)+	;','
1960:	bne	1978		;no line number specified
; get the line number
1962:	jsr	pc,1220		;evaluate expression to integer number in r0
1966:	ble	1954
1968:	cmp	#270F,r0	;9999 decimal
196C:	bcs	1954
196E:	jsr	pc,1182		;return in r1 the address of BASIC line r0
1972:	beq	1986
1974:	jmp	12BA		;ERR4
; go to the beginning of another program
1978:	dec	r2
197A:	mov	#826B,r1	;start address of program P0
197E:	asl	r0		;selected program
1980:	beq	1986
1982:	mov	822A(r0),r1	;start address of program P1...P9
1986:	mov	r2,825A		;old BASIC program counter
198A:	mov	r1,r2		;new BASIC program counter
198C:	rts	pc

; command RETURN
198E:	mov	#81C4,r1	;top of the first GOSUB stack
1992:	mov	-(r1),r2	;get the return address
1994:	bne	19A0		;search for the first non-zero entry
1996:	cmp	#81B4,r1	;bottom of the first GOSUB stack
199A:	bcs	1992
199C:	jmp	12C6		;stack underflow, RETURN without GOSUB error
19A0:	clr	(r1)		;free the first GOSUB stack entry
19A2:	mov	0010(r1),825C	;get address of current BASIC line from the
				;second GOSUB stack
; return may occur to another program
19A8:	mov	#822C,r1	;table of end addresses of BASIC programs
19AC:	cmp	(r1)+,r2	;find the program the r2 address belongs to
19AE:	bcs	19AC
19B0:	sub	#822E,r1	;convert pointer to index
19B4:	asr	r1
19B6:	movb	r1,8268		;selected program
19BA:	jmp	166A		;main execution loop

; command IF
19BE:	mov	#8000,-(sp)
19C2:	jsr	pc,1D50		;evaluate expression
19C6:	mov	r0,8246		;operator
19CA:	mov	r2,8244
19CE:	bit	#4000,(sp)	;identifier of the second object on the stack
19D2:	bne	1A60		;compare strings
; The identifier of the first object should be checked as well! An illegal
; attempt to compare a string with a number isn't reported as an error!
; compare numbers
19D4:	jsr	r4,3AA8
19D8:	.dw	2B42		;FP subtract
	.dw	19DC
19DC:	mov	8246,r3		;operator
19E0:	mov	#1A5A,r1	;table of relational operators
19E4:	cmpb	r3,(r1)+
19E6:	bne	19E4
19E8:	sub	#1A5B,r1
19EC:	asl	r1
19EE:	mov	8244,r2
19F2:	tst	(sp)
19F4:	jmp	@1A4E(r1)

19F8:	beq	1A38		;relational operator =
19FA:	br	1A0E
19FC:	bne	1A38		;relational operator =\
19FE:	br	1A0E
1A00:	blt	1A38		;relational operator <
1A02:	br	1A0E
1A04:	bgt	1A38		;relational operator >
1A06:	br	1A0E
1A08:	ble	1A38		;relational operator <=
1A0A:	br	1A0E
1A0C:	bge	1A38		;relational operator >=
; condition false
1A0E:	cmpb	#E0,(r2)	;THEN
1A12:	bne	1A28
1A14:	cmpb	#3A,(r2)	;':'
1A18:	beq	1A20
1A1A:	tstb	(r2)+
1A1C:	bne	1A14
1A1E:	dec	r2
1A20:	add	#8,sp
1A24:	jmp	166A		;main execution loop
1A28:	cmpb	#3B,(r2)	;';'
1A2C:	beq	1A32
1A2E:	jmp	1CAC		;ERR2
1A32:	tstb	(r2)+
1A34:	bne	1A32
1A36:	sob	r2,1A20
; condition true
1A38:	cmpb	#3B,(r2)+	;';'
1A3C:	beq	1A20
1A3E:	cmpb	#E0,-(r2)	;THEN
1A42:	bne	1A2E		;ERR
1A44:	inc	r2
1A46:	add	#8,sp
1A4A:	jmp	193C		;perform a GOTO

1A4E:	.dw	19F8		;=
	.dw	19FC		;=\
	.dw	1A00		;<
	.dw	1A04		;>
	.dw	1A08		;<=
	.dw	1A0C		;>=

; relational operators
1A5A:	.db	3D, 5C, 3C, 3E, 5F, 7E	;= =\ < > <= >=

; compare strings, only operators = and =\ allowed
1A60:	cmpb	#3D,r0		;operator =
1A64:	beq	1A74
1A66:	cmpb	#5C,r0		;operator =\
1A6A:	beq	1A74
1A6C:	cmpb	r0,-(r2)
1A6E:	bne	1A6C
1A70:	jmp	1CAC		;ERR2 when illegal operator
1A74:	mov	0004(sp),r1	;length of the second string
1A78:	cmp	r1,000C(sp)	;length of the first string
1A7C:	beq	1A8A
; strings of different length
1A7E:	cmpb	#3D,r0		;operator =
1A82:	bne	1A94		;condition true
1A84:	add	#8,sp
1A88:	br	1A0E		;condition false
; strings of equal length
1A8A:	tst	r1
1A8C:	bne	1A9A
; empty strings
1A8E:	cmpb	#3D,r0		;operator =
1A92:	bne	1A84		;condition false
1A94:	add	#8,sp
1A98:	br	1A38		;condition true
; strings not empty
1A9A:	mov	#8060,r5
1A9E:	mov	0002(sp),r3	;address of the second string
1AA2:	tstb	(sp)		;identifier of the second string
1AA4:	bne	1AB8		;skip if not a string variable
; copy the contents of a string variable to the buffer r5
1AA6:	sub	#8,r3		;move the pointer to beginning of the variable
1AAA:	movb	(r3)+,(r5)+	;first character
1AAC:	inc	r3		;skip the indentifier of a string variable
1AAE:	br	1AB2
1AB0:	movb	(r3)+,(r5)+	;copy remaining characters
1AB2:	sob	r1,1AB0
1AB4:	mov	#8060,r3
; r3 points to the beginning of the second string
1AB8:	mov	0004(sp),r0	;length of the string
1ABC:	mov	000A(sp),r4	;address of the first string
1AC0:	tstb	0008(sp)	;identifier of the first string
1AC4:	bne	1ADC		;skip if not a string variable
; copy the contents of a string variable to the buffer r5
1AC6:	mov	r5,r1
1AC8:	sub	#8,r4		;move the pointer to beginning of the variable
1ACC:	movb	(r4)+,(r5)+	;first character
1ACE:	inc	r4		;skip the indentifier of a string variable
1AD0:	br	1AD4
1AD2:	movb	(r4)+,(r5)+	;copy remaining characters
1AD4:	sob	r0,1AD2
1AD6:	mov	r1,r4
1AD8:	mov	0004(sp),r0	;length of the string
; r4 points to the beginning of the first string
1ADC:	cmpb	#3D,8246	;operator =
1AE2:	bne	1AF0
; test if both strings equal
1AE4:	cmpb	(r3)+,(r4)+
1AE6:	bne	1AF6		;condition false
1AE8:	sob	r0,1AE4
1AEA:	add	#8,sp
1AEE:	br	1A38		;condition true
; test if both strings not equal
1AF0:	cmpb	(r3)+,(r4)+
1AF2:	bne	1AEA		;condition true
1AF4:	sob	r0,1AF0
1AF6:	add	#8,sp
1AFA:	br	1A0E		;condition false

; command FOR
1AFC:	mov	#2000,-(sp)
1B00:	jsr	pc,1D50		;evaluate expression
1B04:	cmpb	#E1,(r2)	;TO statement expected
1B08:	beq	1B0E
1B0A:	jmp	1CAC		;ERR2 if missing TO statement
1B0E:	bit	#2000,(sp)	;numeric variable expected
1B12:	bne	1B18
1B14:	jmp	12C0		;ERR5 if invalid control variable
1B18:	mov	0002(sp),r3	;address of the control variable
1B1C:	add	#8,sp
; test if the variable name wasn't already used for some other FOR-NEXT loop
1B20:	mov	#8222,r1
1B24:	mov	#4,r0		;number of FOR stack entries
1B28:	cmp	r3,(r1)
1B2A:	beq	1B46
1B2C:	sub	#14,r1		;size of the FOR stack entry
1B30:	sob	r0,1B28
; scan the FOR stack for a free entry
1B32:	mov	#4,r0		;number of FOR stack entries
1B36:	add	#14,r1		;size of the FOR stack entry
1B3A:	tst	(r1)
1B3C:	beq	1B44
1B3E:	sob	r0,1B36
1B40:	jmp	12C6		;ERR7, FOR stack overflow
1B44:	mov	r3,(r1)		;address of the control variable
; evaluate the TO value
1B46:	mov	r1,8258		;pointer to the FOR stack entry
1B4A:	mov	r2,8240		;pointer to the BASIC line
1B4E:	inc	r2
1B50:	mov	#1000,-(sp)
1B54:	jsr	pc,1D50		;evaluate expression
1B58:	bit	#6000,(sp)	;numeric value expected
1B5C:	bne	1B14		;ERR5
1B5E:	mov	8258,r1		;pointer to the FOR stack entry
; move the TO value from the system stack to the FOR stack entry
1B62:	sub	#A,r1
1B66:	mov	(sp)+,(r1)+
1B68:	mov	(sp)+,(r1)+
1B6A:	mov	(sp)+,(r1)+
1B6C:	mov	(sp)+,(r1)+
1B6E:	cmpb	#E2,(r2)	;STEP statement?
1B72:	beq	1B88
1B74:	mov	r2,(r1)		;destination address of the NEXT loop
; missing STEP statement, use default STEP value of 1
1B76:	sub	#8,r1
1B7A:	clr	-(r1)
1B7C:	clr	-(r1)
1B7E:	mov	#1000,-(r1)
1B82:	mov	#1001,-(r1)
1B86:	br	1BB2
; evaluate the STEP value
1B88:	mov	r1,8258		;pointer to the FOR stack entry
1B8C:	mov	r2,8240		;pointer to the BASIC line
1B90:	inc	r2
1B92:	mov	#1000,-(sp)
1B96:	jsr	pc,1D50		;evaluate expression
1B9A:	bit	#6000,(sp)	;numeric value expected
1B9E:	bne	1B14		;ERR5
1BA0:	mov	8258,r1		;pointer to the FOR stack entry
1BA4:	mov	r2,(r1)		;destination address of the NEXT loop
; move the STEP value from the system stack to the FOR stack entry
1BA6:	sub	#10,r1
1BAA:	mov	(sp)+,(r1)+
1BAC:	mov	(sp)+,(r1)+
1BAE:	mov	(sp)+,(r1)+
1BB0:	mov	(sp)+,(r1)+
1BB2:	jmp	166A		;main execution loop

; command INPUT
1BB6:	mov	r2,825A
1BBA:	bitb	#1,8265		;STOP key pressed?
1BC0:	beq	1BCC		;branch if not
1BC2:	mov	#1BCC,8258
1BC8:	jmp	179A
1BCC:	cmpb	#22,(r2)	;quotation mark?
1BD0:	bne	1BEE
; print characters until next quotation mark
1BD2:	inc	r2
1BD4:	mov	r2,r4
1BD6:	movb	(r4)+,r0
1BD8:	cmpb	#22,r0
1BDC:	beq	1BE4
1BDE:	jsr	pc,097C		;display character r0
1BE2:	br	1BD6
1BE4:	mov	r4,r2
1BE6:	cmpb	#2C,(r2)+	;','
1BEA:	beq	1BCC
1BEC:	br	1CCE
;
1BEE:	mov	r2,8254		;position of error
1BF2:	mov	#2000,-(sp)
1BF6:	jsr	pc,1D50		;evaluate expression
1BFA:	mov	r2,8258
1BFE:	mov	#3F,r0		;question mark
1C02:	jsr	pc,097C		;display character r0
1C06:	clr	8264
1C0A:	jsr	pc,0108		;input line editor
1C0E:	tstb	8264
1C12:	bpl	1C0A
1C14:	jsr	pc,0A32		;clear screen
1C18:	mov	#816D,r2	;input line buffer
1C1C:	mov	r2,r4
1C1E:	bis	#4000,8256	;INPUT mode on
1C24:	bit	#2000,(sp)
1C28:	beq	1C62		;branch if not numeric INPUT variable
; numeric INPUT variable
1C2A:	mov	r2,r5
1C2C:	jsr	pc,26AC
1C30:	mov	#1000,-(sp)
1C34:	jsr	pc,1D50		;evaluate expression
1C38:	mov	000A(sp),r1	;address of the variable
1C3C:	sub	#8,r1		;move the pointer to beginning of the variable
; Missing test of type of the value returned by function 1D50, it could be
; a string!
; copy the number to the variable
1C40:	mov	(sp)+,(r1)+
1C42:	mov	(sp)+,(r1)+
1C44:	mov	(sp)+,(r1)+
1C46:	mov	(sp)+,(r1)+
1C48:	add	#8,sp
1C4C:	bic	#4000,8256	;INPUT mode off
1C52:	mov	8258,r2
1C56:	cmpb	#2C,(r2)+	;','
1C5A:	beq	1BB6		;next INPUT argument
1C5C:	dec	r2
1C5E:	jmp	166A		;main execution loop
; String INPUT variable expected, but missing test if function 1D50 actually
; returned a string variable, it could be a number!
; This can cause random memory locations to be overwritten.
1C62:	tstb	(r4)+
1C64:	bne	1C62
1C66:	sub	#816E,r4	;string length
1C6A:	mov	0002(sp),r1	;address of the variable
1C6E:	mov	#1E,r0		;maximal string length for variable $
1C72:	tstb	(sp)
1C74:	bne	1C7E		;branch if variable $
1C76:	mov	#7,r0		;maximal string length for other variables
1C7A:	sub	#8,r1		;move the pointer to beginning of the variable
1C7E:	cmp	r0,r4		;does the string fit in?
1C80:	bcs	1CA4		;ERR5 if not
; Missing test for an empty input string! When r4=0, the system will crash!
; copy the string to the variable
1C82:	mov	r4,r3
1C84:	tstb	(sp)
1C86:	bne	1C90		;branch if variable $
1C88:	movb	(r2)+,(r1)+	;first character
1C8A:	movb	#60,(r1)+	;identifier of a string variable
1C8E:	br	1C92
1C90:	movb	(r2)+,(r1)+	;copy remaining characters
1C92:	sob	r4,1C90
; fill the rest of the variable with zeros
1C94:	cmp	#7,r0
1C98:	bne	1CA0
1C9A:	cmp	#7,r3
1C9E:	beq	1C48
1CA0:	clrb	(r1)
1CA2:	br	1C48

1CA4:	mov	#35,r0		;error code 5
1CA8:	jmp	@1D4E		;= jump to 12D4, error handler

1CAC:	mov	#32,r0		;error code 2
1CB0:	mov	r2,8254		;position of error
1CB4:	jmp	@1D4E		;= jump to 12D4, error handler

; command DRAWC
1CB8:	clr	825A
1CBC:	br	1CC4

; command DRAW
1CBE:	mov	#1CBE,825A	;any non-zero value would do
1CC4:	jsr	pc,1220		;evaluate expression to integer number in r0
1CC8:	cmpb	#2C,(r2)+	;','
1CCC:	beq	1CD0
1CCE:	sob	r2,1CAC		;ERR2
1CD0:	mov	r0,8258		;X coordinate
1CD4:	jsr	pc,1220		;evaluate expression to integer number in r0
1CD8:	blt	1D1C
1CDA:	cmp	#6,r0		;Y coordinate cannot exceed 6
1CDE:	bcs	1D1C
1CE0:	mov	8258,r1		;X coordinate
1CE4:	blt	1D1C
1CE6:	cmp	#3B,r1		;X coordinate cannot exceed 59
1CEA:	bcs	1D1C
1CEC:	clr	r3
1CEE:	sub	#5,r1
1CF2:	bcs	1CF6
1CF4:	sob	r3,1CEE
1CF6:	neg	r3
1CF8:	asl	r3
1CFA:	asl	r3
1CFC:	asl	r3
1CFE:	add	#8007,r3
1D02:	sub	r0,r3
1D04:	mov	#10,r0
1D08:	com	r1
1D0A:	beq	1D10
1D0C:	asr	r0
1D0E:	sob	r1,1D0C
1D10:	tst	825A
1D14:	bne	1D1A
1D16:	bicb	r0,(r3)
1D18:	br	1D1C
1D1A:	bisb	r0,(r3)
1D1C:	movb	(r3),8080(r3)
1D20:	bicb	#80,8265
1D26:	mov	8256,r0		;mode
1D2A:	bpl	1D4A		;branch if direct mode (bit 15 clr)
1D2C:	asr	r0
1D2E:	bcs	1D4A		;branch if STOP mode (bit 0 set)
1D30:	bit	#0004,r0
1D34:	beq	1D4A		;branch if not trace mode
1D36:	bicb	#80,8264	;display should be cleared before printing
1D3C:	mov	r2,825A
1D40:	mov	#1D4A,8258
1D46:	jmp	17DE
1D4A:	jmp	1652

1D4E:	.dw	12D4		;error handler routine

; evaluate an expression, requires a parameter on the stack:
; 1000	- expected a single expression
; 2000	- expected an expression or a variable, optional with assignment of
; a value
; 8000	- expected a pair of expressions
1D50:	mov	(sp)+,824C	;return address
1D54:	mov	(sp)+,824A	;parameter
1D58:	mov	#814E,r5	;expression evaluator stack
1D5C:	clrb	-(r5)
1D5E:	br	1E38

1D60:	cmpb	#28,(r2)	;'('
1D64:	bne	1E20		;= jmp @(r4)+
1D66:	movb	(r2)+,-(r5)
1D68:	br	1E38

1D6A:	cmpb	#2C,(r2)
1D6E:	bne	1E20
1D70:	inc	r2
1D72:	cmpb	#28,(r5)
1D76:	beq	1D88
1D78:	movb	(r5)+,r1
1D7A:	bne	1D82
1D7C:	dec	r2
1D7E:	jmp	20DE
1D82:	jsr	pc,2236
1D86:	br	1D72
1D88:	mov	#1D9C,r0
1D8C:	cmpb	0001(r5),(r0)+
1D90:	beq	1E38
1D92:	tstb	(r0)
1D94:	bne	1D8C
1D96:	dec	r2
1D98:	jmp	263E		;ERR2

; functions requiring multiple arguments enclosed within parentheses
1D9C:	.db	D2, D3, D4, 00	;RND, MID, GETC

1DA0:	cmpb	#5E,(r2)	;'^'
1DA4:	bne	1E20		;= jmp @(r4)+
1DA6:	movb	(r2)+,-(r5)
1DA8:	jsr	pc,220C
1DAC:	br	1E38

1DAE:	mov	#1E0C,r1
1DB2:	cmpb	(r2),(r1)+
1DB4:	beq	1DBC
1DB6:	tstb	(r1)
1DB8:	bne	1DB2
1DBA:	jmp	@(r4)+
1DBC:	bit	#40FF,824A
1DC2:	beq	1DCC
1DC4:	jmp	263E		;ERR2
1DC8:	jsr	pc,2236
1DCC:	movb	(r5)+,r1
1DCE:	bne	1DC8
1DD0:	dec	r5
1DD2:	movb	(r2)+,r0
1DD4:	add	r0,824A
1DD8:	bpl	1DFC
1DDA:	bit	#2000,(sp)
1DDE:	beq	1E38
1DE0:	mov	0002(sp),r1
1DE4:	add	#8,sp
1DE8:	mov	-(r1),-(sp)
1DEA:	mov	-(r1),-(sp)
1DEC:	mov	-(r1),-(sp)
1DEE:	mov	-(r1),-(sp)
1DF0:	bit	#6000,(sp)
1DF4:	beq	1E38
1DF6:	dec	r2
1DF8:	jmp	264A		;ERR6
; optional assignment of a value to a variable
1DFC:	cmpb	#3D,824A	;'='
1E02:	bne	1E0A
1E04:	bit	#6000,(sp)	;variable on the stack?
1E08:	bne	1E38
1E0A:	sob	r2,1DC4		;ERR2
; The above instruction is equivalent to DEC R2 and JMP 1DC4.
; This looks like code would abruptly end here, but there's no danger for the
; program to go past this instruction, because R2 (parser pointer) is always
; greater than 8000.

; relational operators
1E0C:	.db	3D, 5C, 3C, 3E	; = <> < >
	.db	5F, 7E, 00, 00	; <= >=

1E14:	cmpb	(r2),#C0
1E18:	bcs	1E20
1E1A:	cmpb	#D4,(r2)
1E1E:	bcc	1E22
1E20:	jmp	@(r4)+		;not a function
; function found, parse the argument
1E22:	movb	(r2)+,r0
1E24:	mov	#1D9C,r1
1E28:	tstb	(r1)
1E2A:	beq	1E36
1E2C:	cmpb	r0,(r1)+
1E2E:	bne	1E28
1E30:	cmpb	#28,(r2)	;'('
1E34:	bne	1D96
1E36:	movb	r0,-(r5)
1E38:	jsr	r4,3AA8
1E3C:	.dw	1E40
	.dw	1E4C
1E40:	jsr	pc,268A		;evaluate a chain of operators '+' and '-'
1E44:	tstb	r1
1E46:	beq	1E20		;branch if evaluated to '+'
1E48:	movb	#25,-(r5)	;'%' (unary minus operator)
1E4C:	jsr	r4,3AA8
1E50:	.dw	1E14
	.dw	1E90		;evaluate a variable
	.dw	1EFE		;evaluate a literal
	.dw	1D60
	.dw	263E		;ERR2

1E5A:	tstb	(r2)
1E5C:	bne	1E62
1E5E:	jmp	20C4
1E62:	jsr	pc,268A		;evaluate a chain of operators '+' and '-'
1E66:	tst	r1
1E68:	bpl	1E20		;jmp @(r4)+ if none found
1E6A:	movb	#2B,-(r5)	;push '+' on the expression evaluator stack
1E6E:	tstb	r1
1E70:	beq	1E76		;skip if evaluated to '+'
1E72:	movb	#2D,(r5)	;push '-' on the expression evaluator stack
1E76:	jsr	pc,21D8
1E7A:	br	1E4C

1E7C:	cmpb	#2A,(r2)	;'*'
1E80:	beq	1E88
1E82:	cmpb	#2F,(r2)	;'/'
1E86:	bne	1E20		;= jmp @(r4)+
1E88:	movb	(r2)+,-(r5)
1E8A:	jsr	pc,21F2
1E8E:	br	1E38

; evaluate a variable
; special string variable $ ?
1E90:	cmpb	#24,(r2)	;'$'
1E94:	bne	1EBE
1E96:	inc	r2
1E98:	clr	-(sp)
1E9A:	mov	#814E,r1
1E9E:	tst	824A
1EA2:	bmi	1EAA
; optional assignment of a value to the $ variable
1EA4:	cmpb	#3D,(r2)	;'='
1EA8:	beq	1EB2
1EAA:	tstb	(r1)+
1EAC:	bne	1EAA
1EAE:	sub	#814F,r1
1EB2:	mov	r1,-(sp)	;length of the string
1EB4:	mov	#814E,-(sp)	;pointer to the string variable $ buffer
1EB8:	mov	#4001,-(sp)	;"special string variable" mark
1EBC:	br	1F80
; variable name A-Z ?
1EBE:	cmpb	(r2),#41	;'A'
1EC2:	bcs	1E20
1EC4:	cmpb	#5A,(r2)	;'Z'
1EC8:	bcs	1E20
; calculate the address of the variable
1ECA:	movb	(r2)+,r0
1ECC:	sub	#41,r0
1ED0:	asl	r0
1ED2:	asl	r0
1ED4:	asl	r0
1ED6:	neg	r0
1ED8:	add	8252,r0		;top of the RAM
; push a "numeric variable" on the stack
1EDC:	clr	-(sp)
1EDE:	clr	-(sp)
1EE0:	mov	r0,-(sp)	;address of the variable
1EE2:	mov	#2000,-(sp)	;"numeric variable" mark
; string variable A$-Z$ ?
1EE6:	cmpb	#24,(r2)	;'$'
1EEA:	bne	1EF0
1EEC:	inc	r2
1EEE:	asl	(sp)		;"string variable" mark = 4000
; indexed variable ?
1EF0:	cmpb	#28,(r2)	;'('
1EF4:	bne	1FB2
1EF6:	inc	r2
1EF8:	movb	#5B,-(r5)	;push '[' on the expression evaluator stack
1EFC:	br	1E38

; evaluate a literal or a function without an argument (RAN#, KEY)
; string?
1EFE:	cmpb	#22,(r2)	;'"'
1F02:	bne	1F1E
1F04:	inc	r2
1F06:	clr	-(sp)
1F08:	mov	r2,r1		;r1 = address of the string
; look for the end of the string
1F0A:	cmpb	#22,(r2)+	;'"'
1F0E:	bne	1F0A
1F10:	mov	r2,-(sp)	;address of the end of the string
1F12:	dec	(sp)		;without closing quote
1F14:	sub	r1,(sp)		;length of the string
1F16:	mov	r1,-(sp)	;address of the string
1F18:	mov	#4080,-(sp)	;"string" mark
1F1C:	br	1F80
; constant PI?
1F1E:	cmpb	#7C,(r2)	;PI
1F22:	bne	1F36
; push the PI constant to the stack
1F24:	mov	#5360,-(sp)
1F28:	mov	#5926,-(sp)
1F2C:	mov	#3141,-(sp)
1F30:	mov	#1001,-(sp)
1F34:	br	1F7E
; numeric literal?
1F36:	mov	r5,8248		;expression evaluator stack pointer
1F3A:	mov	r2,8254		;position of error
1F3E:	cmpb	(r2),#30	;'0'
1F42:	bcs	1F4A
1F44:	cmpb	#39,(r2)	;'9'
1F48:	bcc	1F94
1F4A:	cmpb	#2E,(r2)	;'.'
1F4E:	beq	1F94
; function RAN#?
1F50:	cmpb	#D5,(r2)	;RAN#
1F54:	bne	1F5C
1F56:	jsr	pc,2FC6
1F5A:	br	1F76
; function KEY?
1F5C:	cmpb	#D6,(r2)	;KEY
1F60:	beq	1F64
1F62:	jmp	@(r4)+

; function KEY
1F64:	jsr	pc,0770		;code of pressed key in r0
1F68:	mov	r0,-(sp)
1F6A:	mov	sp,r1
1F6C:	mov	#1,-(sp)	;length of the string
1F70:	mov	r1,-(sp)	;address of the string
1F72:	mov	#4080,-(sp)	;"string" mark
1F76:	mov	8248,r5		;expression evaluator stack pointer
1F7A:	mov	8254,r2		;r2 = pointer to the BASIC line
1F7E:	inc	r2
1F80:	jsr	r4,3AA8
1F84:	.dw	1E5A
	.dw	1E7C
	.dw	204E
	.dw	1DA0
	.dw	1D6A
	.dw	1DAE
	.dw	20C4
	.dw	263E		;ERR2

1F94:	mov	r2,r4
1F96:	jsr	pc,2A5C		;evaluate the value of a FP numeric literal
1F9A:	mov	8248,r5		;expression evaluator stack pointer
1F9E:	mov	r4,r2
1FA0:	bcc	1F80
1FA2:	cmpb	#7B,-(r2)	;'E'
1FA6:	beq	1FAE
1FA8:	cmpb	#7D,(r2)	;'E-'
1FAC:	bne	1FA2
1FAE:	jmp	263E		;ERR2

1FB2:	tst	824A
1FB6:	bmi	1FC2
1FB8:	cmpb	#3D,(r2)	;'='
1FBC:	bne	1FC2
1FBE:	jmp	1DAE
1FC2:	bit	#2000,824A
1FC8:	beq	1FEC
1FCA:	tstb	824A
1FCE:	bne	1FEC
1FD0:	tstb	(r2)
1FD2:	beq	1F80
1FD4:	cmpb	#3A,(r2)	;":"
1FD8:	beq	1F80
1FDA:	cmpb	#2C,(r2)	;','
1FDE:	beq	1F80
1FE0:	cmpb	#E1,(r2)	;TO
1FE4:	beq	1F80
1FE6:	cmpb	#21,(r2)	;'!'
1FEA:	beq	1F80
1FEC:	mov	0002(sp),r1
1FF0:	bit	#2000,(sp)
1FF4:	beq	202C
1FF6:	add	#8,sp
1FFA:	mov	-(r1),-(sp)
1FFC:	mov	-(r1),-(sp)
1FFE:	mov	-(r1),-(sp)
2000:	mov	-(r1),-(sp)
2002:	bit	#6000,(sp)
2006:	beq	1F80
2008:	clr	r0
200A:	cmpb	#29,-(r2)	;')'
200E:	bne	2012
2010:	dec	r0
2012:	cmpb	#28,(r2)	;'('
2016:	bne	201C
2018:	inc	r0
201A:	dec	r2
201C:	tst	r0
201E:	blt	200A
2020:	cmpb	#24,(r2)	;'$'
2024:	bne	2028
2026:	dec	r2
2028:	jmp	264A		;ERR6
202C:	sub	#8,r1
2030:	bit	#6000,(r1)
2034:	beq	2008
2036:	mov	#7,r0
203A:	tstb	(r1)+
203C:	beq	1F80
203E:	inc	r1
2040:	br	2046
2042:	tstb	(r1)+
2044:	beq	1F80
2046:	inc	0004(sp)
204A:	sob	r0,2042
204C:	br	1F80

204E:	cmpb	#29,(r2)+	;')'
2052:	beq	2058
2054:	dec	r2
2056:	jmp	@(r4)+
; closing bracket encountered - it can be either an index of a variable or
; a part of an expression, it depends on what is on the expression evaluator
; stack
2058:	movb	(r5)+,r1	;pop from the expression evaluator stack
205A:	bne	2060
205C:	jmp	263E		;ERR2
2060:	cmpb	#5B,r1		;'['
2064:	beq	2072		;index of a variable
2066:	cmpb	#28,r1		;'('
206A:	beq	1F80		;closing bracket of an expression
206C:	jsr	pc,2236
2070:	br	2058
; indexed variable
2072:	mov	r5,8248		;expression evaluator stack pointer
2076:	mov	r2,8254		;pointer to BASIC line / position of error
207A:	jsr	r4,3AA8
207E:	.dw	2F72		;convert a FP number to 16-bit integer
	.dw	2082
2082:	mov	8248,r5		;expression evaluator stack pointer
2086:	mov	8254,r2		;r2 = pointer to BASIC line
208A:	bcs	2008		;branch if conversion to integer failed
208C:	mov	(sp)+,r0	;value of the index
208E:	asl	r0
2090:	bvs	2008
2092:	asl	r0
2094:	bvs	2008
2096:	asl	r0
2098:	bvs	2008
209A:	neg	r0		;index = -8*index
209C:	add	r0,0002(sp)	;add the index to the address of the variable
; check the boundaries
20A0:	cmp	8252,0002(sp)	;check against the top of the RAM
20A6:	bcs	2008
20A8:	mov	8250,r0		;number of variables
20AC:	dec	r0
20AE:	asl	r0
20B0:	asl	r0
20B2:	asl	r0
20B4:	neg	r0
20B6:	add	8252,r0		;top of the RAM
20BA:	cmp	0002(sp),r0	;check against beginning of variable area
20BE:	bcs	2008
20C0:	jmp	1FB2

20C4:	tstb	(r2)
20C6:	beq	20DA
20C8:	mov	#21D0,r1
20CC:	cmpb	(r2),(r1)+
20CE:	beq	20DA
20D0:	tstb	(r1)
20D2:	bne	20CC
20D4:	jmp	@(r4)+
20D6:	jsr	pc,2236
20DA:	movb	(r5)+,r1
20DC:	bne	20D6
20DE:	mov	r2,8254		;position of error
20E2:	mov	824A,r0
20E6:	mov	r0,8242
20EA:	bpl	20F8
20EC:	tstb	r0
20EE:	bne	20F4
20F0:	jmp	263E		;ERR2
20F4:	jmp	@824C
20F8:	tstb	r0
20FA:	beq	20F4
20FC:	cmpb	#3D,r0		;'='
2100:	beq	2106
2102:	jmp	25F6
2106:	bit	#6000,(sp)
210A:	bne	2146
210C:	bit	#2000,0008(sp)
2112:	beq	2102
2114:	mov	000A(sp),r1
2118:	sub	#8,r1
211C:	mov	sp,r3
211E:	mov	(r3)+,(r1)+
2120:	mov	(r3)+,(r1)+
2122:	mov	(r3)+,(r1)+
2124:	mov	(r3)+,(r1)+
2126:	bit	#1000,824A
212C:	beq	2138
212E:	mov	(sp)+,(r3)+
2130:	mov	(sp)+,(r3)+
2132:	mov	(sp)+,(r3)+
2134:	mov	(sp)+,(r3)+
2136:	br	21C8
2138:	bit	#2000,824A
213E:	bne	21C4
2140:	add	#10,sp
2144:	br	21C8
2146:	bit	#4000,0008(sp)
214C:	beq	2102
214E:	mov	000A(sp),r3
2152:	mov	#1E,r4
2156:	tstb	0008(sp)
215A:	bmi	2102
215C:	bne	216A
215E:	sub	#8,r3
2162:	mov	#6000,(r3)
2166:	mov	#7,r4
216A:	mov	0004(sp),r5
216E:	cmp	r4,r5
2170:	bcc	2176
2172:	jmp	2602
2176:	mov	r5,r0
2178:	beq	21A4
217A:	mov	0002(sp),r4
217E:	tstb	(sp)
2180:	bne	218C
2182:	sub	#8,r4
2186:	movb	(r4)+,r1
2188:	inc	r4
218A:	br	218E
218C:	movb	(r4)+,r1
218E:	tstb	0008(sp)
2192:	bne	21A0
2194:	movb	r1,(r3)+
2196:	inc	r3
2198:	add	#2,0008(sp)
219E:	br	21A2
21A0:	movb	r1,(r3)+
21A2:	sob	r5,218C
21A4:	add	#8,sp
21A8:	bic	#2,(sp)
21AC:	mov	r0,0004(sp)
21B0:	tstb	(sp)
21B2:	bne	21BA
21B4:	cmp	#7,r0
21B8:	beq	21BC
21BA:	clrb	(r3)
21BC:	bit	#3000,824A
21C2:	bne	21C8
21C4:	add	#8,sp
21C8:	mov	824A,r0
21CC:	jmp	@824C

21D0:	.db	3A		;':'
	.db	3B		;';'
	.db	21		;'!'
	.db	E0		;THEN
	.db	E1		;TO
	.db	E2		;STEP

21D8:	mov	(sp)+,8244
21DC:	mov	#21E2,8246
21E2:	movb	(r5)+,r0
21E4:	cmpb	#2B,(r5)	;'+'
21E8:	beq	2230
21EA:	cmpb	#2D,(r5)	;'-'
21EE:	beq	2230
21F0:	br	21FE
21F2:	mov	(sp)+,8244
21F6:	mov	#21FC,8246
21FC:	movb	(r5)+,r0
21FE:	cmpb	#2A,(r5)	;'*'
2202:	beq	2230
2204:	cmpb	#2F,(r5)	;'/'
2208:	beq	2230
220A:	br	2218

220C:	mov	(sp)+,8244
2210:	mov	#2216,8246
2216:	movb	(r5)+,r0
2218:	cmpb	#5E,(r5)	;'^'
221C:	beq	2230
221E:	cmpb	#25,(r5)	;'%' (unary minus)
2222:	beq	2230
2224:	cmpb	(r5),#C0
2228:	bcc	2230
222A:	movb	r0,-(r5)
222C:	jmp	@8244

2230:	movb	(r5),r1
2232:	movb	r0,(r5)
2234:	br	223A

2236:	mov	(sp)+,8246
223A:	mov	r5,8248		;expression evaluator stack pointer
223E:	mov	r2,8254		;pointer to BASIC line / position of error
2242:	movb	r1,8242		;code of the command/function/operator
2246:	cmpb	r1,#C0
224A:	bcc	2262		;branch if a function
; scan for operators
224C:	mov	#2278,r3	;table of operators
2250:	tstb	(r3)
2252:	bne	2258
2254:	jmp	2656		;ERR!
2258:	cmpb	r1,(r3)+
225A:	bne	2250
225C:	sub	#21A4,r3	;2278-21A4=D4
2260:	mov	r3,r1
2262:	bic	#FFC0,r1
2266:	asl	r1
2268:	jmp	@2280(r1)

226C:	mov	8248,r5		;expression evaluator stack pointer
2270:	mov	8254,r2		;r2 = pointer to the BASIC line
2274:	jmp	@8246

2278:	.db	2B		;'+'
	.db	2D		;'-'
	.db	2A		;'*'
	.db	2F		;'/'
	.db	5E		;'^'
	.db	25		;'%' (unary minus)
	.db	00, 00

2280:	.dw	22B6		;offset 00, function SIN
	.dw	22CE		;offset 01, function COS
	.dw	22E6		;offset 02, function TAN
	.dw	22FE		;offset 03, function ASN
	.dw	2316		;offset 04, function ACS
	.dw	232E		;offset 05, function ATN
	.dw	2346		;offset 06, function LOG
	.dw	2350		;offset 07, function LN
	.dw	235A		;offset 08, function EXP
	.dw	2364		;offset 09, function SQR
	.dw	23A2		;offset 0A, function ABS
	.dw	23AE		;offset 0B, function INT
	.dw	23BA		;offset 0C, function SGN
	.dw	23C6		;offset 0D, function FRAC
	.dw	2498		;offset 0E, function VAL
	.dw	24EA		;offset 0F, function LEN
	.dw	254E		;offset 10, function CHR
	.dw	2576		;offset 11, function ASCI
	.dw	23DE		;offset 12, function RND
	.dw	2500		;offset 13, function MID
	.dw	25A2		;offset 14, function GETC

	.dw	240E		;offset 15, operator +
	.dw	23EA		;offset 16, operator -
	.dw	23F6		;offset 17, operator *
	.dw	2402		;offset 18, operator /
	.dw	236E		;offset 19, operator ^
	.dw	23D2		;offset 1A, operator % (unary minus)

; function SIN
22B6:	jsr	pc,266C		;expected a FP number on the stack
22BA:	mov	8256,r0		;mode
22BE:	bic	#FFF9,r0
22C2:	jsr	pc,@22C8(r0)
22C6:	br	2376
22C8:	.dw	352E		;DEG
	.dw	353A		;RAD
	.dw	3534		;GRA

; function COS
22CE:	jsr	pc,266C		;expected a FP number on the stack
22D2:	mov	8256,r0		;mode
22D6:	bic	#FFF9,r0
22DA:	jsr	pc,@22E0(r0)
22DE:	br	2376
22E0:	.dw	3594		;DEG
	.dw	35A0		;RAD
	.dw	359A		;GRA

; function TAN
22E6:	jsr	pc,266C		;expected a FP number on the stack
22EA:	mov	8256,r0		;mode
22EE:	bic	#FFF9,r0
22F2:	jsr	pc,@22F8(r0)
22F6:	br	2376
22F8:	.dw	3620		;DEG
	.dw	362C		;RAD
	.dw	3626		;GRA

; function ASN
22FE:	jsr	pc,266C		;expected a FP number on the stack
2302:	mov	8256,r0		;mode
2306:	bic	#FFF9,r0
230A:	jsr	pc,@2310(r0)
230E:	br	2376
2310:	.dw	335A		;DEG
	.dw	3366		;RAD
	.dw	3360		;GRA

; function ACS
2316:	jsr	pc,266C		;expected a FP number on the stack
231A:	mov	8256,r0		;mode
231E:	bic	#FFF9,r0
2322:	jsr	pc,@2328(r0)
2326:	br	2376
2328:	.dw	331E		;DEG
	.dw	332A		;RAD
	.dw	3324		;GRA

; function ATN
232E:	jsr	pc,266C		;expected a FP number on the stack
2332:	mov	8256,r0		;mode
2336:	bic	#FFF9,r0
233A:	jsr	pc,@2340(r0)
233E:	br	2376
2340:	.dw	33D8		;DEG
	.dw	33E4		;RAD
	.dw	33DE		;GRA

; function LOG
2346:	jsr	pc,266C		;expected a FP number on the stack
234A:	jsr	pc,3196
234E:	br	2376

; function LN
2350:	jsr	pc,266C		;expected a FP number on the stack
2354:	jsr	pc,31AC
2358:	br	2376

; function EXP
235A:	jsr	pc,266C		;expected a FP number on the stack
235E:	jsr	pc,30A2
2362:	br	2376

; function SQR
2364:	jsr	pc,266C		;expected a FP number on the stack
2368:	jsr	pc,300E
236C:	br	2376

; operator ^
236E:	jsr	pc,2676		;expected two FP numbers on the stack
2372:	jsr	pc,3296		;power of a number
;
; "integer cheating" of the floating point number on the stack
; If the last four digits of the mantissa are in the range 0001-0009 then they
; are replaced with 0000. Similarly, if the last four mantissa digits are in
; the range 9950-9999, then the number is rounded up until they are 0000.
2376:	cmp	0006(sp),#0010
237C:	bcc	2386
237E:	clr	0006(sp)
2382:	jmp	226C
2386:	cmp	0006(sp),#9950
238C:	bcs	2382
238E:	mov	#0050,-(sp)
2392:	clr	-(sp)
2394:	clr	-(sp)
2396:	mov	0006(sp),-(sp)
239A:	jsr	r4,3AA8
239E:	.dw	2B46		;FP add
	.dw	237E

; function ABS
23A2:	jsr	pc,266C		;expected a FP number on the stack
23A6:	jsr	r4,3AA8
23AA:	.dw	2E12		;FP absolute value
	.dw	226C

; function INT
23AE:	jsr	pc,266C		;expected a FP number on the stack
23B2:	jsr	r4,3AA8
23B6:	.dw	2EE4		;FP integer value
	.dw	226C

; function SGN
23BA:	jsr	pc,266C		;expected a FP number on the stack
23BE:	jsr	r4,3AA8
23C2:	.dw	2E22		;FP sign
	.dw	226C

; function FRAC
23C6:	jsr	pc,266C		;expected a FP number on the stack
23CA:	jsr	r4,3AA8
23CE:	.dw	2EA2		;FP fraction
	.dw	226C

; operator % (unary minus)
23D2:	jsr	pc,266C		;expected a FP number on the stack
23D6:	jsr	r4,3AA8
23DA:	.dw	2E18		;change the sign of a FP number
	.dw	226C

; function RND
23DE:	jsr	pc,2676		;expected two FP numbers on the stack
23E2:	jsr	r4,3AA8
23E6:	.dw	2E3A		;FP rounding
	.dw	226C

;  operator -
23EA:	jsr	pc,2676		;expected two FP numbers on the stack
23EE:	jsr	r4,3AA8
23F2:	.dw	2B42		;FP subtract
	.dw	2376

;  operator *
23F6:	jsr	pc,2676		;expected two FP numbers on the stack
23FA:	jsr	r4,3AA8
23FE:	.dw	2C7E		;FP multiply
	.dw	2376

; operator /
2402:	jsr	pc,2676		;expected two FP numbers on the stack
2406:	jsr	r4,3AA8
240A:	.dw	2CFC		;FP divide
	.dw	2376

; operator +
240E:	mov	(sp),r0
2410:	bis	0008(sp),r0
2414:	bit	#6000,r0
2418:	bne	2426
; adding FP numbers
241A:	jsr	r4,3AA8
241E:	.dw	2B46		;FP add
	.dw	2376

2422:	jmp	25F6

; concatenation of two strings
2426:	bit	#4000,(sp)	;second string expected
242A:	beq	2422		;ERR2
242C:	bit	#4000,0008(sp)	;first string expected
2432:	beq	2422		;ERR2
2434:	mov	0004(sp),r3	;length of second string
2438:	add	000C(sp),r3	;length of first string
243C:	cmp	#1E,r3		;up to 1E characters allowed
2440:	bcc	2446
2442:	jmp	2602		;ERR8
2446:	mov	#812F,r2	;buffer for concatenated strings
; process the first string
244A:	mov	000A(sp),r1	;address of first string
244E:	mov	r2,000A(sp)	;address of concatenated string
2452:	mov	000C(sp),r0	;length of first string
2456:	beq	246C
2458:	tstb	0008(sp)
245C:	bne	2468		;branch if not a string variable
; copy the contents of a string variable to the buffer
245E:	sub	#8,r1		;move the pointer to beginning of the variable
2462:	movb	(r1)+,(r2)+	;copy the first character of a string variable
2464:	inc	r1		;skip the string variable identifier byte 60
2466:	br	246A
; copy a string or the contents of the $ variable to the buffer
2468:	movb	(r1)+,(r2)+
246A:	sob	r0,2468
; process the second string
246C:	mov	0002(sp),r1	;address of second string
2470:	mov	0004(sp),r0	;length of second string
2474:	beq	2488
2476:	tstb	(sp)
2478:	bne	2484		;branch if not a string variable
; copy the contents of a string variable to the buffer
247A:	sub	#8,r1		;move the pointer to beginning of the variable
247E:	movb	(r1)+,(r2)+	;copy the first character of a string variable
2480:	inc	r1		;skip the string variable identifier byte 60
2482:	br	2486
; copy a string or the contents of the $ variable to the buffer
2484:	movb	(r1)+,(r2)+
2486:	sob	r0,2484
2488:	add	#8,sp
248C:	mov	#4080,(sp)	;"string" mark
2490:	mov	r3,0004(sp)	;length of concatenated string
2494:	jmp	226C

; function VAL
2498:	bit	#4000,(sp)
249C:	bne	24A2
249E:	jmp	25F6		;ERR2 if argument not a string
24A2:	mov	0004(sp),r0	;length of the input string
24A6:	beq	249E		;ERR2 if input string empty
24A8:	mov	0002(sp),r4	;address of the input string
; the input string is copied to a buffer allocated on the stack
24AC:	sub	#20,sp		;buffer for the copy of the input string
24B0:	mov	sp,r2		;pointer to the buffer
24B2:	tstb	0020(sp)
24B6:	bne	24C2		;branch if not a string variable
24B8:	sub	#8,r4		;move the pointer to beginning of the variable
24BC:	movb	(r4)+,(r2)+	;copy the first character of a string variable
24BE:	inc	r4		;skip the string variable identifier byte 60
24C0:	br	24C4
24C2:	movb	(r4)+,(r2)+	;copy the remaining characters
24C4:	sob	r0,24C2
24C6:	clrb	(r2)		;terminate the string
24C8:	mov	sp,r4		;pointer to the buffer
24CA:	jsr	pc,2A5C		;evaluate the value of a FP numeric literal
24CE:	bcs	249E		;ERR3 if value out of range
24D0:	tstb	r5
24D2:	bne	249E
; move the calculated numeric literal to the place of the input string
24D4:	mov	sp,r1
24D6:	add	#28,r1
24DA:	mov	(sp)+,(r1)+
24DC:	mov	(sp)+,(r1)+
24DE:	mov	(sp)+,(r1)+
24E0:	mov	(sp)+,(r1)+
24E2:	add	#20,sp		;free the allocated buffer
24E6:	jmp	226C

; function LEN
24EA:	jsr	pc,2662		;expected a string on the stack
24EE:	mov	0004(sp),0006(sp) ;length of string
24F4:	add	#6,sp
24F8:	jsr	r4,3AA8
24FC:	.dw	2F18		;convert a 16-bit signed integer to FP
	.dw	226C

; function MID
2500:	jsr	pc,2676		;expected two FP numbers on the stack
2504:	jsr	r4,3AA8
2508:	.dw	2F72		;convert a FP number to 16-bit integer
	.dw	250C
250C:	bcc	2512		;branch if conversion to integer succeeded
250E:	jmp	25FC		;ERR5
2512:	mov	(sp)+,r5	;starting position of the substring
2514:	blt	250E		;ERR5 if negative
2516:	jsr	r4,3AA8
251A:	.dw	2F72		;convert a FP number to 16-bit integer
	.dw	251E
251E:	bcs	250E		;ERR5 if conversion to integer failed
2520:	mov	(sp)+,r4	;length of the substring
2522:	dec	r4
2524:	blt	250E		;ERR5 if length less than 1
2526:	mov	#814E,r1	;address of the string variable $
252A:	mov	r1,r2
252C:	tstb	(r1)+		;search for the end of the string
252E:	bne	252C
2530:	sub	#814F,r1	;r1 = length of the string
2534:	mov	r4,r0
2536:	add	r5,r0		;r0 = end position of the substring
2538:	cmp	r1,r0		;compare it with the string length
253A:	bcs	250E		;ERR5 if the string to short
253C:	clr	-(sp)		;not used
253E:	mov	r5,-(sp)	;length of the substring
2540:	mov	#814E,-(sp)
2544:	add	r4,(sp)		;address of the substring
2546:	mov	#4080,-(sp)	;"string" mark
254A:	jmp	226C

; function CHR
254E:	jsr	pc,266C		;expected a FP number on the stack
2552:	jsr	r4,3AA8
2556:	.dw	2F72		;convert a FP number to 16-bit integer
	.dw	255A
255A:	bcc	2560		;branch if conversion to integer succeeded
255C:	jmp	25FC		;ERR5
2560:	cmp	(sp),#C0
2564:	bcc	255C
2566:	mov	sp,r0
2568:	mov	#1,-(sp)	;length of string = 1 character
256C:	mov	r0,-(sp)	;address of string
256E:	mov	#4080,-(sp)	;string identifier
2572:	jmp	226C

; function ASCI
2576:	bit	#4000,(sp)	;expected a string on the stack
257A:	bne	2580
257C:	jmp	25F6		;ERR2
2580:	movb	(sp)+,r0	;identifier
2582:	mov	(sp)+,r1	;address
2584:	tstb	r0
2586:	bne	258C		;skip if not a string variable
2588:	sub	#8,r1		;move the pointer to beginning of the variable
258C:	mov	(sp)+,r3	;length of string
258E:	beq	259A
2590:	dec	r3
2592:	beq	2598
2594:	jmp	25FC		;ERR5 if more than 1 character
2598:	movb	(r1),(sp)	;code of the character
259A:	jsr	r4,3AA8
259E:	.dw	2F18		;convert a 16-bit signed integer to FP
	.dw	226C

; function GETC
25A2:	bit	#6000,(sp)	;expected a string on the stack
25A6:	beq	25AC
25A8:	jmp	25F6		;ERR2 when first argument not a string
25AC:	jsr	r4,3AA8
25B0:	.dw	2F72		;convert a FP number to 16-bit integer
	.dw	25B4
25B4:	bcc	25BA		;branch if conversion to integer succeeded
25B6:	jmp	25FC		;ERR5
25BA:	mov	(sp)+,r0
25BC:	ble	25B6		;negative numbers and 0 not allowed
25BE:	bit	#4000,(sp)
25C2:	beq	25A8		;ERR2 when first argument not a string
25C4:	tstb	(sp)
25C6:	bne	25CE		;skip if not a string variable
25C8:	sub	#8,0002(sp)	;move the pointer to beginning of the variable
25CE:	mov	0004(sp),r2	;length of the input string
25D2:	beq	25EE		;branch if empty string
25D4:	cmp	r2,r0
25D6:	bcs	25B6		;input string too short
25D8:	dec	r0		;because second argument counts from 1
25DA:	beq	25E8
25DC:	tstb	(sp)
25DE:	bne	25E4		;skip if not a string variable
25E0:	inc	0002(sp)	;skip the string variable identifier byte 60
25E4:	add	r0,0002(sp)	;address of the character
25E8:	mov	#1,0004(sp)	;truncate length to 1
25EE:	movb	#80,(sp)	;string identifier
25F2:	jmp	226C

25F6:	mov	#32,r0
25FA:	br	260C
25FC:	mov	#35,r0
2600:	br	260C
2602:	mov	#38,r0
2606:	br	260C
2608:	mov	#33,r0
260C:	mov	8254,r2		;r2 = pointer to the BASIC line
2610:	clr	r3
; test for even number of quotes
2612:	cmpb	#22,-(r2)
2616:	bne	261C
2618:	add	#8000,r3
261C:	tst	r3
261E:	bmi	2612
; test for matching number of parentheses
2620:	cmpb	#29,(r2)	;')'
2624:	bne	2628
2626:	incb	r3
2628:	cmpb	#28,(r2)	;'('
262C:	bne	2630
262E:	decb	r3
2630:	tstb	r3
2632:	bgt	2612
2634:	bne	2656		;ERR!
2636:	cmpb	(r2),8242	;8242 = code of the command/function/operator
263A:	bne	2612
263C:	br	265A

; ERR2 handler (syntax error)
263E:	mov	#32,r0
2642:	br	265A
; ERR5 handler (argument error)
2644:	mov	#35,r0
2648:	br	265A
; ERR6 handler (non existing or wrong type of variable)
264A:	mov	#36,r0
264E:	br	265A
; ERR8 handler (attempt to store too many characters in a string variable)
2650:	mov	#38,r0
2654:	br	265A
; ERR! handler (internal error)
2656:	mov	#21,r0
265A:	mov	r2,8254		;position of error
265E:	jmp	@1D4E		;= jump to 12D4, error handler

; test if there's a string on the stack, ERR2 when not
2662:	bit	#6000,0002(sp)
2668:	beq	2686
266A:	rts	pc

; test if there's a FP number on the stack, ERR2 when not
266C:	bit	#6000,0002(sp)
2672:	bne	2686
2674:	rts	pc

; test if there are two FP numbers on the stack, ERR2 when not
2676:	mov	0002(sp),r0
267A:	bis	000A(sp),r0
267E:	bit	#6000,r0
2682:	bne	2686
2684:	rts	pc
2686:	jmp	25F6

; evaluate a chain of operators '+' and '-'
; returns r1.b = 00 if evaluated to '+', or r1.b = FF if evaluated to '-'
; returns bit 15 of r1 set if at least one operator found
268A:	clr	r1
268C:	cmpb	#2B,(r2)+	;'+'
2690:	bne	2698
2692:	bis	#8000,r1
2696:	br	268C
2698:	dec	r2
269A:	cmpb	#2D,(r2)+	;'-'
269E:	bne	26A8
26A0:	bis	#8000,r1
26A4:	comb	r1
26A6:	br	269A
26A8:	dec	r2
26AA:	rts	pc

26AC:	mov	r5,-(sp)
26AE:	clr	r0
26B0:	tstb	r0
26B2:	bmi	271C
26B4:	cmpb	#20,(r4)+
26B8:	beq	26B4
26BA:	dec	r4
26BC:	mov	#C0,r3
26C0:	mov	#27BC,r2
26C4:	mov	r4,r1
26C6:	cmpb	#20,(r2)+
26CA:	beq	26CE
26CC:	dec	r2
26CE:	cmpb	(r2),(r1)+
26D0:	bne	26DC
26D2:	tstb	(r2)+
26D4:	bne	26CE
26D6:	movb	r3,(r5)+
26D8:	mov	r1,r4
26DA:	sob	r4,26B4
26DC:	tstb	(r2)
26DE:	beq	26D6
26E0:	cmpb	#20,(r2)
26E4:	beq	26D6
26E6:	tstb	(r2)+
26E8:	bne	26E6
26EA:	inc	r3
26EC:	tstb	(r2)
26EE:	bne	26C4
26F0:	cmpb	#21,(r4)
26F4:	bne	26FC
26F6:	movb	(r4)+,(r5)+
26F8:	bne	26F6
26FA:	br	2728
26FC:	cmpb	#28,(r4)
2700:	bne	2706
2702:	add	#100,r0
2706:	cmpb	#29,(r4)
270A:	bne	271C
270C:	sub	#100,r0
2710:	bpl	2724
2712:	mov	r4,r2
2714:	mov	(sp)+,8240
2718:	jmp	263E		;ERR2
271C:	cmpb	#22,(r4)
2720:	bne	2724
2722:	comb	r0
2724:	movb	(r4)+,(r5)+
2726:	bne	26B0
2728:	dec	r4
272A:	tst	r0
272C:	bne	2712
272E:	mov	(sp)+,r2
2730:	rts	pc

; copy a BASIC line expanding keywords
; r5 = source address, r4 = destination address
2732:	mov	#81AD,r3	;end of the input line buffer
2736:	sub	r4,r3
2738:	add	r4,r1
; loop
273A:	movb	(r5)+,r0
273C:	bic	#FF00,r0
2740:	cmpb	r0,#C0		;keyword or single character?
; keyword
2744:	bcs	2772		;branch if single character
2746:	mov	#27BC,r2	;keyword table
274A:	sub	#C0,r0		;convert keyword code to index to the table
; find the string of index r0 in the table
274E:	beq	2756
2750:	tstb	(r2)+
2752:	bne	2750
2754:	sob	r0,2750		;next entry
; copy the string to the destination buffer
2756:	tstb	(r2)		;end of the string?
2758:	bne	2760		;branch if not yet
275A:	cmp	r4,r1
275C:	bcc	273A
275E:	sob	r1,273A
2760:	decb	r3
2762:	bge	2768
2764:	jsr	pc,2784
2768:	cmp	r4,r1
276A:	bcc	276E
276C:	inc	r1
276E:	movb	(r2)+,(r4)+
2770:	br	2756
; single character
2772:	decb	r3
2774:	bge	277A
2776:	jsr	pc,2784
277A:	movb	r0,(r4)+
277C:	bne	273A
277E:	sub	#816D,r1	;input line buffer
2782:	rts	pc

2784:	mov	r1,-(sp)
2786:	mov	#816D,r1	;input line buffer
278A:	clrb	(r4)
278C:	tstb	(r1)
278E:	beq	27B8		;ERR!
2790:	cmpb	#22,(r1)+
2794:	bne	279A
2796:	add	#8000,r0
279A:	tst	r0
279C:	bmi	278C
279E:	cmpb	#20,FFFF(r1)
27A4:	bne	278C
27A6:	cmp	(sp),r1
27A8:	bcs	27AC
27AA:	dec	(sp)
27AC:	movb	(r1)+,FFFE(r1)
27B0:	bne	27AC
27B2:	dec	r4
27B4:	mov	(sp)+,r1
27B6:	rts	pc

27B8:	jmp	2656		;ERR!

27BC:	.asciz	"SIN "		;code C0
	.asciz	"COS "		;code C1
	.asciz	"TAN "		;code C2
	.asciz	"ASN "		;code C3
	.asciz	"ACS "		;code C4
	.asciz	"ATN "		;code C5
	.asciz	"LOG "		;code C6
	.asciz	"LN "		;code C7
	.asciz	"EXP "		;code C8
	.asciz	"SQR "		;code C9
	.asciz	"ABS "		;code CA
	.asciz	"INT "		;code CB
	.asciz	"SGN "		;code CC
	.asciz	"FRAC "		;code CD
	.asciz	"VAL "		;code CE
	.asciz	"LEN "		;code CF
	.asciz	"CHR "		;code D0
	.asciz	"ASCI "		;code D1
	.asciz	"RND "		;code D2
	.asciz	"MID "		;code D3
	.asciz	"GETC "		;code D4
	.asciz	"RAN#"		;code D5
	.asciz	"KEY"		;code D6
	.asciz	"CSR "		;code D7
	.asciz	"NEXT "		;code D8
	.asciz	"GOTO "		;code D9
	.asciz	"GOSUB "	;code DA
	.asciz	"RETURN"	;code DB
	.asciz	"IF "		;code DC
	.asciz	"FOR "		;code DD
	.asciz	"PRINT "	;code DE
	.asciz	"INPUT "	;code DF
	.asciz	" THEN "	;code E0
	.asciz	" TO "		;code E1
	.asciz	" STEP "	;code E2
	.asciz	"STOP"		;code E3
	.asciz	"END"		;code E4
	.asciz	"LETC "		;code E5
	.asciz	"DEFM "		;code E6
	.asciz	"VAC"		;code E7
	.asciz	"MODE "		;code E8
	.asciz	"SET "		;code E9
	.asciz	"DRAWC "	;code EA
	.asciz	"DRAW "		;code EB
	.asciz	"RUN "		;code EC
	.asciz	"LIST "		;code ED
	.asciz	"AUTO "		;code EE
	.asciz	"CLEAR "	;code EF
	.asciz	"TEST"		;code F0
	.asciz	"WHO"		;code F1
	.db	0

; convert a FP number on the stack to decimal ASCII,
; also expects number printing precision and destination address on the stack
28CC:	mov	sp,r3
28CE:	add	#8,r3
; move the mantissa to r0-r2
28D2:	mov	(r3)+,r0
28D4:	mov	(r3)+,r1
28D6:	mov	(r3)+,r2
28D8:	mov	(sp)+,-(r3)	;return address
28DA:	mov	(sp)+,-(r3)	;destination address
28DC:	clr	-(r3)
28DE:	mov	r4,-(sp)	;save r4
28E0:	sub	#10,sp
; stack summary:
; sp+00: buffer
; sp+10: saved r4
; sp+12: specified printing precision
; sp+14: on entry signs and exponent, later only exponent
; sp+16: initialised to 0, later sign
; sp+18: destination address
; sp+1A: return address
28E4:	mov	sp,r5
28E6:	movb	#30,(r5)+	;'0'
28EA:	tst	-(r3)		;sp+14, signs and exponent
28EC:	beq	28F4		;branch if FP number = 0
28EE:	asl	(r3)+		;sp+14, signs and exponent
28F0:	ror	(r3)		;sp+16, sign goes to bit 15 (decimal)
28F2:	ror	-(r3)		;sp+14, exponent, sign cleared
28F4:	add	#F000,(r3)	;sp+14, convert the exponent to signed integer
28F8:	movb	0012(sp),r4	;sp+12, specified printing precision
28FC:	bpl	2906
28FE:	neg	r4
2900:	cmp	#A,r4
2904:	bcc	290A
2906:	mov	#A,r4		;default printing precision
290A:	swab	r4
290C:	mov	r4,r3
; this loop converts N+1 digits of the mantissa to ASCII, where N is the upper
; byte of the r4 register
290E:	bis	#0004,r4
; this loop shifts the mantissa one digit left, the most significant digit
; goes to r3
2912:	asl	r2
2914:	rol	r1
2916:	rol	r0
2918:	rolb	r3
291A:	decb	r4
291C:	bgt	2912
291E:	bis	#30,r3		;convert digit to ASCII
2922:	movb	r3,(r5)+	;store the digit in the buffer sp+00
; next digit
2924:	clrb	r3
2926:	sub	#0100,r4
292A:	bge	290E
; rounding (the last digit will be dropped)
292C:	cmpb	-(r5),#35	;is last digit >= 5 ?
2930:	bcs	293C		;skip rounding up when not
; rounding up
; the number at sp+00 starts with '0', which will be changed to '1' if
; mantissa = 0.9999...
2932:	incb	-(r5)
2934:	cmpb	(r5),#39	;'9'
2938:	bhi	2932
293A:	inc	r5
; remove trailing zeros
293C:	clrb	(r5)		;truncate the string
293E:	cmpb	#30,-(r5)	;'0'
2942:	bne	294A
2944:	cmp	r5,sp
2946:	bhi	293C
2948:	br	2958
; remove the leading zero
294A:	mov	sp,r5
294C:	cmpb	#30,(r5)+
2950:	beq	2958
2952:	dec	r5
2954:	inc	0014(sp)	;exponent
; output the minus sign for negative numbers
2958:	mov	0018(sp),r4	;r4 = destination address
295C:	movb	#2D,(r4)+	;'-'
2960:	tst	0016(sp)	;sign
2964:	bmi	2972
; space before a positive number, unless maximal precision set
2966:	movb	#20,-(r4)	;' '
296A:	tst	0012(sp)	;specified printing precision
296E:	bpl	2972		;skip when maximal precision
2970:	inc	r4
;
2972:	swab	r3		;actual printing precision
2974:	mov	0014(sp),r2	;exponent
2978:	bgt	29AA
297A:	cmp	#F000,r2	;number = 0 ?
297E:	beq	29AE
2980:	neg	r2
2982:	cmp	r2,#2
2986:	bhi	29B4
2988:	tstb	0012(sp)	;specified precision
298C:	bmi	2998
298E:	sub	r2,r3
2990:	cmp	0018(sp),r4	;destination address
2994:	beq	2998
2996:	dec	r3
; fractional number in normal (not scientific) display format
2998:	movb	#30,(r4)+	;'0'
299C:	movb	#2E,(r4)+	;'.'
; this loop outputs zeros between the decimal point and the mantissa
29A0:	dec	r2
29A2:	blt	29AE
29A4:	movb	#30,(r4)+
29A8:	br	29A0
29AA:	cmp	r2,r3
29AC:	bhi	29B4
29AE:	clr	0014(sp)	;exponent
29B2:	br	29DE
29B4:	tstb	0012(sp)	;specified precision
29B8:	bmi	29D6
29BA:	mov	#5,r3
29BE:	cmp	0018(sp),r4	;sp+18 = destination address
29C2:	bne	29C6
29C4:	inc	r3
; this loop counts the digits of the exponent and corrects r3 accordingly
29C6:	mov	#3,r0
29CA:	mov	#2A56,r1	;table of powers of ten
29CE:	cmp	r2,(r1)+
29D0:	bcc	29D6
29D2:	inc	r3
29D4:	sob	r0,29CE
29D6:	dec	0014(sp)	;exponent
29DA:	mov	#1,r2		;single digit before the decimal point
; this loop outputs r3 digits of the mantissa
; r2 = number of digits before the decimal point
29DE:	movb	(r5)+,(r4)+
29E0:	tstb	(r5)
29E2:	beq	29F4
29E4:	dec	r2
29E6:	bne	29EC
29E8:	movb	#2E,(r4)+	;'.'
29EC:	sob	r3,29DE
29EE:	br	29F8
; this loop outputs trailing zeros
29F0:	movb	#30,(r4)+
29F4:	dec	r2
29F6:	bgt	29F0
; output the exponent
29F8:	mov	0014(sp),r5	;exponent
29FC:	beq	2A16		;skip when exponent is equal 0
29FE:	bpl	2A02
2A00:	neg	r5		;absolute value of the exponent
2A02:	movb	#7B,(r4)+	;'E'
2A06:	tst	0014(sp)
2A0A:	bpl	2A12
2A0C:	movb	#7D,FFFF(r4)	;'E-'
2A12:	jsr	pc,2A22		;convert r5 to decimal ASCII
; terminate the output string
2A16:	clrb	(r4)
2A18:	mov	0010(sp),r4	;restore r4
2A1C:	add	#1A,sp
2A20:	rts	pc

; convert unsigned integer in r5 to decimal ASCII, destination address in r4
2A22:	mov	#2A54,r3	;table of powers of 10
2A26:	mov	#FFFF,r2
; divide r5/(r3) using successive subtraction,
; returns quotient in lower byte of r2, remainder in r5
2A2A:	clrb	r2
2A2C:	sub	(r3),r5		;subtract until negative
2A2E:	bmi	2A32
2A30:	sob	r2,2A2C
2A32:	add	(r3),r5
2A34:	negb	r2
2A36:	bne	2A3C
2A38:	tst	r2		;flag of leading zeros
2A3A:	bmi	2A44		;don't output leading zeros
2A3C:	bisb	#30,r2		;convert digit to ASCII
2A40:	movb	r2,(r4)+	;output the digit
2A42:	clr	r2		;clear the flag of leading zeros
2A44:	cmpb	(r3)+,(r3)+	;= add #2,r3 ; advance the pointer
2A46:	cmp	r3,#2A5A	;end of the table?
2A4A:	blos	2A2A
2A4C:	bis	#30,r5		;convert ones to ASCII
2A50:	movb	r5,(r4)+	;output the digit
2A52:	rts	pc

2A54:	.dw	2710, 03E8, 0064, 000A	;powers of ten

; evaluate the value of a floating point numeric literal pointed to by r4,
; Carry set if out of range
2A5C:	clr	-(sp)
2A5E:	clr	-(sp)
2A60:	mov	#100C,-(sp)	;initial value of the exponent = 0C
; initial mantissa value
2A64:	clr	r0
2A66:	clr	r1
2A68:	clr	r2
; parse the sign of the mantissa
2A6A:	cmpb	#2B,(r4)+	;'+'
2A6E:	beq	2A6A
2A70:	cmpb	#2D,-(r4)	;'-'
2A74:	bne	2A7E
2A76:	inc	r4
2A78:	add	#8000,(sp)	;change the sign of the mantissa
2A7C:	br	2A6A
; parse the mantissa digits before the decimal point
2A7E:	jsr	pc,2B1C		;r5 = value of a digit
2A82:	bcs	2A94		;branch if not a digit
2A84:	inc	(sp)		;exponent
2A86:	bit	#F000,r0	;already 12 (decimal) digits parsed?
2A8A:	bne	2A7E		;ignore further digits, only increment exponent
2A8C:	jsr	pc,2B30		;shift the mantissa one digit left
2A90:	bisb	r5,r2		;add the digit
2A92:	br	2A7E
; parse the decimal point
2A94:	cmpb	#2E,r5		;'.'
2A98:	bne	2AAE
; parse the mantissa digits after the decimal point
2A9A:	jsr	pc,2B1C		;r5 = value of a digit
2A9E:	bcs	2AAE		;branch if not a digit
2AA0:	bit	#F000,r0	;already 12 (decimal) digits parsed?
2AA4:	bne	2A9A		;ignore further digits
2AA6:	jsr	pc,2B30		;shift the mantissa one digit left
2AAA:	bisb	r5,r2		;add the digit
2AAC:	br	2A9A
; test the mantissa for 0
2AAE:	mov	r0,r3
2AB0:	bis	r1,r3
2AB2:	bis	r2,r3
2AB4:	bne	2ABE
; special case, value 0
2AB6:	clr	(sp)
2AB8:	br	2B06
; normalise the mantissa
2ABA:	jsr	pc,2B30		;shift the mantissa one digit left...
2ABE:	bit	#F000,r0	;...until first digit not zero
2AC2:	beq	2ABA
; parse the exponent sign
2AC4:	clr	r3		;initial exponent value
2AC6:	cmpb	#7B,r5		;'E'
2ACA:	beq	2AD6
2ACC:	cmpb	#7D,r5		;'E-'
2AD0:	bne	2AF2
2AD2:	comb	0002(sp)	;store the sign of the exponent
; parse the exponent value
2AD6:	jsr	pc,2B1C		;r5 = value of a digit
2ADA:	bcs	2AF2		;branch if not a digit
2ADC:	asl	r3
2ADE:	add	r3,r5
2AE0:	asl	r3
2AE2:	asl	r3
2AE4:	add	r5,r3		;r3 = 10 (decimal) * r3 + r5
2AE6:	bit	#C000,r3	;test the exponent range
2AEA:	beq	2AD6
; value out of range
2AEC:	sec
2AEE:	jmp	@0006(sp)	;jump to return address
; process the sign of the exponent
2AF2:	tstb	0002(sp)	;stored sign of the exponent
2AF6:	bpl	2AFE
; exponent negative
2AF8:	sub	r3,(sp)
2AFA:	blos	2AEC
2AFC:	br	2B06
; exponent positive
2AFE:	add	r3,(sp)
2B00:	bit	#6000,(sp)
2B04:	bne	2AEC
; place the numeric value on the stack
2B06:	mov	0006(sp),r3	;save the return address
2B0A:	mov	r0,0002(sp)
2B0E:	mov	r1,0004(sp)
2B12:	mov	r2,0006(sp)
2B16:	dec	r4
2B18:	clc
2B1A:	jmp	(r3)		;jump to return address

; r5 = value of a digit pointed to by r4
; returns Carry set if r4 doesn't point to a digit
2B1C:	movb	(r4)+,r5
2B1E:	cmpb	#39,r5		;'9'
2B22:	bcs	2B2E
2B24:	cmpb	r5,#30		;'0'
2B28:	bcs	2B2E
2B2A:	bic	#FFF0,r5
2B2E:	rts	pc

; shift the mantissa one digit left and decrement the exponent
2B30:	mov	#4,r3
2B34:	asl	r2
2B36:	rol	r1
2B38:	rol	r0
2B3A:	sob	r3,2B34
2B3C:	dec	0002(sp)
2B40:	rts	pc


; FP subtraction routine
2B42:	add	#8000,(sp)	;change the sign of the second addend
; FP addition routine
2B46:	mov	sp,r5
2B48:	add	#8,r5		;r5 points to the first addend
2B4C:	clr	r1
2B4E:	asl	(r5)
2B50:	beq	2B76		;branch if first addend is equal 0
2B52:	rol	r1		;sign of the first addend in bit 0 of r1
2B54:	asl	(sp)
2B56:	bne	2B60		;branch if second addend is not equal 0
; second addend is equal 0
2B58:	asr	r1
2B5A:	ror	(r5)
2B5C:	mov	r5,sp
2B5E:	br	2B7E
;
2B60:	rol	r1		;sign of the first addend in bit 1 of r1
				;sign of the second addend in bit 0 of r1
2B62:	mov	r5,r2
2B64:	mov	(sp),r3		;doubled biased exponent of the second addend
2B66:	sub	(r5),r3		;doubled biased exponent of the first addend
2B68:	ror	r3		;difference between exponents
2B6A:	bmi	2B86

; biased exponent of the first addend <= biased exponent of the second addend
2B6C:	cmp	r3,#C
2B70:	blos	2B9E		;branch if difference between exponents <= 0C
; difference between exponents > 0C, first addend is insignificant
2B72:	asr	r1		;sign of the second addend -> Carry
2B74:	ror	(sp)		;restore the exponent of the second addend
2B76:	mov	(sp)+,(r5)+
2B78:	mov	(sp)+,(r5)+
2B7A:	mov	(sp)+,(r5)+
2B7C:	mov	(sp)+,(r5)+
; The sign change of the second addend at the address 2B24 may result in
; a value of -0. This potential issue is addressed by the code below.
2B7E:	asl	(sp)
2B80:	beq	2B84		;drop the sign if biased exponent = 0
2B82:	ror	(sp)		;restore the biased exponent
2B84:	jmp	@(r4)+

; biased exponent of the first addend > biased exponent of the second addend
2B86:	neg	r3		;difference between exponents
2B88:	mov	(r5),(sp)
2B8A:	add	#8,r2
2B8E:	cmp	r3,#C
2B92:	blos	2B9E		;branch if difference between exponents <= 0C
; difference between exponents > 0C, second addend is insignificant
2B94:	mov	r5,sp
2B96:	asr	r1
2B98:	asr	r1		;sign of the first addend -> Carry
2B9A:	ror	(sp)		;restore the exponent of the first addend
2B9C:	jmp	@(r4)+

; both addends are significant
2B9E:	mov	(sp),-(sp)
2BA0:	clr	0002(sp)
2BA4:	clr	(r5)
2BA6:	asr	(sp)
2BA8:	tst	r3		;difference between exponents
2BAA:	beq	2BCC
2BAC:	dec	(sp)
2BAE:	jsr	r4,3970		;integer BCD multiplication by ten
2BB2:	.dw	2BB4
2BB4:	sub	#8,r2
2BB8:	cmp	r2,r5
2BBA:	beq	2BC8
2BBC:	add	#10,r2
2BC0:	br	2BC8
2BC2:	jsr	r4,3986		;integer BCD division by ten
2BC6:	.dw	2BC8
2BC8:	mov	(sp)+,r4
2BCA:	sob	r3,2BC2
; both addends are aligned (i.e. have equal exponents)
2BCC:	mov	r5,r3
2BCE:	add	#8,r3
2BD2:	mov	r5,r2
2BD4:	mov	#4,r0
2BD8:	asl	r1	;r1 stores the signs of the addends on bits 2 and 1
2BDA:	jmp	@2BDE(r1)

2BDE:	.dw	2C24		;both addends positive
	.dw	2BF2		;first addend positive, second addend negative
	.dw	2BE6		;first addend negative, second addend positive
	.dw	2C20		;both addends negative

; first addend negative, second addend positive
2BE6:   cmp     FFF8(r2),(r2)+
2BEA:	bcs	2C12
2BEC:	bne	2C08
2BEE:	sob	r0,2BE6
2BF0:	br	2BFC		;push zero on the stack

; first addend positive, second addend negative
2BF2:	cmp	FFF8(r2),(r2)+
2BF6:	bcs	2C16
2BF8:	bne	2C0C
2BFA:	sob	r0,2BF2
; push zero on the stack
2BFC:	mov	r3,sp
2BFE:	clr	-(sp)
2C00:	clr	-(sp)
2C02:	clr	-(sp)
2C04:	clr	-(sp)
2C06:	jmp	@(r4)+

2C08:	add	#8000,(sp)
2C0C:	mov	r3,r2
2C0E:	mov	r5,r3
2C10:	mov	r2,r5
2C12:	add	#8000,(sp)
2C16:	jsr	r4,3874		;integer BCD subtraction
2C1A:	.dw	2C2C
2C1C:	.dw	2C3E
2C1E:	jmp	@(r4)+

; both addends negative
2C20:	add	#8000,(sp)
; both addends positive
2C24:	jsr	r4,3840		;integer BCD addition
2C28:	.dw	2C3E

2C2A:	jmp	@(r4)+		;superfluous, never used
2C2C:	cmp	r3,r5
2C2E:	bcc 2C3C    

2C30:	mov	-(r3),-(r5)
2C32:	mov	-(r3),-(r5)
2C34:	mov	-(r3),-(r5)
2C36:	mov	-(r3),-(r5)
2C38:	add	#10,r3
2C3C:	jmp	@(r4)+

2C3E:	mov	(sp)+,r4
2C40:	tst	(r5)
2C42:	beq	2C4C
2C44:	inc	(sp)
2C46:	jsr	r4,3984		;integer BCD division by ten
2C4A:	.dw	2C3E
2C4C:	add	#8,r5
2C50:	mov	-(r5),r0
2C52:	bis	-(r5),r0
2C54:	bis	-(r5),r0
2C56:	bis	-(r5),r0
2C58:	beq	2C70
2C5A:	bit	#F000,0002(r5)
2C60:	bne	2C6E
2C62:	jsr	r4,396E		;integer BCD multiplication by ten
2C66:	.dw	2C68
2C68:	mov	(sp)+,r4
2C6A:	dec	(sp)
2C6C:	br	2C5A
; common exit point for the addition, multiplication and division routines
; r5 points to the mantissa, sp points to the exponent of the result
2C6E:	mov	(sp),(r5)	;copy the exponent to the result
2C70:	mov	r5,sp		;clear the stack
2C72:	bit	#6000,(sp)	;test for overflow/underflow
2C76:	beq	2C7C
2C78:	jmp	3AA4		;ERR3
2C7C:	jmp	@(r4)+


; FP multiplication routine
2C7E:	mov	sp,r5
2C80:	mov	#8,r3
2C84:	add	r3,r5		;points to the end of the multiplicand
2C86:	add	r5,r3		;points to the end of the multiplier
; return 0 if either of the factors is equal zero
2C88:	tst	(sp)		;biased exponent of the multiplier
2C8A:	beq	2BFC		;push zero on the stack
2C8C:	tst	(r5)		;biased exponent of the multiplicand
2C8E:	beq	2BFC		;push zero on the stack
; calculate the exponent of the product - add exponents of both factors
2C90:	mov	(r5),r2		;exponent of the multiplicand
2C92:	clr	(r5)		;clear the exponent of the multiplicand
2C94:	add	(sp),r2		;exponent of the multiplier
2C96:	clr	(sp)		;clear the exponent of the multiplier
2C98:	sub	#1001,r2	;correct the exponent bias
; move the multiplier to the top of the stack and initialise the product to 0
2C9C:	mov	#4,r0
2CA0:	mov	r3,r1
2CA2:	mov	-(r1),-(sp)
2CA4:	clr	(r1)
2CA6:	sob	r0,2CA2
;
2CA8:	mov	r2,-(sp)
2CAA:	mov	r5,r2		;r2 points to the end of the multiplicand
2CAC:	jsr	r4,3970		;shift the multiplicand one digit left
2CB0:	.dw	2CB2
; data on the stack:
; 1 word - return address (R4 pushed by the subroutine call at address 2CAC)
; 1 word - exponent of the product, pointed to by sp
; 4 words - product, the end pointed to by r3
; 4 words - multiplier, the end pointed to by -8(r5)
; 4 words - multiplicand, the end pointed to by r5
2CB2:	mov	#C,-(sp)	;loop counter (13 digits)
; repeated addition of the multiplicand to the product as many times as there
; are units in the multiplier
2CB6:	bit	#000F,FFF6(r5)	;least significant digit of the multiplier
2CBC:	beq	2CCA
2CBE:	dec	FFF6(r5)		;least significant digit of the multiplier
2CC2:	jsr	r4,3AA8
2CC6:	.dw	3840		;add the multiplicand to the product
	.dw	2CB6
; addition done, next digit of the multiplier will be processed
2CCA:	dec	(sp)		;loop counter
2CCC:	ble	2CDE
2CCE:	mov	r3,r2		;-10(r2) points to the end of the multiplier
2CD0:	jsr	r4,3AA8
2CD4:	.dw	39F2		;shift the multiplier one digit right
	.dw	3984		;shift the product one digit right
	.dw	2CB6

; this loop normalises the mantissa
2CDA:	inc	0004(sp)	;exponent
2CDE:	jsr	r4,3AA8
; rounding
2CE2:	.dw	3942		;constant 0000 0000 0000 0005
	.dw	3840		;integer BCD addition
	.dw	3984		;integer BCD division by ten
	.dw	2CEA
2CEA:	tst	(r5)		;first word of the product
2CEC:	bne	2CDA		;repeat until the first word of the product = 0
2CEE:	tst	(sp)+		;drop the loop counter
2CF0:	mov	(sp)+,r4	;return address
2CF2:	jmp	2C6E


; FP modulo routine, returns the FP remainder on the stack and two least
; significant digits of an integer quotient in r0 
2CF6:	mov	#0080,r1	;flag of a special division
2CFA:	br	2CFE

; FP division routine
2CFC:	clr	r1		;flag of an ordinary division
2CFE:	tst	(sp)		;test the divisor for 0
2D00:	bne	2D06
2D02:	jmp	3AA4		;ERR3 when division by 0 attempted
2D06:	mov	sp,r5		;r5 points to the divisor
2D08:	mov	#8,r3
2D0C:	add	r3,r5		;r5 points to the dividend
2D0E:	add	r5,r3		;r3 points to the end of the dividend
2D10:	mov	(r5),r0		;test the dividend for 0
2D12:	beq	2C8E		;push 0 on the stack
; calculate the exponent of the quotient in r2
2D14:	mov	#100D,r2	;bias
2D18:	add	(r5),r2		;exponent of the dividend
2D1A:	clr	(r5)		;clear the exponent of the dividend
2D1C:	sub	(sp),r2		;exponent of the divisor
2D1E:	clr	(sp)		;clear exponent of the divisor
; make room for the quotient on the stack, initialised to 0
2D20:	clr	-(sp)
2D22:	clr	-(sp)
2D24:	clr	-(sp)
2D26:	clr	-(sp)
2D28:	mov	r1,-(sp)	;push the flag what's calculated
2D2A:	mov	r2,-(sp)	;push the exponent
; data on the stack:
; 1 word - exponent of the quotient, pointed to by sp
; 1 word - flag what's calculated, pointed to by 2(sp)
; 4 words - quotient, pointed to by -10(r5)
; 4 words - divisor, pointed to by -8(r5)
; 4 words - dividend (and later the remainder), pointed to by r5 and -8(r3)
;
; repeated subtraction of the divisor from the dividend, the quotient is
; incremented at every subtraction
2D2C:	mov	#4,r0		;counter of words of the mantissa
2D30:	mov	r5,r1
2D32:	cmp	FFF8(r1),(r1)+	;compare divisor with dividend
2D36:	bcs	2D3C		;subtract when dividend>=divisor
2D38:	bne	2D4A		;stop when dividend<divisor
2D3A:	sob	r0,2D32		;next word
; subtract when dividend>=divisor
; r3 points to the end of the dividend, r5 points to the end of the divisor
2D3C:	jsr	r4,3874		;integer BCD subtraction
2D40:	.dw	2D42
2D42:	mov	(sp)+,r4
2D44:	inc	FFF6(r5)		;increment the quotient at every subtraction
2D48:	br	2D2C		;next attempt of subtraction
; subtraction done
2D4A:	tstb	0002(sp)	;flag
2D4E:	bgt	2D96
; in case of ordinary division the shift/subtraction loop is repeated until
; we get 13 digits of the quotient (i.e. the 13th digit is not equal 0)
2D50:	bit	#0F00,FFF0(r5)	;first word of the quotient
2D56:	bne	2D8C
2D58:	dec	(sp)		;exponent of the quotient
; shift the quotient one digit left
; in case of ordinary division, an example mantissa 1234567890123 would be
; stored as 01xx 2345 6789 0123 (only the most significant byte of the first
; word is used)
2D5A:	mov	#4,r0		;counter of shifts
2D5E:	mov	r5,r2
2D60:	sub	#8,r2		;r2 points to the end of the quotient
2D64:	asl	-(r2)
2D66:	rol	-(r2)
2D68:	rol	-(r2)
2D6A:	rolb	-(r2)		;most significant byte of the first word
2D6C:	bit	#00FF,0002(sp)	;flag (wouldn't be TSTB 0002(SP) equivalent?)
2D72:	beq	2D80		;skip when ordinary division
; the following code rotates only 12 bits of the word pointed to by r2
; in case of a special division, an example integer quotient 123 would be
; stored as 0312 xxxx xxxx xxxx
2D74:	rolb	-(r2)		;least significant byte of the first word
2D76:	add	#F000,(r2)	;Carry <- bit 12 of the word pointed to by r2
2D7A:	adc	(r2)
2D7C:	bic	#F000,(r2)
2D80:	sob	r0,2D5E
;
2D82:	jsr	r4,396E		;shift the dividend one digit left
2D86:	.dw	2D88
2D88:	mov	(sp)+,r4
2D8A:	br	2D2C		;back to the subtraction loop
;
2D8C:	tstb	0002(sp)	;flag
2D90:	beq	2DD4		;skip when ordinary division
;
2D92:	comb	0002(sp)
2D96:	mov	r3,r2
2D98:	sub	#0017,r2	;r2 points to the beginning of the quotient +1
; test the quotient for 0
2D9C:	movb	(r2)+,r0
2D9E:	bis	(r2)+,r0
2DA0:	bis	(r2)+,r0
2DA2:	bis	(r2)+,r0
2DA4:	beq	2DB6
2DA6:	mov	(sp),r0		;exponent of the quotient
2DA8:	asl	r0
2DAA:	cmp	r0,#2000
2DAE:	bgt	2D58
2DB0:	clrb	0002(sp)
2DB4:	br	2D50
;
2DB6:	sub	#8,r2
2DBA:	mov	(sp),r0
2DBC:	clr	(sp)
2DBE:	asl	r0
2DC0:	cmp	r0,#2002
2DC4:	bcs	2DD4
2DC6:	beq	2DCC
2DC8:	clrb	(r2)
2DCA:	br	2DD4
2DCC:	aslb	(r2)
2DCE:	aslb	(r2)
2DD0:	aslb	(r2)
2DD2:	aslb	(r2)
;
2DD4:	mov	r5,r3
2DD6:	mov	r5,r2
2DD8:	sub	#000F,r2
2DDC:	movb	(r2)+,(r3)+
2DDE:	clrb	(r3)+
2DE0:	mov	(r2)+,(r3)+
2DE2:	mov	(r2)+,(r3)+
2DE4:	mov	(r2)+,(r3)+
; this loop normalises the mantissa of the result
2DE6:	mov	r5,r2
; rounding, function 3942 could be used here 
2DE8:	mov	#0005,-(r2)	;constant 0000 0000 0000 0005
2DEC:	clr	-(r2)
2DEE:	clr	-(r2)
2DF0:	clr	-(r2)
2DF2:	jsr	r4,3840		;integer BCD addition
2DF6:	.dw	3984		;integer BCD division by ten
2DF8:	.dw	2DFA
2DFA:	mov	(sp)+,r4
2DFC:	bit	#000F,(r5)
2E00:	beq	2E06
2E02:	inc	(sp)		;exponent of the result
2E04:	br	2DE6
2E06:	movb	FFF0(r5),r0	;first word of the quotient
; the following 3 instructions could be replaced by JMP 2C6E
2E0A:	mov	(sp),(r5)	;copy the exponent to the result
2E0C:	mov	r5,sp		;clear the stack
2E0E:	jmp	2C72		;test for overflow/underflow and return via R4


; FP absolute value calculating routine
2E12:	bic	#8000,(sp)		;clear the sign
2E16:	jmp	@(r4)+


; change the sign of a FP number
2E18:	tst	(sp)			;do nothing when number is equal 0
2E1A:	beq	2E20
2E1C:	add	#8000,(sp)
2E20:	jmp	@(r4)+


; FP sign calculating routine
2E22:	tst	(sp)			;do nothing when number is equal 0
2E24:	beq	2E38
2E26:	mov	sp,r5
; replace the FP number on the stack with 1.00000000000 keeping only the
; original sign
2E28:	bic	#7FFF,(r5)
2E2C:	bis	#1001,(r5)+
2E30:	mov	#1000,(r5)+
2E34:	clr	(r5)+
2E36:	clr	(r5)+
2E38:	jmp	@(r4)+


; FP rounding routine
2E3A:	mov	r4,r5		
2E3C:	jsr	r4,3AA8  

; Вроде как надо   
2E40:   cmp @2E44(R5), 8602(R2)                ;convert a FP number to 16-bit integer;

; В оригинале
;2E40:	.dw	2F72		;convert a FP number to 16-bit integer;
;	    .dw	2E44
;2E42:	bcc	2E4A      
				    
2E46:	jmp	3AA4		; ERR3 when conversion to integer failed
2E4A:	mov	r5,r4       
2E4C:	mov	(sp)+,r1
2E4E:	mov	(sp),r2
2E50:	beq	2E38
2E52:	mov	sp,r3
2E54:	mov	(sp),-(sp)
2E56:	clr	(r3)
2E58:	add	#8,r3
2E5C:	mov	sp,r5
2E5E:	bic	#8000,r2
2E62:	add	#EFF4,r2
2E66:	sub	r2,r1
2E68:	bmi	2E9C
2E6A:	beq	2E82
2E6C:	cmp	r1,#C
2E70:	bcs	2E76
2E72:	jmp	2BFC		;push zero on the stack
2E76:	jsr	r4,3984		;integer BCD division by ten
2E7A:	.dw	2E7C
2E7C:	mov	(sp)+,r4
2E7E:	inc	(sp)
2E80:	sob	r1,2E76
2E82:	mov	#5,-(sp)
2E86:	clr	-(sp)
2E88:	clr	-(sp)
2E8A:	clr	-(sp)
2E8C:	jsr	r4,3840		;integer BCD addition
2E90:	.dw	2E92
2E92:	mov	(sp)+,r4
2E94:	mov	r5,sp
2E96:	bic	#F,FFFE(r3)
2E9C:	tst	(r5)+
2E9E:	jmp	2C40


; FP fraction calculating routine
2EA2:	mov	sp,r3
2EA4:	mov	(r3),r5
2EA6:	add	#8,r3		;r3 points to the end of the number
2EAA:	mov	(sp),r1
2EAC:	bic	#8000,r1	;clear the sign of the mantissa
2EB0:	add	#F000,r1
2EB4:	ble	2E38		;do nothing when exponent negative
2EB6:	cmp	r1,#C		;less than 0C digits before the decimal point?
2EBA:	bcs	2EC0		;continue when yes
2EBC:	jmp	2BFC		;push zero on the stack when no
; drop digits before the decimal point by shifting the number left r1 times
2EC0:	jsr	r4,396E		;integer BCD multiplication by ten
2EC4:	.dw	2EC6
2EC6:	mov	(sp)+,r4
2EC8:	sob	r1,2EC0
2ECA:	asl	r5
2ECC:	mov	-(r2),r5
2ECE:	bis	-(r2),r5
2ED0:	bis	-(r2),r5
2ED2:	mov	r5,-(r2)
2ED4:	beq	2E38
2ED6:	mov	#2000,r5
2EDA:	ror	r5
2EDC:	mov	r5,-(sp)
2EDE:	mov	r2,r5
2EE0:	jmp	2C4C


; FP integer value calculating routine
2EE4:	mov	sp,r3
2EE6:	add	#8,r3		;r3 points to the end of the number
2EEA:	mov	(sp),r2
2EEC:	bic	#8000,r2	;clear the sign of the mantissa
2EF0:	add	#F000,r2
2EF4:	ble	2EBC		;push zero on the stack when exponent negative
2EF6:	mov	#C,r1
2EFA:	cmp	r1,r2
2EFC:	blos	2F16		;do nothing when number >= 1e12
2EFE:	sub	r2,r1
2F00:	mov	r1,r5		;number of digits after decimal point
; drop digits after the decimal point by shifting the number right r1 times
2F02:	jsr	r4,3984		;integer BCD division by ten
2F06:	.dw	2F08
2F08:	mov	(sp)+,r4
2F0A:	sob	r1,2F02
; shift the truncated number left r5 times, digits after the decimal point
; will be replaced with zeros
2F0C:	jsr	r4,396E		;integer BCD multiplication by ten
2F10:	.dw	2F12
2F12:	mov	(sp)+,r4
2F14:	sob	r5,2F0C
2F16:	jmp	@(r4)+

; convert a 16-bit signed integer to FP
2F18:	clr	r1		;mantissa
2F1A:	clr	r3		;exponent for input value of 0
2F1C:	mov	(sp),r2		;number to be converted
2F1E:	beq	2F68
2F20:	bpl	2F24
2F22:	neg	r2
2F24:	mov	#1005,r3	;exponent
2F28:	mov	#2A54,r5	;table of powers of ten
2F2C:	mov	#4,r0		;digit counter
; shift the calculated digit left
2F30:	asl	r1
2F32:	asl	r1
2F34:	asl	r1
2F36:	asl	r1
; divide r1 = r2/(r5) using successive subtraction
2F38:	cmp	r2,(r5)+
2F3A:	bcs	2F42
2F3C:	sub	-(r5),r2
2F3E:	inc	r1
2F40:	br	2F38
2F42:	sob	r0,2F30		;next digit
; r2 = last digit (ones)
2F44:	asl	r2
2F46:	asl	r2
2F48:	asl	r2
2F4A:	asl	r2
2F4C:	swab	r2
2F4E:	bic	#7FFF,(sp)	;preserve the sign
2F52:	add	(sp),r3
; normalise the mantissa
2F54:	bit	#F000,r1	;first digit of mantissa must not be 0
2F58:	bne	2F68
; shift the mantissa one digit left
2F5A:	mov	#4,r0
2F5E:	asl	r2
2F60:	rol	r1
2F62:	sob	r0,2F5E
2F64:	dec	r3		;decrement the exponent
2F66:	br	2F54
; push the converted number on the stack
2F68:	clr	(sp)
2F6A:	mov	r2,-(sp)	;digit 0 (ones)
2F6C:	mov	r1,-(sp)	;digits 4 to 1
2F6E:	mov	r3,-(sp)	;exponent
2F70:	jmp	@(r4)+

; convert a FP number on the stack a to 16-bit signed integer,
; allowed range -32767 to +32767 (values shown decimal),
; returns Carry set if conversion failed
2F72:	mov	sp,r3
2F74:	clr	r1
2F76:	mov	(r3)+,r2	;biased exponent
2F78:	beq	2FB4		;branch if the number = 0
2F7A:	bic	#8000,r2	;drop the sign
2F7E:	add	#F000,r2
2F82:	ble	2FB4		;return 0 for numbers < 1
2F84:	cmp	#5,r2		;test the exponent
2F88:	bcs	2FBC		;number too big, conversion failed
; shift the most significant mantissa digit to -(sp)
2F8A:	mov	#4,r0
2F8E:	clr	-(sp)
2F90:	asl	0002(r3)
2F94:	rol	(r3)
2F96:	rol	(sp)
2F98:	sob	r0,2F90
2F9A:	bit	#F000,r1
2F9E:	bne	2FBC		;result out of specified range
; r1 = 10decimal * r1 + (sp)+
2FA0:	asl	r1
2FA2:	add	r1,(sp)
2FA4:	asl	r1
2FA6:	asl	r1
2FA8:	add	(sp)+,r1
2FAA:	bmi	2FBC
2FAC:	sob	r2,2F8A
; process negative numbers
2FAE:	tst	(sp)
2FB0:	bpl	2FB4
2FB2:	neg	r1
; conversion succeeded, return the integer number on the stack and Carry clr
2FB4:	add	#6,sp
2FB8:	mov	r1,(sp)
2FBA:	jmp	@(r4)+
; conversion failed, return 0 on the stack and Carry set
2FBC:	add	#6,sp
2FC0:	clr	(sp)
2FC2:	sec
2FC4:	jmp	@(r4)+


; function RAN#
; algorithm:
; seed = (12869*seed + 6925) and 32767
; RAN# = seed/32768
2FC6:	sub	#8,sp		;make room on the stack
2FCA:	mov	0008(sp),(sp)	;move the return address to the top of stack
2FCE:	mov	#11,r0
2FD2:	mov	824E,r1		;RAN# seed
2FD6:	clr	r2
2FD8:	mov	#3245,r3
2FDC:	ror	r2
2FDE:	ror	r3
2FE0:	bcc	2FE4
2FE2:	add	r1,r2
2FE4:	sob	r0,2FDC
2FE6:	add	#1B0D,r3
2FEA:	bic	#8000,r3
2FEE:	mov	r3,824E
2FF2:	mov	#1250,-(sp)
2FF6:	mov	#7578,-(sp)
2FFA:	mov	#3051,-(sp)
2FFE:	mov	#0FFC,-(sp)	;number 0.30517578125E-4 = 1/32768
3002:	mov	r3,-(sp)
3004:	jsr	r4,3AA8
3008:	.dw	2F18		;convert a 16-bit signed integer to FP
	.dw	2C7E		;FP multiply
	.dw	3610


; The following arithmetic functions use algorithms described by J.E.Meggitt
; in the IBM Journal (April 1962) in an article "Pseudo Division and Pseudo
; Multiplication processes", which can be treated as an implementation of the
; CORDIC method developed by J.Volder.
; The pseudo multiplication algorithm was slightly modified - the iteration
; loop is terminated when the shifted multiplicand Q reaches 0. It has
; following advantages against the original:
; - less iterations for small values of Q
; - the product A is always left aligned
; This modification requires subtraction of the remaining J value (iteration
; counter) from the exponent of the final result.

; Function SQR
300E:	mov	sp,r5
3010:	mov	r5,r3
3012:	tst	(r3)+		;= add #2,r3 ; skip the return address
3014:	mov	(r3),r1
3016:	beq	306E		;do nothing when number is equal 0
3018:	bpl	301E
301A:	jmp	3AA4		;ERR3 when number negative
301E:	clr	(r3)
3020:	add	#8,r3		;r3 points to the end of the mantissa
3024:	sub	#18,sp
3028:	add	#F000,r1	;remove the exponent bias
302C:	asr	r1		;divide the exponent by 2
302E:	bcs	303A		;branch if odd exponent
3030:	jsr	r4,396E		;integer BCD multiplication by ten
3034:	.dw	3036
3036:	tst	(sp)+		;= add #2,sp ; drop a word from the stack
3038:	dec	r1		;adjust the exponent
303A:	mov	r1,-(sp)
; Data on the stack:
; 4 words: quotient Q, the end pointed to by -10(r5) and by -1A(r3)
; 4 words: number D by which the divisor B is incremented, contains digit 1
;   moving from the most significant position to the least significant one at
;   each iteration, the end pointed to by -8(r5)
; 4 words: divisor B, the end pointed to by r5
; 1 word: return address
; 4 words: radicand A (and later the remainder), the end pointed to by r3
303C:	mov	#3080,r1	;conditional branch control block
3040:	jsr	r4,3AA8
3044:	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	3934	;initial divisor B = 0001 0000 0000 0000
	.dw	394A	;initial quotient Q = 0000 0000 0000 0000
	.dw	396E	;shift the radicand A left by one digit
	.dw	38AA	;conditional branch

; end of the SQR calculation
3050:	mov	0010(sp),r1
3054:	add	#2A,sp
3058:	add	#1001,r1	;bias the exponent
305C:	tst	(r5)+		;= add #2,r5
; normalise the mantissa
305E:	tst	(r5)
3060:	beq	306C
3062:	jsr	r4,3984		;integer BCD division by ten
3066:	.dw	3068
3068:	tst	(sp)+		;= add #2,sp ; drop a word from the stack
306A:	inc	r1		;increment the exponent
306C:	mov	r1,(r5)
306E:	rts	pc

; the conditional branch control block, copied to the top of the stack
3070:	.dw	0000	;iteration counter J
	.dw	0000	;not used
	.dw	3080	;branch address when A >= B
	.dw	308C	;branch address when A < B
	.dw	3098	;branch address when iteration counter reached 0C
	.dw	0000	;not used
	.dw	0000	;not used
	.dw	0000	;not used

; pseudo-division iteration loop
; repeat while A >= B
3080:	.dw	395E	;A=A-B
	.dw	39F8	;calculate D from the iteration counter J
	.dw	39A6	;B=B+D
	.dw	39A6	;B=B+D
	.dw	39D8	;increment quotient Q
	.dw	38AA	;conditional branch

; enter the next iteration round when A < B
308C:	.dw	396E	;shift A left by one digit
	.dw	399A	;B=B-D
	.dw	39E4	;shift quotient Q left, increment iteration counter J
	.dw	39F8	;calculate D from the iteration counter
	.dw	39A6	;B=B+D
	.dw	38AA	;conditional branch

; end of the iteration
3098:	.dw	3918	;copy the quotient to the bottom of the stack
; rounding
	.dw	3942	;constant 0000 0000 0000 0005
	.dw	3840	;integer BCD addition
	.dw	3984	;integer BCD division by ten
	.dw	3050	;end of calculation


; function EXP
30A2:	jsr	r4,3AA8
30A6:	.dw	37AE	;DUP (skip the return address)
; the argument is converted to the form: n * LN 10 + a
; EXP (n * LN 10 + a) = 10^n * EXP (a)
; a = x mod (LN 10), argument scaled to range 0..LN 10
	.dw	37CE	;push LN 10 on the stack
	.dw	2CFC	;FP divide
	.dw	2EA2	;FP fraction
	.dw	37CE	;push LN 10 on the stack
	.dw	2C7E	;FP multiply
; n = x div (LN 10), scaling factor
	.dw	37BA	;OVER (skip the return address)
	.dw	37CE	;push LN 10 on the stack
	.dw	2CFC	;FP divide
	.dw	2F72	;convert a FP number to 16-bit integer
	.dw	30BC
30BC:	bcs	3136	;ERR3 if conversion to integer failed
30BE:	mov	(sp)+,r1	;scaling factor n
30C0:	mov	(sp),r0		;exponent
30C2:	clr	(sp)		;the most significant word of the argument
30C4:	mov	sp,r3
30C6:	add	#8,r3		;r3 will point to the end of the argument
30CA:	bic	#8000,r0	;absolute value of the argument
30CE:	beq	30E0
30D0:	add	#F000,r0	;remove the exponent bias
30D4:	ble	30E0
30D6:	jsr	r4,396E		;integer BCD multiplication by ten
30DA:	.dw	30DC
30DC:	tst	(sp)+		;= add #2,sp
30DE:	clr	r0
30E0:	mov	000A(sp),r2	;exponent of the original argument x
30E4:	sub	#10,sp
30E8:	mov	r1,-(sp)	;scaling factor
30EA:	mov	r0,-(sp)	;offset to the table of constants
; If the exponent = 0, the argument can be converted to BCD integer simply by
; dropping the exponent. However, for exponents < 0, the mantissa would have
; to be shifted right. To save the shifts, an offset is subtracted from the
; index to the table of constants 10^j * ln (1+10^-j). For example:
; if argument is < 0.1 and >= 0.01 then offset = -1 (division starts from the
; second position of the table of constants)
; if argument is < 0.01 and >= 0.001 then offset = -2 (division starts from
; the third position of the table of constants)
30EC:	mov	r3,r5	;r5 points to the end of the scaled argument
30EE:	add	#A,r3	;r3 points to the end of rhe original argument
30F2:	mov	#3164,r1
30F6:	jsr	r4,3AA8
30FA:	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	313A	;save the sign of the argument X
	.dw	391E	;move the scaled argument to another location
	.dw	394A	;initial quotient Q = 0000 0000 0000 0000
	.dw	396E	;integer BCD multiplication by ten
	.dw	3AAC	;unconditional jump
	.dw	316E	;address

; end of the EXP calculation
310A:	tst	(r5)+		;= add #2,r5 ; r5 will point to the result now
310C:	mov	0012(sp),(r5)	;scaling factor goes to the exponent
3110:	bpl	3114
3112:	neg	(r5)
3114:	add	#1001,(r5)	;bias the exponent
3118:	mov	(sp),r0		;sign of the original argument
311A:	add	#2C,sp
311E:	bit	#E000,(r5)
3122:	bne	3136		;ERR3 if overflow
3124:	tst	r0		;test the sign of the original argument
3126:	bmi	312A		;reciprocal the result if negative
3128:	rts	pc
; reciprocal for negative arguments, EXP(-X) = 1/EXP(X)
312A:	jsr	r4,3AA8
312E:	.dw	37D4		;push 1.00000000000 on the stack
	.dw	37CA		;push a FP number pointed to by r3 on the stack
	.dw	2CFC		;FP divide
	.dw	3610

3136:	jmp	3AA4		;ERR3

; save the sign of the argument X
313A:	asl	r2		;sign + exponent word of the orig. arg. X
313C:	ror	(sp)		;first word of the branch control block
313E:	jmp	@(r4)+

; adjust the position of the product A
3140:	movb	(sp),r1		;iteration counter
3142:	sub	0010(sp),r1	;offset to the table of constants
3146:	beq	3152
3148:	jsr	r4,3984		;shift the product A one digit right
314C:	.dw	314E
314E:	mov	(sp)+,r4
3150:	sob	r1,3148
3152:	jmp	@(r4)+

; the conditional branch control block, copied to the top of the stack
3154:	.dw	0000	;MSB: sign of the argument X, LSB: iteration counter J
	.dw	3256	;pointer to the table of constants 10^j * ln(1+10^-j)
; first iteration loop (pseudo division)
	.dw	3164	;branch address when A >= B
	.dw	316A	;branch address when A < B
	.dw	3172	;branch address when end of iteration
; second iteration loop (pseudo multiplication)
	.dw	3178	;branch address when last digit of Q <> 0
	.dw	3182	;branch address when next iteration round (when Q <> 0)
	.dw	3188	;branch address when end of iteration (when Q = 0)

; First iteration:
; The scaled argument will be expressed as a sum of products q[j]*ln(1+10^-j)

; Data on the stack:
; 1 word: offset to the table of constants, pointed to by 10(sp)
; 1 word: scaling factor, pointed to by 12(sp)
; 4 words: quotient Q storing the q[j] values, the end pointed to by -10(r5)
; 4 words: unused in this iteration, the end pointed to by -8(r5)
; 4 words: divisor B, the end pointed to by r5
; 1 word: return address
; 4 words: scaled argument A, the end pointed to by r3

; repeat while A >= B
3164:	.dw	395E	;A=A-B
	.dw	39D8	;increment quotient Q
	.dw	38AA	;conditional branch

; enter the next iteration round when A < B
316A:	.dw	396E	;shift A left by one digit
	.dw	39E4	;shift quotient Q left, increment iteration counter J
316E:	.dw	39BA	;set B from the table of constants
	.dw	38AA	;conditional branch

; End of the first iteration, second iteration follows:
; Calculate EXP(X)-1 using pseudo multiplication

; Data on the stack:
; 1 word: offset to the table of constants, pointed to by 10(sp)
; 1 word: scaling factor, pointed to by 12(sp)
; 4 words: multiplicand Q storing the q[j] values, the end pointed to by -10(r5)
; 4 words: modifier M, the end pointed to by -8(r5)
; 4 words: multiplicand B, the end pointed to by r5
; 1 word: return address
; 4 words: product A, the end pointed to by r3

3172:	.dw	3952	;clear the product A
	.dw	3934	;initial multiplicand B = 0001 0000 0000 0000
	.dw	38EE	;conditional branch

; repeat while last digit of Q <> 0
3178:	.dw	3A30	;M=B*10^(-J+offset)
	.dw	3964	;A=A+B
	.dw	39A6	;B=B+M
	.dw	39DE	;decrement Q
	.dw	38EE	;conditional branch

; next iteration round when Q <> 0
3182:	.dw	3984	;shift A one digit right
	.dw	39EE	;shift Q one digit right, decrement iter. counter J
	.dw	38EE	;conditional branch

; end of the second iteration when Q = 0
3188:	.dw	3140	;adjust the position of the product A
	.dw	3934	;constant 0001 0000 0000 0000
	.dw	3840	;integer BCD addition
; rounding
	.dw	3942	;constant 0000 0000 0000 0005
	.dw	3840	;integer BCD addition
	.dw	3984	;integer BCD division by ten
	.dw	310A	;end of calculation


; function LOG (x) = LN (x) / LN (10)
3196:	jsr	r4,3AA8
319A:	.dw	37AE		;DUP (skip the return address)
	.dw	319E
319E:	jsr	pc,31AC		;function LN
31A2:	jsr	r4,3AA8
31A6:	.dw	37CE		;push LN 10 on the stack
	.dw	2CFC		;FP divide
	.dw	3610


; function LN
31AC:	mov	sp,r5
31AE:	mov	r5,r3
31B0:	add	#A,r3		;r3 points to the end of the argument
31B4:	mov	0002(r5),r2	;exponent of the argument
31B8:	bgt	31BE
31BA:	jmp	3AA4		;ERR3 if argument is equal 0 or negative
31BE:	clr	0002(r5)	;drop the exponent
31C2:	add	#EFFF,r2	;remove the exponent bias
31C6:	sub	#18,sp
31CA:	mov	r2,-(sp)	;exponent of the argument
31CC:	clr	-(sp)		;offset to the table of constants = 0
31CE:	mov	#322A,r1
31D2:	jsr	r4,3AA8
31D6:	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	394A	;initial quotient Q = 0000 0000 0000 0000
	.dw	3934	;initial divisor B = 0001 0000 0000 0000
	.dw	396E	;shift mantissa A left by one digit
	.dw	3874	;A=A-B
	.dw	38AA	;conditional branch

; end of the calculation
31E4:	mov	#1000,r1	;exponent bias
31E8:	sub	(sp),r1		;iteration counter J
31EA:	mov	12(sp),2A(sp)	;save the exponent of the argument in the last
				;word of B, just before the return address
31F0:	add	#2A,sp		;sp points to the saved exponent of the arg.
31F4:	tst	(r5)+
; normalise the mantissa of the result
31F6:	tst	(r5)+		;first word of the product A
31F8:	beq	3204
31FA:	jsr	r4,3984		;integer BCD division by ten
31FE:	.dw	3200
3200:	tst	(sp)+
3202:	inc	r1		;exponent
3204:	tst	(r5)		;test the result for 0
3206:	beq	320A		;skip if result 0
3208:	mov	r1,-(r5)	;biased exponent
; LN(x*10^n) = LN(x) + n*LN(10)
320A:	jsr	r4,3AA8
320E:	.dw	2F18		;convert saved exponent of the argument to FP
3210:	.dw	37CE		;push LN 10 on the stack
	.dw	2C7E		;FP multiply
	.dw	37BA		;OVER (skip the return address)
	.dw	2B46		;FP add
	.dw	3610

; the conditional branch control block, copied to the top of the stack
321A:	.dw	0000	;iteration counter
	.dw	3256	;pointer to the table of constants 10^j * ln(1+10^-j)
; first iteration loop (pseudo division)
	.dw	322A	;branch address when A >= B
	.dw	3234	;branch address when A < B
	.dw	323A	;branch address when iteration counter reached 0C
; second iteration loop (pseudo multiplication)
	.dw	3240	;branch address when last digit of Q <> 0
	.dw	3246	;branch address when next iteration round (when Q <> 0)
	.dw	324E	;branch address when end of iteration (when Q = 0)

; First iteration:
; The mantissa will be expressed as a product of powers (1+10^-j)^q[j] using
; pseudo division

; Data on the stack:
; 1 word: offset to the table of constants = 0, pointed to by 10(sp)
; 1 word: exponent of the argument, pointed to by 12(sp)
; 4 words: quotient Q storing the q[j] values, the end pointed to by -10(r5)
; 4 words: modifier M, the end pointed to by -8(r5)
; 4 words: divisor B, the end pointed to by r5
; 1 word: return address
; 4 words: mantissa A, the end pointed to by r3

; repeat while A >= B
322A:	.dw	3A30	;M=B*10^(-J+offset)
322C:	.dw	395E	;A=A-B
	.dw	39A6	;B=B+M
	.dw	39D8	;increment quotient Q
	.dw	38AA	;conditional branch

; enter the next iteration round when A < B
3234:	.dw	396E	;shift A left by one digit
	.dw	39E4	;shift quotient Q left, increment iteration counter J
	.dw	38AA	;conditional branch

; End of the first iteration, second iteration follows:
; Calculate LN(x) as a sum of terms q[j]*LN(1+10^-J) using pseudo multiplication

; Data on the stack:
; 1 word: offset to the table of constants = 0, pointed to by 10(sp)
; 1 word: exponent of the argument, pointed to by 12(sp)
; 4 words: multiplicand Q storing the q[j] values, the end pointed to by -10(r5)
; 4 words: not used in this iteration
; 4 words: multiplicand B, the end pointed to by r5
; 1 word: return address
; 4 words: product A, the end pointed to by r3

323A:	.dw	3952	;clear the product A
	.dw	3AAC	;unconditional jump
	.dw	324A	;address

; repeat while last digit of Q <> 0
3240:	.dw	3964	;A=A+B
	.dw	39DE	;decrement Q
	.dw	38EE	;conditional branch

; next iteration round when Q <> 0
3246:	.dw	3984	;shift A one digit right
	.dw	39EE	;shift Q one digit right, decrement iter. counter J
324A:	.dw	39BA	;set B from the table of constants
	.dw	38EE	;conditional branch

; end of the second iteration when Q = 0
; rounding
324E:	.dw	3942	;constant 0000 0000 0000 0005
	.dw	3840	;integer BCD addition
	.dw	3984	;integer BCD division by ten
	.dw	31E4	;end of calculation

; table of constants 10^j * ln (1+10^-j)
3256:	.dw	0006, 9314, 7180, 5600	;ln 2 = 0.6931471805600
325E:	.dw	0009, 5310, 1798, 0432	;ln 1.1 = 0.09531017980432
3266:	.dw	0009, 9503, 3085, 3168	;ln 1.01 = 0.009950330853168
326E:	.dw	0009, 9950, 0333, 0835	;ln 1.001 = 0.0009995003330835
3276:	.dw	0009, 9995, 0003, 3330	;ln 1.0001 = 0.00009999500033330
327E:	.dw	0009, 9999, 5000, 0343	;ln 1.00001 = 0.000009999950000343
3286:	.dw	0009, 9999, 9500, 0013	;ln 1.000001 = 0.0000009999995000013
; this entry is used for J>=7
328E:	.dw	0009, 9999, 9950, 0288	;ln 1.0000001 = 0.00000009999999500288


; power of a number
3296:	mov	sp,r4
3298:	mov	r4,r5
329A:	mov	(r4)+,r3
329C:	mov	#4,r0
32A0:	mov	(r4)+,(r5)+
32A2:	sob	r0,32A0
32A4:	mov	r3,(r5)+
32A6:	tst	(r5)
32A8:	bne	32B0
32AA:	add	#8,sp
32AE:	rts	pc
32B0:	bpl	32F6
32B2:	jsr	r4,3AA8
32B6:	.dw	37A8		;DUPlicate
	.dw	2EA2		;FP fraction
	.dw	32BC
32BC:	tst	(sp)
32BE:	beq	32C4
32C0:	jmp	3AA4		;ERR3
32C4:	add	#8,sp
32C8:	mov	(sp),r1
32CA:	beq	32F0
32CC:	bic	#F000,r1
32D0:	cmp	#C,r1
32D4:	bcs	32F6
32D6:	dec	r1
32D8:	clr	r2
32DA:	asr	r1
32DC:	rol	r2
32DE:	asr	r1
32E0:	rol	r2
32E2:	rol	r2
32E4:	inc	r1
32E6:	rol	r1
32E8:	add	sp,r1
32EA:	bit	3A28(r2),(r1)
32EE:	bne	32F6
32F0:	bic	#8000,000A(sp)
32F6:	jsr	r4,3AA8
32FA:	.dw	37BA		;OVER (skip the return address)
	.dw	2E12		;FP absolute value
	.dw	3300
3300:	jsr	pc,31AC		;function LN
3304:	jsr	r4,3AA8
3308:	.dw	2C7E		;FP multiply
	.dw	330C
330C:	jsr	pc,30A2		;function EXP
3310:	bic	#7FFF,000A(sp)
3316:	add	000A(sp),(sp)
331A:	jmp	3610


; function ACS, angle in DEG
331E:	mov	#0008,r2
3322:	br	332C
; function ACS, angle in GRA
3324:	mov	#0010,r2
3328:	br	332C
; function ACS, angle in RAD
332A:	clr	r2
; ACS (x) = PI/2 - ASN (x)
332C:	jsr	r4,3AA8
3330:	.dw	37AE		;DUP (skip the return address)
	.dw	3334
3334:	mov	r2,(r1)
3336:	jsr	pc,3366		;function ASN, angle in RAD
333A:	jsr	r4,3AA8
333E:	.dw	2E18		;change the sign of a FP number
3340:	.dw	37DA		;push PI/2 on the stack
	.dw	2B46		;FP add
	.dw	3346
3346:	mov	sp,r1
3348:	add	#A,r1
334C:	mov	(r1),r2
334E:	mov	(sp)+,(r1)+
3350:	mov	(sp)+,(r1)+
3352:	mov	(sp)+,(r1)+
3354:	mov	(sp)+,(r1)+
3356:	jmp	34B8		;optional conversion of the result to DEG/GRA


; function ASN, angle in DEG
335A:	mov	#0008,r2
335E:	br	3368
; function ASN, angle in GRA
3360:	mov	#0010,r2
3364:	br	3368
; function ASN, angle in RAD
3366:	clr	r2
3368:	mov	sp,r5
336A:	tst	(r5)+
336C:	tst	(r5)
336E:	bne	3372
3370:	rts	pc
3372:	asl	(r5)
3374:	rol	r0
3376:	cmp	#2002,(r5)+
337A:	bne	33A0
337C:	cmp	#1000,(r5)+
3380:	bne	33A0
3382:	mov	(r5)+,r1
3384:	bis	(r5)+,r1
3386:	bne	33A0
3388:	mov	#2680,-(r5)
338C:	mov	#7963,-(r5)
3390:	mov	#1570,-(r5)
3394:	mov	#2002,-(r5)	;PI/2
3398:	ror	r0
339A:	ror	(r5)
339C:	jmp	34B8		;optional conversion of the result to DEG/GRA


; ASN (x) = ATN (x/SQR(1-x^2))
33A0:	ror	r0
33A2:	ror	0002(sp)
33A6:	mov	r2,-(sp)
33A8:	mov	#C,r1
33AC:	jsr	r4,3AA8
33B0:	.dw	37BE		;OVER (skip 2 words on the stack)
	.dw	37D4		;push 1.00000000000 on the stack
	.dw	37B4		;OVER
	.dw	37A8		;DUPlicate
	.dw	2C7E		;FP multiply
	.dw	2B42		;FP subtract
	.dw	33BE
33BE:	jsr	pc,300E		;FP square root
33C2:	jsr	r4,3AA8
33C6:	.dw	2CFC		;FP divide
	.dw	33CA
33CA:	mov	#4,r0
33CE:	mov	(sp)+,000A(sp)
33D2:	sob	r0,33CE
33D4:	mov	(sp)+,r2
33D6:	br	33E6		;function ATN


; function ATN, angle in DEG
33D8:	mov	#0008,r2
33DC:	br	33E6
; function ATN, angle in GRA
33DE:	mov	#10,r2
33E2:	br	33E6
; function ATN, angle in RAD
33E4:	clr	r2
33E6:	tst	0002(sp)	;test the argument for 0
33EA:	bne	33EE
33EC:	rts	pc		;do nothing if the argument = 0
33EE:	jsr	r4,3AA8
33F2:	.dw	37D4		;push 1.00000000000 on the stack
	.dw	37BA		;OVER (skip the return address)
	.dw	33F8
; r1 points to the begin of the original argument
33F8:	bic	#7FFF,(r1)	;clear the exponent, leave the sign intact
33FC:	bis	r2,(r1)		;angle mode
33FE:	mov	sp,r1
; r1 points to the begin of the copy of the argument
3400:	bic	#8000,(r1)	;clear the sign (absolute value)
; if argument > 1 then argument = 1/argument
; ATN(x) = PI/2 - ATN(1/x)
; An alternative to this approach would be to align the initial value of the
; divisor B with the argument, instead of using fixed 0001 0000 0000 0000.
3404:	mov	#4,r0		;up to 4 words to compare
3408:	cmp	(r1)+,0006(r1)	;compare the argument against 1.0000... 
340C:	bcs	3412		;branch if argument < 1.0000...
340E:	bne	3456		;reciprocal of an argument greater than 1
3410:	sob	r0,3408
; drop the number 1.0000... from the stack by moving the argument
3412:	mov	#4,r0
3416:	mov	(sp)+,0006(sp)
341A:	sob	r0,3416
341C:	bis	#0100,000A(sp)	;flag of a non-inverted argument
3422:	mov	sp,r3
3424:	add	#8,r3
3428:	mov	(sp),r1
342A:	clr	(sp)
342C:	add	#EFFF,r1	;remove the exponent bias
3430:	mov	r3,r5
3432:	add	#A,r3
3436:	sub	#10,sp
343A:	mov	001A(sp),-(sp)
343E:	mov	r1,-(sp)
3440:	mov	#34E0,r1
3444:	jsr	r4,3AA8
3448:	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	391E	;move the scaled argument to another location
	.dw	3934	;initial divisor B = 0001 0000 0000 0000
	.dw	394A	;initial quotient Q = 0000 0000 0000 0000
	.dw	396E	;shift argument A left by one digit
	.dw	38AA	;conditional branch

3456:	jsr	r4,3AA8
345A:	.dw	2CFC		;FP divide
	.dw	3422

; end of the ATN calculation
345E:	neg	(sp)
3460:	add	#1000,(sp)
3464:	add	0010(sp),(sp)
3468:	mov	r3,r2
346A:	mov	r5,r3
346C:	mov	-(r2),-(r5)
346E:	mov	-(r2),-(r5)
3470:	mov	-(r2),-(r5)
3472:	mov	-(r2),-(r5)
3474:	beq	3480
3476:	jsr	r4,3984		;integer BCD division by ten
347A:	.dw	347C
347C:	tst	(sp)+
347E:	inc	(sp)
3480:	mov	(sp),(r5)
3482:	mov	0012(sp),0002(r3)
3488:	mov	r5,sp
348A:	bit	#0100,0002(r3)	;was the argument inverted?
3490:	bne	34A4		;skip if not
; angle = PI/2 - angle
3492:	jsr	r4,3AA8
3496:	.dw	2E18		;change the sign of a FP number
	.dw	37DA		;push PI/2 on the stack
	.dw	2B46		;FP add
	.dw	349E
349E:	mov	sp,r3
34A0:	add	#8,r3
34A4:	mov	0002(r3),r2
34A8:	bpl	34AE
34AA:	add	#8000,(sp)
34AE:	tst	(r3)+
34B0:	mov	(sp)+,(r3)+
34B2:	mov	(sp)+,(r3)+
34B4:	mov	(sp)+,(r3)+
34B6:	mov	(sp)+,(r3)+
; optional conversion of the angle in RAD to DEG or GRA
34B8:	movb	r2,r2		;= byte->word conversion
34BA:	beq	34CE		;angle in RAD required, no conversion needed
34BC:	add	#3820,r2
34C0:	mov	r2,r1
34C2:	jsr	r4,3AA8
34C6:	.dw	37C0		;push a FP number pointed to by r1 on the stack
	.dw	37BA		;OVER (skip the return address)
	.dw	2C7E		;FP multiply
	.dw	3610
34CE:	rts	pc

; the conditional branch control block, copied to the top of the stack
; reused part of the logarithm code
34D0:	.dw	0000	;iteration counter
	.dw	34EE	;pointer to the table of constants 10^j * atn(10^-j)
; first iteration loop (pseudo division)
	.dw	34E0	;branch address when A >= B
	.dw	3234	;branch address when A < B
	.dw	323A	;branch address when iteration counter reached 0C
; second iteration loop (pseudo multiplication)
	.dw	3240	;branch address when last digit of Q <> 0
	.dw	3246	;branch address when next iteration round (when Q <> 0)
	.dw	34E6	;branch address when end of iteration (when Q = 0)

; First iteration: pseudo division

; Data on the stack:
; 1 word: offset to the table of constants = 0, pointed to by 10(sp)
; 1 word: exponent of the argument, pointed to by 12(sp)
; 4 words: quotient Q storing the q[j] values, the end pointed to by -10(r5)
; 4 words: modifier M, the end pointed to by -8(r5)
; 4 words: divisor B, the end pointed to by r5
; 1 word: return address
; 4 words: dividend A, the end pointed to by r3

; repeat while A >= B
34E0:	.dw	3A92	;M=A*10^-(2*J+offset)
	.dw	3AAC	;unconditional jump
	.dw	322C	;address
;322C:	.dw	395E	;A=A-B
;	.dw	39A6	;B=B+M
;	.dw	39D8	;increment quotient Q
;	.dw	38AA	;conditional branch

; enter the next iteration round when A < B
;3234:	.dw	396E	;shift A left by one digit
;	.dw	39E4	;shift quotient Q left, increment iteration counter J
;	.dw	38AA	;conditional branch

; End of the first iteration, second iteration follows:
; Calculate ATN(x) as a sum of terms q[j]*ATN(10^-J) using pseudo multiplication

; Data on the stack:
; 1 word: offset to the table of constants = 0, pointed to by 10(sp)
; 1 word: exponent of the argument, pointed to by 12(sp)
; 4 words: multiplicand Q storing the q[j] values, the end pointed to by -10(r5)
; 4 words: not used in this iteration
; 4 words: multiplicand B, the end pointed to by r5
; 1 word: return address
; 4 words: product A, the end pointed to by r3

;323A:	.dw	3952	;clear the product A
;	.dw	3AAC	;unconditional jump
;	.dw	324A	;address

; repeat while last digit of Q <> 0
;3240:	.dw	3964	;A=A+B
;	.dw	39DE	;decrement Q
;	.dw	38EE	;conditional branch

; next iteration round when Q <> 0
;3246:	.dw	3984	;shift A one digit right
;	.dw	39EE	;shift Q one digit right, decrement iter. counter J
;324A:	.dw	39BA	;set B from the table of constants
;	.dw	38EE	;conditional branch

; rounding
34E6:	.dw	3942	;constant 0000 0000 0000 0005
	.dw	3840	;integer BCD addition
	.dw	3984	;integer BCD division by ten
34EC:	.dw	345E	;end of calculation

; table of constants 10^j * atn (10^-j)
34EE:	.dw	0007, 8539, 8163, 4000	;atn 1 = 0.7853981634000
34F6:	.dw	0009, 9668, 6524, 9117	;atn 0.1 = 0.09966865249117
34FE:	.dw	0009, 9996, 6668, 6666	;atn 0.01 = 0.009999666686666
3506:	.dw	0009, 9999, 9666, 6669	;atn 0.001 = 0.0009999996666669
350E:	.dw	0009, 9999, 9996, 6667	;atn 0.0001 = 0.00009999999966667
3516:	.dw	0009, 9999, 9999, 9667	;atn 0.00001 = 0.000009999999999667
351E:	.dw	0009, 9999, 9999, 9997	;atn 0.000001 = 0.0000009999999999997
; this entry is used for J>=7
3526:	.dw	0010, 0000, 0000, 0010


; function SIN, angle in DEG
352E:	mov	#0102,r2
3532:	br	353E
; function SIN, angle in GRA
3534:	mov	#0104,r2
3538:	br	353E
; function SIN, angle in RAD
353A:	mov	#0100,r2
; SIN(x) =  TAN(x) / SQR(1+TAN(x)^2)
353E:	jsr	r4,3AA8
3542:	.dw	37AE		;DUP (skip the return address)
	.dw	3546
3546:	jsr	pc,362E		;function TAN
354A:	tst	r1
354C:	bne	3562
354E:	bit	#2,r0
3552:	beq	3610
3554:	mov	sp,r2
3556:	mov	#1001,(r2)+
355A:	mov	#1000,(r2)+
355E:	clr	(r2)+
3560:	clr	(r2)+
3562:	bit	#4,r0
3566:	beq	356C
3568:	add	#8000,r0
356C:	tst	r0
356E:	bpl	3574
3570:	add	#8000,(sp)
3574:	tst	r1
3576:	beq	3610
3578:	jsr	r4,3AA8
357C:	.dw	37D4		;push 1.00000000000 on the stack
	.dw	37B4		;OVER
	.dw	37A8		;DUPlicate
	.dw	2C7E		;FP multiply
	.dw	2B46		;FP add
	.dw	3588
3588:	jsr	pc,300E		;FP square root
358C:	jsr	r4,3AA8
3590:	.dw	2CFC		;FP divide
	.dw	3610


; function COS, angle in DEG
3594:	mov	#0202,r2
3598:	br	35A4
; function COS, angle in GRA
359A:	mov	#0204,r2
359E:	br	35A4
; function COS, angle in RAD
35A0:	mov	#0200,r2
; COS(x) = 1 / SQR(1+TAN(x)^2)
35A4:	jsr	r4,3AA8
35A8:	.dw	37AE		;DUP (skip the return address)
	.dw	35AC
35AC:	jsr	pc,362E		;function TAN
35B0:	tst	r1
35B2:	bne	35C8
35B4:	bit	#2,r0
35B8:	bne	3610
35BA:	mov	sp,r2
35BC:	mov	#1001,(r2)+
35C0:	mov	#1000,(r2)+
35C4:	clr	(r2)+
35C6:	clr	(r2)+
35C8:	bit	#6,r0
35CC:	beq	35DA
35CE:	com	r0
35D0:	bit	#6,r0
35D4:	beq	35DA
35D6:	add	#8000,(sp)
35DA:	tst	r1
35DC:	beq	3610
35DE:	jsr	r4,3AA8
35E2:	.dw	37D4		;push 1.00000000000 on the stack
	.dw	37B4		;OVER
	.dw	37A8		;DUPlicate
	.dw	2C7E		;FP multiply
	.dw	2B46		;FP add
	.dw	35EE
35EE:	jsr	pc,300E		;FP square root
35F2:	mov	sp,r2
35F4:	add	#8,r2
35F8:	asl	(r2)
35FA:	mov	#2002,(r2)
35FE:	ror	(r2)+
3600:	mov	#1000,(r2)+
3604:	clr	(r2)+
3606:	clr	(r2)+
3608:	jsr	r4,3AA8
360C:	.dw	2CFC		;FP divide
	.dw	3610
3610:	mov	sp,r5
3612:	add	#A,r5
3616:	mov	(sp)+,(r5)+
3618:	mov	(sp)+,(r5)+
361A:	mov	(sp)+,(r5)+
361C:	mov	(sp)+,(r5)+
361E:	rts	pc


; function TAN, angle in DEG
3620:	mov	#0002,r2
3624:	br	362E
; function TAN, angle in GRA
3626:	mov	#0004,r2
362A:	br	362E
; function TAN, angle in RAD
362C:	clr	r2
; the angle is trimmed to the range 0..PI/2 RAD (or 0..90 DEG, or 0..100 GRA)
362E:	jsr	r4,3AA8
3632:	.dw	37AE	;DUP (skip the return address)
	.dw	3728	;constant PI/2 (or 90, or 100)
	.dw	2CF6	;FP modulo, remainder on the stack, qoutient in r0
	.dw	374A	;save the quadrant r0 to 10(sp)
	.dw	373A	;constant PI/2 (or 90, or 100)
	.dw	2C7E	;FP multiply
	.dw	3640

; data on the stack:
; 4 words - trimmed angle, pointed to by sp
; 1 word - return address, pointed to by 08(sp)
; 1 word - biased exponent of the absolute value of the initial angle,
;	pointed to by 0A(sp)
; 1 word - pointed to by 0C(sp)
; 1 word - argument mode (0=RAD, 2=DEG, 4=GRA), pointed to by 0E(sp)
; 1 word - quadrant of the angle, pointed to by 10(sp)

3640:	mov	0010(sp),r0	;quadrant
3644:	mov	r0,r1
3646:	bic	#FFF0,r1	;the "ones" digit of the quadrant
364A:	bic	#FF0F,r0	;the "tens" digit of the quadrant
364E:	asr	r0
3650:	add	r0,r1
3652:	asl	r1
3654:	asl	r1
3656:	add	r1,r0		;r0 = 40*tens + 4*ones = 4*quadrant
3658:	bic	#FFF0,r0
365C:	asl	000A(sp)	;biased exponent of the initial angle
3660:	ror	r0
3662:	add	r0,000C(sp)
; if angle > PI/4 then angle = PI/2-angle
; TAN(PI/2 - x) = 1/TAN(x)
3666:	mov	#4,r0		;up to 4 words to compare
366A:	mov	000E(sp),r1	;argument mode
366E:	asl	r1
3670:	asl	r1
3672:	add	#37F8,r1	;table of FP constants PI/4, 45, 50
3676:	mov	sp,r2		;r2 points to the angle
3678:	cmp	(r2)+,(r1)+
367A:	bcs	3680
367C:	bne	36CA
367E:	sob	r0,3678
; convert the angle to RAD
3680:	mov	000E(sp),r1	;argument mode
3684:	beq	3698		;skip if RAD mode
3686:	asl	r1
3688:	asl	r1
368A:	add	#3830,r1	;table of FP constants PI/180, PI/200
368E:	jsr	r4,3AA8
3692:	.dw	37C0		;push a FP number pointed to by r1 on the stack
	.dw	2C7E		;FP multiply
	.dw	3698
;
3698:	mov	r3,r5
369A:	add	#A,r3
369E:	mov	000C(sp),r0
36A2:	mov	(sp),r1
36A4:	beq	36F8
36A6:	add	#F000,r1
36AA:	clr	(sp)
36AC:	sub	#10,sp
36B0:	mov	r0,-(sp)
36B2:	mov	r1,-(sp)
36B4:	mov	#3798,r1
36B8:	jsr	r4,3AA8
36BC:	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	37C0	;push 4 words pointed to by r1 on the stack
	.dw	391E	;move the trimmed angle to another location
	.dw	396E	;integer BCD multiplication by ten
	.dw	394A	;initial quotient Q = 0000 0000 0000 0000
	.dw	3AAC	;unconditional jump
	.dw	316E	;address = first EXP(x) iteration loop

36CA:	inc	000C(sp)
36CE:	jsr	r4,3AA8
36D2:	.dw	2E18	;change the sign of a FP number
	.dw	373A	;constant PI/2 (or 90, or 100)
	.dw	2B46	;FP add
	.dw	3680

; end of the TAN calculation
36DA:	movb	(sp),r1		;iteration counter J
36DC:	sub	#0C,r1
36E0:	neg	r1
36E2:	add	#1001,r1	;exponent bias
36E6:	movb	0001(sp),r0
36EA:	sub	r0,r1
36EC:	add	0010(sp),r1	;offset to the table of constants
36F0:	mov	0012(sp),r0
36F4:	sub	#10,r5		;r5 points to the end of the quotient now
36F8:	mov	-(r5),-(r3)	;copy the result to the destination place
36FA:	mov	-(r5),-(r3)
36FC:	mov	-(r5),-(r3)
36FE:	mov	r1,-(r3)	;exponent
3700:	tst	-(r3)		;= sub #2,r3
3702:	mov	r3,sp		;sp points to the return address now
3704:	bit	#0300,r0
3708:	bne	3726
370A:	bit	#0002,r0
370E:	beq	371C
3710:	tst	r1
3712:	bne	3718
3714:	jmp	3AA4		;ERR3
3718:	add	#8000,r0
371C:	tst	r0
371E:	bpl	3726
3720:	add	#8000,0002(sp)	;result = -result
3726:	rts	pc

3728:	bic	#8000,(sp)	;absolute value of the argument
372C:	mov	r2,r1		;index to the table 3744
372E:	movb	r1,r1		;byte to word conversion
3730:	clrb	r2
3732:	mov	r2,000C(sp)
3736:	mov	r1,000E(sp)
; returns the constant PI/2 or 90 or 100 depending on the argument mode
373A:	mov	000E(sp),r1	;index to the table 3744
373E:	mov	3744(r1),r1
3742:	br	37C0		;push a FP number pointed to by r1 on the stack

3744:	.dw	37F8		;points to a FP number PI/2
	.dw	3818		;points to a FP number 90.0000000000
	.dw	3820		;points to a FP number 100.000000000

; save the quadrant r0 to 10(sp)
374A:	mov	r0,0010(sp)
374E:	jmp	@(r4)+

; prepare for the third iteration: division A/B
3750:	mov	#3234,0006(sp)	;branch address when A < B
3756:	mov	#37A4,0008(sp)	;branch address when end of iteration
375C:	mov	0012(sp),r0
3760:	asr	r0
3762:	adc	r0
3764:	asr	r0
3766:	bcc	3782
; swap the coordinates A and B to calculate reciprocal of the tangent (for
; angle values in range PI/4..PI/2)
3768:	mov	#4,r0
376C:	mov	-(r5),r1
376E:	mov	-(r3),(r5)
3770:	mov	r1,(r3)
3772:	sob	r0,376C
3774:	add	#8,r5
3778:	add	#8,r3
377C:	neg	0010(sp)
3780:	negb	(sp)
3782:	swab	(sp)
3784:	jmp	38AA	;conditional branch

; the conditional branch control block, copied to the top of the stack,
; reused parts of the EXP(x) and logarithm code
3788:	.dw	0000	;iteration counter
	.dw	34EE	;pointer to the table of constants 10^j * atn(10^-j)
; first iteration loop (pseudo division),
	.dw	3164	;branch address when A >= B
	.dw	316A	;branch address when A < B
	.dw	3172	;branch address when end of iteration
; second iteration loop (pseudo multiplication)
	.dw	3798	;branch address when last digit of Q <> 0
	.dw	3182	;branch address when next iteration round (when Q <> 0)
	.dw	37A2	;branch address when end of iteration (when Q = 0)

; First iteration:
; the trimmed angle will be expressed as a sum of products q[j]*atn(10^-j)

; Data on the stack:
; 1 word: offset to the table of constants, pointed to by 10(sp)
; 1 word: pointed to by 12(sp)
; 4 words: quotient Q storing the q[j] values, the end pointed to by -10(r5)
; 4 words: unused in this iteration, the end pointed to by -8(r5)
; 4 words: divisor B, the end pointed to by r5
; 1 word: return address
; 4 words: trimmed angle A, the end pointed to by r3

; repeat while A >= B
;3164:	.dw	395E	;A=A-B
;	.dw	39D8	;increment quotient Q
;	.dw	38AA	;conditional branch

; enter the next iteration round when A < B
;316A:	.dw	396E	;shift A left by one digit
;	.dw	39E4	;shift quotient Q left, increment iteration counter J
;316E:	.dw	39BA	;set B from the table of constants
;	.dw	38AA	;conditional branch

; End of the first iteration, second iteration follows:
; Calculate coordinates A and B using pseudo multiplication

; Data on the stack:
; 1 word: offset to the table of constants, pointed to by 10(sp)
; 1 word: pointed to by 12(sp)
; 4 words: multiplicand Q storing the q[j] values, the end pointed to by -10(r5)
; 4 words: modifier M, the end pointed to by -8(r5)
; 4 words: multiplicand B, the end pointed to by r5
; 1 word: return address
; 4 words: product A, the end pointed to by r3

;3172:	.dw	3952	;clear the product A
;	.dw	3934	;initial multiplicand B = 0001 0000 0000 0000
;	.dw	38EE	;conditional branch

; repeat while last digit of Q <> 0
3798:	.dw	3A92	;M=A*10^-(2*J+offset)
	.dw	3964	;A=A+B
	.dw	399A	;B=B-M
	.dw	39DE	;decrement Q
	.dw	38EE	;conditional branch

; next iteration round when Q <> 0
;3182:	.dw	3984	;shift A one digit right
;	.dw	39EE	;shift Q one digit right, decrement iter. counter J
;	.dw	38EE	;conditional branch

; End of the second iteration when Q = 0, third iteration follows:
; Calculate the tangent with the division A/B
; Note: this division limits the calculated tangent output range to 9.999...
; Larger values would cause an overflow on the most significant digit of
; the quotient. Consequently, the input angle range for the tangent iteration
; is limited to arctan(9.999...) = 1.4711... radians.
; For input angles above PI/4 the dividend A and divisor B are swapped (to
; obtain a reciprocal). In this case the divisor is left aligned, so a
; division oferflow is excluded.

37A2:	.dw	3750	;prepare data

; repeat while A >= B
;3164:	.dw	395E	;A=A-B
;	.dw	39D8	;increment quotient Q
;	.dw	38AA	;conditional branch

; enter the next iteration round when A < B
;3234:	.dw	396E	;shift A left by one digit
;	.dw	39E4	;shift quotient Q left, increment iteration counter J
;	.dw	38AA	;conditional branch

; End of the third iteration
37A4:	.dw	39F0	;shift Q one digit right
	.dw	36DA	;end of calculation


; push the TOS FP-number on the stack (equivalent to DUP in FORTH)
37A8:	mov	#8,r1
37AC:	br	37BE
; skip a word on the stack (return address), then push the TOS FP-number
; (roughly equivalent to DUP in FORTH)
37AE:	mov	#A,r1
37B2:	br	37BE
; skip a FP number on TOS, then push the NOS FP-number
; (equivalent to OVER in FORTH)
37B4:	mov	#10,r1
37B8:	br	37BE
; skip a word on the stack (return address), and a FP number on TOS, then push
; the NOS FP-number (roughly equivalent to OVER in FORTH)
37BA:	mov	#12,r1
37BE:	add	sp,r1
; push a FP number on the stack
37C0:	mov	-(r1),-(sp)
37C2:	mov	-(r1),-(sp)
37C4:	mov	-(r1),-(sp)
37C6:	mov	-(r1),-(sp)
37C8:	jmp	@(r4)+

; push a FP number pointed to by r3 on the stack
37CA:	mov	r3,r1
37CC:	br	37C0

; push LN 10 on the stack
37CE:	mov	#37E8,r1
37D2:	br	37C0

; push 1.00000000000 on the stack
37D4:	mov	#37F0,r1
37D8:	br	37C0

; push PI/2 on the stack
37DA:	mov	#37F8,r1
37DE:	br	37C0

; floating point constants
37E0:	.dw	1001, 2302, 5850, 9300	;= 2.30258509300 = LN 10
37E8:	.dw	1001, 1000, 0000, 0000	;= 1.00000000000
37F0:	.dw	1001, 1570, 7963, 2680	;= 1.57079632680 = PI/2
37F8:	.dw	1000, 7853, 9816, 3400	;= 0.785398163400 = PI/4
3800:	.dw	1002, 4500, 0000, 0000	;= 45.0000000000
3808:	.dw	1002, 5000, 0000, 0000	;= 50.0000000000
3810:	.dw	1002, 9000, 0000, 0000	;= 90.0000000000
3818:	.dw	1003, 1000, 0000, 0000	;= 100.000000000
3820:	.dw	1002, 5729, 5779, 5131	;= 57.2957795131 = 180/PI
3828:	.dw	1002, 6366, 1977, 2368	;= 63.6619772368 = 200/PI
3830:	.dw	0FFF, 1745, 3292, 5200	;= 0.0174532925200 = PI/180
3838:	.dw	0FFF, 1570, 7963, 2680	;= 0.0157079632680 = PI/200


; From the following two procedures is clearly visible that a PDP-11
; compatible processor (without native BCD support) was a poor choice for a
; calculator. This may be the cause why the machine is so slow, despite
; a powerful 16-bit CPU.

; integer BCD addition (r3) += (r5), sixteen digits
; r3 and r5 point to the end of the numbers
;
; Algorithm: the procedure performs binary addition, then applies decimal
; adjust to the sum, i.e. adds 6 to each 4-bit digit which:
; - is greater than 9 (this condition will be evaluated in r1)
; or
; - carry occurred to the next digit (this condition will be evaluated in r2)
; For all logical operations in the procedure (bis, bic, com) only the most
; significant bit of each digit is important, i.e. bits 15,11,7,3 in the word.
3840:	mov	#4,r0		;four words
3844:	mov	-(r3),r2
3846:	add	-(r5),(r3)	;(r3) will be called "sum" from now on
; sum = addend1 + addend2; (binary addition)
3848:	bne	384C
384A:	bcc	3870	;branch if sum = 0000 without carry to next word
384C:	adc	FFFE(r3)
3850:	bis	(r5),r2
3852:	bic	(r3),r2
; r2 = (addend1 | addend2) & ~sum;
; Relevant bits in the r2 registers are set for digits where carry to next
; digit occurred, i.e.:
; - at least one of the addends is greater than or equal 8 (i.e. has the most
;   significant bit set)
; and
; - the sum has the most significant bit cleared
3854:	mov	(r3),r1
3856:	com	r1
3858:	add	#6666,(r3)
385C:	adc	FFFE(r3)
3860:	bis	(r3),r1
; r1 = ~sum | (sum + 0x6666);
; Relevant bits in the r1 register are cleared for digits in the sum which
; are greater than 9, i.e.:
; - the digit is greater than or equal 8 (i.e. has the most significant bit
;   set)
; and
; - after adding 6 the digit is greater than or equal 16 (i.e. has the most
;   significant bit cleared)
3862:	bic	r2,r1		;consider both conditions
; r1 = r1 & ~r2;
; The r1 register has the relevant (i.e. most significant) bits cleared for
; digits in the sum requiring decimal correction.
3864:	bic	#7777,r1	;separate the relevant bits: r1 &= 0x8888;
; Decimal correction was already applied to all digits. Now we have to
; subtract 6 back from digits which don't require the decimal correction.
3868:	ror	r1
386A:	sub	r1,(r3)		;subtract 4 from concerned digits
386C:	ror	r1
386E:	sub	r1,(r3)		;subtract 2 from concerned digits
3870:	sob	r0,3844		;next word (i.e. next four BCD digits)
3872:	br	38A0


; integer BCD subtraction (r3) -= (r5), sixteen digits
; r3 and r5 point to the end of the numbers
;
; Algorithm: the procedure performs binary subtraction, then applies decimal
; adjust to the remainder, i.e. subtracts 6 from each 4-bit digit for which
; carry (i.e. borrow) occurred from the next digit.
3874:	mov	#4,r0
3878:	clr	r2		;initial carry value
387A:	mov	-(r3),r1	;minuend
387C:	add	-(r5),r2	;add carry to the subtrahend
387E:	beq	389E		;branch if subtrahend is equal 0000
3880:	xor	r2,r1
3882:	sub	r2,(r3)		;perform binary subtraction
3884:	mov	(r3),r2		;remainder
3886:	xor	r2,r1
; r1 = minuend ^ subtrahend ^ remainder
; r1 contains ones on bits from which carry occurred
3888:	ror	r1
388A:	asr	r1		;carry from subtraction preserved on bit 15
388C:	clr	r2
388E:	add	#8000,r1	;bit 15 of r1 goes to carry
3892:	adc	r2		;r2 = carry from the next word
3894:	bic	#BBBB,r1	;separate the relevant bits: r1 &= 0x4444;
3898:	sub	r1,(r3)		;subtract 4 from concerned digits
389A:	asr	r1
389C:	sub	r1,(r3)		;subtract 2 from concerned digits
389E:	sob	r0,387A		;next word (i.e. next four BCD digits)
; restore the pointers
38A0:	add	#8,r3
38A4:	add	#8,r5
38A8:	jmp	@(r4)+


; conditional branch controlling iteration loops, expects a control block
; on the stack
; r5 points to the end of the first number
; r3 points to the end of the second number
; -10(r5) points to the end of the third number
38AA:	mov	#FFF8,r1
38AE:	mov	r1,r2
38B0:	add	r5,r1		;begin of the first number
38B2:	add	r3,r2		;begin of the second number
38B4:	mov	#4,r0
38B8:	cmp	(r1)+,(r2)+
38BA:	bcs	38C0
38BC:	bne	38C6
38BE:	sob	r0,38B8
38C0:	mov	0004(sp),r4	;branch if first <= second
38C4:	jmp	@(r4)+
; first > second, test the iteration counter
38C6:	cmpb	(sp),#C		;iteration counter
38CA:	bcc	38D2
38CC:	mov	0006(sp),r4	;branch if not the end of the iteration yet
38D0:	jmp	@(r4)+
; end of the iteration, test the third number for 0
38D2:	mov	r5,r1
38D4:	sub	#10,r1
38D8:	mov	-(r1),r0
38DA:	bis	-(r1),r0
38DC:	bis	-(r1),r0
38DE:	bis	-(r1),r0
38E0:	beq	38E8
; third number isn't equal 0, test the -18(r5) byte for 0
38E2:	tstb	FFE8(r5)
38E6:	beq	38CC
38E8:	mov	0008(sp),r4	;branch if the third number is equal 0
38EC:	jmp	@(r4)+


; conditional branch controlling iteration loops, expects a control block
; on the stack
; -10(r5) points to the end of the number
38EE:	bit	#000F,FFEE(r5)	;last digit of the number
38F4:	beq	38FC
38F6:	mov	000A(sp),r4	;branch if digit <> 0
38FA:	jmp	@(r4)+
; digit = 0, test the number for 0
38FC:	mov	r5,r1
38FE:	sub	#10,r1
3902:	mov	-(r1),r0
3904:	bis	-(r1),r0
3906:	bis	-(r1),r0
3908:	bis	-(r1),r0
390A:	beq	3912
; branch if number <> 0
390C:	mov	000C(sp),r4
3910:	jmp	@(r4)+
; branch if number = 0
3912:	mov	000E(sp),r4
3916:	jmp	@(r4)+


; copy a number
; end of source pointed to by -1A(r3),
; end of destination pointed to by r3
3918:	mov	#FFDE,r2
391C:	br	3922
; copy a number
; end of source pointed to by -A(r3),
; end of destination pointed to by r3
391E:	mov	#FFEE,r2
3922:	add	r3,r2
3924:	mov	r3,r1
3926:	sub	#8,r1
392A:	mov	(r2)+,(r1)+
392C:	mov	(r2)+,(r1)+
392E:	mov	(r2)+,(r1)+
3930:	mov	(r2)+,(r1)+
3932:	jmp	@(r4)+

; integer constant 0001 0000 0000 0000
3934:	mov	r5,r2
3936:	clr	-(r2)
3938:	clr	-(r2)
393A:	clr	-(r2)
393C:	mov	#0001,-(r2)
3940:	jmp	@(r4)+

; integer constant 0000 0000 0000 0005
3942:	mov	r5,r2
3944:	mov	#0005,-(r2)
3948:	br	3956

; clear the number, -10(r5) points to the end of the number
394A:	mov	r5,r2
394C:	sub	#0010,r2
3950:	br	3954

; clear the number, r3 points to the end of the number
3952:	mov	r3,r2
3954:	clr	-(r2)
3956:	clr	-(r2)
3958:	clr	-(r2)
395A:	clr	-(r2)
395C:	jmp	@(r4)+

; strange, roundabout way of calling those two math functions...
; integer BCD subtraction, could be called directly by address 3874
395E:	jsr	r4,3874		;integer BCD subtraction
3962:	.dw	396A
; integer BCD addition, could be called directly by address 3840
3964:	jsr	r4,3840		;integer BCD addition
3968:	.dw	396A
396A:	mov	(sp)+,r4
396C:	jmp	@(r4)+

; integer BCD multiplication by ten, r3 points to the end of the number,
; sixteen digits
396E:	mov	r3,r2
3970:	mov	#4,r0
3974:	asl	-(r2)
3976:	rol	-(r2)
3978:	rol	-(r2)
397A:	rol	-(r2)
397C:	add	#8,r2
3980:	sob	r0,3974
3982:	jmp	@(r4)+

; integer BCD division by ten, r3 points to the end of the number,
; sixteen digits
3984:	mov	r3,r2
3986:	mov	#4,r0
398A:	sub	#8,r2
398E:	ror	(r2)+
3990:	ror	(r2)+
3992:	ror	(r2)+
3994:	ror	(r2)+
3996:	sob	r0,398A
3998:	jmp	@(r4)+

; integer BCD subtraction, @r5 -= @-8(r5)
; -8(r5) points to the end of the substrahend
; r5 points to the end of the minuend and the remainder
399A:	mov	r5,r3		;minuend
399C:	sub	#8,r5		;substrahend
39A0:	jsr	r4,3874		;integer BCD subtraction
39A4:	.dw	39B2

; integer BCD addition, @r5 += @-8(r5)
; -8(r5) points to the end of the first addend
; r5 points to the end of the second addend and the sum
39A6:	mov	r5,r3
39A8:	sub	#8,r5
39AC:	jsr	r4,3840		;integer BCD addition
39B0:	.dw	39B2
39B2:	mov	r3,r5
39B4:	add	#A,r3
39B8:	br	396A

; read an entry from the table of constants,
; index = iteration counter + offset (i.e. subtract negative offset),
; r5 points to the end of the destination address
39BA:	movb	(sp),r2		;iteration counter
39BC:	sub	0010(sp),r2	;offset
39C0:	cmp	r2,#7
39C4:	blos	39CA
; for index>7 use the last entry of the table (index=7)
39C6:	mov	#7,r2
; r2 = index to the table of constants
39CA:	asl	r2
39CC:	asl	r2
39CE:	asl	r2
39D0:	add	0002(sp),r2	;pointer to the table of constants
39D4:	mov	r5,r1
39D6:	br	3926		;copy to the destination address

39D8:	inc	FFEE(r5)
39DC:	jmp	@(r4)+

39DE:	dec	FFEE(r5)
39E2:	jmp	@(r4)+

; increment the iteration counter on the stack,
; shift the integer number pointed to by -10(r5) one digit left
39E4:	inc	(sp)		;increment the iteration counter
39E6:	mov	r5,r2
39E8:	sub	#10,r2		;-10(r2) points to the end of the number
39EC:	br	3970		;integer BCD multiplication by ten


; decrement the iteration counter on the stack,
; shift the integer number pointed to by -10(r5) one digit right
39EE:	dec	(sp)		;decrement the iteration counter
39F0:	mov	r5,r2
39F2:	sub	#10,r2		;-10(r2) points to the end of the number
39F6:	br	3986		;integer BCD division by ten


; function used by the SQR procedure,
; creates an integer number containing single digit 1 on a position determined
; by the iteration counter, i.e. performs 10dec ^ -counter
; -8(r5) points to the end of the number
; counter=00 -> 0001 0000 0000 0000
; counter=01 -> 0000 1000 0000 0000
; ...
; counter=0B -> 0000 0000 0000 0010
; counter=0C -> 0000 0000 0000 0001
39F8:	movb	(sp),r1		;iteration counter (value 0 to 0C)
39FA:	clr	r2
39FC:	dec	r1
39FE:	asr	r1
3A00:	rol	r2
3A02:	asr	r1
3A04:	rol	r2
3A06:	rol	r2
3A08:	inc	r1
; r1 = index of the word with the digit 1	(0,1,1,1,1,2,2,2,2,3,3,3,3)
; r2 = position of the digit 1 in the word	(6,0,4,2,6,0,4,2,6,0,4,2,6)
3A0A:	sub	#10,r5
3A0E:	mov	#4,r0
3A12:	clr	(r5)+
3A14:	tst	r1
3A16:	bne	3A1E
3A18:	mov	3A28(r2),FFFE(r5)
3A1E:	dec	r1
3A20:	sob	r0,3A12
3A22:	add	#8,r5
3A26:	jmp	@(r4)+

3A28:	.dw	1000
	.dw	0010
	.dw	0100
	.dw	0001


; function used by the EXP and LN procedures, M=B*10^(-J+offset)
3A30:	sub	#7,r5		;r5 points to the multiplicand B
3A34:	mov	r5,r2
3A36:	sub	#8,r2		;r2 points to the modifier M
3A3A:	movb	(sp),r1		;iteration counter
3A3C:	sub	0010(sp),r1	;offset to the table of constants
3A40:	asr	r1
3A42:	bcc	3A48		;skip if (-J+offset) is even
3A44:	add	#8000,r1	;mark odd (-J+offset)
; M = B/10^(2*r1.b)
3A48:	mov	#8,r0
3A4C:	tstb	r1
3A4E:	ble	3A54
3A50:	clrb	(r2)
3A52:	br	3A62
3A54:	movb	(r5),(r2)
3A56:	dec	r5
3A58:	bit	#1,r5
3A5C:	beq	3A62
3A5E:	add	#4,r5
3A62:	dec	r2
3A64:	bit	#1,r2
3A68:	beq	3A6E
3A6A:	add	#4,r2
3A6E:	decb	r1
3A70:	sob	r0,3A4C
;
3A72:	tst	r1
3A74:	bpl	3A8A		;skip if (-J+offset) is even
; M = M/10
3A76:	dec	r2
3A78:	mov	#4,r0
3A7C:	sub	#8,r2
3A80:	ror	(r2)+
3A82:	ror	(r2)+
3A84:	ror	(r2)+
3A86:	ror	(r2)+
3A88:	sob	r0,3A7C
;
3A8A:	mov	r3,r5
3A8C:	sub	#A,r5
3A90:	jmp	@(r4)+

; function used by the TAN and ATN procedures, M=A*10^(-2*J+offset)
3A92:	add	#3,r5
3A96:	mov	r5,r2
3A98:	sub	#12,r2
3A9C:	movb	(sp),r1		;iteration counter
3A9E:	sub	0010(sp),r1	;offset to the table of constants
; for operands < +/-1E-127 radians the negative offset would exceed 8 bits,
; which would disrupt further processing!
3AA2:	br	3A48

3AA4:	jmp	2608		;ERR3

; enter the FORTH-like stack-based FP engine
3AA8:	tst	(sp)+		;drop the saved R4 from the stack
3AAA:	jmp	@(r4)+

; unconditional jump to address in the next word
3AAC:	mov	(r4),r4
3AAE:	jmp	@(r4)+

; font table, character codes 0x01-0xBF, 7 bytes for each character
3AB0:	.db 00, 01, 03, 07,  0F, 1F, 00, 00,  10, 18, 1C, 1E,  1F, 00, 00, 1F
3AC0:	.db 1E, 1C, 18, 10,  00, 00, 1F, 0F,  07, 03, 01, 00,  00, 1F, 0E, 04
3AD0:	.db 0E, 1F, 00, 00,  11, 1B, 1F, 1B,  11, 00, 08, 04,  04, 02, 04, 04
3AE0:	.db 08, 02, 04, 04,  08, 04, 04, 02,  00, 16, 09, 15,  12, 0D, 00, 00
3AF0:	.db 00, 00, 00, 00,  00, 15, 00, 0E,  11, 11, 11, 0E,  00, 1F, 11, 02
3B00:	.db 04, 02, 11, 1F,  06, 09, 09, 06,  00, 00, 00, 00,  00, 04, 0A, 1F
3B10:	.db 00, 00, 00, 00,  00, 00, 00, 00,  1F, 00, 11, 0A,  04, 0A, 11, 00
3B20:	.db 00, 04, 00, 1F,  00, 04, 00, 04,  0E, 1F, 1F, 15,  04, 0E, 00, 0A
3B30:	.db 1F, 1F, 0E, 04,  00, 00, 04, 0E,  1F, 0E, 04, 00,  04, 0E, 04, 1F
3B40:	.db 1F, 04, 0E, 00,  00, 09, 09, 17,  01, 01, 0E, 11,  11, 11, 0A, 0A
3B50:	.db 1B, 04, 04, 04,  04, 15, 0E, 04,  00, 04, 02, 1F,  02, 04, 00, 00
3B60:	.db 04, 08, 1F, 08,  04, 00, 11, 0A,  1F, 04, 1F, 04,  04, 00, 1F, 11
3B70:	.db 11, 11, 1F, 00,  00, 00, 00, 06,  06, 00, 00, 03,  02, 02, 0E, 12
3B80:	.db 12, 0E, 00, 00,  03, 02, 0E, 12,  0E, 00, 00, 00,  00, 00, 00, 00
3B90:	.db 04, 04, 04, 04,  04, 00, 04, 0A,  0A, 0A, 00, 00,  00, 00, 0A, 0A
3BA0:	.db 1F, 0A, 1F, 0A,  0A, 04, 1E, 05,  0E, 14, 0F, 04,  03, 13, 08, 04
3BB0:	.db 02, 19, 18, 06,  09, 05, 02, 15,  09, 16, 06, 04,  02, 00, 00, 00
3BC0:	.db 00, 08, 04, 02,  02, 02, 04, 08,  02, 04, 08, 08,  08, 04, 02, 00
3BD0:	.db 04, 15, 0E, 15,  04, 00, 00, 04,  04, 1F, 04, 04,  00, 00, 00, 00
3BE0:	.db 00, 06, 04, 02,  00, 00, 00, 1F,  00, 00, 00, 00,  00, 00, 00, 00
3BF0:	.db 06, 06, 00, 10,  08, 04, 02, 01,  00, 0E, 11, 19,  15, 13, 11, 0E
3C00:	.db 04, 06, 04, 04,  04, 04, 0E, 0E,  11, 10, 08, 04,  02, 1F, 1F, 08
3C10:	.db 04, 08, 10, 11,  0E, 08, 0C, 0A,  09, 1F, 08, 08,  1F, 01, 0F, 10
3C20:	.db 10, 11, 0E, 0C,  02, 01, 0F, 11,  11, 0E, 1F, 10,  08, 04, 04, 04
3C30:	.db 04, 0E, 11, 11,  0E, 11, 11, 0E,  0E, 11, 11, 1E,  10, 08, 06, 00
3C40:	.db 06, 06, 00, 06,  06, 00, 00, 06,  06, 00, 06, 04,  02, 08, 04, 02
3C50:	.db 01, 02, 04, 08,  00, 00, 1F, 00,  1F, 00, 00, 02,  04, 08, 10, 08
3C60:	.db 04, 02, 0E, 11,  10, 08, 04, 00,  04, 00, 0F, 10,  16, 15, 15, 0E
3C70:	.db 0E, 11, 11, 1F,  11, 11, 11, 0F,  11, 11, 0F, 11,  11, 0F, 0E, 11
3C80:	.db 01, 01, 01, 11,  0E, 07, 09, 11,  11, 11, 09, 07,  1F, 01, 01, 0F
3C90:	.db 01, 01, 1F, 1F,  01, 01, 0F, 01,  01, 01, 0E, 11,  01, 1D, 11, 11
3CA0:	.db 1E, 11, 11, 11,  1F, 11, 11, 11,  0E, 04, 04, 04,  04, 04, 0E, 1C
3CB0:	.db 08, 08, 08, 08,  09, 06, 11, 09,  05, 03, 05, 09,  11, 01, 01, 01
3CC0:	.db 01, 01, 01, 1F,  11, 1B, 15, 15,  11, 11, 11, 11,  11, 13, 15, 19
3CD0:	.db 11, 11, 0E, 11,  11, 11, 11, 11,  0E, 0F, 11, 11,  0F, 01, 01, 01
3CE0:	.db 0E, 11, 11, 11,  15, 09, 16, 0F,  11, 11, 0F, 05,  09, 11, 1E, 01
3CF0:	.db 01, 0E, 10, 10,  0F, 1F, 04, 04,  04, 04, 04, 04,  11, 11, 11, 11
3D00:	.db 11, 11, 0E, 11,  11, 11, 11, 11,  0A, 04, 11, 11,  11, 15, 15, 1B
3D10:	.db 11, 11, 11, 0A,  04, 0A, 11, 11,  11, 11, 0A, 04,  04, 04, 04, 1F
3D20:	.db 10, 08, 04, 02,  01, 1F, 0E, 02,  02, 02, 02, 02,  0E, 00, 02, 1F
3D30:	.db 04, 1F, 08, 00,  0E, 08, 08, 08,  08, 08, 0E, 04,  0E, 15, 04, 04
3D40:	.db 04, 04, 00, 08,  04, 02, 1F, 00,  1F, 00, 00, 00,  00, 00, 00, 00
3D50:	.db 00, 00, 0E, 10,  1E, 11, 1E, 01,  01, 0D, 13, 11,  11, 0E, 00, 00
3D60:	.db 0E, 01, 01, 11,  0E, 10, 10, 16,  19, 11, 11, 0E,  00, 00, 0E, 11
3D70:	.db 1F, 01, 0E, 08,  14, 04, 0E, 04,  04, 04, 00, 00,  1E, 11, 1E, 10
3D80:	.db 0E, 01, 01, 0D,  13, 11, 11, 11,  04, 00, 06, 04,  04, 04, 0E, 08
3D90:	.db 00, 08, 08, 08,  09, 06, 02, 02,  12, 0A, 06, 0A,  12, 06, 04, 04
3DA0:	.db 04, 04, 04, 0E,  00, 00, 0B, 15,  15, 15, 15, 00,  00, 0D, 13, 11
3DB0:	.db 11, 11, 00, 00,  0E, 11, 11, 11,  0E, 00, 00, 0F,  11, 0F, 01, 01
3DC0:	.db 00, 00, 1E, 11,  1E, 10, 10, 00,  00, 1A, 06, 02,  02, 02, 00, 00
3DD0:	.db 1E, 01, 0E, 10,  0F, 00, 04, 0E,  04, 04, 14, 08,  00, 00, 11, 11
3DE0:	.db 11, 19, 16, 00,  00, 11, 11, 11,  0A, 04, 00, 00,  11, 11, 15, 15
3DF0:	.db 0A, 00, 00, 13,  0C, 04, 06, 19,  00, 00, 11, 12,  0C, 04, 03, 00
3E00:	.db 00, 1F, 08, 04,  02, 1F, 00, 00,  0F, 01, 07, 01,  0F, 00, 00, 1F
3E10:	.db 0A, 0A, 0A, 19,  1C, 00, 07, 01,  07, 01, 07, 00,  02, 04, 08, 1F
3E20:	.db 00, 1F, 1F, 1F,  1F, 1F, 1F, 1F,  1F, 00, 00, 09,  15, 17, 15, 09
3E30:	.db 00, 00, 0E, 10,  1E, 11, 1E, 1E,  01, 0E, 11, 11,  11, 0E, 00, 00
3E40:	.db 09, 09, 09, 1F,  10, 0E, 10, 1E,  11, 11, 11, 0E,  00, 00, 0E, 11
3E50:	.db 1F, 01, 0E, 00,  04, 0E, 15, 15,  0E, 04, 00, 00,  0E, 10, 0E, 01
3E60:	.db 0E, 00, 00, 13,  0C, 04, 06, 19,  00, 00, 11, 11,  11, 19, 16, 00
3E70:	.db 00, 15, 11, 11,  19, 16, 00, 00,  12, 0A, 06, 0A,  12, 00, 00, 1C
3E80:	.db 12, 12, 12, 11,  00, 00, 11, 1B,  15, 11, 11, 00,  00, 11, 11, 1F
3E90:	.db 11, 11, 00, 00,  0E, 11, 11, 11,  0E, 00, 00, 0D,  13, 11, 11, 11
3EA0:	.db 00, 00, 1E, 11,  1E, 14, 13, 00,  00, 0F, 11, 0F,  01, 01, 00, 00
3EB0:	.db 0E, 11, 01, 01,  0E, 00, 00, 0B,  15, 15, 15, 15,  00, 00, 11, 12
3EC0:	.db 0C, 04, 03, 00,  00, 15, 15, 0E,  15, 15, 03, 05,  05, 0F, 11, 11
3ED0:	.db 0E, 00, 00, 01,  01, 0F, 11, 0F,  00, 00, 11, 11,  13, 15, 17, 00
3EE0:	.db 00, 0E, 10, 0C,  11, 0E, 00, 00,  15, 15, 15, 15,  1F, 00, 00, 0F
3EF0:	.db 10, 1E, 10, 0F,  00, 00, 15, 15,  15, 1F, 10, 00,  00, 11, 11, 1E
3F00:	.db 10, 10, 00, 0A,  0E, 11, 1F, 01,  0E, 09, 15, 15,  17, 15, 15, 09
3F10:	.db 1C, 12, 11, 1F,  11, 11, 11, 1F,  01, 01, 0F, 11,  11, 0F, 09, 09
3F20:	.db 09, 09, 09, 1F,  10, 0C, 0A, 0A,  0A, 0A, 1F, 11,  1F, 01, 01, 0F
3F30:	.db 01, 01, 1F, 04,  0E, 15, 15, 15,  0E, 04, 1F, 01,  01, 01, 01, 01
3F40:	.db 01, 11, 11, 0A,  04, 0A, 11, 11,  11, 11, 19, 15,  13, 11, 11, 15
3F50:	.db 11, 19, 15, 13,  11, 11, 11, 09,  05, 03, 05, 09,  11, 1C, 12, 11
3F60:	.db 11, 11, 11, 11,  11, 1B, 15, 15,  11, 11, 11, 11,  11, 11, 1F, 11
3F70:	.db 11, 11, 0E, 11,  11, 11, 11, 11,  0E, 1F, 11, 11,  11, 11, 11, 11
3F80:	.db 1E, 11, 11, 1E,  14, 12, 11, 0F,  11, 11, 0F, 01,  01, 01, 0E, 11
3F90:	.db 01, 01, 01, 11,  0E, 1F, 04, 04,  04, 04, 04, 04,  11, 11, 11, 1E
3FA0:	.db 10, 10, 0F, 15,  15, 0E, 04, 0E,  15, 15, 0F, 11,  11, 0F, 11, 11
3FB0:	.db 0F, 01, 01, 01,  0F, 11, 11, 0F,  11, 11, 11, 13,  15, 15, 17, 0E
3FC0:	.db 11, 10, 0C, 10,  11, 0E, 15, 15,  15, 15, 15, 15,  1F, 0E, 11, 10
3FD0:	.db 1E, 10, 11, 0E,  15, 15, 15, 15,  15, 1F, 10, 11,  11, 11, 1E, 10
3FE0:	.db 10, 10, 0A, 1F,  01, 07, 01, 01,  1F

3FFE:	.dw	F55C	;ROM checksum
