SECTION "enemy manager", ROMX

SpawnEnemyf::
    ; Check if we can spawn an enemy
    ; ^ if respawn timer has looped AND if we have an enemy dead or unspawned
    ; if can spawn enemy1 // if can spawn enemy2
    ret

GameManager::
    call PointBalloonUpdate

    ld a, [score+1]
    and %00001111
    cp a, 1
    jr c, .end
    ; SCORE >= 100
.scoreLow:
	call EnemyUpdate

    ld a, [score+1]
    and %00001111
    cp a, 4
    jr c, .end
    ; SCORE >= X
.scoreMid:
    call BirdUpdate

    ld a, [score+1]
    and %00001111
    cp a, 8
    jr c, .end
    ; SCORE >= X
.scoreHigh:
    call Enemy2Update
.end:
    ret