INCLUDE "hardware.inc"

SECTION "rom", ROM0[$100]
	jp EntryPoint
	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
	call Wait_VBlank

	; Turn the LCD off
	call LCD_Off

; 	; Copy the tiles
	ld bc, Tiles
	ld hl, $9000
	ld de, TilesEnd - Tiles
	call memcpy

	; Copy the tilemap
	ld bc, Tilemap
	ld hl, $9800
	ld de, TilemapEnd - Tilemap
	call memcpy

	; Turn the LCD on
	call LCD_On

	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a

	; Move DMA routine to HRAM
	call CopyDMARoutine

Done:

	; Wait for the display to finish updating
	call Wait_VBlank

	call VBlank_HScroll

	; Scroll screen
	; ldh a, [rSCX]
	; add 1
	; ldh  [rSCX], a

	; Load sprites in buffer
	call LoadTestSprite
	
	; Call the DMA subroutine we copied to HRAM
  	; which then copies the bytes to the OAM and sprites begin to draw
	ld  a, HIGH(wShadowOAM)
	call hOAMDMA

	jp Done


SECTION "OAM DMA routine", ROM0

CopyDMARoutine:
	ld  hl, DMARoutine
	ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
	ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
	ld  a, [hli]
	ldh [c], a
	inc c
	dec b
	jr  nz, .copy
	ret

DMARoutine:
	ldh [rDMA], a
	
	ld  a, 40
.wait
	dec a
	jr  nz, .wait
	ret
DMARoutineEnd:

SECTION "OAM DMA", HRAM
hOAMDMA: ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to

SECTION "Shadow OAM", WRAM0,ALIGN[8]
wShadowOAM: ds 4 * 40 ; This is the buffer we'll write sprite data to

SECTION "HARDWARE SPRITES", rom0
SetHardwareSprite:	
	;A=Hardware Sprite No. BC = X,Y , E = Source Data, H=Palette etc
	;On the gameboy You need to set XY to 8,16 to get the top corner of the screen
	push af
		rlca							;4 bytes per sprite
		rlca		
		push hl
		push de
			push hl
				ld hl, wShadowOAM
				ld l,a					;L address for selected sprite
				ld a,c					;y
				ldi [hl], a
				ld a,b					;x
				ldi [hl], a
				ld a,e					;tile
				ldi [hl], a
			pop de
			ld a,d						;attribs
			ldi [hl],a
		pop de
		pop hl
	pop af
	ret

LoadTestSprite:
	ld bc, $4840 ;xy
	ld e, 164 ;pattern
	ld h, 0 ;tiledetails
	ld a, 0 ;sprite
	call SetHardwareSprite
	ld a, 8
	add b
	ld b, a
	inc e
	ld a, 1
	call SetHardwareSprite
	ld a, 8
	add c
	ld c, a
	inc e
	inc e
	ld a, 2
	call SetHardwareSprite
	ld a, -8
	add b
	ld b, a
	dec e
	ld a, 3
	call SetHardwareSprite
	ret

SECTION "Scrolling", ROM0 
VBlank_HScroll:
	di
	push af

	; Increment Scroll Timer
	ld a, [scroll_timer]
	inc	a
	ld [scroll_timer], a

	; Can We Scroll (every 16th vblank)
	and	%00001111
	jr nz, .end

	; Horizontal Scroll
	ldh a, [rSCX]
	add 1
	ldh  [rSCX], a

.end:
	pop af
	ei		; enable interrupts
	reti	; and done

SECTION "Tiles", ROM0
Tiles:
	DB $6F,$33,$14,$1B,$2F,$08,$1F,$1F
	DB $10,$1F,$1F,$1F,$08,$0F,$07,$07
	DB $F6,$CC,$28,$D8,$F4,$10,$F8,$F8
	DB $08,$F8,$F8,$F8,$10,$F0,$E0,$E0
	DB $00,$00,$0A,$00,$07,$07,$1B,$0C
	DB $57,$18,$3F,$24,$7B,$26,$3F,$20
	DB $00,$00,$50,$00,$E0,$E0,$D8,$30
	DB $EA,$18,$FC,$24,$DE,$64,$FC,$04
	DB $30,$3F,$10,$1F,$08,$0F,$0C,$0F
	DB $03,$03,$01,$00,$01,$00,$01,$00
	DB $0C,$FC,$08,$F8,$10,$F0,$30,$F0
	DB $C0,$C0,$80,$00,$80,$00,$80,$00
	DB $0F,$0F,$30,$3F,$40,$7F,$42,$7F
	DB $80,$FF,$82,$FF,$C1,$FF,$40,$7F
	DB $F0,$F0,$0C,$FC,$02,$FE,$42,$FE
	DB $01,$FF,$41,$FF,$83,$FF,$02,$FE
	DB $3B,$2A,$57,$12,$03,$02,$0F,$0F
	DB $08,$0F,$0F,$0F,$04,$07,$07,$07
	DB $DC,$54,$EA,$48,$C0,$40,$F0,$F0
	DB $10,$F0,$F0,$F0,$20,$E0,$E0,$E0
	DB $00,$04,$01,$03,$06,$07,$07,$04
	DB $17,$06,$1D,$1E,$7F,$20,$3F,$2E
	DB $00,$20,$80,$C0,$60,$E0,$E0,$20
	DB $E8,$60,$B8,$78,$FE,$04,$FC,$74
	DB $0F,$0F,$30,$3F,$4C,$7F,$46,$7B
	DB $80,$FF,$81,$FF,$C3,$FF,$42,$7F
	DB $F0,$F0,$0C,$FC,$32,$FE,$62,$DE
	DB $01,$FF,$81,$FF,$C3,$FF,$42,$FE
	DB $28,$28,$50,$50,$40,$40,$40,$48
	DB $80,$BD,$98,$FF,$68,$6F,$07,$07
	DB $00,$00,$00,$00,$01,$01,$02,$02
	DB $04,$04,$08,$08,$08,$08,$08,$08
	DB $00,$00,$60,$60,$98,$98,$04,$04
	DB $05,$05,$02,$02,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00
	DB $E0,$E0,$10,$10,$08,$08,$04,$04
	DB $00,$00,$00,$00,$00,$00,$00,$03
	DB $01,$D7,$02,$FE,$C4,$FC,$38,$38
	DB $02,$02,$01,$07,$01,$4F,$06,$DE
	DB $C8,$F8,$30,$30,$00,$00,$00,$00
TilesEnd:
	
SECTION "Tilemap", ROM0
Tilemap:
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$0F,$10,$11,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$0E,$12,$13,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$0F,$10,$10,$0F,$10,$11,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$0E,$12,$13,$0E,$12,$13,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$0F,$10,$11,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$0E,$12,$13,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$0F,$10,$11,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$0E,$12,$13,$14,$14,$14,$14,$14,$14,$14,$0C,$0D,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$04,$05,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$0A,$0B,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$08,$09,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
	DB $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14, 0,0,0,0,0,0,0,0,0,0,0,0
TilemapEnd: