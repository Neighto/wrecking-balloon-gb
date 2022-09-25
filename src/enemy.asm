INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "enemy struct vars", HRAM
    ; NOTE: UPDATE ENEMY_STRUCT_SIZE in enemyConstants if we add vars here!
    ; TODO: Can I define a public constant here that is EndStruct - StartStruct instead?

    ; These must be in this order in each enemy
    hEnemyFlags:: DB ; BIT #: [0=active] [1=alive] [2=dying] [3=direction] [4=hit enemy] [5-7=generic]
    hEnemyNumber:: DB
    hEnemyY:: DB
    hEnemyX:: DB
    hEnemyOAM:: DB
    ; These can be in any order in an enemy
    hEnemyAnimationFrame:: DB
    hEnemyAnimationTimer:: DB
    hEnemyParam1:: DB
    hEnemyParam2:: DB
    hEnemyVariant:: DB

SECTION "enemy struct", ROM0

InitializeEnemyStructVars::
    xor a ; ld a, 0
    ldh [hEnemyFlags], a
    ; ldh [hEnemyNumber], a ; Do not clear
    ; ldh [hEnemyY], a
    ; ldh [hEnemyX], a
    ldh [hEnemyOAM], a
    ldh [hEnemyAnimationFrame], a
    ldh [hEnemyAnimationTimer], a
    ldh [hEnemyParam1], a 
    ldh [hEnemyParam2], a
    ; ldh [hEnemyVariant], a ; Do not clear
    ret

SECTION "enemy data vars", WRAM0

    wEnemies:: DS ENEMY_DATA_SIZE
    wEnemyOffset:: DB ; Offset for looping through enemy data
    wEnemyOffset2:: DB ; Offset for looping through enemy data within enemy
    wEnemyOffset3:: DB ; Offset for looping through enemy data for balloon carrier
    wEnemyLoopIndex:: DB
    wEnemyLoopIndex2:: DB
    wEnemyLoopIndex3:: DB

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
    ; Get flags
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    ld a, [hli]
    ldh [hEnemyFlags], a
    ; Check active
    and ENEMY_FLAG_ACTIVE_MASK
    cp a, 0
    jr z, .checkLoop
    ; Get enemy number
    ld a, [hli]
    ldh [hEnemyNumber], a
    ; Get enemy Y
    ld a, [hli]
    ldh [hEnemyY], a
    ; Get enemy X
    ld a, [hli]
    ldh [hEnemyX], a
    ; Get enemy OAM
    ld a, [hli]
    ldh [hEnemyOAM], a
    ; Check enemy number
    ld a, [hEnemyNumber]
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
    jr nz, .bossNeedle
    call ProjectileUpdate
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
    jp nz, .loop
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
    ld d, a
    ; Get collision OAM addresses
    inc hl
    inc hl
    SET_BC_TO_ADDRESS wOAM, hl
    LD_HL_BC ; OAM address stored in hl
    SET_BC_TO_ADDRESS wOAM, hEnemyOAM ; OAM address stored in bc
    ; Check enemy number
    ld a, d
.pointBalloon:
    cp a, POINT_BALLOON
    jr nz, .bird
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr z, .checkLoop
    jr .hitEnemy
.bird:
    cp a, BIRD
    jr nz, .bomb
    ld d, 24
    ld e, 8
    call CollisionCheck
    cp a, 0
    jr z, .checkLoop
    jr .hitEnemy
.bomb:
    cp a, BOMB
    jr nz, .carrier
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr z, .checkLoop
    jr .hitEnemy
.carrier:
    cp a, BALLOON_CARRIER
    jr nz, .checkLoop
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr z, .checkLoop
    jr .hitEnemy
.checkLoop:
    ld a, [wEnemyOffset2]
    add a, ENEMY_STRUCT_SIZE
    ld [wEnemyOffset2], a    
    ld a, [wEnemyLoopIndex2]
    dec a
    ld [wEnemyLoopIndex2], a
    cp a, 0
    jp nz, .loop
    ; z flag set
    ret
.hitEnemy:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset2
    set ENEMY_FLAG_HIT_ENEMY_BIT, [hl]
    ld a, [hl]
    cp a, 0
    ; nz flag set
    ret

FindBalloonCarrier::
    ; Returns z flag as failed / nz flag as succeeded
    ld a, NUMBER_OF_ENEMIES
    ld [wEnemyLoopIndex3], a
    xor a ; ld a, 0
    ld [wEnemyOffset3], a
.loop:
    ; Get enemy number
    SET_HL_TO_ADDRESS wEnemies+1, wEnemyOffset3
    ld a, [hl]
    cp a, BALLOON_CARRIER
    jr nz, .checkLoop
    or 1
    ; nz flag set
    ret
.checkLoop:
    ld a, [wEnemyOffset3]
    add a, ENEMY_STRUCT_SIZE
    ld [wEnemyOffset3], a
    ld a, [wEnemyLoopIndex3]
    dec a
    ld [wEnemyLoopIndex3], a
    cp a, 0
    jr nz, .loop
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
    and POPPING_BALLOON_ANIMATION_TIME
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
    ldh a, [hEnemyFlags]
    res ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
    ret
.endFrame:
    ldh a, [hEnemyAnimationFrame]
    inc a 
    ldh [hEnemyAnimationFrame], a
    ret