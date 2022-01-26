INCLUDE "hardware.inc"
INCLUDE "macro.inc"

LEVEL_UPDATE_REFRESH_TIME EQU %00001111

LEVEL_DATA_FIELDS EQU 3

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

; ENEMY SETS *************************************

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

; LEVEL INSTRUCTIONS *************************************

LevelInstructions:
    LEVEL_SPAWN Set1, Set1Size
    LEVEL_WAIT 8
    LEVEL_SPAWN Set2, Set2Size
    LEVEL_WAIT 8
    LEVEL_SPAWN Set3, Set3Size
    LEVEL_WAIT 8
    LEVEL_SPAWN Set4, Set4Size
    LEVEL_WAIT 8
    LEVEL_SPAWN Set5, Set5Size
    LEVEL_WAIT 8
    LEVEL_SPAWN Set6, Set6Size
    LEVEL_WAIT 8
    LEVEL_SPAWN Set7, Set7Size
    LEVEL_WAIT 8
    LEVEL_SPAWN Set8, Set8Size
    LEVEL_END

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
    ld a, [hli]
    cp a, EMPTY
    jr z, .empty

    ; Update enemy Y/X
    ld b, a
    ld a, [hli]
    ld [wEnemyY], a
    ld a, [hli]
    ld [wEnemyX], a
    ld a, b

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
    ret
.pointBalloon:
    call SpawnPointBalloon
    jr .loopCheck
.balloonCactus:
    call SpawnBalloonCactus
    jr .loopCheck
.bird:
    call SpawnBird
    jr .loopCheck
.bomb:
    call SpawnBomb
    jr .loopCheck
.porcupine:
    call SpawnPorcupine
    jr .loopCheck
.empty:
    inc hl
    inc hl
.loopCheck:
    dec de
    ld a, d
    or a, e
    jr nz, .loop
    ret

LevelDataManager::
    ; Frequency we read 
    ld a, [wGlobalTimer]
    and LEVEL_UPDATE_REFRESH_TIME
    ret nz
    
    ; Read next level instruction
    SET_HL_TO_ADDRESS LevelInstructions, wLevelPointer
    ld a, [hl]

    ; Interpret
    cp a, LEVEL_SPAWN_KEY
    jr z, .spawn
    cp a, LEVEL_WAIT_KEY
    jr z, .wait 
    ret
.spawn:
    ; Next instructions: start address and size
    inc hl
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
    inc hl
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