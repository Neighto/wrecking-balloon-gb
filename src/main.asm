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

GAMELOOP:
	call WAIT_VBLANK

	; Scroll screen
	; call VBlank_HScroll

	call ReadInput
	ld  a,[joypad_down]
	call JOY_RIGHT
	jr  nz, .skip
	call VBlank_HScroll
.skip
	
  	; Call DMA subroutine to copy the bytes to OAM for sprites begin to draw
	ld  a, HIGH(wShadowOAM)
	call hOAMDMA

	jp GAMELOOP


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
	call MEMCPY
 	; Copy the background tiles
	ld bc, BackgroundTiles
	ld hl, $9000
	ld de, BackgroundTilesEnd - BackgroundTiles
	call MEMCPY
	; Copy the tilemap
	ld bc, BackgroundMap
	ld hl, $9800
	ld de, BackgroundMapEnd - BackgroundMap
	call MEMCPY
	; Initialize player
	call InitializePlayer
	ret

SECTION "Input", rom0

ReadInput:
	;select dpad
	ld  a,%00100000
  
	;takes a few cycles to get accurate reading
	ld  [_IO],a
	ld  a,[_IO]
	ld  a,[_IO]
	ld  a,[_IO]
	ld  a,[_IO]
	
	;complement a
	cpl
  
	;select dpad buttons
	and %00001111
	swap a
	ld  b,a
  
	;select other buttons
	ld  a,%00010000
  
	;a few cycles later..
	ld  [_IO],a  
	ld  a,[_IO]
	ld  a,[_IO]
	ld  a,[_IO]
	ld  a,[_IO]
	cpl
	and %00001111
	or  b
	
	;you get the idea
	ld  b,a
	ld  a,[joypad_down]
	cpl
	and b
	ld  [joypad_pressed],a
	ld  a,b
	ld  [joypad_down],a
	ret
  
  JOY_RIGHT:
	and %00010000
	cp  %00010000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
  JOY_LEFT:
	and %00100000
	cp  %00100000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
  JOY_UP:
	and %01000000
	cp  %01000000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
  JOY_DOWN:
	and %10000000
	cp  %10000000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
  JOY_A:
	and %00000001
	cp  %00000001
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
  JOY_B:
	and %00000010
	cp  %00000010
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
  JOY_SELECT:
	and %00000100
	cp  %00000100
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
  JOY_START:
	and %00001000
	cp  %00001000
	jp  nz,JOY_FALSE
	ld  a,$1
	ret
  JOY_FALSE:
	ld  a,$0
	ret

; 	set 4, [hl]
; 	ld a, [hl]
; 	or 0
; 	; bit 1 is 1 on a => not pressed, if 0 => pressed
; 	jr nz, .ReadInputEnd
; 	call VBlank_HScroll
; .ReadInputEnd
; 	ret