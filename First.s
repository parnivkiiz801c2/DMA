	INCLUDE		STM32F4xx.s
Array_1		EQU		0x200
Array_2		EQU		0x220
	
	AREA	SRAM1,	NOINIT,	READWRITE
	SPACE	0x400
Stack_Top
	
	AREA	RESET,	DATA,	READONLY
	DCD		Stack_Top				;[0x000-0x003]
	DCD		Start_Init				;[0x004-0x007]
	SPACE	0x78			
	DCD		DMA1_Stream5_IRQHandler	;[80]
	DCD		DMA1_Stream6_IRQHandler	;[0x84]
	SPACE	0x50
	DCD		USART2_IRQHandler		;[0x0D8-0x0DC]
	SPACE	0x44
	DCD		DMA2_Stream0_IRQHandler
	
	
	AREA	PROGRAM,	CODE,		READONLY
	ENTRY
	
E0
	B	E0

Start_Init

;Uses USART1: TX = PB6, RX = PB7 (AF7)
	LDR			R0,			=RCC_BASE
;USART1 CLK Enable
	LDR			R1,			[R0,		#RCC_APB1ENR]
	ORR			R1,			R1,			#RCC_APB1ENR_USART2EN
	STR			R1,			[R0,		#RCC_APB1ENR]
;GPIOA CLK Enable
	LDR			R1,			[R0,		#RCC_AHB1ENR]
	ORR			R1,			R1,			#RCC_AHB1ENR_GPIODEN
	STR			R1,			[R0,		#RCC_AHB1ENR]
;PB6  = USART1_TX (AF7) | PB7 = USART1_RX (AF7)
	LDR			R0,			=GPIOD_BASE
	LDR			R1,			[R0,		#GPIO_MODER]
	BFC			R1,			#GPIO_MODER_MODER5_Pos,		#4
	ORR			R1,			R1,			#(GPIO_MODER_MODER5_1 + GPIO_MODER_MODER6_1)
	STR			R1,			[R0,		#GPIO_MODER]
;PB6 Pull Up | PB7 Pull Up
	LDR			R1,			[R0,		#GPIO_PUPDR]
	BFC			R1,			#GPIO_PUPDR_PUPD6_Pos,		#4
	ORR			R1,			R1,			#(GPIO_PUPDR_PUPD5_0 + GPIO_PUPDR_PUPD6_0)
	STR			R1,			[R0,		#GPIO_PUPDR]
	LDR			R1,			[R0,		#GPIO_AFRL]
	BFC			R1,			#GPIO_AFRL_AFSEL6_Pos,		#8
	ORR			R1,			R1,			#(7 << GPIO_AFRL_AFSEL6_Pos)
	ORR			R1,			R1,			#(7 << GPIO_AFRL_AFSEL5_Pos)
	STR			R1,			[R0,		#GPIO_AFRL]
	
;USART1 BR = 57 600, 2 stop bits, no parity
	LDR			R0,			=USART2_BASE
;F_APB2 = 16 MHz
;BRR = (16 MHz -  (57 600 / 2)) / 57 600 = 277
	MOV			R1,			#277
	STR			R1,			[R0,		#USART_BRR]
	LDR			R1,			[R0,		#USART_CR2]
	AND			R1,			R1,			#~USART_CR2_STOP
	ORR			R1,			R1,			#USART_CR2_STOP_1
	STR			R1,			[R0,		#USART_CR2]
	LDR			R1,			[R0,		#USART_CR1]
	ORR			R1,			R1,			#(USART_CR1_RE + USART_CR1_TE)
	ORR			R1,			R1,			#(USART_CR1_RXNEIE + USART_CR1_TCIE)
	ORR			R1,			R1,			#USART_CR1_UE
	STR			R1,			[R0,		#USART_CR1]
;USART1 Interrupts Enable
	LDR			R0,			=NVIC_BASE
	LDR			R1,			[R0,		#NVIC_ISER1]
	ORR			R1,			R1,			#(1 << (USART2_IRQn - 32))
	STR			R1,			[R0,		#NVIC_ISER1]


;DMA1 Mem to Mem Init
	LDR			R0,			=RCC_BASE
	LDR			R1,			[R0,		#RCC_AHB1ENR]
	ORR			R1,			R1,			#RCC_AHB1ENR_DMA2EN
	STR			R1,			[R0,		#RCC_AHB1ENR]
;1
	LDR			R0,			=DMA1_BASE
	LDR			R1,			[R0,		#DMA_S0CR]
	AND			R1,			R1,			#DMA_SxCR_EN
	CMP			R1,			#0
	BNE			E0
;2
	LDR			R1,			=(USART2_BASE + USART_DR)
	STR			R1,			[R0,	#DMA_S0PAR]
;3
	LDR			R1,			=(SRAM1_BASE + Array_1)
	STR			R1,			[R0,	#DMA_S0M0AR]
;4

;Skip 5, 6, 7 and 8
;9
	LDR			R1,			[R0,	#DMA_S5CR]
	;LDR	R1,	[ DMA_S5CR_HSEL]
	AND			R1,			R1,		#~DMA_SxCR_CHSEL
	ORR			R1,			#(4 << DMA_SxCR_CHSEL_Pos)
	AND			R1,			R1,		#~DMA_SxCR_DIR		
	ORR			R1,			R1,		#(DMA_SxCR_MINC + DMA_SxCR_PINC)
	ORR			R1,			R1,		#DMA_SxCR_TCIE
	STR			R1,			[R0,	#DMA_S5CR]
;DMA1_S0 Interrupt Enable
	LDR			R2,			=NVIC_BASE
	LDR			R1,			[R2,	#NVIC_ISER1]
	ORR			R1,			R1,	#(1 << (DMA1_Stream5_IRQn - 32))
	STR			R1,			[R2,	#NVIC_ISER1]

	
	

;DMA2 S0 Enable
;	LDR			R1,			[R0,	#DMA_S0CR]
;	ORR			R1,			R1,		#DMA_SxCR_EN
;	STR			R1,			[R0,	#DMA_S0CR]

;DMA2 Mem to Mem Init
	LDR			R0,			=RCC_BASE
	LDR			R1,			[R0,	#RCC_AHB1ENR]
	ORR			R1,			R1,	#RCC_AHB1ENR_DMA2EN
	STR			R1,			[R0,	#RCC_AHB1ENR]
;1
	LDR			R0,			=DMA2_BASE
	LDR			R1,			[R0,	#DMA_S0CR]
	AND			R1,			R1,		#DMA_SxCR_EN
	CMP			R1,			#0
	BNE	E0
;2
	LDR			R1,			=(SRAM1_BASE + Array_1)
	STR			R1,			[R0,	#DMA_S0PAR]
;3
	LDR			R1,			=(SRAM1_BASE + Array_2)
	STR			R1,			[R0,	#DMA_S0M0AR]
;4
	MOV			R1,			#10
	STR			R1,			[R0,	#DMA_S0NDTR]
;Skip 5, 6, 7 and 8
;9
	LDR			R1,			[R0,	#DMA_S0CR]
	AND			R1,			R1,		#~DMA_SxCR_DIR
	ORR			R1,			R1,		#DMA_SxCR_DIR_1
	ORR			R1,			R1,		#(DMA_SxCR_MINC + DMA_SxCR_PINC)
	ORR			R1,			R1,		#DMA_SxCR_TCIE
	STR			R1,			[R0,	#DMA_S0CR]
;DMA2_S0 Interrupt Enable
	LDR			R2,			=NVIC_BASE
	LDR			R1,			[R2,	#NVIC_ISER1]
	ORR			R1,			R1,		#(1 << (DMA2_Stream0_IRQn - 32))
	STR			R1,			[R2,	#NVIC_ISER1]
;Array_1 Init
	
;DMA2 S0 Enable
	LDR			R1,			[R0,	#DMA_S0CR]
;	ORR			R1,			R1,		#DMA_SxCR_EN
	STR			R1,			[R0,	#DMA_S0CR]
;	\|/
Main_Loop
	B	Main_Loop
	
DMA2_Stream0_IRQHandler
	LDR			R0,			=DMA2_BASE
	LDR			R1,			[R0,	#DMA_LIFCR]
	ORR			R1,			R1,		#(DMA_LIFCR_CTCIF0 + DMA_LIFCR_CHTIF0)
	STR			R1,			[R0,	#DMA_LIFCR]
	BX			LR
		
	
	
DMA1_Stream5_IRQHandler
	MOV			R1,			#10
	STR			R1,			[R0,	#DMA_S0NDTR]
	BX		LR
	
DMA1_Stream6_IRQHandler
	BX		LR

USART2_IRQHandler
	LDR			R0,			=USART2_BASE
	LDR			R1,			[R0,		#USART_SR]
;Check RXNE
	AND			R2,			R1,			#USART_SR_RXNE
	CMP			R2,			#USART_SR_RXNE
	BEQ			USART2_IRQHandler_RXNE
;Check TC
	AND			R2,			R1,			#USART_SR_TC
	CMP			R2,			#USART_SR_TC
	BEQ			USART2_IRQHandler_TC
;Check ORE
	AND			R2,			R1,			#USART_SR_ORE
	CMP			R2,			#USART_SR_ORE
	BEQ			USART2_IRQHandler_ORE
	BX			LR

USART2_IRQHandler_TC
	AND			R1,			R1,			#~USART_SR_TC
	STR			R1,			[R0,		#USART_SR]
	BX			LR

USART2_IRQHandler_RXNE
	LDR			R1,			[R0,		#USART_DR]
	STR			R1,			[R0,		#USART_DR]
	
;DMA1 S0 Enable
	LDR			R0,			=DMA1_BASE
	LDR			R1,			[R0,	#DMA_S0CR]
	ORR			R1,			R1,		#DMA_SxCR_EN
	STR			R1,			[R0,	#DMA_S0CR]
	BX			LR

USART2_IRQHandler_ORE
	BX			LR
	
	END
