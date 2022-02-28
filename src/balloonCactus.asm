INCLUDE "balloonConstants.inc"
INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BALLOON_CACTUS_OAM_SPRITES EQU 4
BALLOON_CACTUS_MOVE_TIME EQU %00000011
BALLOON_CACTUS_COLLISION_TIME EQU %00001000
BALLOON_CACTUS_TILE EQU $14
BALLOON_CACTUS_SCREAMING_TILE EQU $16

ENEMY_CACTUS_POINTS EQU 15

SECTION "balloon cactus", ROMX

SetStruct:
    ; Argument hl = start of free enemy struct
    ld a, [wEnemyActive]
    ld [hli], a
    ld a, [wEnemyNumber]
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
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
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
    ld a, BALLOON_CACTUS
    ld [wEnemyNumber], a
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
    ld [hl], BALLOON_CACTUS_TILE
    inc l
    ld [hl], OAMF_PAL0
.cactusRight:
    inc l
    ld a, [wEnemyY2]
    ld [hli], a
    ld a, [wEnemyX2]
    add 8
    ld [hli], a
    ld [hl], BALLOON_CACTUS_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret

ClearCactus:
    SET_HL_TO_ADDRESS wOAM+8, wEnemyOAM
    xor a ; ld a, 0
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
    xor a ; ld a, 0
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
    ld a, [wEnemyPoppingFrame]
    inc a 
    ld [wEnemyPoppingFrame], a
.end:
    ret

CactusFallingCollision:
    ; Costly and awkward operation but worth it for the fun
;     push bc
; .checkBird:
;     xor a ; ld a, 0
;     ld [wEnemyOffset2], a
;     ld bc, 2 ; BIRD_STRUCT_AMOUNT
; .birdLoop:
;     SET_HL_TO_ADDRESS bird, wEnemyOffset2+4 ; Alive
;     ld a, [hl]
;     cp a, 0
;     jr z, .checkBirdLoop
; .isAlive:
;     push bc
;     SET_HL_TO_ADDRESS wOAM+8, wEnemyOAM
;     LD_BC_HL
;     SET_HL_TO_ADDRESS bird+3, wEnemyOffset2 ; OAM
;     ld a, [hl]
;     ld hl, wOAM
;     ADD_TO_HL a
;     ld e, 8
;     call CollisionCheck
;     pop bc
;     cp a, 0
;     jr z, .checkBirdLoop
; .hitBird:
;     SET_HL_TO_ADDRESS bird+8, wEnemyOffset2 ; To Die
;     ld [hl], 1
; .checkBirdLoop:
;     ld a, [wEnemyOffset2]
;     add a, 9;BIRD_STRUCT_SIZE
;     ld [wEnemyOffset2], a
;     dec bc
;     ld a, b
;     or a, c
;     jr nz, .birdLoop
; .end:
;     pop bc
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
    call CactusFallingCollision

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

BalloonCactusUpdate::
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

.checkAlive:
    ld a, [wEnemyAlive]
    cp a, 0
    jp z, .popped
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	BALLOON_CACTUS_MOVE_TIME
    jr nz, .endMove
.canMove:
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
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	BALLOON_CACTUS_COLLISION_TIME
    jr nz, .endCollision
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+8, wEnemyOAM
    ld e, 16
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr nz, .deathOfBalloonCactus
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call ClearBullet
.deathOfBalloonCactus:
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
    ld [hl], BALLOON_CACTUS_SCREAMING_TILE
    SET_HL_TO_ADDRESS wOAM+14, wEnemyOAM
    ld [hl], BALLOON_CACTUS_SCREAMING_TILE
    ; Sound
    call PopSound
.endCollision:

.checkOffscreen:
    ld a, [wEnemyX]
    ld b, a
    ld a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreen
    ld a, SCRN_VX - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreen
.offscreen:
    call Clear
    jr .setStruct
.endOffscreen:

.popped:
    ld a, [wEnemyPopping]
    cp a, 0
    call nz, PopBalloonAnimation
    ld a, [wEnemyFalling]
    cp a, 0
    call nz, CactusFalling
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret