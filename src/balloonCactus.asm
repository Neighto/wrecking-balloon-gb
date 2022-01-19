INCLUDE "points.inc"
INCLUDE "balloonConstants.inc"
INCLUDE "tileConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

BALLOON_CACTUS_STRUCT_SIZE EQU 15
BALLOON_CACTUS_STRUCT_AMOUNT EQU 2
BALLOON_CACTUS_DATA_SIZE EQU BALLOON_CACTUS_STRUCT_SIZE * BALLOON_CACTUS_STRUCT_AMOUNT
BALLOON_CACTUS_OAM_SPRITES EQU 4
BALLOON_CACTUS_OAM_BYTES EQU BALLOON_CACTUS_OAM_SPRITES * 4
BALLOON_CACTUS_MOVE_TIME EQU %00000011
BALLOON_CACTUS_COLLISION_TIME EQU %00001000

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

SetStruct:
    ; Argument hl = start of free enemy struct
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
    ret

SpawnBalloonCactus::
    push af
    push hl
    push de
    push bc
    ld hl, balloonCactus
    ld d, BALLOON_CACTUS_STRUCT_AMOUNT
    ld e, BALLOON_CACTUS_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    cp a, 0
    jp z, .end
.availableSpace:
    ld b, BALLOON_CACTUS_OAM_SPRITES
	call RequestOAMSpace ; b now contains OAM address
    cp a, 0
    jr z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ld [wEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ld [wEnemyActive], a
    ld [wEnemyAlive], a
    ld [wEnemyFallingSpeed], a
    ld a, [wEnemyY]
    add 16
    ld [wEnemyY2], a
    ld a, [wEnemyX]
    ld [wEnemyX2], a
    cp a, SCRN_X / 2
    jr c, .isLeftside
    ld [wEnemyRightside], a
.isLeftside:
.balloonLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
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
    ld [hl], $10
    inc l
    ld [hl], OAMF_PAL0
.cactusRight:
    inc l
    ld a, [wEnemyY2]
    ld [hli], a
    ld a, [wEnemyX2]
    add 8
    ld [hli], a
    ld [hl], $10
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop bc
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
    call ClearCactus
    call ClearBalloon
    call InitializeEnemyStructVars
    ret

PopBalloonAnimation:
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr z, .frame0
    ld a, [wEnemyPoppingTimer]
	inc	a
	ld [wEnemyPoppingTimer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    ret nz
.canSwitchFrames:
    ld a, [wEnemyPoppingFrame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret
.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    inc l
    ld [hl], OAMF_PAL0
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jr .endFrame
.frame1:
    ; Popped left - frame 1
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], POP_BALLOON_FRAME_1_TILE
    inc l
    ld [hl], OAMF_PAL0
    ; Popped right - frame 1
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], POP_BALLOON_FRAME_1_TILE
    inc l
    ld [hl], OAMF_XFLIP
    jr .endFrame
.clear:
    ; Remove sprites
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], EMPTY_TILE
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], EMPTY_TILE
    ; Reset variables
    xor a
    ld [wEnemyPopping], a
    ret
.endFrame:
    inc a 
    ld [wEnemyPoppingFrame], a
.end:
    ret

CactusFalling:
    ld a, [wEnemyFallingTimer]
    inc a
    ld [wEnemyFallingTimer], a
    and CACTUS_FALLING_TIME
    ret nz
    ; Check offscreen
    ld a, SCRN_X
    ld hl, wEnemyY2
    cp a, [hl]
    jr c, .offScreen
.falling:
    ld a, [wEnemyDelayFallingTimer]
    inc a
    ld [wEnemyDelayFallingTimer], a
    cp a, CACTUS_DELAY_FALLING_TIME
    jr c, .skipAcceleration
    xor a ; ld a, 0
    ld [wEnemyDelayFallingTimer], a
    ld a, [wEnemyFallingSpeed]
    add a, a
    ld [wEnemyFallingSpeed], a
.skipAcceleration:
    INCREMENT_POS wEnemyY2, [wEnemyFallingSpeed]
    call UpdateCactusPosition
    ret
.offScreen:
    call Clear
.end:
    ret

UpdateBalloonPosition:
.balloonLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    inc l
    inc l
.balloonRight:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hl], a
    ret

UpdateCactusPosition:
.cactusLeft:
    SET_HL_TO_ADDRESS wOAM+8, wEnemyOAM
    ld a, [wEnemyY2]
    ld [hli], a
    ld a, [wEnemyX2]
    ld [hli], a
    inc l
    inc l
.cactusRight:
    ld a, [wEnemyY2]
    ld [hli], a
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
    ld [hl], $12
    SET_HL_TO_ADDRESS wOAM+14, wEnemyOAM
    ld [hl], $12
    ; Sound
    call PopSound
    ret
    
CollisionBalloonCactus:
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    xor a ; ld a, 0
    call CollisionCheck
    cp a, 0
    call nz, DeathOfBalloonCactus
.checkHitPlayer:
    ld a, [wPlayerAlive]
    cp a, 0
    ret z
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+8, wEnemyOAM
    xor a ; ld a, 0
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
    ret

BalloonCactusUpdate::
    ld bc, BALLOON_CACTUS_STRUCT_AMOUNT
    xor a ; ld a, 0
    ld [wEnemyOffset], a
.loop:
    ; Get active state
    SET_HL_TO_ADDRESS balloonCactus, wEnemyOffset
    ld a, [hli]
    ld [wEnemyActive], a
    ; Check active
    ld a, [wEnemyActive]
    cp a, 0
    jp z, .checkLoopSkipSet
    ; Get rest of struct
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
    ; Check if alive
    ld a, [wEnemyAlive]
    cp a, 0
    jr z, .popped
.isAlive:
    ; Check if we can move
    ld a, [global_timer]
    and	BALLOON_CACTUS_MOVE_TIME
    call z, Move
    ; Check if we can collide
    ld a, [global_timer]
    and	BALLOON_CACTUS_COLLISION_TIME
    push bc
    call z, CollisionBalloonCactus
    ; Check offscreen
    ld a, [wEnemyX]
    ld b, a
    call OffScreenXEnemies
    pop bc
    cp a, 0
    jr z, .checkLoop
.offScreen:
    call Clear
    jr .checkLoop
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
.checkLoopSkipSet:
    ld a, [wEnemyOffset]
    add a, BALLOON_CACTUS_STRUCT_SIZE
    ld [wEnemyOffset], a    
    dec bc
    ld a, b
    or a, c
    jp nz, .loop
    ret