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

load_tiles:	
  	; write nametables
	; write letters in background
	LDA PPUSTATUS ; G
	LDA #$21
	STA PPUADDR
	LDA #$A3
	STA PPUADDR
	LDX #$01
	STX PPUDATA

	LDA PPUSTATUS ; A
	LDA #$21
	STA PPUADDR
	LDA #$A5
	STA PPUADDR
	LDX #$02
	STX PPUDATA
	
	LDA PPUSTATUS ; B
	LDA #$21
	STA PPUADDR
	LDA #$A7
	STA PPUADDR
	LDX #$03
	STX PPUDATA

	LDA PPUSTATUS ; R
	LDA #$21
	STA PPUADDR
	LDA #$A9
	STA PPUADDR
	LDX #$04
	STX PPUDATA

	LDA PPUSTATUS ; I
	LDA #$21
	STA PPUADDR
	LDA #$AB
	STA PPUADDR
	LDX #$05
	STX PPUDATA

	LDA PPUSTATUS ; E
	LDA #$21
	STA PPUADDR
	LDA #$AD
	STA PPUADDR
	LDX #$06
	STX PPUDATA

	LDA PPUSTATUS ; L
	LDA #$21
	STA PPUADDR
	LDA #$AF
	STA PPUADDR
	LDX #$07
	STX PPUDATA

	LDA PPUSTATUS ; V
	LDA #$21
	STA PPUADDR
	LDA #$B5
	STA PPUADDR
	LDX #$08
	STX PPUDATA

	LDA PPUSTATUS ; I
	LDA #$21
	STA PPUADDR
	LDA #$B7
	STA PPUADDR
	LDX #$05
	STX PPUDATA

	LDA PPUSTATUS ; E
	LDA #$21
	STA PPUADDR
	LDA #$B9
	STA PPUADDR
	LDX #$06
	STX PPUDATA

	LDA PPUSTATUS ; R
	LDA #$21
	STA PPUADDR
	LDA #$BB
	STA PPUADDR
	LDX #$04
	STX PPUDATA

	LDA PPUSTATUS ;A
	LDA #$21
	STA PPUADDR
	LDA #$BD
	STA PPUADDR
	LDX #$02
	STX PPUDATA

	; Attribute table
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D8
	STA PPUADDR
	LDA #%00001000
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$D9
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DA
	STA PPUADDR
	LDA #%00000110
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DB
	STA PPUADDR
	LDA #%00001000
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DD
	STA PPUADDR
	LDA #%00000001
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DE
	STA PPUADDR
	LDA #%00000110
	STA PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$DF
	STA PPUADDR
	LDA #%00000000
	STA PPUDATA

vblankwait: ; wait for another vblank before continuing
  bit PPUSTATUS
  bpl vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  jmp forever
.endproc

.segment "VECTORS"
  .addr nmi_handler, reset, irq_handler

.segment "RODATA"
palettes: 
  ; Background Palette
  .byte $0f, $21, $11, $01
  .byte $0f, $25, $15, $05  
  .byte $0f, $29, $19, $09
  .byte $0f, $24, $14, $04

  ; Sprite Palette  %notice that the first palette contains the white color in the second element
  .byte $0f, $21, $11, $01
  .byte $0f, $25, $15, $05  
  .byte $0f, $29, $19, $09
  .byte $0f, $24, $14, $04

.segment "CHR"
.incbin "letters.chr"