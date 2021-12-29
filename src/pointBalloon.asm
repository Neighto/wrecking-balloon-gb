INCLUDE "points.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

POINT_BALLOON_STRUCT_SIZE EQU 7
POINT_BALLOON_SPRITE_MOVE_WAIT_TIME EQU %00000001

SECTION "point balloon vars", WRAM0
PointBalloonStart:
    pointBalloon:: DS POINT_BALLOON_STRUCT_SIZE*3
PointBalloonEnd:

SECTION "point balloon", ROMX

UpdateBalloonPosition:
    SET_HL_TO_ADDRESS wOAM, pointBalloon+2
    ; Update Y
    ld a, [pointBalloon]
    ld [hli], a
    ; Update X
    ld a, [pointBalloon+1]
    ld [hl], a
  
    SET_HL_TO_ADDRESS wOAM+4, pointBalloon+2
    ; Update Y
    ld a, [pointBalloon]
    ld [hli], a
    ; Update X
    ld a, [pointBalloon+1]
    add 8
    ld [hl], a
    ret

InitializePointBalloon::
    push bc
    push hl
    RESET_IN_RANGE pointBalloon, PointBalloonEnd - PointBalloonStart
    pop hl
    pop bc
    ret

SpawnPointBalloon::
    ; argument b = Y spawn
    ; argument c = X spawn
    push af
    push hl
    ; Skip if alive
    ld hl, pointBalloon+3
    ld a, [hl] ; Alive
    cp a, 0
    jr nz, .end
    call InitializePointBalloon
    ; Set Alive
    ld [hl], 1

    ; Set Coordinates
    ld hl, pointBalloon
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a

    ; Request OAM
    ld b, 2
	call RequestOAMSpaceOffset
	ld [hli], a

.balloonLeft:
    ; Balloon left
    SET_HL_TO_ADDRESS wOAM, pointBalloon+2
    ld a, [pointBalloon]
    ld [hli], a
    ld a, [pointBalloon+1]
    ld [hli], a
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1
.balloonRight:
    ; Balloon right
    inc l
    ld a, [pointBalloon]
    ld [hli], a
    ld a, [pointBalloon+1]
    add 8
    ld [hli], a
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1 | OAMF_XFLIP
.end:
    pop hl
    pop af
    ret

FloatPointBalloonUp:
    ld hl, pointBalloon
    ld a, [hl]
    dec a
    ld [hl], a
    call UpdateBalloonPosition
    ret

PopBalloonAnimation:
    ; Check what frame we are on
    ld a, [pointBalloon+5] ; Frame
    cp a, 0
    jr z, .frame0

    ld a, [pointBalloon+6] ; Timer
	inc	a
	ld [pointBalloon+6], a ; Timer
    and POPPING_BALLOON_ANIMATION_SPEED
    jp nz, .end
    ; Can do next frame
    ; Check what frame we are on
    ld a, [pointBalloon+5] ; Frame
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, pointBalloon+2
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, pointBalloon+2
    ld [hl], $88
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, pointBalloon+5 ; Frame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    SET_HL_TO_ADDRESS wOAM+2, pointBalloon+2
    ld [hl], $8A
    inc l
    ld [hl], %00000000
    ; Popped right - frame 1
    SET_HL_TO_ADDRESS wOAM+6, pointBalloon+2
    ld [hl], $8A
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, pointBalloon+5 ; Frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, pointBalloon+2
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ; Reset variables
    ld hl, pointBalloon+4 ; Popping
    ld [hl], a
    ld hl, pointBalloon+6 ; Timer
    ld [hl], a
    ld hl, pointBalloon+5 ; Frame
    ld [hl], a
.end:
    ret

PointBalloonUpdate::
    ; Check if alive
    ld a, [pointBalloon+3] ; Alive
    cp a, 0
    jr z, .popped
    ; Check if we can move
    ld a, [global_timer]
    and	POINT_BALLOON_SPRITE_MOVE_WAIT_TIME
    jr nz, .end
    call FloatPointBalloonUp
    jr .end
.popped:
    ; Check if we need to play popping animation
    ld a, [pointBalloon+4] ; Popping
    cp a, 0
    jr z, .end
    call PopBalloonAnimation
.end:
    ret

DeathOfPointBalloon::
    ; Death
    ld hl, pointBalloon+3 ; Alive
    ld [hl], 0
    ; Points
    ld d, POINT_BALLOON_POINTS
    call AddPoints
    ; Animation trigger
    ld hl, pointBalloon+4 ; Popping
    ld [hl], 1
    ; Sound
    call PopSound
    ret