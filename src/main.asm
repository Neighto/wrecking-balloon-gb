INCLUDE "hardware.inc"
INCLUDE "header.inc"

SECTION "rom", ROM0

START::
	; ei

	; ;enable vblank interrupt
	; ld  sp,$FFFE
	; ld  a,IEF_VBLANK
	; 	ld  [rIE],a

	; ; Shut down audio circuitry
	ld a, 0
	ld [rNR52], a

	; Do not turn the LCD off outside of VBlank
	call WAIT_VBLANK
	call LCD_OFF

	; Shade palettes
	ld  a,%11100100
	ldh [rBGP],a
	ldh [rOCPD],a
	ldh [rOBP0],a
	ldh [rOBP1],a

	call CLEAR_MAP
	call CLEAR_OAM
	call CLEAR_RAM
	call CLEAR_SPRITES
	call LoadGameData
	call CopyDMARoutine

	call LCD_ON

GameLoop:
	call WAIT_VBLANK

	; Scroll screen
	call VBlank_HScroll
	
  	; Call DMA subroutine to copy the bytes to OAM for sprites begin to draw
	ld  a, HIGH(wShadowOAM)
	call hOAMDMA

	jp GameLoop


SECTION "OAM DMA routine", ROM0

; Move DMA routine to HRAM
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

SECTION "Graphics", ROM0
; Load tiles, draw sprites and draw tilemap
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