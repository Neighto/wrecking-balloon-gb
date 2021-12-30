LEVEL_UPDATE_REFRESH_TIME EQU %00000011

; Enemy Legend (Get Enemy_Number Here)
EMPTY EQU 0
POINT_BALLOON EQU 1
BALLOON_CACTUS EQU 2
BIRD EQU 3
BOMB EQU 4

; Spawning Coordinates
OFFSCREEN_BOTTOM_Y EQU 156
POINT_BALLOON_SPAWN_A EQU 32
POINT_BALLOON_SPAWN_B EQU 64
POINT_BALLOON_SPAWN_C EQU 96
POINT_BALLOON_SPAWN_D EQU 128

SECTION "level vars", WRAM0
    wWorld:: DB
    wLevel:: DB
    wWave:: DB

SECTION "level data", ROM0

; Template Format
;   Label: WXLY (W:World, L:Level)
;   Enemy_Number, Spawn_Location_Y, Spawn_Location_X

; World 1

W1L1::
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, POINT_BALLOON_SPAWN_C
    ; DB BALLOON_CACTUS, 60, 0
W1L1End::

W1L2:
    ; DB POINT_BALLOON, 140, 40
W1L2End:

; World 2

W2L1:
    DB BIRD, 80, 150, 0
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
    ld b, [hl]
    ; X
    inc hl
    ld c, [hl]
    call SpawnPointBalloon
    jr .loopCheck
.balloonCactus:
    jr .loopCheck
.bird:
    jr .loopCheck
.bomb:
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
    and LEVEL_UPDATE_REFRESH_TIME
    jr nz, .end

    ; Find which world, level, wave we are on
    ld a, [wWorld]
    cp a, 1
    jr z, .w1 
    cp a, 2
    jr z, .w2 
    cp a, 3
    jr z, .w3
    jr .end
.w1:
    ld a, [wLevel]
    cp a, 1
    jr z, .w1l1
    cp a, 2
    jr z, .w1l2
    jr .end
.w1l1:
    ld hl, W1L1
    ld de, W1L1End - W1L1
    jr .handle
.w1l2:
    ; ld hl, W1L2
    ; ld de, W1L2End - W1L2
    ; jr .handle
    jr .end ; temp
.w2:
    jr .end ; temp
.w3:
    jr .end ; temp
.handle:
    ld a, [wLevel]  ; temp so we only read it once
    inc a 
    ld [wLevel], a
    call LevelDataHandler
.end:
    ; Possibly here too we will increment those vars where needed
ret