INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

SECTION "enemy struct vars", WRAM0
    ; NOTE: UPDATE ENEMY_STRUCT_SIZE in enemyConstants if we add vars here!
    ; TODO: Can I define a public constant here that is EndStruct - StartStruct instead?

    ; These must be in this order in each enemy
    wEnemyActive:: DB
    wEnemyNumber:: DB

    ; These can be in any order
    wEnemyY:: DB
    wEnemyX:: DB
    wEnemyOAM:: DB
    wEnemyAlive:: DB
    wEnemyPopping:: DB
    wEnemyPoppingFrame:: DB ; rename to general anims
    wEnemyPoppingTimer:: DB
    wEnemyRightside:: DB
    wEnemyY2:: DB
    wEnemyX2:: DB
    wEnemyFalling:: DB
    wEnemyFallingSpeed:: DB
    wEnemyFallingTimer:: DB
    wEnemyDelayFallingTimer:: DB
    wEnemyToDie:: DB ; If enemy set to die from external file
    wEnemyDifficulty:: DB
    ; TODO clean these up to be more generic and helpful

SECTION "enemy struct", ROM0

InitializeEnemyStructVars::
    push af
    xor a ; ld a, 0
    ld [wEnemyActive], a
    ld [wEnemyOAM], a
    ld [wEnemyAlive], a
    ld [wEnemyPopping], a
    ld [wEnemyPoppingFrame], a
    ld [wEnemyPoppingTimer], a
    ld [wEnemyRightside], a
    ld [wEnemyY2], a
    ld [wEnemyX2], a
    ld [wEnemyFalling], a 
    ld [wEnemyFallingSpeed], a 
    ld [wEnemyFallingTimer], a
    ld [wEnemyDelayFallingTimer], a
    ld [wEnemyToDie], a
    pop af
    ret

SECTION "enemy data vars", WRAM0

    wEnemies:: DS ENEMY_DATA_SIZE
    wEnemyOffset:: DB ; Offset for looping through enemy data
    wEnemyOffset2:: DB ; If we loop inside another enemy's data
    wEnemyLoopIndex:: DB

SECTION "enemy", ROM0

InitializeEnemies::
    RESET_IN_RANGE wEnemies, ENEMY_DATA_SIZE
    ret

UpdateEnemy::
    ld a, NUMBER_OF_ENEMIES
    ld [wEnemyLoopIndex], a
    xor a ; ld a, 0
    ld [wEnemyOffset], a
.loop:
    ; Get active state
    SET_HL_TO_ADDRESS wEnemies, wEnemyOffset
    ld a, [hli]
    ld [wEnemyActive], a
    ; Check active
    ld a, [wEnemyActive]
    cp a, 0
    jr z, .checkLoop
    ; Get enemy number
    ld a, [hli]
    ld [wEnemyNumber], a
    ; Check enemy number
    cp a, POINT_BALLOON
    jr z, .pointBalloon
    cp a, BALLOON_CACTUS
    jr z, .balloonCactus
    cp a, BIRD
    jr z, .bird
    cp a, BOMB
    jr z, .bomb
    cp a, PORCUPINE
    jr z, .porcupine
    jr .checkLoop
.pointBalloon:
    call PointBalloonUpdate
    jr .checkLoop
.balloonCactus:
    call BalloonCactusUpdate
    jr .checkLoop
.bird:
    call BirdUpdate
    jr .checkLoop
.bomb:
    call BombUpdate
    jr .checkLoop
.porcupine:
    call PorcupineUpdate
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