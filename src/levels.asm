INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "constants.inc"
INCLUDE "enemyConstants.inc"
INCLUDE "playerConstants.inc"

LEVEL_UPDATE_REFRESH_TIME EQU %00001111

; Common Spawning Coordinates
SPAWN_Y_A EQU 28
SPAWN_Y_B EQU 56
SPAWN_Y_C EQU 84
SPAWN_Y_D EQU 112
SPAWN_X_A EQU 32
SPAWN_X_B EQU 64
SPAWN_X_C EQU 96
SPAWN_X_D EQU 128

SECTION "level vars", HRAM
    hLevel:: DB
    hLevelDataAddress:: DS 2
    hLevelWaitCounter:: DB
    hLevelWaitBoss:: DB
    hLevelRepeatCounter:: DB

SECTION "level data", ROM0

; LEVEL INSTRUCTIONS *************************************

; City Levels

; Level 1
Level1:
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_C + 8
    LVL__WAIT 10
.intro:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__WAIT 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 8
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_B
    LVL__WAIT 6
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__WAIT 4
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN - 28
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN + 28
    LVL__WAIT 6
.trick1:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__WAIT 3
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__WAIT 8
.trick2:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B - 8
    LVL__WAIT 6
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B - 8
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C + 8
    LVL__WAIT 6
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C + 8
    LVL__WAIT 8
.introduceFollowCarrier:
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_A
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_C
    LVL__WAIT 5
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D - 8
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A + 8
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B - 8
    LVL__WAIT 8
.trick3:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B - 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B - 16
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A + 2
    LVL__BALLOON_CARRIER_FOLLOW_LEFT_____ SPAWN_Y_C + 8
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 16
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D - 2
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_D - 8
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C - 6
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C - 19
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B - 3
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B - 19
    LVL__WAIT 4
.trick4:
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_A - 1
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_B - 1
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_C - 1
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_D - 1
    LVL__WAIT 6
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__WAIT 3
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 16
    LVL__WAIT 7
.trick5:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__WAIT 2
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__WAIT 2
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A
    LVL__REPT 1, .trick5
.trick6:
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN - 32
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_D + 12
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN + 8
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_A - 8
    LVL__WAIT 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 2
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A + 24
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A + 50
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A + 76
    LVL__WAIT 6
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__WAIT 2
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D - 24
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D - 50
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D - 76
    LVL__WAIT 6
.trick7:
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_B - 8
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_A
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 8
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_D
    LVL__WAIT 5
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 8
    LVL__WAIT 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D - 10
    LVL__BALLOON_CARRIER_FOLLOW_LEFT_____ SPAWN_Y_B
    LVL__WAIT 3
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B + 32
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B
    LVL__WAIT 5
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__WAIT 3
.fun:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 8
    LVL__WAIT 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B - 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 8
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
.outro:
    LVL__REPT 1, LevelOutro
    
; Level 2
Level2:
.intro:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 6
    LVL__WAIT 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B - 6
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 4
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_A
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 8
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_B - 8
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__WAIT 4
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__WAIT 8
.trick1:
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_B
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 16
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B + 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A + 8
    LVL__WAIT 6
.introduceProjectileCarrier:
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN + 64
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN + 32
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__WAIT 4
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_B
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN + 32
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN + 64
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_A
    LVL__WAIT 9
.trick2:
    ; Right 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D + 16
    LVL__WAIT 3
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 12
    ; Right 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C + 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__WAIT 3
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C + 4
    ; Left 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B - 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__WAIT 3
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B - 4
    ; Left 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 16
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A - 8
    LVL__WAIT 3
    ; Dash back right
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__BALLOON_CARRIER_PROJECTILE_RIGHT SPAWN_Y_C
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__WAIT 2
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A - 4
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B - 4
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C - 4
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 16
    LVL__WAIT 6
.trick3:
    LVL__BALLOON_CARRIER_FOLLOW_LEFT_____ SPAWN_Y_A + 8
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_C + 8
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D - 4
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D - 24
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 16
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B + 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 8
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_A
    LVL__WAIT 10
.trick4:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 12
    LVL__WAIT 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 12
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 12
    LVL__WAIT 0
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN - 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 12
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN - 8
    LVL__WAIT 0
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN - 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 8
    LVL__WAIT 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C + 8
    LVL__WAIT 0
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 8
    LVL__WAIT 0
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C + 8
    LVL__REPT 1, .trick4
    LVL__WAIT 7
.theWall:
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_D - 8
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_D - 8
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_C - 16
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_C - 16
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_B - 24
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_B - 24
    LVL__WAIT 5
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__WAIT 0
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__WAIT 9
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN + 24
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN - 24
    LVL__WAIT 5
.finalTrick:
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_A + 8
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__BALLOON_CARRIER_PROJECTILE_RIGHT SPAWN_Y_D - 8
    LVL__WAIT 5
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__WAIT 3
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A - 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 8
    LVL__WAIT 6
.fun:
    LVL__WAIT 3
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A + 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D - 8
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A + 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D - 8
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__REPT 1, .fun
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN - 24
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN + 24
.outro:
    LVL__REPT 1, LevelOutro

; Desert Levels

; Level 3
Level3:
.intro:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 8
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D + 3
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 3
    LVL__WAIT 4
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__WAIT 4
.introduceBirds:
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_C + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A - 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B - 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C - 8
    LVL__WAIT 6
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_D
    LVL__WAIT 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B - 12
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_C
    LVL__WAIT 4
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__WAIT 8
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_D
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D - 7
    LVL__WAIT 3
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_D
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A + 5
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A + 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 5
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_B + 16
    LVL__WAIT 5
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__WAIT 5
.trick1:
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_B
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B + 16
    LVL__WAIT 2
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_A
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_D
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__WAIT 3
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__WAIT 4
.balloonsThroughBirdsTrick:
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B + 4
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A + 5
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B + 20
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_C + 5
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B + 36
    LVL__WAIT 1
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D + 8
    LVL__WAIT 1
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B - 4
    LVL__WAIT 1
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A - 5
    LVL__WAIT 8
.trick2:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_B - 4
    LVL__WAIT 1
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A - 2
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_D
    LVL__WAIT 4
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A + 12
    LVL__WAIT 4
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_B + 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 8
    LVL__WAIT 2
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_C + 12
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_A
    LVL__WAIT 2
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__WAIT 4
.trick3:
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__WAIT 1
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__WAIT 1
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__WAIT 1
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 16
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D + 16
    LVL__WAIT 2
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A - 16
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A - 16
    LVL__WAIT 8
.trick4:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 8
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_D
    LVL__WAIT 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 2
    LVL__BALLOON_CARRIER_FOLLOW_LEFT_____ SPAWN_Y_A
    LVL__WAIT 8
.birdStorm:
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_X_C - 8
    LVL__BIRD_EASY_LEFT__________________ SPAWN_X_A
    LVL__WAIT 4
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_X_D - 16
    LVL__BIRD_EASY_LEFT__________________ SPAWN_X_B
    LVL__WAIT 2
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__REPT 2, .birdStorm
    LVL__WAIT 5
.trickFinal:
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN - 24
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN + 24
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN - 24
    LVL__WAIT 8
    LVL__BOMB_FOLLOW_____________________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN - 16
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN + 16
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_B
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_B
    LVL__WAIT 6
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__WAIT 6
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN + 16
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN - 16
.outro:
    LVL__REPT 1, LevelOutro

; Level 4
Level4:
.intro:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C + 8
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 12
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A - 3
    LVL__WAIT 4
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__WAIT 4
.introduceBirds:
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A + 8
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_B
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B
    LVL__WAIT 5
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D - 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C
    LVL__WAIT 3
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D + 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D + 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B + 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C + 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 8
    LVL__WAIT 4
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_C + 12
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_A + 12
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__WAIT 12
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A
    LVL__WAIT 6
.birdWallsIntro:
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D
    LVL__WAIT 2
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_B + 4
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_C + 4
    LVL__WAIT 5
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_B - 8
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_C
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__WAIT 6
.birdWallsBody:
    ; Wave 1
    LVL__WAIT 4
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_C + 4
    ; LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_B + 4
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A + 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    ; Wave 2
    LVL__WAIT 6
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_C
    ; LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D + 4
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_C + 8
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_B + 8
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A + 8
    ; Wave 3
    LVL__WAIT 3
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__WAIT 4
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_A - 6
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_B - 6
    ; LVL__REPT 1, .birdWallsBody
.birdWallsOutro:
    LVL__WAIT 6
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_C + 4
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_B + 4
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A + 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D - 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 4
    LVL__WAIT 4
    LVL__ANVIL_NORMAL____________________ SPAWN_X_B
    LVL__WAIT 8
.trick1:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 16
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_B + 8
    LVL__WAIT 2
    LVL__BALLOON_CARRIER_PROJECTILE_RIGHT SPAWN_Y_A
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_B + 8
    LVL__WAIT 2
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__WAIT 4
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__WAIT 2
.trick2:
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN - 24
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__WAIT 2
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_D - 4
    LVL__BALLOON_CARRIER_PROJECTILE_RIGHT SPAWN_Y_D - 4
    LVL__WAIT 2
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN - 8
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN + 8
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN - 8
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN + 8
    LVL__WAIT 8
.trick3:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D + 6
    LVL__WAIT 2
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_D
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_C
    LVL__POINT_BALLOON_EASY______________ SPAWN_Y_A
    LVL__BALLOON_CARRIER_FOLLOW_LEFT_____ SPAWN_Y_A - 4
    LVL__WAIT 4
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A
    LVL__WAIT 4
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_B + 10
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B - 12
    LVL__WAIT 2
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_D - 8
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__WAIT 6
.trick4:
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D - 4
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A + 12
    LVL__WAIT 2
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_B - 16
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_D
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN + 16
    LVL__WAIT 4
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_D - 8
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_A
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_C
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_C - 12
    LVL__WAIT 3
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D + 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN - 32
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN + 32
    LVL__WAIT 3
.trick5:
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_B
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_C
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_D
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A - 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 8
    LVL__WAIT 4
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A - 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 8
    LVL__WAIT 2
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN - 18
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN + 12
.outro:
    LVL__REPT 1, LevelOutro

; Showdown Levels

; Level 5
Level5:
.intro:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_C
    LVL__WAIT 8
.introduceBombCarrier:
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A
    LVL__BALLOON_CARRIER_BOMB_RIGHT______ SPAWN_Y_D - 8
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_B
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_C
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_D - 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__WAIT 9
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B - 16
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A - 16
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A - 16
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B - 16
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_A - 8
    LVL__BALLOON_CARRIER_FOLLOW_LEFT_____ SPAWN_Y_A - 8
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__BALLOON_CARRIER_BOMB_LEFT_______ SPAWN_Y_D - 8
    LVL__WAIT 16
.trick1:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_D - 4
    LVL__BOMB_FOLLOW_____________________ MIDDLE_SCREEN
    LVL__BALLOON_CARRIER_PROJECTILE_RIGHT SPAWN_Y_D - 4
    LVL__WAIT 5
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN - 16
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN + 16
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__WAIT 9
.introduceHardBird:
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A
    LVL__BIRD_HARD_RIGHT_________________ SPAWN_Y_C
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__WAIT 16
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_C + 5
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A + 4
    LVL__BIRD_HARD_LEFT__________________ SPAWN_Y_B + 8
    LVL__WAIT 6
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B - 5
    LVL__WAIT 6
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A - 16
    LVL__WAIT 5
.trick2:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 16
    LVL__WAIT 6
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C
    LVL__WAIT 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_D
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_C
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_B
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_A
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A - 10
    LVL__WAIT 8
.trick3:
    LVL__BALLOON_CARRIER_BOMB_RIGHT______ SPAWN_Y_C + 8
    LVL__BALLOON_CARRIER_BOMB_RIGHT______ SPAWN_Y_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A
    LVL__WAIT 4
    LVL__BALLOON_CARRIER_BOMB_RIGHT______ SPAWN_Y_B
    LVL__BALLOON_CARRIER_BOMB_RIGHT______ SPAWN_Y_C + 8
    LVL__WAIT 4
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_A - 4
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_B - 4
    LVL__WAIT 4
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A
    LVL__WAIT 8
.lotsOfHardBirds:
    LVL__BIRD_HARD_LEFT__________________ SPAWN_Y_B - 8
    LVL__BIRD_HARD_LEFT__________________ SPAWN_Y_D - 8
    LVL__BIRD_HARD_LEFT__________________ SPAWN_Y_C - 8
    LVL__WAIT 2
    LVL__BIRD_HARD_RIGHT_________________ SPAWN_Y_A - 8
    LVL__BIRD_HARD_RIGHT_________________ SPAWN_Y_C - 8
    LVL__BIRD_HARD_RIGHT_________________ SPAWN_Y_B - 8
    LVL__WAIT 6
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 8
    LVL__WAIT 6
    LVL__REPT 1, .lotsOfHardBirds
.trick5:
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_C + 8
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_A
    LVL__BALLOON_CARRIER_BOMB_RIGHT______ SPAWN_Y_A
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_D
    LVL__WAIT 16
.twister:
    LVL__WAIT 2
    LVL__BALLOON_CARRIER_BOMB_LEFT_______ SPAWN_Y_A + 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__WAIT 5
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__BIRD_HARD_LEFT__________________ SPAWN_Y_D - 8
    LVL__REPT 2, .twister
    LVL__WAIT 8
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__WAIT 6
.finalPop:
    ; Wave 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    ; Wave 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    ; Wave 3
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN - 20
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN + 20
    LVL__WAIT 2
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
.outro:
    LVL__REPT 1, LevelOutro

; Level 6
Level6:
    LVL__WAIT_BOSS
.outro:
    LVL__WAIT 2
    LVL__POINTS_FOR_LIVES
    LVL__VICTORY_SONG
    LVL__WAIT 8
    LVL__GAME_WON

LevelOutro:
    LVL__WAIT 16
    LVL__VICTORY_SONG
    LVL__WAIT 8
    LVL__SPAWN_RANDOM EXPLOSION, EXPLOSION_CONGRATULATIONS_VARIANT, 16, 8, 60, 144
    LVL__SPAWN_RANDOM EXPLOSION, EXPLOSION_CONGRATULATIONS_VARIANT, 16, 8, 60, 144
    LVL__SPAWN_RANDOM EXPLOSION, EXPLOSION_CONGRATULATIONS_VARIANT, 16, 8, 60, 144
    LVL__SPAWN_RANDOM EXPLOSION, EXPLOSION_CONGRATULATIONS_VARIANT, 16, 8, 60, 144
    LVL__SPAWN_RANDOM EXPLOSION, EXPLOSION_CONGRATULATIONS_VARIANT, 16, 8, 60, 144
    LVL__WAIT 4
    LVL__END

; Handler and Initializer

InitializeNewLevel::
    xor a ; ld a, 0
    ldh [hLevelWaitCounter], a
    ldh [hLevelWaitBoss], a
    ldh [hLevelRepeatCounter], a

    ldh a, [hLevel]
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
    jr nz, .level5
    ld bc, Level4
    jr .setLevelDataAddress
.level5:
    cp a, 5
    jr nz, .level6
    ld bc, Level5
    jr .setLevelDataAddress
.level6:
    ; cp a, 6
    ; jr nz, .level7
    ld bc, Level6
    ; jr .setLevelDataAddress
.setLevelDataAddress:
    ld hl, hLevelDataAddress
    ld a, LOW(bc)
    ld [hli], a
    ld a, HIGH(bc)
    ld [hl], a
    ret

InitializeLevelVars::
    ld a, 1
    ldh [hLevel], a
    jp InitializeNewLevel

SpawnDataHandler:
    ; Argument hl = source address

    ; Update enemy Y/X
.random:
    ld a, [hli] ; y1
    ld e, a 
    ld a, [hli] ; x1
    ld c, a 
    ld a, [hli] ; y2
    sub a, e
    inc a
    RANDOM a
    add a, e
    ldh [hEnemyY], a
    ld a, [hli] ; x2
    sub a, c
    inc a
    RANDOM a
    add a, c
    ldh [hEnemyX], a
    jr .updateAfterXY
.top:
    ld a, OFFSCREEN_TOP
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    jr .updateAfterXY
.left:
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, OFFSCREEN_LEFT
    ldh [hEnemyX], a
    jr .updateAfterXY
.right:
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, OFFSCREEN_RIGHT
    ldh [hEnemyX], a
    jr .updateAfterXY
.bottom:
    ld a, OFFSCREEN_BOTTOM
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ; jr .updateAfterXY
.updateAfterXY:
    ; Update variant
    ld a, [hli]
    ld b, a
    and LOW_HALF_BYTE_MASK
    ldh [hEnemyVariant], a
    ; Update enemy number
    ld a, b
    and HIGH_HALF_BYTE_MASK
    swap a
    ldh [hEnemyNumber], a
.handleSpawns:
    ; Spawns
    push hl
.pointBalloon:
    cp a, POINT_BALLOON
    jr nz, .balloonCarrier
    call SpawnPointBalloon
    jr .end
.balloonCarrier:
    cp a, BALLOON_CARRIER
    jr nz, .bird
    call SpawnBalloonCarrier
    jr .end
.bird:
    cp a, BIRD
    jr nz, .bomb
    call SpawnBird
    jr .end
.bomb:
    cp a, BOMB
    jr nz, .anvil
    call SpawnBomb
    jr .end
.anvil: 
    cp a, ANVIL 
    jr nz, .explosion
    call SpawnAnvil
    jr .end
.explosion:
    cp a, EXPLOSION 
    jr nz, .projectile
    call SpawnExplosion
    jr .end
.projectile:
    cp a, PROJECTILE
    jr nz, .bossNeedle
    call SpawnProjectile
    jr .end
.bossNeedle:
    ; cp a, BOSS_NEEDLE
    ; jr nz, .end
    call SpawnBossNeedle
    ; jr .end
.end:
    pop hl
    ret

LevelDataHandler::
    ; Frequency we read 
    ldh a, [hGlobalTimer]
    and LEVEL_UPDATE_REFRESH_TIME
    ret nz

    ; Read next level instruction
    ldh a, [hLevelDataAddress]
    ld l, a
    ldh a, [hLevelDataAddress+1]
    ld h, a
    ld a, [hl]

    ; Interpret
.spawnBottom:
    cp a, LEVEL_SPAWN_BOTTOM_KEY
    jr nz, .spawnRight
    ; Next instructions: x, enemy 4-upper-bits | variant 4-lower-bits
    inc hl
    call SpawnDataHandler.bottom
    jp .incrementLevelDataAddress
.spawnRight:
    cp a, LEVEL_SPAWN_RIGHT_KEY
    jr nz, .spawnLeft
    ; Next instructions: y, enemy 4-upper-bits | variant 4-lower-bits
    inc hl
    call SpawnDataHandler.right
    jp .incrementLevelDataAddress
.spawnLeft:
    cp a, LEVEL_SPAWN_LEFT_KEY
    jr nz, .spawnTop
    ; Next instructions: y, enemy 4-upper-bits | variant 4-lower-bits
    inc hl
    call SpawnDataHandler.left
    jp .incrementLevelDataAddress
.spawnTop:
    cp a, LEVEL_SPAWN_TOP_KEY
    jr nz, .spawnRandom
    ; Next instructions: x, enemy 4-upper-bits | variant 4-lower-bits
    inc hl
    call SpawnDataHandler.top
    jr .incrementLevelDataAddress
.spawnRandom:
    cp a, LEVEL_SPAWN_RANDOM_KEY
    jr nz, .wait
    ; Next instructions: y1, x1, y2, x2, enemy 4-upper-bits | variant 4-lower-bits
    inc hl
    call SpawnDataHandler.random
    jr .incrementLevelDataAddress
.wait:
    cp a, LEVEL_WAIT_KEY
    jr nz, .waitBoss
    ; Next instruction: amount to wait
    inc hl
    ldh a, [hLevelWaitCounter]
    cp a, [hl]
    jr nc, .waitEnd
    inc a
    ldh [hLevelWaitCounter], a
    ret
.waitEnd:
    inc hl
    xor a ; ld a, 0
    ldh [hLevelWaitCounter], a
    jr .incrementLevelDataAddress
.waitBoss:
    cp a, LEVEL_WAIT_BOSS_KEY
    jr nz, .repeat
    ldh a, [hLevelWaitBoss]
    cp a, 0
    jr nz, .waitBossEnd
    jp WaitBossUpdate
.waitBossEnd:
    inc hl
    jr .incrementLevelDataAddress
.repeat:
    cp a, LEVEL_REPEAT_KEY
    jr nz, .victorySong
    ; Next instructions: times to repeat and address
    inc hl
    ldh a, [hLevelRepeatCounter]
    cp a, [hl]
    jr nc, .repeatEnd
    inc a
    ldh [hLevelRepeatCounter], a
    inc hl
    ld a, [hli]
    ldh [hLevelDataAddress], a
    ld a, [hl]
    ldh [hLevelDataAddress+1], a
    ret
.repeatEnd:
    inc hl
    inc hl
    inc hl
    xor a ; ld a, 0
    ldh [hLevelRepeatCounter], a
    jr .incrementLevelDataAddress
.victorySong:
    cp a, LEVEL_VICTORY_SONG_KEY
    jr nz, .pointsForLives
    inc hl
    push hl
    call ClearSound
    ld hl, levelWonTheme
	call hUGE_init
    pop hl
    jr .incrementLevelDataAddress
.pointsForLives:
    cp a, LEVEL_POINTS_FOR_LIVES_KEY
    jr nz, .end
    inc hl
    ldh a, [hPlayerLives]
.pointsForLivesLoop:
    cp a, 0
    jr z, .incrementLevelDataAddress
    dec a
    push af
    push hl
    ld a, EXTRA_LIFE_POINTS
    call AddPoints
    pop hl
    pop af
    jr .pointsForLivesLoop
    ; jr .incrementLevelDataAddress
.incrementLevelDataAddress:
    ld a, l
    ldh [hLevelDataAddress], a
    ld a, h
    ldh [hLevelDataAddress+1], a
    ret
.end:
    cp a, LEVEL_END_KEY
    jr nz, .won
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    ret z
    ldh a, [hLevel] 
    inc a
    ldh [hLevel], a 
    jp StageClear
.won:
    ; cp a, GAME_WON_KEY
    ; jr nz, .next
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_ALIVE_MASK
    ret z
    call FadeOutPalettes
    ret z
    jp GameWon