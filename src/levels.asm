INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "enemyConstants.inc"

LEVEL_UPDATE_REFRESH_TIME EQU %00001111

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
    wLevelWaitBoss:: DB
    wLevelDataAddress:: DS 2

SECTION "level data", ROM0

; LEVEL INSTRUCTIONS *************************************

; City Levels

Level1:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, MEDIUM
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_D, SCRN_X, MEDIUM
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 6
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, MEDIUM
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, HARD
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_A, 0, MEDIUM
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, SCRN_X, MEDIUM
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 16
    LEVEL_END
    
Level2:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, MEDIUM
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, HARD
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_A, SCRN_X, MEDIUM
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, 0, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A + 8, MEDIUM
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, SCRN_X, EASY
    LEVEL_WAIT 12
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y - 4, SPAWN_X_D - 16, MEDIUM
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D - 32, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D + 4, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A - 12, EASY
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A - 12, EASY
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D + 12, EASY
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D + 12, EASY
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B + 8, EASY
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B + 8, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A + 3, EASY
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B - 8, SCRN_X, EASY
    LEVEL_WAIT 6
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C + 8, MEDIUM
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C + 2, HARD
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_D - 4, SCRN_X, MEDIUM
    LEVEL_WAIT 8
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, HARD
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_WAIT 16
    LEVEL_END

Level3:
    ; LEVEL_SPAWN BALLOON_CACTUS, 32, 0, ALTERNATE
    LEVEL_WAIT_BOSS
    LEVEL_WAIT 10
    LEVEL_END

    ; Desert Levels
Level4:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A - 8, EASY
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B + 8, HARD
    LEVEL_WAIT 2
    LEVEL_SPAWN BIRD, SPAWN_Y_C + 8, SCRN_X, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B - 12, EASY
    LEVEL_SPAWN BIRD, SPAWN_Y_B, 0, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, MEDIUM
    LEVEL_WAIT 4
    LEVEL_SPAWN BIRD, SPAWN_Y_A, 0, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_D, SCRN_X, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, MEDIUM
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A + 5, MEDIUM
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D + 5, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN BIRD, SPAWN_Y_A, 0, EASY
    LEVEL_SPAWN BIRD, SPAWN_Y_B, 0, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B + 4, HARD
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, MEDIUM
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, MEDIUM
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B + 8, EASY
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B + 8, EASY
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B + 4, HARD
    LEVEL_SPAWN BIRD, SPAWN_Y_A + 5, SCRN_X, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B + 20, HARD
    LEVEL_SPAWN BIRD, SPAWN_Y_C + 5, SCRN_X, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B + 36, HARD
    LEVEL_WAIT 2

    LEVEL_WAIT 16
    LEVEL_END

Level5:
    ; Will be desert at night, make all sprites black
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_A, MEDIUM
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, SCRN_X, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, 0, MEDIUM
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
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, MEDIUM
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_D, HARD
    LEVEL_WAIT 3
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_C, 0, HARD
    LEVEL_WAIT 9
    LEVEL_SPAWN BIRD, SPAWN_Y_A, 0, EASY
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_B, 0, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CACTUS, SPAWN_Y_D, SCRN_X, MEDIUM
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-2, SPAWN_X_A, MEDIUM
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-6, SPAWN_X_B, EASY
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM_Y, SPAWN_X_C, EASY
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y-4, SPAWN_X_D, EASY
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM_Y, SPAWN_X_B, HARD
    LEVEL_WAIT 3
    LEVEL_SPAWN ANVIL, 0, SPAWN_X_B, NONE ; TESTING
    LEVEL_WAIT 8
    GAME_WON ; testing
    LEVEL_END

Level6:
    ; Will be a boss fight
    ; LEVEL_SPAWN BOSS, 30, 30, NONE
    LEVEL_END

    ; Showdown Levels

Level7:
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
    LEVEL_WAIT 16
    GAME_WON

; Handler and Initializer

InitializeNewLevel::
    xor a ; ld a, 0
    ld [wLevelWaitCounter], a
    ld [wLevelWaitBoss], a

    ld a, [wLevel]
.level1:
    cp a, 1
    jr nz, .level2
    ld bc, Level1
    jr .setLevelDataAddress
.level2:
    cp a, 2
    jr nz, .level3
    ld bc, Level2
    jr .setLevelDataAddress
.level3:
    cp a, 3
    jr nz, .level4
    ld bc, Level3
    jr .setLevelDataAddress
.level4:
    cp a, 4
    jr nz, .end
    ld bc, Level4
    jr .setLevelDataAddress
.setLevelDataAddress:
    ld hl, wLevelDataAddress
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
.end:
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
    ldh [hEnemyNumber], a
    ld b, a
    ; Update enemy Y/X
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ; Update difficulty
    ld [hEnemyDifficulty], a
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
    cp a, PROJECTILE
    jp z, SpawnProjectile
    cp a, BOSS
    jp z, SpawnBoss
    cp a, BOSS_NEEDLE
    jp z, SpawnBossNeedle
    cp a, ANVIL 
    jp z, SpawnAnvil
    cp a, BALLOON_ANVIL 
    jp z, SpawnBalloonAnvil
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
    cp a, LEVEL_WAIT_BOSS_KEY
    jr z, .waitBoss
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
.waitBoss:
    ld a, [wLevelWaitBoss]
    cp a, 0
    ret z
    inc hl
    ld a, l
    ld [wLevelDataAddress], a
    ld a, h
    ld [wLevelDataAddress+1], a
    ret
.end:
    call CanFadeLevel
    jr z, .incrementLevel
    call FadeOutPalettes
    ret z
.incrementLevel:
    ld a, [wLevel] 
    inc a
    ld [wLevel], a 
    jp StageClear
.won:
    call FadeOutPalettes
    ret z
    jp GameWon