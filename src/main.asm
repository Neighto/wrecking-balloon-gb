INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

START::

	; ;enable interrupts
	; ei

	; ;enable vblank interrupt
	; ld  sp,$FFFE
	; ld  a,IEF_VBLANK
	; 	ld  [rIE],a

	; ; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
	call Wait_VBlank
	call LCD_Off

	; Shade palettes
	ld  a,%11100100
	ldh [rBGP],a
	ldh [rOCPD],a
	ldh [rOBP0],a
	ldh [rOBP1],a

	; Clear everything
	call CLEAR_MAP
	; call CLEAR_OAM
	; call CLEAR_RAM
	call CLEAR_SPRITES

	; Load tiles, draw sprites and draw tilemap
	call LoadGameData

	; Move DMA routine to HRAM
	call CopyDMARoutine

	call LCD_On

GameLoop:
	; Wait for the display to finish updating
	call Wait_VBlank

	; Scroll screen
	call VBlank_HScroll
	
  	; Call DMA subroutine to copy the bytes to OAM for sprites begin to draw
	ld  a, HIGH(wShadowOAM)
	call hOAMDMA

	jp GameLoop


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
hOAMDMA:: ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to

SECTION "Shadow OAM", WRAM0,ALIGN[8]
wShadowOAM:: ds 4 * 40 ; This is the buffer we'll write sprite data to

SECTION "Scrolling", ROM0
VBlank_HScroll::
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
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$10,$11,$12,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$0F,$13,$14,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$10
	DB $11,$12,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$0F,$13,$14,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$10,$11,$12,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$0F,$13,$14
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$10,$11,$12,$10,$11,$12,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$0F,$13,$13,$0F,$13,$14,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$15,$10
	DB $11,$12,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $10,$0F,$13,$14,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$0F,$13,$14,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$10,$11,$12,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$0F,$13,$14
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $10,$11,$12,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$0F,$13,$14,$00,$00,$00,$00,$00
	DB $00,$00,$0D,$0E,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$05,$06,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$0B,$0C,$00,$00
	DB $00,$00,$00,$00,$00,$10,$11,$12,$10,$11
	DB $12,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$09,$0A
	DB $00,$00,$00,$00,$00,$00,$00,$0F,$13,$13
	DB $0F,$13,$14,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	DB $00,$00,$00,$00,$00,$00
TilemapEnd:

LoadGameData:
	; Copy the sprite tiles
	ld bc, CactusTiles
	ld hl, $8800
	ld de, CactusTilesEnd - CactusTiles
	call memcpy
 	; Copy the background tiles
	ld bc, BackgroundTiles
	ld hl, $9000
	ld de, BackgroundTilesEnd - BackgroundTiles
	call memcpy
	; Copy the tilemap
	ld bc, BackgroundMap
	ld hl, $9800
	ld de, BackgroundMapEnd - BackgroundMap
	call memcpy
	; Initialize player
	call player_sprite_init
	ret