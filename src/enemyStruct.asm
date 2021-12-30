
SECTION "enemy struct vars", WRAM0

    ; Offset for looping through enemy data
    wEnemyOffset:: DB

    ; Vars shared by enemies
    wEnemyActive:: DB
    wEnemyY:: DB
    wEnemyX:: DB
    wEnemyOAM:: DB
    wEnemyAlive:: DB
    wEnemyPopping:: DB
    wEnemyPoppingFrame:: DB
    wEnemyPoppingTimer:: DB

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
    pop af
    ret