; Gabriel A. Viera Perez
.include "constants.inc"

.segment "HEADER"
  ; .byte "NES", $1A      ; iNES header identifier
  .byte $4e, $45, $53, $1a ; Magic string that always begins an iNES header
  .byte $02        ; Number of 16KB PRG-ROM banks
  .byte $01        ; Number of 8KB CHR-ROM banks
  .byte %00000000  ; Horizontal mirroring, no save RAM, no mapper
  .byte %00000000  ; No special-case flags set, no mapper
  .byte $00        ; No PRG-RAM present
  .byte $00        ; NTSC format

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00
	STA $2005
	STA $2005
  RTI
.endproc

reset:
  sei		; disable IRQs
  cld		; disable decimal mode
  ldx #$40
  stx $4017	; disable APU frame IRQ
  ldx #$ff 	; Set up stack
  txs		;  .
  inx		; now X = 0
  stx $2000	; disable NMI
  stx $2001 	; disable rendering
  stx $4010 	; disable DMC IRQs

;; first wait for vblank to make sure PPU is ready
; vblankwait1:
;   bit PPUSTATUS
;   bpl vblankwait1
;   LDA #%10010000  ; turn on NMIs, sprites use first pattern table
;   STA PPUCTRL
;   LDA #%00011110  ; turn on screen
;   STA PPUMASK

clear_memory:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0200, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  inx
  bne clear_memory

.export main
.proc main

  lda PPUSTATUS ;reads from the CPU-RAM PPU address register to reset it
  lda #$3f  ;loads the higher byte of the PPU address register of the palettes in a (we want to write in $3f00 of the PPU since it is the address where the palettes of the PPU are stored)
  sta PPUADDR ;store what's in a (higher byte of PPU palettes address register $3f00) in the CPU-RAM memory location that transfers it into the PPU ($2006)
  lda #$00  ;loads the lower byte of the PPU address register in a
  sta PPUADDR ;store what's in a (lower byte of PPU palettes address register $3f00) in the CPU-RAM memory location that transfers it into the PPU ($2006)
            ;THE PPU-RAM POINTER GETS INCREASED AUTOMATICALLY WHENEVER WE WRITE ON IT

; NO NEED TO MODIFY THIS LOOP SUBROUTINE, IT ALWAYS LOADS THE SAME AMOUNT OF PALETTE REGISTER. TO MODIFY PALETTES, REFER TO THE PALETTE SECTION
load_palettes: 
  lda palettes, x   ; as x starts at zero, it starts loading in a the first element in the palettes code section ($0f). This address mode allows us to copy elements from a tag with .data directives and the index in x
  sta PPUDATA        ;THE PPU-RAM POINTER GETS INCREASED AUTOMATICALLY WHENEVER WE WRITE ON IT
  inx
  cpx #$20
  bne load_palettes

  LDX #$00

; enable_rendering: ; DO NOT MODIFY THIS
;   lda #%10000000	; Enable NMI
;   sta $2000
;   lda #%00010000	; Enable Sprites
;   sta $2001

load_sprites:	
  lda name, x 	; Load the name message into SPR-RAM one by one, the pointer is increased every time a byte is written. Sprites are referenced by using the third byte of the 4-byte arrays in "name"
  sta $0200,x
  inx
  cpx #$10            ;ATTENTION: if you add more letters, you must increase this number by 4 per each additional letter. This is the limit for the sprite memory copy routine
  bne load_sprites

  	; write nametables
	; big stars first
	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$E7
	STA PPUADDR
	LDX #$0A
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$E8
	STA PPUADDR
	LDX #$04
	STX PPUDATA
	
	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$E9
	STA PPUADDR
	LDX #$05
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EA
	STA PPUADDR
	LDX #$15
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EB
	STA PPUADDR
	LDX #$0C
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$EC
	STA PPUADDR
	LDX #$08
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$ED
	STA PPUADDR
	LDX #$0F
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F1
	STA PPUADDR
	LDX #$19
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F2
	STA PPUADDR
	LDX #$0C
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F3
	STA PPUADDR
	LDX #$08
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F4
	STA PPUADDR
	LDX #$15
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$F5
	STA PPUADDR
	LDX #$04
	STX PPUDATA

	; finally, attribute table
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D9
	STA PPUADDR
	LDA #%11000000
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DA
	STA PPUADDR
	LDA #%01100000
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DC
	STA PPUADDR
	LDA #%10001011
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DD
	STA PPUADDR
	LDA #%00010000
	STA PPUDATA

;; second wait for vblank, PPU is ready after this
vblankwait:
  bit PPUSTATUS
  bpl vblankwait
  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever: ;FOREVER LOOP WAITING FOR THEN NMI INTERRUPT, WHICH OCCURS WHENEVER THE LAST PIXEL IN THE BOTTOM RIGHT CORNER IS PROJECTED
  jmp forever
.endproc

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi_handler, reset, irq_handler
  ;; When the processor first turns on or is reset, it will jump to the label reset:

  ;; External interrupt IRQ (unused)


.segment "RODATA"
palettes: ;The first color should always be the same accross all the palettes. MOdify this section to determine which colors you'd like to use
  ; Background Palette % all black and gray
	.byte $0f, $12, $23, $27
	.byte $0f, $2b, $3c, $39
	.byte $0f, $0c, $07, $13
	.byte $0f, $19, $09, $29

  ; Sprite Palette  %notice that the first palette contains the white color in the second element
  .byte $0f, $21, $11, $01
  .byte $0f, $25, $15, $05  
  .byte $0f, $29, $19, $09
  .byte $0f, $24, $14, $04

name:
  ; .byte $6c, $00, $00, $6c  ; Y=$6c(108), Sprite=00(G), Palette=00, X=%6c(108)
  ; .byte $6c, $01, $01, $76  ; Y=$6c(108), Sprite=01(A), Palette=00, X=%76(118)
  ; .byte $6c, $02, $00, $80  ; Y=$6c(108), Sprite=02(B), Palette=00, X=%80(128)
  ; .byte $6c, $03, $01, $8A  ; Y=$6c(108), Sprite=03(R), Palette=00, X=%8A(138)
  ; .byte $6c, $04, $00, $94  ; Y=$6c(108), Sprite=04(I), Palette=00, X=%94(148)
  ; .byte $6c, $05, $01, $9E  ; Y=$6c(108), Sprite=05(E), Palette=00, X=%9E(158)
  ; .byte $6c, $06, $00, $A8  ; Y=$6c(108), Sprite=06(L), Palette=00, X=%A8(168)

  ; .byte $76, $07, $00, $76  ; Y=$76(118), Sprite=07(V), Palette=00, X=%B2(118)
  ; .byte $76, $04, $01, $80  ; Y=$76(118), Sprite=04(I), Palette=01, X=%94(128)
  ; .byte $76, $05, $00, $8A  ; Y=$76(118), Sprite=05(E), Palette=00, X=%9E(138)
  ; .byte $76, $03, $01, $94  ; Y=$76(118), Sprite=03(R), Palette=01, X=%8A(148)
  ; .byte $76, $01, $00, $9E  ; Y=$76(118), Sprite=01(A), Palette=00, X=%76(158)

;   .byte $70, $05, $00, $80
;   .byte $70, $06, $00, $88
;   .byte $78, $07, $00, $80
;   .byte $78, $08, $00, $88

.segment "CHR"
.incbin "starfield.chr"