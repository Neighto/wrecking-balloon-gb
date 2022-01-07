INCLUDE "points.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

BALLOON_CACTUS_STRUCT_SIZE EQU 15
BALLOON_CACTUS_STRUCT_AMOUNT EQU 2
BALLOON_CACTUS_DATA_SIZE EQU BALLOON_CACTUS_STRUCT_SIZE * BALLOON_CACTUS_STRUCT_AMOUNT

SECTION "balloon cactus vars", WRAM0
    balloonCactus:: DS BALLOON_CACTUS_DATA_SIZE

SECTION "balloon cactus", ROMX

InitializeBalloonCactus::
    push hl
    push bc
    RESET_IN_RANGE balloonCactus, BALLOON_CACTUS_DATA_SIZE
    pop bc
    pop hl
    ret

GetStruct:
    ; Argument hl = start of free enemy struct
    push af
    ld a, [hli]
    ld [wEnemyActive], a
    ld a, [hli]
    ld [wEnemyY], a
    ld a, [hli]
    ld [wEnemyX], a
    ld a, [hli]
    ld [wEnemyOAM], a
    ld a, [hli]
    ld [wEnemyAlive], a
    ld a, [hli]
    ld [wEnemyPopping], a
    ld a, [hli]
    ld [wEnemyPoppingFrame], a
    ld a, [hli]
    ld [wEnemyPoppingTimer], a
    ld a, [hli]
    ld [wEnemyRightside], a
    ld a, [hli]
    ld [wEnemyY2], a
    ld a, [hli]
    ld [wEnemyX2], a
    ld a, [hli]
    ld [wEnemyFalling], a 
    ld a, [hli]
    ld [wEnemyFallingSpeed], a 
    ld a, [hli]
    ld [wEnemyFallingTimer], a
    ld a, [hl]
    ld [wEnemyDelayFallingTimer], a
    pop af
    ret

SetStruct:
    ; Argument hl = start of free enemy struct
    push af
    ld a, [wEnemyActive]
    ld [hli], a
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld a, [wEnemyOAM]
    ld [hli], a
    ld a, [wEnemyAlive]
    ld [hli], a
    ld a, [wEnemyPopping]
    ld [hli], a
    ld a, [wEnemyPoppingFrame]
    ld [hli], a
    ld a, [wEnemyPoppingTimer]
    ld [hli], a
    ld a, [wEnemyRightside]
    ld [hli], a
    ld a, [wEnemyY2]
    ld [hli], a
    ld a, [wEnemyX2]
    ld [hli], a
    ld a, [wEnemyFalling]
    ld [hli], a
    ld a, [wEnemyFallingSpeed]
    ld [hli], a
    ld a, [wEnemyFallingTimer]
    ld [hli], a
    ld a, [wEnemyDelayFallingTimer]
    ld [hl], a
    pop af
    ret

SpawnBalloonCactus::
    ; Argument b = Y spawn
    ; Argument c = X spawn
    push af
    push hl
    push de
    ld hl, balloonCactus
    ld d, BALLOON_CACTUS_STRUCT_AMOUNT
    ld e, BALLOON_CACTUS_STRUCT_SIZE
    call RequestRAMSpace ; Returns HL
    LD_DE_HL
    cp a, 0
    jp z, .end
.availableSpace:
    call InitializeEnemyStructVars
    call SetStruct
    LD_HL_BC ; Arguments now in HL
    ld b, 4
	call RequestOAMSpace
    cp a, 0
    jr z, .end
.availableOAMSpace:
    ld a, b
    ld [wEnemyOAM], a
    ld a, 1
    ld [wEnemyActive], a
    ld [wEnemyAlive], a
    ld [wEnemyFallingSpeed], a
    ld a, h
    ld [wEnemyY], a
    add 16
    ld [wEnemyY2], a
    ld a, l
    ld [wEnemyX], a
    ld [wEnemyX2], a
    cp a, SCRN_X / 2
    jr c, .isLeftside
    ld [wEnemyRightside], a
.isLeftside:
.balloonLeft:
    SET_HL_TO_ADDRESS_WITH_BC wOAM, wEnemyOAM ; DONT FORGET WITH BC
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1
.balloonRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1 | OAMF_XFLIP
.cactusLeft:
    inc l
    ld a, [wEnemyY2]
    ld [hli], a
    ld a, [wEnemyX2]
    ld [hli], a
    ld [hl], $86
    inc l
    ld [hl], %00000000
.cactusRight:
    inc l
    ld a, [wEnemyY2]
    ld [hli], a
    ld a, [wEnemyX2]
    add 8
    ld [hli], a
    ld [hl], $86
    inc l
    ld [hl], OAMF_XFLIP
.setStruct:
    LD_HL_DE
    call SetStruct
.end:
    pop de
    pop hl
    pop af
    ret

ClearCactus:
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM+8, wEnemyOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret 

ClearBalloon:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

Clear:
    ; xor a ; ld a, 0
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hli], a
    ; ld [hl], a
    call ClearCactus
    call ClearBalloon
    call InitializeEnemyStructVars
    ret

FallCactusDown:
    ld hl, wEnemyFallingSpeed
    ld a, [wEnemyDelayFallingTimer]
    inc a
    ld [wEnemyDelayFallingTimer], a
    cp a, CACTUS_DELAY_FALLING_TIME
    jr c, .skipAcceleration
    xor a ; ld a, 0
    ld [wEnemyDelayFallingTimer], a
    ld a, [hl]
    add a, a
    ld [hl], a
.skipAcceleration
    INCREMENT_POS wEnemyY2, [wEnemyFallingSpeed]
    ret

PopBalloonAnimation:
    ; Check what frame we are on
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr z, .frame0

    ld a, [wEnemyPoppingTimer]
	inc	a
	ld [wEnemyPoppingTimer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    jp nz, .end
    ; Can do next frame
    ; Check what frame we are on
    ld a, [wEnemyPoppingFrame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $88
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, wEnemyPoppingFrame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], $8A
    inc l
    ld [hl], %00000000
    ; Popped right - frame 1
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $8A
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, wEnemyPoppingFrame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], $00
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $00
    ; Reset variables
    ld hl, wEnemyPopping
    ld [hl], a
    ld hl, wEnemyPoppingTimer
    ld [hl], a
    ld hl, wEnemyPoppingFrame
    ld [hl], a
.end:
    ret

CactusFalling:
    ld a, [wEnemyFallingTimer]
    inc a
    ld [wEnemyFallingTimer], a
    and CACTUS_FALLING_TIME
    jr nz, .end
    ; Can we move cactus down
    ld a, 160
    ld hl, wEnemyY2
    cp a, [hl]
    jr c, .offScreen
    call FallCactusDown
    call UpdateCactusPosition
    ret
.offScreen:
    call Clear
.end
    ret

UpdateBalloonPosition:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ; Update Y
    ld a, [wEnemyY]
    ld [hli], a
    ; Update X
    ld a, [wEnemyX]
    ld [hl], a
  
    SET_HL_TO_ADDRESS wOAM+4, wEnemyOAM
    ; Update Y
    ld a, [wEnemyY]
    ld [hli], a
    ; Update X
    ld a, [wEnemyX]
    add 8
    ld [hl], a
    ret

UpdateCactusPosition:
    SET_HL_TO_ADDRESS wOAM+8, wEnemyOAM
    ; Update Y
    ld a, [wEnemyY2]
    ld [hli], a
    ; Update X
    ld a, [wEnemyX2]
    ld [hl], a
  
    SET_HL_TO_ADDRESS wOAM+12, wEnemyOAM
    ; Update Y
    ld a, [wEnemyY2]
    ld [hli], a
    ; Update X
    ld a, [wEnemyX2]
    add 8
    ld [hl], a
    ret

Move:
    ld a, [wEnemyRightside]
    cp a, 0
    jr z, .isLeftside
    DECREMENT_POS wEnemyX, 1
    DECREMENT_POS wEnemyX2, 1
    jr .updatePosition
.isLeftside:
    INCREMENT_POS wEnemyX, 1
    INCREMENT_POS wEnemyX2, 1
.updatePosition:
    call UpdateBalloonPosition
    call UpdateCactusPosition
    ret

DeathOfBalloonCactus:
    ; Death
    xor a ; ld a, 0
    ld [wEnemyAlive], a
    ; Points
    ld d, ENEMY_CACTUS_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1
    ld [wEnemyPopping], a
    ld [wEnemyFalling], a
    ; Screaming cactus
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], $8E
    SET_HL_TO_ADDRESS wOAM+14, wEnemyOAM
    ld [hl], $8E
    ; Sound
    call PopSound
    ret
    
CollisionBalloonCactus:
    push bc
    push hl
    push af
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    xor a ; ld a, 0
    call CollisionCheck
    cp a, 0
    call nz, DeathOfBalloonCactus
.checkHitPlayer:
    ld a, [player_alive]
    cp a, 0
    jr z, .end
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+8, wEnemyOAM
    xor a ; ld a, 0
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
.end:
    pop af
    pop hl
    pop bc
    ret

BalloonCactusUpdate::
    push bc
    push de
    push hl
    push af
    ld bc, BALLOON_CACTUS_STRUCT_AMOUNT
    xor a ; ld a, 0
    ld [wEnemyOffset], a ; TODO, we can remove enemy offset this if we optimize this code
.loop:
    SET_HL_TO_ADDRESS balloonCactus, wEnemyOffset
    call GetStruct

    ; Check active
    ld a, [wEnemyActive]
    cp a, 0
    jr z, .checkLoop
    ; Check if alive
    ld a, [wEnemyAlive]
    cp a, 0
    jr z, .popped
.isAlive:
    ; Check if we can move and collide
    ld a, [global_timer]
    and	ENEMY_SPRITE_MOVE_WAIT_TIME
    jr nz, .checkLoop
    call Move
    call CollisionBalloonCactus
    ; Check offscreen
    push bc
    ld a, [wEnemyX]
    ld b, a
    call OffScreenXEnemies
    pop bc
    cp a, 0
    jr z, .checkLoop
.offScreen:
    call Clear
    jr z, .checkLoop
.popped:
    ; Check if we need to play popping animation
    ld a, [wEnemyPopping]
    cp a, 0
    jr z, .notPopping
    call PopBalloonAnimation
.notPopping:
    ; Check if we need to drop the cactus
    ld a, [wEnemyFalling]
    cp a, 0
    jr z, .checkLoop
    call CactusFalling
.checkLoop:
    SET_HL_TO_ADDRESS balloonCactus, wEnemyOffset
    call SetStruct
    ld a, [wEnemyOffset]
    add a, BALLOON_CACTUS_STRUCT_SIZE
    ld [wEnemyOffset], a    
    dec bc
    ld a, b
    or a, c
    jr nz, .loop
.end:
    xor a ; ld a, 0
    ld [wEnemyOffset], a
    pop af
    pop hl
    pop de
    pop bc
    ret