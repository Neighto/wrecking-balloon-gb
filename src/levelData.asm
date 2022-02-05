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
    wLevelDataAddress:: DS 2

SECTION "level data", ROM0

; LEVEL INSTRUCTIONS *************************************

Level1:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, SCRN_X
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, 0
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_A, 0
    LEVEL_SPAWN BIRD, SPAWN_Y_C, SCRN_X
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    LEVEL_WAIT 8
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_A, 0
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, 0
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-2, SPAWN_X_A
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-6, SPAWN_X_B
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-4, SPAWN_X_D
    LEVEL_WAIT 16
    LEVEL_END

Level2:
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_B, 0
    LEVEL_SPAWN BIRD, SPAWN_Y_C, SCRN_X
    LEVEL_WAIT 8
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    LEVEL_WAIT 16
    LEVEL_END

Level3:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    LEVEL_WAIT 16
    LEVEL_END

; Handler and Initializer

InitializeNewLevel::
    xor a ; ld a, 0
    ld [wLevelPointer], a
    ld [wLevelPointerWaitCounter], a

    ld a, [wLevel]
    cp a, 1
    jr z, .level1
    cp a, 2
    jr z, .level2
    cp a, 3
    jr z, .level3
    cp a, 4
    jr z, .level4
    ret
.level1:
    ld bc, Level1
    jr .setLevelDataAddress
.level2:
    ld bc, Level2
    jr .setLevelDataAddress
.level3:
    ld bc, Level3
    jr .setLevelDataAddress
.level4:
    ; nothing
    ret
.setLevelDataAddress:
    ld hl, wLevelDataAddress
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
    ret

InitializeLevelVars::
    ld a, 1
    ld [wLevel], a
    call InitializeNewLevel
    ret

LevelDataHandler:
    ; argument hl = source address
    ld a, [hli]
    cp a, EMPTY
    ret z

    ; Update enemy Y/X
    ld b, a
    ld a, [hli]
    ld [wEnemyY], a
    ld a, [hli]
    ld [wEnemyX], a
    ld a, b

    ; Spawns
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
    ret
.balloonCactus:
    call SpawnBalloonCactus
    ret
.bird:
    call SpawnBird
    ret
.bomb:
    call SpawnBomb
    ret
.porcupine:
    call SpawnPorcupine
    ret

LevelDataManager::
    ; Frequency we read 
    ld a, [wGlobalTimer]
    and LEVEL_UPDATE_REFRESH_TIME
    ret nz
    
    ; Testing remove later
    ld a, [wLevel]
    cp a, 4
    jp z, Start

    ; Read next level instruction
    ld a, [wLevelDataAddress]
    ld l, a
    ld a, [wLevelDataAddress+1]
    ld h, a
    ADD_TO_HL [wLevelPointer]
    ld a, [hl]

    ; Interpret
    cp a, LEVEL_SPAWN_KEY
    jr z, .spawn
    cp a, LEVEL_WAIT_KEY
    jr z, .wait
    cp a, LEVEL_END_KEY
    jr z, .end
    ret
.spawn:
    ; Next instructions: enemy, y, x
    inc hl
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
.end:
    call FadeOutPalettes
	cp a, 0
    ret z
    ld a, [wLevel] 
    inc a
    ld [wLevel], a 
    jp SetupNextLevel ; should actually take you to an intermediate screen first
    ret