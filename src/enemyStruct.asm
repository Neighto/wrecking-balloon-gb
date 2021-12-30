
SECTION "enemy struct vars", WRAM0

    ; Offset for looping through enemy data
    wEnemyOffset:: DB

    ; Vars shared by enemies
    wEnemyActive:: DB
    wEnemyY:: DB
    wEnemyX:: DB
    wEnemyOAM:: DB
    wEnemyAlive:: DB

    ; Balloon enemies
    wEnemyPopping:: DB
    wEnemyPoppingFrame:: DB
    wEnemyPoppingTimer:: DB

    ; Cactus enemies
    wEnemyY2:: DB
    wEnemyX2:: DB
    wEnemyFalling:: DB
    wEnemyFallingSpeed:: DB
    wEnemyFallingTimer:: DB
    wEnemyDelayFallingTimer:: DB

SECTION "enemy struct", ROM0

InitializeEnemyStructVars::
    push af
    xor a ; ld a, 0
    ld [wEnemyOffset], a
    ld [wEnemyActive], a
    ld [wEnemyY], a
    ld [wEnemyX], a
    ld [wEnemyOAM], a
    ld [wEnemyAlive], a
    ld [wEnemyPopping], a
    ld [wEnemyPoppingFrame], a
    ld [wEnemyPoppingTimer], a
    ld [wEnemyY2], a
    ld [wEnemyX2], a
    ld [wEnemyFalling], a 
    ld [wEnemyFallingSpeed], a 
    ld [wEnemyFallingTimer], a
    ld [wEnemyDelayFallingTimer], a
    pop af
    ret

; Functions every enemy should have (where Enemy is name of enemy)
; InitializeEnemy
; RequestEnemySpace
; GetEnemyStruct
; SetEnemyStruct
; SpawnEnemy
; ClearEnemy
; MoveEnemy
; DeathOfEnemy
; CollisionEnemy
; EnemyUpdate