INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

LEVEL_UPDATE_REFRESH_TIME EQU %00001111

LEVEL_DATA_FIELDS EQU 3

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
    wLevelWaitCounter:: DB
    wLevelDataAddress:: DS 2

SECTION "level data", ROM0

; LEVEL INSTRUCTIONS *************************************

Level1:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, MEDIUM
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, SCRN_X, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, 0, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, HARD
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_A, 0, EASY
    LEVEL_SPAWN BIRD, SPAWN_Y_C, SCRN_X, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, HARD
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_A, 0, EASY
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, 0, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-2, SPAWN_X_A, MEDIUM
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-6, SPAWN_X_B, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-4, SPAWN_X_D, EASY
    LEVEL_WAIT 16
    LEVEL_END

Level2:
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_C, SCRN_X, EASY
    LEVEL_SPAWN BIRD, SPAWN_Y_D, SCRN_X, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN BIRD, SPAWN_Y_A, 0, EASY
    LEVEL_SPAWN BIRD, SPAWN_Y_B, 0, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_C, 0, EASY
    LEVEL_SPAWN BIRD, SPAWN_Y_B, SCRN_X, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_B, 0, EASY
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_A, SCRN_X, EASY
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, SCRN_X, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 1
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_WAIT 1
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_SPAWN BIRD, SPAWN_Y_A, SCRN_X, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_D, SCRN_X, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 16
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, SCRN_X, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, 0, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_A, 0, EASY
    LEVEL_SPAWN BIRD, SPAWN_Y_C, SCRN_X, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_A, 0, EASY
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, 0, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-2, SPAWN_X_A, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-6, SPAWN_X_B, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-4, SPAWN_X_D, EASY
    LEVEL_WAIT 16
    LEVEL_END

Level3:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 8
    LEVEL_WAIT 8
    LEVEL_WAIT 8
    LEVEL_WAIT 8

    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, SCRN_X, EASY
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_A, 0, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 8
    ; LEVEL_SPAWN BIRD, SPAWN_Y_B, SCRN_X
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    ; LEVEL_WAIT 16
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    ; LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, SCRN_X
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, 0
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_A, 0
    ; LEVEL_SPAWN BIRD, SPAWN_Y_C, SCRN_X
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN BIRD, SPAWN_Y_A, 0
    ; LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, 0
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-2, SPAWN_X_A
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-6, SPAWN_X_B
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-4, SPAWN_X_D
    ; LEVEL_WAIT 16
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    ; LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, SCRN_X
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, 0
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_A, 0
    ; LEVEL_SPAWN BIRD, SPAWN_Y_C, SCRN_X
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN BIRD, SPAWN_Y_A, 0
    ; LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, 0
    ; LEVEL_WAIT 8
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-2, SPAWN_X_A
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-6, SPAWN_X_B
    ; LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C
    ; LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-4, SPAWN_X_D
    LEVEL_WAIT 16
    LEVEL_END

; Handler and Initializer

InitializeNewLevel::
    xor a ; ld a, 0
    ld [wLevelWaitCounter], a

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

SpawnDataHandler:
    ; Argument hl = source address
    ld a, [hli]
    ; Update enemy number
    ld [wEnemyNumber], a
    ld b, a
    ; Update enemy Y/X
    ld a, [hli]
    ld [wEnemyY], a
    ld a, [hli]
    ld [wEnemyX], a
    ld a, [hli]
    ; Update difficulty
    ld [wEnemyDifficulty], a
    ld a, b
    ; Spawns
    cp a, POINT_BALLOON
    jp z, SpawnPointBalloon
    cp a, BALLOON_CACTUS
    jp z, SpawnBalloonCactus
    cp a, BIRD
    jp z, SpawnBird
    cp a, BOMB
    jp z, SpawnBomb
    cp a, BOSS
    jp z, SpawnBoss
    ret

LevelDataHandler::
    ; Frequency we read 
    ldh a, [hGlobalTimer]
    and LEVEL_UPDATE_REFRESH_TIME
    ret nz

    ; Read next level instruction
    ld a, [wLevelDataAddress]
    ld l, a
    ld a, [wLevelDataAddress+1]
    ld h, a
    ld a, [hl]

    ; Interpret
    cp a, LEVEL_SPAWN_KEY
    jr z, .spawn
    cp a, LEVEL_WAIT_KEY
    jr z, .wait
    cp a, LEVEL_END_KEY
    jr z, .end
    cp a, GAME_WON_KEY
    jr z, .won
    ret
.spawn:
    ; Next instructions: enemy, y, x
    inc hl
    call SpawnDataHandler
    ld a, l
    ld [wLevelDataAddress], a
    ld a, h
    ld [wLevelDataAddress+1], a
    ret
.wait:
    ; Next instruction: amount to wait
    inc hl
    ld a, [wLevelWaitCounter]
    cp a, [hl]
    jr nc, .waitEnd
    inc a
    ld [wLevelWaitCounter], a
    ret
.waitEnd:
    inc hl
    ld a, l
    ld [wLevelDataAddress], a
    ld a, h
    ld [wLevelDataAddress+1], a
    xor a ; ld a, 0
    ld [wLevelWaitCounter], a
    ret 
.end:
    call FadeOutPalettes
	cp a, 0
    ret z
    ld a, [wLevel] 
    inc a
    ld [wLevel], a 
    jp StageClear
.won:
    call FadeOutPalettes
	cp a, 0
    ret z
    jp GameWon