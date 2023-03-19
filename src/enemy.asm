INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "playerConstants.inc"
INCLUDE "tileConstants.inc"

SECTION "enemy struct vars", HRAM
    ; NOTE: UPDATE ENEMY_STRUCT_SIZE in enemyConstants if we add vars here!
    ; TODO: Can I define a public constant here that is EndStruct - StartStruct instead?

    ; These must be in this order in each enemy
hEnemyFlags:: DB ; BIT #: [0=active] [1=alive] [2=dying] [3=direction] [4=hit enemy] [5-7=generic]
hEnemyNumber:: DB
hEnemyY:: DB
hEnemyX:: DB
hEnemyOAM:: DB
hEnemyVariant:: DB
hEnemyParam1:: DB
hEnemyParam2:: DB
hEnemyParam3:: DB

SECTION "enemy struct", ROM0

InitializeEnemyStructVars::
    xor a ; ld a, 0
    ldh [hEnemyFlags], a
    ; ldh [hEnemyNumber], a ; Do not clear
    ; ldh [hEnemyY], a
    ; ldh [hEnemyX], a
    ldh [hEnemyOAM], a
    ; ldh [hEnemyVariant], a ; Do not clear
    ldh [hEnemyParam1], a 
    ldh [hEnemyParam2], a
    ldh [hEnemyParam3], a
    ret

SetEnemyStruct::
    ; Argument hl = start of free enemy struct
    ldh a, [hEnemyFlags]
    ld [hli], a
    ldh a, [hEnemyNumber]
    ld [hli], a
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ldh a, [hEnemyOAM]
    ld [hli], a
    ldh a, [hEnemyVariant]
    ld [hli], a
    ldh a, [hEnemyParam1]
    ld [hli], a
    ldh a, [hEnemyParam2]
    ld [hli], a
    ldh a, [hEnemyParam3]
    ld [hl], a
    ret

SECTION "enemy data vars (wram)", WRAM0
wEnemies:: DS ENEMY_DATA_SIZE

SECTION "enemy data vars (hram)", HRAM
hEnemyOffset:: DB ; Offset for looping through enemy data
hEnemyOffset2:: DB ; Offset for looping through enemy data within enemy
hEnemyOffset3:: DB ; Offset for looping through enemy data for balloon carrier
hEnemyLoopIndex:: DB
hEnemyLoopIndex2:: DB
hEnemyLoopIndex3:: DB

SECTION "enemy", ROM0

InitializeEnemies::
    ld hl, wEnemies
    ld bc, ENEMY_DATA_SIZE
    jp ResetHLInRange

EnemyUpdate::

    ; Only handle half the enemies per call
.handleEnemiesHalf:
    ldh a, [hGlobalTimer]
    and %00000001
    jr nz, .secondHalf
.firstHalf:
    xor a ; ld a, 0
    jr .setOffsetAndLoopIndex
.secondHalf:
    ld a, ENEMY_STRUCT_SIZE * NUMBER_OF_ENEMIES_HALF
    ; jr .setOffsetAndLoopIndex
.setOffsetAndLoopIndex:
    ldh [hEnemyOffset], a
    ld a, NUMBER_OF_ENEMIES_HALF
    ldh [hEnemyLoopIndex], a
.endHandleEnemiesHalf:

.loop:
    ; Get flags
    ld hl, wEnemies
    ldh a, [hEnemyOffset]
    ADD_A_TO_HL
    ld a, [hli]
    ldh [hEnemyFlags], a
    ; Check active
    and ENEMY_FLAG_ACTIVE_MASK
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
    ; Get enemy variant
    ld a, [hli]
    ldh [hEnemyVariant], a
    ; Get enemy param 1
    ld a, [hli]
    ldh [hEnemyParam1], a
    ; Get enemy param 2
    ld a, [hli]
    ldh [hEnemyParam2], a
    ; Get enemy param 3
    ld a, [hl]
    ldh [hEnemyParam3], a
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
    ; jr .checkLoop
.checkLoop:
    ldh a, [hEnemyOffset]
    add a, ENEMY_STRUCT_SIZE
    ldh [hEnemyOffset], a 
    ldh a, [hEnemyLoopIndex]
    dec a
    ldh [hEnemyLoopIndex], a
    cp a, 0
    jp nz, .loop
    ret

; Arg: B = Sprite space needed
; Ret: HL = Free RAM space address
; Ret: B = Free OAM space address offset
; Ret: Z/NZ = Failed / succeeded respectively
FindRAMAndOAMForEnemy::
    ; Check Enemy RAM
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    ret z
    ; Check OAM
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    ret

; Ret: Z/NZ = Failed / succeeded respectively
EnemyInterCollision::
    ld a, NUMBER_OF_ENEMIES
    ldh [hEnemyLoopIndex2], a
    xor a ; ld a, 0
    ldh [hEnemyOffset2], a
.loop:
    ; Get active state
    ld hl, wEnemies
    ldh a, [hEnemyOffset2]
    ADD_A_TO_HL
    ld a, [hli]
    and ENEMY_FLAG_ALIVE_MASK
    ; Check alive
    jr z, .checkLoop
    ; Get enemy number
    ld a, [hli]
    ; Check enemy number
.pointBalloon:
    cp a, POINT_BALLOON
    jr nz, .bird
    ld d, 16
    ld e, d
    jr .checkCollision
.bird:
    cp a, BIRD
    jr nz, .bomb
    ld d, 24
    ld e, 8
    jr .checkCollision
.bomb:
    cp a, BOMB
    jr nz, .carrier
    ld d, 16
    ld e, d
    jr .checkCollision
.carrier:
    cp a, BALLOON_CARRIER
    jr nz, .checkLoop
    ld d, 16
    ld e, d
.checkCollision:
    ; Get collision OAM addresses
    inc hl
    inc hl
    ld a, [hl]
    ld hl, wOAM
    LD_BC_HL ; ld bc, wOAM
    ADD_A_TO_HL ; OAM address stored in hl
    ldh a, [hEnemyOAM]
    ADD_A_TO_BC ; OAM address stored in bc
    ; Check collision
    call CollisionCheck
    jr nz, .hitEnemy
.checkLoop:
    ldh a, [hEnemyOffset2]
    add a, ENEMY_STRUCT_SIZE
    ldh [hEnemyOffset2], a    
    ldh a, [hEnemyLoopIndex2]
    dec a
    ldh [hEnemyLoopIndex2], a
    cp a, 0
    jp nz, .loop
    ; z flag set
    ret
.hitEnemy:
    ld hl, wEnemies
    ldh a, [hEnemyOffset2]
    ADD_A_TO_HL
    set ENEMY_FLAG_HIT_ENEMY_BIT, [hl]
    ; nz flag set
    or a, 1
    ret

SetEnemyHitForEnemy1::
    ld hl, wEnemies
    set ENEMY_FLAG_HIT_ENEMY_BIT, [hl]
    ret

; Ret: Z/NZ = Failed / succeeded respectively
EnemyHitBullet::
    ldh a, [hPlayerBulletFlags]
    and PLAYER_BULLET_FLAG_ACTIVE_MASK
    jr z, .notHitByBullet
    ; Collision check
    ld bc, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_BC
    ld hl, wPlayerBulletOAM
    ld d, PLAYER_BULLET_WIDTH
    ld e, PLAYER_BULLET_HEIGHT
    call CollisionCheck
.notHitByBullet:
    ; z flag set
    ret z
.hitByBullet:
    call ClearBullet
    ; nz flag set
    or a, 1
    ret

; Ret: Z/NZ = Failed / succeeded respectively
FindBalloonCarrier::
    ld a, NUMBER_OF_ENEMIES
    ldh [hEnemyLoopIndex3], a
    xor a ; ld a, 0
    ldh [hEnemyOffset3], a
.loop:
    ; Get enemy number
    ld hl, wEnemies+1
    ldh a, [hEnemyOffset3]
    ADD_A_TO_HL
    ld a, [hl]
    cp a, BALLOON_CARRIER
    jr nz, .checkLoop
    ; nz flag set
    or a, 1
    ret
.checkLoop:
    ldh a, [hEnemyOffset3]
    add a, ENEMY_STRUCT_SIZE
    ldh [hEnemyOffset3], a
    ldh a, [hEnemyLoopIndex3]
    dec a
    ldh [hEnemyLoopIndex3], a
    cp a, 0
    jr nz, .loop
    ; z flag set
    ret

; Arg: BC = Enemy OAM Bytes
ClearEnemy::
    ld hl, wOAM
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    call ResetHLInRange
    jp InitializeEnemyStructVars

; Arg: BC = Enemy OAM Bytes
HandleEnemyOffscreenVertical::
    ldh a, [hEnemyY]
    ld h, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, h
    ret nc
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, h
    ret c
    ; Offscreen
    jp ClearEnemy

; Arg: BC = Enemy OAM Bytes
HandleEnemyOffscreenHorizontal::
    ldh a, [hEnemyX]
    ld h, a
    ld a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    cp a, h
    ret nc
    ld a, SCRN_VX - OFF_SCREEN_ENEMY_BUFFER
    cp a, h
    ret c
    ; Offscreen
    jp ClearEnemy

SECTION "enemy animations", ROM0

PopBalloonAnimation::
    ; hEnemyParam1 = Animation Frame
    ; hEnemyParam2 = Animation Timer
    ldh a, [hEnemyParam2]
    inc a
    ldh [hEnemyParam2], a
    dec a
    and POPPING_BALLOON_ANIMATION_TIME
    ret nz
    ; Find our frame
    ldh a, [hEnemyParam1]
.frame0:
    cp a, 0
    jr nz, .frame1
    ld b, POP_BALLOON_FRAME_0_TILE
    jr .updateFrame
.frame1:
    cp a, 1
    jr nz, .frame2
    ld b, POP_BALLOON_FRAME_1_TILE
    jr .updateFrame
.frame2:
    ; jr nz, .frame3
    ; cp a, 2
    ldh a, [hEnemyFlags]
    res ENEMY_FLAG_DYING_BIT, a
    ldh [hEnemyFlags], a
    ret
.updateFrame:
    ; Point hl to enemy oam
    ld hl, wOAM+2
    ldh a, [hEnemyOAM]
    ADD_A_TO_HL
    ; Left sprite
    ld a, b
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hli], a
    inc l
    inc l
    ; Right sprite
    ld a, b
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hl], a
    ; Next frame
    ldh a, [hEnemyParam1]
    inc a 
    ldh [hEnemyParam1], a
    ret