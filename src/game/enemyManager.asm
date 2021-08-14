SECTION "enemy manager", ROMX

SpawnEnemyf::
    ; Check if we can spawn an enemy
    ; ^ if respawn timer has looped AND if we have an enemy dead or unspawned
    ; if can spawn enemy1 // if can spawn enemy2
    ret

GameManager::
    call PointBalloonUpdate

    ld a, [difficulty_level]
    cp a, 3
    jr nc, .levelThree
    cp a, 2
    jr nc, .levelTwo
    cp a, 1
    jr nc, .levelOne
    ret
.levelThree:
    call Enemy2Update
.levelTwo:
    call BirdUpdate
.levelOne:
	call EnemyUpdate
.end:
    ret