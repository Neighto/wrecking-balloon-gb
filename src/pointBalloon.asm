INCLUDE "balloonConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "constants.inc"

POINT_BALLOON_OAM_SPRITES EQU 2
POINT_BALLOON_OAM_BYTES EQU POINT_BALLOON_OAM_SPRITES * 4
POINT_BALLOON_MOVE_TIME EQU %00000001
POINT_BALLOON_COLLISION_TIME EQU %00001000

POINT_BALLOON_EASY_TILE EQU $3A
POINT_BALLOON_EASY_POINTS EQU 25

POINT_BALLOON_MEDIUM_TILE EQU $56
POINT_BALLOON_MEDIUM_POINTS EQU 50

POINT_BALLOON_HARD_TILE EQU $3A
POINT_BALLOON_HARD_POINTS EQU 80


SECTION "point balloon", ROMX

SetStruct:
    ; Argument hl = start of free enemy struct
    ldh a, [wEnemyActive]
    ld [hli], a
    ldh a, [wEnemyNumber]
    ld [hli], a
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    ld [hli], a
    ldh a, [wEnemyOAM]
    ld [hli], a
    ldh a, [wEnemyAlive]
    ld [hli], a
    ldh a, [wEnemyPopping]
    ld [hli], a
    ldh a, [wEnemyPoppingFrame]
    ld [hli], a
    ldh a, [wEnemyPoppingTimer]
    ld [hli], a
    ldh a, [wEnemyDifficulty]
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
    ldh [wEnemyActive], a
    ldh [wEnemyAlive], a
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM

.difficultyVisual:
    ldh a, [wEnemyDifficulty]
.easyVisual:
    cp a, EASY
    jr nz, .mediumVisual
    ld d, POINT_BALLOON_EASY_TILE
    ld e, OAMF_PAL0
    jr .endDifficultyVisual
.mediumVisual:
    cp a, MEDIUM
    jr nz, .hardVisual
    ld d, POINT_BALLOON_MEDIUM_TILE
    ld e, OAMF_PAL0
    jr .endDifficultyVisual
.hardVisual:
    cp a, HARD
    jr nz, .endDifficultyVisual
    ld d, POINT_BALLOON_HARD_TILE
    ld e, OAMF_PAL1
.endDifficultyVisual:

.balloonLeftOAM:
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    ld [hli], a
.balloonRightOAM:
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    add 8
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, e
    or a, OAMF_XFLIP
    ld [hl], a
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop hl
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

PointBalloonUpdate::
    ; Get rest of struct
    ld a, [hli]
    ldh [wEnemyY], a
    ld a, [hli]
    ldh [wEnemyX], a
    ld a, [hli]
    ldh [wEnemyOAM], a
    ld a, [hli]
    ldh [wEnemyAlive], a
    ld a, [hli]
    ldh [wEnemyPopping], a
    ld a, [hli]
    ldh [wEnemyPoppingFrame], a
    ld a, [hli]
    ldh [wEnemyPoppingTimer], a
    ld a, [hl]
    ldh [wEnemyDifficulty], a

.checkAlive:
    ldh a, [wEnemyAlive]
    cp a, 0
    jp z, .popped
.isAlive:

.checkMove:
    ldh a, [hGlobalTimer]
    and	POINT_BALLOON_MOVE_TIME
    jr nz, .endMove
.canMove:
    ld hl, wEnemyY
    ldh a, [wEnemyDifficulty]
.moveEasy:
    cp a, EASY
    jr nz, .moveMedium
    dec [hl]
    jr .balloonLeftOAM
.moveMedium:
    cp a, MEDIUM
    jr nz, .moveHard
    dec [hl]
    dec [hl]
    jr .balloonLeftOAM
.moveHard:
    cp a, HARD
    jr nz, .balloonLeftOAM
    dec [hl]
    dec [hl]
    dec [hl]
.balloonLeftOAM:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX] ; Do not need to update X for point balloon
    ld [hli], a
    inc l
    inc l
.balloonRightOAM:
    ldh a, [wEnemyY]
    ld [hli], a
    ldh a, [wEnemyX]
    add 8
    ld [hl], a
.endMove:

.checkCollision:
    ldh a, [hGlobalTimer]
    and	POINT_BALLOON_COLLISION_TIME
    jr nz, .endCollision
.checkHit:
    ld bc, wPlayerCactusOAM
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld d, 16
    ld e, 16
    call CollisionCheck
    cp a, 0
    jr nz, .deathOfPointBalloon
.checkHitByBullet:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    LD_BC_HL
    ld hl, wPlayerBulletOAM
    ld d, 16
    ld e, 4
    call CollisionCheck
    cp a, 0
    jr z, .endCollision
    call ClearBullet
.deathOfPointBalloon:
    xor a ; ld a, 0
    ldh [wEnemyAlive], a
    ; Points
.difficultyPoints:
    ldh a, [wEnemyDifficulty]
.easyPoints:
    cp a, EASY
    jr nz, .mediumPoints
    ld d, POINT_BALLOON_EASY_POINTS
    jr .endDifficultyPoints
.mediumPoints:
    cp a, MEDIUM
    jr nz, .hardPoints
    ld d, POINT_BALLOON_MEDIUM_POINTS
    jr .endDifficultyPoints
.hardPoints:
    cp a, HARD
    jr nz, .endDifficultyPoints
    ld d, POINT_BALLOON_HARD_POINTS
.endDifficultyPoints:
    call AddPoints
    ; Animation trigger
    ld a, 1 
    ldh [wEnemyPopping], a
    ; Sound
    call PopSound
.endCollision:

.checkOffscreen:
    ldh a, [wEnemyY]
    ld b, a
    ld a, SCRN_Y + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreen
    ld a, SCRN_VY - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreen
.offscreen:
    call Clear
    jr .setStruct
.endOffscreen:
    jr .setStruct

.popped:
    ldh a, [wEnemyPopping]
    cp a, 0
    jr z, .clear
.animating:
    call PopBalloonAnimation
    jr .setStruct
.clear:
    call Clear
.setStruct:
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    call SetStruct
    ret