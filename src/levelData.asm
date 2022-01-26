INCLUDE "hardware.inc"
INCLUDE "macro.inc"

LEVEL_UPDATE_REFRESH_TIME EQU %00001111

LEVEL_DATA_FIELDS EQU 3

; Instructions Legend
SPAWN_GROUP EQU 0 ; Followed by start address of group and size
WAIT EQU 1 ; Followed by how many iterations to wait
END EQU 2

; Enemy Legend (Get Enemy_Number Here)
EMPTY EQU 0
POINT_BALLOON EQU 1
BALLOON_CACTUS EQU 2
BIRD EQU 3
BOMB EQU 4
PORCUPINE EQU 5

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
    wLevel:: DB
    wLevelPointer:: DB
    wLevelPointerWaitCounter:: DB

SECTION "level data", ROM0

; Template Format
;   Label: WXLYWZ (W:World, L:Level, W:Wave)
;   Enemy_Number, Spawn_Location_Y, Spawn_Location_X


Set1:
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ;     ; DB PORCUPINE, 50, 50
Set1End:
Set1Size EQU (Set1End - Set1) / LEVEL_DATA_FIELDS

Set2:
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    DB BALLOON_CACTUS, SPAWN_Y_B, SCRN_X
Set2End:
Set2Size EQU (Set2End - Set2) / LEVEL_DATA_FIELDS

Set3:
    DB BALLOON_CACTUS, SPAWN_Y_C, 0
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
Set3End:
Set3Size EQU (Set3End - Set3) / LEVEL_DATA_FIELDS

Set4:
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    DB BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
Set4End:
Set4Size EQU (Set4End - Set4) / LEVEL_DATA_FIELDS

Set5:
    DB BALLOON_CACTUS, SPAWN_Y_A, 0
    DB BIRD, SPAWN_Y_C, SCRN_X
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
Set5End:
Set5Size EQU (Set5End - Set5) / LEVEL_DATA_FIELDS

Set6:
    DB BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
Set6End:
Set6Size EQU (Set6End - Set6) / LEVEL_DATA_FIELDS

Set7:
    DB BIRD, SPAWN_Y_A, 0
    DB BALLOON_CACTUS, SPAWN_Y_B, 0
Set7End:
Set7Size EQU (Set7End - Set7) / LEVEL_DATA_FIELDS

Set8:
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y-2, SPAWN_X_A
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y-6, SPAWN_X_B
    DB BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    DB POINT_BALLOON, OFFSCREEN_BOTTOM_Y-4, SPAWN_X_D
Set8End:
Set8Size EQU (Set8End - Set8) / LEVEL_DATA_FIELDS

; Template Level 1

LevelInstructions:
    ADD_INSTRUCTION SPAWN_GROUP, Set1, Set1Size
    ADD_INSTRUCTION2 WAIT, 0
    ADD_INSTRUCTION SPAWN_GROUP, Set2, Set2Size
    ADD_INSTRUCTION2 WAIT, 1
    ADD_INSTRUCTION SPAWN_GROUP, Set1, Set1Size
    DB END

; Handler and Initializer

InitializeLevelVars::
    xor a ; ld a, 0
    ld [wLevelPointer], a
    ld [wLevelPointerWaitCounter], a
    ld a, 1
    ld [wLevel], a 
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
    cp a, PORCUPINE
    jr z, .porcupine
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
    ld a, [hl]
    ld [wEnemyY], a
    ; X
    inc hl
    ld a, [hl]
    ld [wEnemyX], a
    call SpawnBalloonCactus
    jr .loopCheck
.bird:
    ; Y
    inc hl
    ld a, [hl]
    ld [wEnemyY], a
    ; X
    inc hl
    ld a, [hl]
    ld [wEnemyX], a
    call SpawnBird
    jr .loopCheck
.bomb:
    ; Y
    inc hl
    ld a, [hl]
    ld [wEnemyY], a
    ; X
    inc hl
    ld a, [hl]
    ld [wEnemyX], a
    call SpawnBomb
    jr .loopCheck
.porcupine:
    ; Y
    inc hl
    ld a, [hl]
    ld [wEnemyY], a
    ; X
    inc hl
    ld a, [hl]
    ld [wEnemyX], a
    call SpawnPorcupine
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
    ld a, [wGlobalTimer]
    and %00011111
    ret nz
    
    ; Read next level instruction
    SET_HL_TO_ADDRESS LevelInstructions, wLevelPointer
    ld a, [hl]

    ; Interpret
    cp a, SPAWN_GROUP
    jr z, .spawnGroup 
    cp a, WAIT
    jr z, .wait 
    ret
.spawnGroup:
    ; Next instructions: start address and size
    inc l
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    ld d, 0
    ld e, [hl]
    LD_HL_BC
    call LevelDataHandler
    ld a, [wLevelPointer]
    add a, 4
    ld [wLevelPointer], a
    ret
.wait:
    ; Next instruction: amount to wait
    inc l
    ld b, [hl]
    ld a, [wLevelPointerWaitCounter]
    cp a, b
    jr nc, .waitEnd
    inc a
    ld [wLevelPointerWaitCounter], a
    ret
.waitEnd:
    ld a, [wLevelPointer]
    add a, 2
    ld [wLevelPointer], a
    xor a ; ld a, 0
    ld [wLevelPointerWaitCounter], a
    ret