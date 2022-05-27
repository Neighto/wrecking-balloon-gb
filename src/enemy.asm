INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "balloonConstants.inc"

SECTION "enemy struct vars", HRAM
    ; NOTE: UPDATE ENEMY_STRUCT_SIZE in enemyConstants if we add vars here!
    ; TODO: Can I define a public constant here that is EndStruct - StartStruct instead?

    ; These must be in this order in each enemy
    hEnemyActive:: DB
    hEnemyNumber:: DB

    ; These can be in any order
    hEnemyY:: DB
    hEnemyX:: DB
    hEnemyOAM:: DB
    hEnemyAlive:: DB
    hEnemyDifficulty:: DB
    hEnemyY2:: DB
    hEnemyX2:: DB
    hEnemyDying:: DB
    hEnemyAnimationFrame:: DB
    hEnemyAnimationTimer:: DB
    hEnemyDirectionLeft:: DB
    hEnemySpeed:: DB
    hEnemyParam1:: DB
    hEnemyParam2:: DB
    hEnemyParam3:: DB
    hEnemyParam4:: DB

SECTION "enemy struct", ROM0

InitializeEnemyStructVars::
    xor a ; ld a, 0
    ldh [hEnemyActive], a
    ; ldh [hEnemyNumber], a ; Do not clear
    ldh [hEnemyOAM], a
    ldh [hEnemyAlive], a
    ldh [hEnemyY2], a
    ldh [hEnemyX2], a
    ; ldh [hEnemyDifficulty], a ; Do not clear
    ldh [hEnemyDying], a
    ldh [hEnemyAnimationFrame], a
    ldh [hEnemyAnimationTimer], a
    ldh [hEnemyDirectionLeft], a
    ldh [hEnemySpeed], a 
    ldh [hEnemyParam1], a 
    ldh [hEnemyParam2], a
    ldh [hEnemyParam3], a
    ldh [hEnemyParam4], a
    ret

SECTION "enemy data vars", WRAM0

    wEnemies:: DS ENEMY_DATA_SIZE
    wEnemyOffset:: DB ; Offset for looping through enemy data
    wEnemyOffset2:: DB ; Offset for looping through enemy data within enemy
    wEnemyLoopIndex:: DB
    wEnemyLoopIndex2:: DB

SECTION "enemy", ROM0

InitializeEnemies::
    RESET_IN_RANGE wEnemies, ENEMY_DATA_SIZE
    ret

EnemyUpdate::
    ld a, NUMBER_OF_ENEMIES
    ld [wEnemyLoopIndex], a
    xor a ; ld a, 0
    ld [wEnemyOffset], a
.loop:
    ; Get active state
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    ld a, [hli]
    ldh [hEnemyActive], a
    ; Check active
    ldh a, [hEnemyActive]
    cp a, 0
    jr z, .checkLoop
    ; Get enemy number
    ld a, [hli]
    ldh [hEnemyNumber], a
    ; Check enemy number
.pointBalloon:
    cp a, POINT_BALLOON
    jr nz, .balloonCactus
    call PointBalloonUpdate
    jr .checkLoop
.balloonCactus:
    cp a, BALLOON_CACTUS
    jr nz, .bird
    call BalloonCactusUpdate
    jr .checkLoop
.bird:
    cp a, BIRD
    jr nz, .bomb
    call BirdUpdate
    jr .checkLoop
.bomb:
    cp a, BOMB
    jr nz, .projectile
    call BombUpdate
    jr .checkLoop
.projectile:
    cp a, PROJECTILE
    jr nz, .boss
    call ProjectileUpdate
    jr .checkLoop
.boss:
    cp a, BOSS
    jr nz, .bossNeedle
    call BossUpdate
    jr .checkLoop
.bossNeedle:
    cp a, BOSS_NEEDLE
    jr nz, .anvil
    call BossNeedleUpdate
    jr .checkLoop
.anvil:
    cp a, ANVIL
    jr nz, .balloonAnvil
    call AnvilUpdate
    jr .checkLoop
.balloonAnvil:
    cp a, BALLOON_ANVIL
    jr nz, .checkLoop
    call BalloonAnvilUpdate
    jr .checkLoop
.checkLoop:
    ld a, [wEnemyOffset]
    add a, ENEMY_STRUCT_SIZE
    ld [wEnemyOffset], a    
    ld hl, wEnemyLoopIndex
    dec [hl]
    ld a, [hl]
    cp a, 0
    jr nz, .loop
    ret

EnemyInterCollision::
    ; Call from enemy script
    ; Returns z flag as failed / nz flag as succeeded
    ld a, NUMBER_OF_ENEMIES
    ld [wEnemyLoopIndex2], a
    xor a ; ld a, 0
    ld [wEnemyOffset2], a
.loop:
    ; Get active state
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset2
    ld a, [hli]
    ; Check active
    cp a, 0
    jr z, .checkLoop
    ; Get enemy number
    ld a, [hli]
    ; Check enemy number
.boss:
    cp a, BOSS
    jr nz, .checkLoop
    inc hl
    inc hl
    LD_BC_HL ; hEnemyOAM stored in bc
    SET_HL_TO_ADDRESS wEnemies, bc
    LD_BC_HL ; OAM address stored in bc
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 32
    ld e, 32
    call CollisionCheck
    cp a, 0
    jr z, .checkLoop
    ; nz flag set
    ret
.checkLoop:
    ld a, [wEnemyOffset2]
    add a, ENEMY_STRUCT_SIZE
    ld [wEnemyOffset2], a    
    ld a, [wEnemyLoopIndex2]
    dec a
    ld [wEnemyLoopIndex2], a
    cp a, 0
    jr nz, .loop
.end:
    ; z flag set
    ret

SECTION "enemy animations", ROM0

PopBalloonAnimation::
    ldh a, [hEnemyAnimationFrame]
    cp a, 0
    jr z, .frame0
    ldh a, [hEnemyAnimationTimer]
	inc	a
	ldh [hEnemyAnimationTimer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    ret nz
.canSwitchFrames:
    ldh a, [hEnemyAnimationFrame]
    cp a, 1
    jr z, .frame1
    cp a, 2
    jr z, .clear
    ret
.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    inc l
    ld [hl], OAMF_PAL0
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jr .endFrame
.frame1:
    ; Popped left - frame 1
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
    ld [hl], POP_BALLOON_FRAME_1_TILE
    inc l
    ld [hl], OAMF_PAL0
    ; Popped right - frame 1
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], POP_BALLOON_FRAME_1_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jr .endFrame
.clear:
    xor a
    ldh [hEnemyDying], a
    ret
.endFrame:
    ldh a, [hEnemyAnimationFrame]
    inc a 
    ldh [hEnemyAnimationFrame], a
    ret

ExplosionAnimation::
    ldh a, [hEnemyAnimationFrame]
    cp a, 0
    jr z, .frame0
    ldh a, [hEnemyAnimationTimer]
	inc	a
	ldh [hEnemyAnimationTimer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    ret nz
.canSwitchFrames:
    ldh a, [hEnemyAnimationFrame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .frame2
    cp a, 3
    jp z, .frame3
    cp a, 4
    jp z, .clear
    ret
.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, hEnemyOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, hEnemyOAM
    ld [hl], POP_BALLOON_FRAME_0_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jp .endFrame
.frame1:
    ; Explosion left
    SET_HL_TO_ADDRESS wOAM+1, hEnemyOAM
    ldh a, [hEnemyX]
    sub 4
    ld [hli], a
    ld a, BOMB_EXPLOSION_TILE_1
    ld [hl], a
    ; Explosion middle
    SET_HL_TO_ADDRESS wOAM+5, hEnemyOAM
    ldh a, [hEnemyX]
    add 4
    ld [hli], a
    ld a, BOMB_EXPLOSION_TILE_2
    ld [hl], a
    ; Explosion right
    SET_HL_TO_ADDRESS wOAM+9, hEnemyOAM
    ldh a, [hEnemyX]
    add 12
    ld [hli], a
    ld a, BOMB_EXPLOSION_TILE_1
    ld [hli], a
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jr .endFrame
.frame2:
    ; Flip palette
    SET_HL_TO_ADDRESS wOAM+3, hEnemyOAM
    ld [hl], OAMF_PAL1
    SET_HL_TO_ADDRESS wOAM+7, hEnemyOAM
    ld [hl], OAMF_PAL1
    SET_HL_TO_ADDRESS wOAM+11, hEnemyOAM
    ld [hl], OAMF_PAL1 | OAMF_XFLIP
    jr .endFrame
.frame3:
    ; Flip palette
    SET_HL_TO_ADDRESS wOAM+3, hEnemyOAM
    ld [hl], OAMF_PAL0
    SET_HL_TO_ADDRESS wOAM+7, hEnemyOAM
    ld [hl], OAMF_PAL0
    SET_HL_TO_ADDRESS wOAM+11, hEnemyOAM
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    jr .endFrame
.clear:
    xor a
    ldh [hEnemyDying], a
    ret 
.endFrame:
    ldh a, [hEnemyAnimationFrame]
    inc a 
    ldh [hEnemyAnimationFrame], a
    ret