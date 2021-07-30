SECTION "enemy", ROMX

ENEMY_START_X EQU 20
ENEMY_START_Y EQU 50
ENEMY_BALLOON_START_Y EQU (ENEMY_START_Y-16)

InitializeEnemy::
    ; Set variables
    ld hl, enemy_x
    ld [hl], ENEMY_START_X
    ld hl, enemy_y
    ld [hl], ENEMY_BALLOON_START_Y
    ld hl, enemy_cactus_x
    ld [hl], ENEMY_START_X
    ld hl, enemy_cactus_y
    ld [hl], ENEMY_START_Y
    ; Balloon left
    ld hl, enemy_balloon
    ld [hl], ENEMY_BALLOON_START_Y
    inc l
    ld [hl], ENEMY_START_X
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00000000
    ; Balloon right
    ld hl, enemy_balloon+4
    ld [hl], ENEMY_BALLOON_START_Y
    inc l
    ld [hl], ENEMY_START_X+8
    inc l
    ld [hl], $86
    inc l
    ld [hl], %00100000
    ; Cactus left
    ld hl, enemy_cactus
    ld [hl], ENEMY_START_Y
    inc l
    ld [hl], ENEMY_START_X
    inc l
    ld [hl], $84
    inc l
    ld [hl], %00000000
    ; Cactus right
    ld hl, enemy_cactus+4
    ld [hl], ENEMY_START_Y
    inc l
    ld [hl], ENEMY_START_X+8
    inc l
    ld [hl], $84
    inc l
    ld [hl], %00100000
    ret

EnemyUpdate::
    ret