INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "interrupts", ROM0

VBlank_Interrupt::
    push hl
    ld hl, vblank_flag
    ld [hl], 1
    pop hl
    reti

LCD_Interrupt_Park:
	ld a, [rLYC]
	cp a, 0
    jr z, .clouds
    CP a, 72
    jr z, .ground
    ret
.clouds:
    ; AT LINE 0
    ld a, 72
	ldh [rLYC], a
    ld a, [rSCX]
    ld hl, cloud_scroll_offset
    add a, [hl]
	ldh [rSCX], a
    ret
.ground:
    ; AT LINE 72
    ld a, 0
    ldh [rLYC], a
    xor a ; ld a, 0
	ldh [rSCX], a
    ret

LCD_Interrupt_Classic:
    ld a, [rLYC]
    cp a, 136
    jr z, .hideSpritesOnWindow
    cp a, 144
    jr z, .showSprites
.showSprites:
    ; AT LINE 144
    ld a, 136
    ldh [rLYC], a
    ld hl, rLCDC
    set 1, [hl]
    ret
.hideSpritesOnWindow:
    ; AT LINE 136
    ld a, 144
    ldh [rLYC], a
    ld hl, rLCDC
    res 1, [hl]
    ret

LCD_Interrupt::
    push hl
    push af
    ld a, [classic_mode_stage]
    cp a, STAGE_CLASSIC_STARTED
    jr z, .classic
.park:
    call LCD_Interrupt_Park
    jr .end
.classic:
    call LCD_Interrupt_Classic
.end:
    pop af
    pop hl
    ret