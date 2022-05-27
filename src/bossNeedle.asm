INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

BOSS_NEEDLE_OAM_SPRITES EQU 1
BOSS_NEEDLE_MOVE_TIME EQU %00000001
BOSS_NEEDLE_COLLISION_TIME EQU %00001000
BOSS_NEEDLE_TILE EQU $62

BOSS_NEEDLE_SPEED EQU 2

SECTION "boss needle", ROM0

; Enemy difficulty / Effect
; NONE - Shoot top-left
; EASY - Shoot top-right
; MEDIUM - Shoot bottom-left
; HARD - Shoot bottom-right

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
    ldh a, [hEnemyDifficulty]
    ld [hl], a
    ret

SpawnBossNeedle::
    push hl
    ld hl, wEnemies
    ld d, NUMBER_OF_ENEMIES
    ld e, ENEMY_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    jr z, .end
.availableSpace:
    ld b, BOSS_NEEDLE_OAM_SPRITES
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
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.difficultyDirection:
    ldh a, [hEnemyDifficulty]
.topLeftDirection:
    cp a, NONE
    jr nz, .topRightDirection
    ld e, OAMF_PAL0
    jr .endDifficultyDirection
.topRightDirection:
    cp a, EASY
    jr nz, .bottomLeftDirection
    ld e, OAMF_PAL0 | OAMF_XFLIP
    jr .endDifficultyDirection
.bottomLeftDirection:
    cp a, MEDIUM
    jr nz, .bottomRightDirection
    ld e, OAMF_PAL0 | OAMF_XFLIP
    jr .endDifficultyDirection
.bottomRightDirection:
    ld e, OAMF_PAL0
.endDifficultyDirection:

.bossNeedleOAM:
    ldh a, [hEnemyY]
    ld [hli], a
    ldh a, [hEnemyX]
    ld [hli], a
    ld a, BOSS_NEEDLE_TILE
    ld [hli], a
    ld [hl], e
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

BossNeedleUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ldh [hEnemyOAM], a
    ld a, [hli]
    ldh [hEnemyDifficulty], a
    ld a, [hl]

.checkMove:
    ldh a, [hGlobalTimer]
    and	BOSS_NEEDLE_MOVE_TIME
    jr nz, .endMove
.canMove:
.bossNeedleOAM:
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM

.difficultyDirection:
    ldh a, [hEnemyDifficulty]
.topLeftDirection:
    cp a, NONE
    jr nz, .topRightDirection
    ld b, BOSS_NEEDLE_SPEED * -1
    ld c, BOSS_NEEDLE_SPEED * -1
    jr .endDifficultyDirection
.topRightDirection:
    cp a, EASY
    jr nz, .bottomLeftDirection
    ld b, BOSS_NEEDLE_SPEED * -1
    ld c, BOSS_NEEDLE_SPEED
    jr .endDifficultyDirection
.bottomLeftDirection:
    cp a, MEDIUM
    jr nz, .bottomRightDirection
    ld b, BOSS_NEEDLE_SPEED
    ld c, BOSS_NEEDLE_SPEED * -1
    jr .endDifficultyDirection
.bottomRightDirection:
    ld b, BOSS_NEEDLE_SPEED
    ld c, BOSS_NEEDLE_SPEED
.endDifficultyDirection:
    ldh a, [hEnemyY]
    add a, b
    ldh [hEnemyY], a
    ld [hli], a
    ldh a, [hEnemyX]
    add a, c
    ldh [hEnemyX], a
    ld [hl], a
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	BOSS_NEEDLE_COLLISION_TIME
    jr nz, .endCollision
.checkHit:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM, hEnemyOAM
    ld d, 8 ; should be 4... Maybe make collision that can read flipped
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
.deathOfBossNeedle:
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