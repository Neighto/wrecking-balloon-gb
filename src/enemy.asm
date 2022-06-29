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
    hEnemyVariant:: DB
    hEnemyDying:: DB
    hEnemyHitEnemy:: DB
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
    ; ldh [hEnemyVariant], a ; Do not clear
    ldh [hEnemyDying], a
    ldh [hEnemyHitEnemy], a
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
    ld hl, wEnemies
    ld bc, ENEMY_DATA_SIZE
    call ResetHLInRange
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
    jr nz, .balloonCarrier
    call PointBalloonUpdate
    jr .checkLoop
.balloonCarrier:
    cp a, BALLOON_CARRIER
    jr nz, .bird
    call BalloonCarrierUpdate
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
    jr nz, .explosion
    call AnvilUpdate
    jr .checkLoop
.explosion:
    cp a, EXPLOSION
    jr nz, .checkLoop
    call ExplosionUpdate
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
    jp z, .checkLoop
    ; Get enemy number
    ld a, [hli]
    ; Check enemy number
.pointBalloon:
    cp a, POINT_BALLOON
    jr nz, .bird
    inc hl
    inc hl
    LD_BC_HL ; hEnemyOAM stored in bc
    SET_HL_TO_ADDRESS wOAM, bc ; OAM address stored in hl
    SET_BC_TO_ADDRESS wOAM, hEnemyOAM ; OAM address stored in bc
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    jp z, .checkLoop
    SET_HL_TO_ADDRESS wEnemies+7, wEnemyOffset2 ; hEnemyHitEnemy
    ld a, 1 
    ld [hl], a
    cp a, 0
    ; nz flag set
    ret
.bird:
    cp a, BIRD
    jr nz, .bomb
    inc hl
    inc hl
    LD_BC_HL ; hEnemyOAM stored in bc
    SET_HL_TO_ADDRESS wOAM, bc ; OAM address stored in hl
    SET_BC_TO_ADDRESS wOAM, hEnemyOAM ; OAM address stored in bc
    ld d, 24
    ld e, 8
    call CollisionCheck
    cp a, 0
    jp z, .checkLoop
    SET_HL_TO_ADDRESS wEnemies+8, wEnemyOffset2 ; hEnemyHitEnemy
    ld a, 1 
    ld [hl], a
    cp a, 0
    ; nz flag set
    ret
.bomb:
    cp a, BOMB
    jr nz, .boss
    inc hl
    inc hl
    LD_BC_HL ; hEnemyOAM stored in bc
    SET_HL_TO_ADDRESS wOAM, bc ; OAM address stored in hl
    SET_BC_TO_ADDRESS wOAM, hEnemyOAM ; OAM address stored in bc
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr z, .checkLoop
    SET_HL_TO_ADDRESS wEnemies+7, wEnemyOffset2 ; hEnemyHitEnemy
    ld a, 1 
    ld [hl], a
    cp a, 0
    ; nz flag set
    ret
.boss:
    cp a, BOSS
    jr nz, .checkLoop
    inc hl
    inc hl
    LD_BC_HL ; hEnemyOAM stored in bc
    SET_HL_TO_ADDRESS wOAM, bc ; OAM address stored in hl
    SET_BC_TO_ADDRESS wOAM, hEnemyOAM ; OAM address stored in bc
    ld d, 32
    ld e, 24
    call CollisionCheck
    cp a, 0
    jr z, .checkLoop
    SET_HL_TO_ADDRESS wEnemies+7, wEnemyOffset2 ; hEnemyHitEnemy
    ld a, 1 
    ld [hl], a
    cp a, 0
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
    jp nz, .loop
.end:
    ; z flag set
    ret

ClearEnemy::
    ; bc = Enemy OAM Bytes
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    call ResetHLInRange
    call InitializeEnemyStructVars
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