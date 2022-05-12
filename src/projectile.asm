INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

PROJECTILE_OAM_SPRITES EQU 1
PROJECTILE_MOVE_TIME EQU %00000001
PROJECTILE_COLLISION_TIME EQU %00001000
PROJECTILE_TILE EQU $46

SECTION "enemy projectile", ROM0

SetStruct:
    ; Argument hl = start of free enemy struct
    ldh a, [hEnemyActive]
    ld [hli], a
    ldh a, [hEnemyNumber]
    ld [hli], a
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ldh a, [hEnemyOAM]
    ld [hli], a
    ldh a, [hEnemyY2] ; Add to Y
    ld [hli], a
    ldh a, [hEnemyX2] ; Add to X
    ld [hl], a
    ret

SpawnProjectile::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jr z, .end
.availableSpace:
    ld b, PROJECTILE_OAM_SPRITES
    push hl
	call RequestOAMSpace ; b now contains OAM address
    pop hl
    jr z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ldh [hEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ldh [hEnemyActive], a
.setupY2:
    ld a, [wPlayerY]
    ld d, a
    ldh a, [hEnemyY]
    cp a, d
    jr c, .down
.up:
    ld a, -1
    jr .endY
; .middleY:
;     xor a ; ld a, 0
;     jr .endY
.down:
    ld a, 1
.endY:
    ldh [hEnemyY2], a
.endSetupY2:
.setupX2:
    ld a, [wPlayerX]
    ld d, a
    ldh a, [hEnemyX]
    cp a, d
    jr c, .right
.left:
    ld a, -1
    jr .endX
; .middleX:
;     xor a ; ld a, 0
;     jr .endX
.right:
    ld a, 1
.endX:
    ldh [hEnemyX2], a
.endSetupX2:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
.projectileOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, PROJECTILE_TILE
    ld [hli], a
    ld [hl], OAMF_PAL0
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
    ret
  
Clear:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    xor a ; ld a, 0
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    call InitializeEnemyStructVars
    ret

ProjectileUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ldh [hEnemyOAM], a
    ld a, [hli]
    ldh [hEnemyY2], a
    ld a, [hli]
    ldh [hEnemyX2], a
    ld a, [hl]

.checkFlicker:
    ldh a, [hGlobalTimer]
    and	%00000111
    jr nz, .endFlicker
.canFlicker:
    SET_HL_TO_ADDRESS wOAM+3, hEnemyOAM
    ld a, [hl]
    cp a, OAMF_PAL0
    jr z, .palette1
.palette0:
    ld [hl], OAMF_PAL0
    jr .endFlicker
.palette1:
    ld [hl], OAMF_PAL1
.endFlicker:

.checkMove:
    ldh a, [hGlobalTimer]
    and	PROJECTILE_MOVE_TIME
    jr nz, .endMove
.canMove:
.projectileOAM:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ldh a, [hEnemyY]
    ld b, a
    ldh a, [hEnemyY2]
    add a, b
    ldh [hEnemyY], a
    ld [hli], a
    ldh a, [hEnemyX]
    ld b, a
    ldh a, [hEnemyX2]
    add a, b
    ldh [hEnemyX], a
    ld [hl], a
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	PROJECTILE_COLLISION_TIME
    jr nz, .endCollision
.checkHit:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 8
    ld e, 8
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
.deathOfProjectile:
    call Clear
    call CollisionWithPlayer
    jr .setStruct
.endCollision:

.checkOffscreenY:
    ldh a, [hEnemyY]
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreenY
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreenY
.offscreenY:
    call Clear
.endOffscreenY:
.checkOffscreenX:
    ldh a, [hEnemyX]
    ld b, a
    ld a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreenX
    ld a, SCRN_VX - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreenX
.offscreenX:
    call Clear
.endOffscreenX:

.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret