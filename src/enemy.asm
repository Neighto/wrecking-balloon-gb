INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

SECTION "enemy struct vars", WRAM0

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

SECTION "enemy struct", ROM0

InitializeEnemyStructVars::
    push af
    xor a ; ld a, 0
    ld [wEnemyActive], a
    ld [wEnemyNumber], a
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

SECTION "enemy", ROM0

InitializeEnemies::
    push hl
    push bc
    RESET_IN_RANGE wEnemies, ENEMY_DATA_SIZE
    pop bc
    pop hl
    ret

UpdateEnemy::
    ld bc, NUMBER_OF_ENEMIES
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
    dec bc
    ld a, b
    or a, c
    jr nz, .loop
    ret

; Functions every enemy should have (where Enemy is name of enemy)
; SetStruct
; SpawnEnemy
; Clear
; Move
; DeathOfEnemy
; CollisionEnemy
; EnemyUpdate