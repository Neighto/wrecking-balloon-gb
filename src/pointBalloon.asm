INCLUDE "balloonConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

POINT_BALLOON_OAM_SPRITES EQU 2
POINT_BALLOON_OAM_BYTES EQU POINT_BALLOON_OAM_SPRITES * 4
POINT_BALLOON_MOVE_TIME EQU %00000001
POINT_BALLOON_COLLISION_TIME EQU %00001000

POINT_BALLOON_POINTS EQU 50

SECTION "point balloon", ROMX

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
    ld [hl], a
    ret

SpawnPointBalloon::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    cp a, 0
    jr z, .end
.availableSpace:
    ld b, POINT_BALLOON_OAM_SPRITES
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
    ld a, POINT_BALLOON
    ld [wEnemyNumber], a
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
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
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
    jr z, .frame1
    cp a, 2
    jr z, .clear
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
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jr .endFrame
.clear:
    call Clear
    ret
.endFrame:
    ld a, [wEnemyPoppingFrame]
    inc a 
    ld [wEnemyPoppingFrame], a
    ret

Clear:
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
    call InitializeEnemyStructVars
    ret

Move:
    ; Move up
    ld a, [wEnemyY]
    dec a
    ld [wEnemyY], a
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

DeathOfPointBalloon:
    ; Death
    xor a ; ld a, 0
    ld [wEnemyAlive], a
    ; Points
    ld d, POINT_BALLOON_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1 
    ld [wEnemyPopping], a
    ; Sound
    call PopSound
    ret

CollisionPointBalloon:
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr z, .checkHitByBullet
    call DeathOfPointBalloon
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .end
    call DeathOfPointBalloon
    call ClearBullet
.end:
    ret

PointBalloonUpdate::
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
    ld a, [hl]
    ld [wEnemyPoppingTimer], a
    ; Check alive
    ld a, [wEnemyAlive]
    cp a, 0
    jr z, .popped
.isAlive:
    ; Check if we can move
    ldh a, [hGlobalTimer]
    and	POINT_BALLOON_MOVE_TIME
    call z, Move
    ; Check if we can collide
    ldh a, [hGlobalTimer]
    and	POINT_BALLOON_COLLISION_TIME
    push bc
    call z, CollisionPointBalloon
    ; Check offscreen
    ld a, [wEnemyY]
    ld b, a
    call OffScreenYEnemies
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
    jr z, .checkLoop
    call PopBalloonAnimation
.checkLoop:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret