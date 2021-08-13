SECTION "enemy manager", ROMX

SpawnEnemyf::
    ; Check if we can spawn an enemy
    ; ^ if respawn timer has looped AND if we have an enemy dead or unspawned
    ; if can spawn enemy1 // if can spawn enemy2

    ret

EnemiesUpdate::
	; call PointBalloonUpdate
	; call EnemyUpdate
	; call Enemy2Update
	; call BirdUpdate
    ret

GameManager::
    call PointBalloonUpdate
    ld hl, score+1
    ld a, [hl]
    and %00001111
    cp a, 1 ; score = 100
    jr nc, .scoreLow
;     ; Use score to dictate new behaviors and environments
    ret
.scoreLow:
	call EnemyUpdate

.scoreHigh:
    ret