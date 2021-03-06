	INCLUDE		STM32F4xx.s
Array_1		EQU		0x200
Array_2		EQU		0x220
	
	AREA	SRAM1,	NOINIT,	READWRITE
	SPACE	0x400
Stack_Top
	
	AREA	RESET,	DATA,	READONLY
	DCD		Stack_Top				;[0x000-0x003]
	DCD		Start_Init				;[0x004-0x007]
	SPACE	0x68			
	DCD		DMA1_Stream1_IRQHandler	;[70]
	SPACE	0x10
	DCD		DMA1_Stream6_IRQHandler	;[0x80]	
	SPACE	0x98
	DCD		DMA2_Stream0_IRQHandler
	
	
	AREA	PROGRAM,	CODE,		READONLY
	ENTRY
	
E0
	
	B	E0

Start_Init
;PD9 - RX USART3
;Uses USART2: TX = PD5
	LDR			R0,			=RCC_BASE
;USART2 CLK Enable
	LDR			R1,			[R0,		#RCC_APB1ENR]
	ORR			R1,			R1,			#RCC_APB1ENR_USART2EN
	STR			R1,			[R0,		#RCC_APB1ENR]
;GPIOD CLK Enable
	LDR			R1,			[R0,		#RCC_AHB1ENR]
	ORR			R1,			R1,			#RCC_AHB1ENR_GPIODEN
	STR			R1,			[R0,		#RCC_AHB1ENR]
;PD5 = USART1_TX (AF7)
	LDR			R0,			=GPIOD_BASE
	LDR			R1,			[R0,		#GPIO_MODER]
	BFC			R1,			#GPIO_MODER_MODER5_Pos,		#4
	ORR			R1,			R1,			#GPIO_MODER_MODER5_1
	STR			R1,			[R0,		#GPIO_MODER]
;PD6 Pull Up
	LDR			R1,			[R0,		#GPIO_PUPDR]
	BFC			R1,			#GPIO_PUPDR_PUPD5_Pos,		#4
	ORR			R1,			R1,			#GPIO_PUPDR_PUPD5_0
	STR			R1,			[R0,		#GPIO_PUPDR]
	LDR			R1,			[R0,		#GPIO_AFRL]
	BFC			R1,			#GPIO_AFRL_AFSEL5_Pos,		#8
	ORR			R1,			R1,			#(7 << GPIO_AFRL_AFSEL5_Pos)
	STR			R1,			[R0,		#GPIO_AFRL]
;USART3 CLK Enable
	LDR			R0,			=RCC_BASE
	LDR			R1,			[R0,		#RCC_APB1ENR]
	ORR			R1,			R1,			#RCC_APB1ENR_USART3EN
	STR			R1,			[R0,		#RCC_APB1ENR]
;GPIOD CLK Enable
	LDR			R1,			[R0,		#RCC_AHB1ENR]
	ORR			R1,			R1,			#RCC_AHB1ENR_GPIODEN
	STR			R1,			[R0,		#RCC_AHB1ENR]
;PD8  = USART1_TX (AF7)
	LDR			R0,			=GPIOD_BASE
	LDR			R1,			[R0,		#GPIO_MODER]
	BFC			R1,			#GPIO_MODER_MODER9_Pos,		#4
	ORR			R1,			R1,			#GPIO_MODER_MODER9_1 
	STR			R1,			[R0,		#GPIO_MODER]
;PD8 Pull Up
	LDR			R1,			[R0,		#GPIO_PUPDR]
	BFC			R1,			#GPIO_PUPDR_PUPD9_Pos,		#4
	ORR			R1,			R1,			#GPIO_PUPDR_PUPD9_0
	STR			R1,			[R0,		#GPIO_PUPDR]
	LDR			R1,			[R0,		#GPIO_AFRH]
	BFC			R1,			#GPIO_AFRH_AFSEL9_Pos,		#8
	ORR			R1,			R1,			#(7 << GPIO_AFRH_AFSEL9_Pos)
	STR			R1,			[R0,		#GPIO_AFRH]
	
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
	LDR			R1,			[R0,		#USART_CR3]
;	ORR			R1,			R1,			#USART_CR3_DMAR
	ORR			R1,			R1,			#USART_CR3_DMAT
	STR			R1,			[R0,		#USART_CR3]
	LDR			R1,			[R0,		#USART_CR1]
	ORR			R1,			R1,			#(USART_CR1_RE + USART_CR1_TE)
	ORR			R1,			R1,			#(USART_CR1_RXNEIE + USART_CR1_TCIE)
	ORR			R1,			R1,			#USART_CR1_UE
	STR			R1,			[R0,		#USART_CR1]
;USART3 CONFIG	
	LDR			R0,			=USART3_BASE
;F_APB2 = 16 MHz
;BRR = (16 MHz -  (57 600 / 2)) / 57 600 = 277
	MOV			R1,			#277
	STR			R1,			[R0,		#USART_BRR]
	LDR			R1,			[R0,		#USART_CR2]
	AND			R1,			R1,			#~USART_CR2_STOP
	ORR			R1,			R1,			#USART_CR2_STOP_1
	STR			R1,			[R0,		#USART_CR2]
	LDR			R1,			[R0,		#USART_CR3]
	ORR			R1,			R1,			#USART_CR3_DMAR
;	ORR			R1,			R1,			#USART_CR3_DMAT
	STR			R1,			[R0,		#USART_CR3]
	LDR			R1,			[R0,		#USART_CR1]
	ORR			R1,			R1,			#(USART_CR1_RE + USART_CR1_TE)
	ORR			R1,			R1,			#(USART_CR1_RXNEIE + USART_CR1_TCIE)
	ORR			R1,			R1,			#USART_CR1_UE
	STR			R1,			[R0,		#USART_CR1]


;DMA1 Per to Mem Init
	LDR			R0,			=RCC_BASE
	LDR			R1,			[R0,		#RCC_AHB1ENR]
	ORR			R1,			R1,			#RCC_AHB1ENR_DMA1EN
	STR			R1,			[R0,		#RCC_AHB1ENR]
;1
	LDR			R0,			=DMA1_BASE
	LDR			R1,			[R0,		#DMA_S1CR]
	AND			R1,			R1,			#DMA_SxCR_EN
	CMP			R1,			#0
	BNE			E0
;2
	LDR			R1,			=(USART3_BASE + USART_DR)
	STR			R1,			[R0,	#DMA_S1PAR]
;3
	LDR			R1,			=(SRAM1_BASE + Array_1)
	STR			R1,			[R0,	#DMA_S1M0AR]
;4
	MOV			R1,			#10
	STR			R1,			[R0,	#DMA_S1NDTR]
;Skip 5, 6, 7 and 8
;9
	LDR			R1,			[R0,	#DMA_S1CR]
	AND			R1,			R1,		#~DMA_SxCR_CHSEL
	ORR			R1,			#(4 << DMA_SxCR_CHSEL_Pos)
	AND			R1,			R1,		#~DMA_SxCR_DIR		
	ORR			R1,			R1,		#DMA_SxCR_MINC
	ORR			R1,			R1,		#DMA_SxCR_TCIE
	STR			R1,			[R0,	#DMA_S1CR]
;DMA1_S0 Interrupt Enable
	LDR			R2,			=NVIC_BASE
	LDR			R1,			[R2,	#NVIC_ISER0]
	ORR			R1,			R1,		#(1 << DMA1_Stream1_IRQn)
	STR			R1,			[R2,	#NVIC_ISER0]

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
	STR			R1,			[R0,	#DMA_S0CR]
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
	
;DMA1 S6 ENABLE
;DMA1 MEM to PER Init
	LDR			R0,			=RCC_BASE
	LDR			R1,			[R0,		#RCC_AHB1ENR]
	ORR			R1,			R1,			#RCC_AHB1ENR_DMA1EN
	STR			R1,			[R0,		#RCC_AHB1ENR]
;1
	LDR			R0,			=DMA1_BASE
	LDR			R1,			[R0,		#DMA_S6CR]
	AND			R1,			R1,			#DMA_SxCR_EN
	CMP			R1,			#0
	BNE			E0
;2
	LDR			R1,			=(USART2_BASE + USART_DR)
	STR			R1,			[R0,	#DMA_S6PAR]
;3
	LDR			R1,			=(SRAM1_BASE + Array_2)
	STR			R1,			[R0,	#DMA_S6M0AR]
;4
	MOV			R1,			#10
	STR			R1,			[R0,	#DMA_S6NDTR]
;Skip 5, 6, 7 and 8
;9
	LDR			R1,			[R0,	#DMA_S6CR]
	AND			R1,			R1,		#~DMA_SxCR_CHSEL
	ORR			R1,			#(4 << DMA_SxCR_CHSEL_Pos)
	AND			R1,			R1,		#~DMA_SxCR_DIR
	ORR			R1,			R1,		#DMA_SxCR_DIR_0	
	ORR			R1,			R1,		#DMA_SxCR_MINC
	ORR			R1,			R1,		#DMA_SxCR_TCIE
	STR			R1,			[R0,	#DMA_S6CR]
;DMA1_S0 Interrupt Enable
	LDR			R2,			=NVIC_BASE
	LDR			R1,			[R2,	#NVIC_ISER0]
	ORR			R1,			R1,		#(1 << DMA1_Stream6_IRQn)
	STR			R1,			[R2,	#NVIC_ISER0]
	
	
	
	LDR			R0,			=DMA1_BASE
	LDR			R1,			[R0,	#DMA_S1CR]
	ORR			R1,			R1,		#DMA_SxCR_EN
	STR			R1,			[R0,	#DMA_S1CR]	
	

Main_Loop
	B	Main_Loop
			
DMA1_Stream1_IRQHandler
	LDR			R0,			=DMA1_BASE
	LDR			R1,			[R0,	#DMA_LIFCR]
	ORR			R1,			R1,		#DMA_LIFCR_CTCIF1
	ORR			R1,			R1,		#DMA_LIFCR_CHTIF1
	STR			R1,			[R0,	#DMA_LIFCR]
;DMA2 S0 Enable
	LDR			R0,			=DMA2_BASE
	LDR			R1,			[R0,	#DMA_S0CR]
	ORR			R1,			R1,		#DMA_SxCR_EN
	STR			R1,			[R0,	#DMA_S0CR]
	BX			LR
	
DMA2_Stream0_IRQHandler
	LDR			R0,			=DMA2_BASE
	LDR			R1,			[R0,	#DMA_LIFCR]
	ORR			R1,			R1,		#(DMA_LIFCR_CTCIF0 + DMA_LIFCR_CHTIF0)
	STR			R1,			[R0,	#DMA_LIFCR]
;DMA2 S6 Enable
	LDR			R0,			=DMA1_BASE
	LDR			R1,			[R0,	#DMA_S6CR]
	ORR			R1,			R1,		#DMA_SxCR_EN
	STR			R1,			[R0,	#DMA_S6CR]
	BX			LR
	
DMA1_Stream6_IRQHandler
	LDR			R0,			=DMA1_BASE
	LDR			R1,			[R0,	#DMA_HIFCR]
	ORR			R1,			R1,		#DMA_HIFCR_CTCIF6
	ORR			R1,			R1,		#DMA_HIFCR_CHTIF6
	STR			R1,			[R0,	#DMA_HIFCR]
;DMA1 S5 Enable
	LDR			R0,			=DMA1_BASE
	LDR			R1,			[R0,	#DMA_S1CR]
	ORR			R1,			R1,		#DMA_SxCR_EN
	STR			R1,			[R0,	#DMA_S1CR]
	BX			LR



	END
