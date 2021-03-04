	INCLUDE		STM32F4xx.s
Array_1		EQU		0x200
Array_2		EQU		0x220
	
	AREA	SRAM1,	NOINIT,	READWRITE
	SPACE	0x400
Stack_Top
	
	AREA	RESET,	DATA,	READONLY
	DCD	Stack_Top		;[0x000-0x003]
	DCD	Start_Init		;[0x004-0x007]
	SPACE	0x118			;[0x008-0x11F]
	DCD	DMA2_Stream0_IRQHandler	;[0x120-0x123]
	
	AREA	PROGRAM,	CODE,		READONLY
	ENTRY
	
E0
	B	E0

Start_Init
;DMA2 Mem to Mem Init
	LDR	R0,	=RCC_BASE
	LDR	R1,	[R0,	#RCC_AHB1ENR]
	ORR	R1,	R1,	#RCC_AHB1ENR_DMA2EN
	STR	R1,	[R0,	#RCC_AHB1ENR]
;1
	LDR	R0,	=DMA2_BASE
	LDR	R1,	[R0,	#DMA_S0CR]
	AND	R1,	R1,	#DMA_SxCR_EN
	CMP	R1,	#0
	BNE	E0
;2
	LDR	R1,	=(SRAM1_BASE + Array_1)
	STR	R1,	[R0,	#DMA_S0PAR]
;3
	LDR	R1,	=(SRAM1_BASE + Array_2)
	STR	R1,	[R0,	#DMA_S0M0AR]
;4
	MOV	R1,	#10
	STR	R1,	[R0,	#DMA_S0NDTR]
;Skip 5, 6, 7 and 8
;9
	LDR	R1,	[R0,	#DMA_S0CR]
	AND	R1,	R1,	#~DMA_SxCR_DIR
	ORR	R1,	R1,	#DMA_SxCR_DIR_1
	ORR	R1,	R1,	#(DMA_SxCR_MINC + DMA_SxCR_PINC)
	ORR	R1,	R1,	#DMA_SxCR_TCIE
	STR	R1,	[R0,	#DMA_S0CR]
;DMA2_S0 Interrupt Enable
	LDR	R2,	=NVIC_BASE
	LDR	R1,	[R2,	#NVIC_ISER1]
	ORR	R1,	R1,	#(1 << (DMA2_Stream0_IRQn - 32))
	STR	R1,	[R2,	#NVIC_ISER1]
;Array_1 Init
	LDR	R3,	=(SRAM1_BASE + Array_1)
	MOV	R1,	#'0'
	STR	R1,	[R3,	#0]
	MOV	R1,	#'1'
	STR	R1,	[R3,	#1]
	MOV	R1,	#'2'
	STR	R1,	[R3,	#2]
	MOV	R1,	#'3'
	STR	R1,	[R3,	#3]
	MOV	R1,	#'4'
	STR	R1,	[R3,	#4]
	MOV	R1,	#'5'
	STR	R1,	[R3,	#5]
	MOV	R1,	#'6'
	STR	R1,	[R3,	#6]
	MOV	R1,	#'7'
	STR	R1,	[R3,	#7]
	MOV	R1,	#'8'
	STR	R1,	[R3,	#8]
	MOV	R1,	#'9'
	STR	R1,	[R3,	#9]
;DMA2 S0 Enable
	LDR	R1,	[R0,	#DMA_S0CR]
	ORR	R1,	R1,	#DMA_SxCR_EN
	STR	R1,	[R0,	#DMA_S0CR]
;	\|/
Main_Loop
	B	Main_Loop
	
DMA2_Stream0_IRQHandler
	LDR	R0,	=DMA2_BASE
	LDR	R1,	[R0,	#DMA_LIFCR]
	ORR	R1,	R1,	#(DMA_LIFCR_CTCIF0 + DMA_LIFCR_CHTIF0)
	STR	R1,	[R0,	#DMA_LIFCR]
	BX	LR
	
	END