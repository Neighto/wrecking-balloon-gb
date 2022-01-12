INCLUDE "hardware.inc"

LEVEL_UPDATE_REFRESH_TIME EQU %00001111

LEVEL_DATA_FIELDS EQU 3

; Enemy Legend (Get Enemy_Number Here)
EMPTY EQU 0
POINT_BALLOON EQU 1
BALLOON_CACTUS EQU 2
BIRD EQU 3
BOMB EQU 4

; Common Spawning Coordinates
OFFSCREEN_BOTTOM_Y EQU 156
SPAWN_Y_A EQU 28
SPAWN_Y_B EQU 56
SPAWN_Y_C EQU 84
SPAWN_Y_D EQU 112
SPAWN_X_A EQU 32
SPAWN_X_B EQU 64
SPAWN_X_C EQU 96
SPAWN_X_D EQU 128

SECTION "level vars", WRAM0
    wWorld:: DB
    wLevel:: DB
    wWave:: DB

SECTION "level data", ROM0

; Template Format
;   Label: WXLYWZ (W:World, L:Level, W:Wave)
;   Enemy_Number, Spawn_Location_Y, Spawn_Location_X

; World 1

W1L1W1:
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
W1L1W1End:

W1L1W2:
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    DB BALLOON_CACTUS, SPAWN_Y_B, SCRN_X
W1L1W2End:

W1L1W3:
    DB BALLOON_CACTUS, SPAWN_Y_C, 0
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
W1L1W3End:

W1L1W4:
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    DB BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
W1L1W4End:

W1L2W1:
    DB BALLOON_CACTUS, SPAWN_Y_A, 0
    DB BIRD, SPAWN_Y_C, SCRN_X
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
W1L2W1End:

W1L2W2:
    DB BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
W1L2W2End:

W1L2W3:
    DB BIRD, SPAWN_Y_A, 0
    DB BALLOON_CACTUS, SPAWN_Y_B, 0
W1L2W3End:

W1L2W4:
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y-2, SPAWN_X_A
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y-6, SPAWN_X_B
    DB BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y-4, SPAWN_X_D
W1L2W4End:

; World 2

W2L1:
    DB BIRD, 80, 150
W2L1End:

; Handler and Initializer

InitializeLevelVars::
    ld a, 1
    ld [wWorld], a 
    ld [wLevel], a 
    ld [wWave], a 
    ret

LevelDataHandler:
    ; argument hl = source address
    ; argument de = size
.loop:
    ld a, [hl]
    cp a, EMPTY
    jr z, .empty 
    cp a, POINT_BALLOON
    jr z, .pointBalloon 
    cp a, BALLOON_CACTUS
    jr z, .balloonCactus 
    cp a, BIRD
    jr z, .bird 
    cp a, BOMB
    jr z, .bomb 
    jr .end
.pointBalloon:
    ; Y
    inc hl
    ld a, [hl]
    ld [wEnemyY], a
    ; X
    inc hl
    ld a, [hl]
    ld [wEnemyX], a
    call SpawnPointBalloon
    jr .loopCheck
.balloonCactus:
    ; Y
    inc hl
    ld b, [hl]
    ; X
    inc hl
    ld c, [hl]
    call SpawnBalloonCactus
    jr .loopCheck
.bird:
    ; Y
    inc hl
    ld b, [hl]
    ; X
    inc hl
    ld c, [hl]
    call SpawnBird
    jr .loopCheck
.bomb:
    ; Y
    inc hl
    ld b, [hl]
    ; X
    inc hl
    ld c, [hl]
    call SpawnBomb
    jr .loopCheck
.empty:
    inc hl
    inc hl
.loopCheck:
    inc hl
    dec de
    ld a, d
    or a, e
    jr nz, .loop
.end:
    ret

LevelDataManager::
    ; Frequency we read 
    ld a, [global_timer]
    cp a, 50
    jp nz, .end

    ; Find which world, level, wave we are on
    ld a, [wWorld]
    cp a, 1
    jp z, .w1 
    cp a, 2
    jp z, .w2 
    cp a, 3
    jp z, .w3
    jp .end
.w1:
    ld a, [wLevel]
    cp a, 1
    jr z, .w1_l1
    cp a, 2
    jr z, .w1_l2
    jp .end
    ; LEVEL 1 *******************************
.w1_l1:
    ld a, [wWave]
    cp a, 1
    jr z, .w1_l1_w1
    cp a, 2
    jr z, .w1_l1_w2
    cp a, 3
    jr z, .w1_l1_w3
    cp a, 4
    jr z, .w1_l1_w4
    jp .end
.w1_l1_w1:
    ld hl, W1L1W1
    ld de, (W1L1W1End - W1L1W1) / LEVEL_DATA_FIELDS
    jr .handle
.w1_l1_w2:
    ld hl, W1L1W2
    ld de, (W1L1W2End - W1L1W2) / LEVEL_DATA_FIELDS
    jr .handle
.w1_l1_w3:
    ld hl, W1L1W3
    ld de, (W1L1W3End - W1L1W3) / LEVEL_DATA_FIELDS
    jr .handle
.w1_l1_w4:
    xor a ; ld a, 0
    ld [wWave], a ; set to 0 about to increment to 1
    ld a, [wLevel]
    inc a
    ld [wLevel], a
    ld hl, W1L1W4
    ld de, (W1L1W4End - W1L1W4) / LEVEL_DATA_FIELDS
    jr .handle
    ; LEVEL 2 *******************************
.w1_l2:
    ld a, [wWave]
    cp a, 1
    jr z, .w1_l2_w1
    cp a, 2
    jr z, .w1_l2_w2
    cp a, 3
    jr z, .w1_l2_w3
    cp a, 4
    jr z, .w1_l2_w4
    jr .end
.w1_l2_w1:
    ld hl, W1L2W1
    ld de, (W1L2W1End - W1L2W1) / LEVEL_DATA_FIELDS
    jr .handle
.w1_l2_w2:
    ld hl, W1L2W2
    ld de, (W1L2W2End - W1L2W2) / LEVEL_DATA_FIELDS
    jr .handle
.w1_l2_w3:
    ld hl, W1L2W3
    ld de, (W1L2W3End - W1L2W3) / LEVEL_DATA_FIELDS
    jr .handle
.w1_l2_w4:
    ld hl, W1L2W4
    ld de, (W1L2W4End - W1L2W4) / LEVEL_DATA_FIELDS
    jr .handle
.w2:
    jr .end ; temp
.w3:
    jr .end ; temp
.handle:
    ld a, [wWave]  ; temp so we only read it once
    inc a 
    ld [wWave], a
    call LevelDataHandler
.end:
    ; Possibly here too we will increment those vars where needed
ret