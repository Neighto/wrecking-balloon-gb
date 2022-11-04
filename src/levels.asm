INCLUDE "hardware.inc"
INCLUDE "macro.inc"
INCLUDE "constants.inc"
INCLUDE "enemyConstants.inc"

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

SECTION "level vars", WRAM0
    wLevel:: DB
    wLevelDataAddress:: DS 2
    wLevelWaitCounter:: DB
    wLevelWaitBoss:: DB
    wLevelRepeatCounter:: DB

SECTION "level data", ROM0

; LEVEL INSTRUCTIONS *************************************

; City Levels

Level1:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 8
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_B
    LVL__WAIT 6
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 4
    LVL__WAIT 4
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A
    LVL__WAIT 6
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__WAIT 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__WAIT 2
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__WAIT 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__WAIT 6
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B
    LVL__WAIT 8
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_A
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_C
    LVL__WAIT 5
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D - 8
    LVL__WAIT 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__WAIT 2
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B - 4
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C + 4
    LVL__WAIT 6
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
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_B + 4
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
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B + 64
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B + 32
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B
    LVL__WAIT 5
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    ; Could add here, about 55 seconds now
.outro:
    LVL__WAIT 11
    LVL__VICTORY_SONG
    LVL__WAIT 8
    LVL__EXPLOSION_CONGRATULATIONS_______ 40, 40
    LVL__EXPLOSION_CONGRATULATIONS_______ 30, 90
    LVL__EXPLOSION_CONGRATULATIONS_______ 42, 112
    LVL__WAIT 4
    LVL__END
    
Level2:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__WAIT 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B + 6
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_A
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 8
    LVL__BALLOON_CARRIER_NORMAL_LEFT_____ SPAWN_Y_B - 8
    LVL__WAIT 4
    LVL__POINT_BALLOON_HARD______________ 76
    LVL__WAIT 8
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_B + 16
    LVL__WAIT 1
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_B - 18
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 6
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B + 6
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A + 6
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ 76
    LVL__WAIT 4
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_B
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 6
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_A
    LVL__WAIT 3
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D - 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D + 1
    LVL__WAIT 8
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A + 2
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C + 3
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A + 3
    LVL__WAIT 2
    LVL__BALLOON_CARRIER_PROJECTILE_RIGHT SPAWN_Y_C
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B + 3
    LVL__WAIT 10
    LVL__BALLOON_CARRIER_FOLLOW_LEFT_____ SPAWN_Y_A + 4
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D - 16
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D - 32
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 4
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 12
    LVL__WAIT 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 12
    LVL__WAIT 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 12
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN - 8
    LVL__WAIT 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 12
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN - 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 8
    LVL__WAIT 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C + 8
    LVL__WAIT 2
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C + 8
    LVL__WAIT 10
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_A + 6
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN - 4
    LVL__BALLOON_CARRIER_PROJECTILE_RIGHT SPAWN_Y_B + 8
    LVL__WAIT 6
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__WAIT 2
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A + 4
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_D - 4
    LVL__WAIT 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B
    LVL__WAIT 2
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__WAIT 6
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_A
    LVL__BALLOON_CARRIER_PROJECTILE_RIGHT SPAWN_Y_D - 1
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C + 2
    LVL__WAIT 2
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_C - 8
    LVL__WAIT 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 4
    LVL__WAIT 3
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A + 4
    ; Could add here, about 1 minute now
.outro:
    LVL__WAIT 16
    LVL__VICTORY_SONG
    LVL__WAIT 8
    LVL__EXPLOSION_CONGRATULATIONS_______ 46, 108
    LVL__EXPLOSION_CONGRATULATIONS_______ 34, 40
    LVL__EXPLOSION_CONGRATULATIONS_______ 40, 74
    LVL__WAIT 4
    LVL__END

; Desert Levels

Level3:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 8
    LVL__WAIT 2
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D + 3
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 3
    LVL__WAIT 4
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__WAIT 4
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
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 2
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__WAIT 5
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
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B + 4
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A + 5
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B + 20
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_C + 5
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_B + 36
    LVL__WAIT 1
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D + 8
    LVL__WAIT 8
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
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN
    LVL__WAIT 1
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__WAIT 1
    LVL__BOMB_DIRECT_____________________ SPAWN_X_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__WAIT 8
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D + 8
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D
    LVL__WAIT 1
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__WAIT 2
    LVL__BALLOON_CARRIER_FOLLOW_RIGHT____ SPAWN_Y_A
    LVL__WAIT 8
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN - 16
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN + 16
    ; Could add here, about 1 minute now
.outro:
    LVL__WAIT 16
    LVL__VICTORY_SONG
    LVL__WAIT 8
    LVL__EXPLOSION_CONGRATULATIONS_______ 20, 120
    LVL__EXPLOSION_CONGRATULATIONS_______ 46, 114
    LVL__EXPLOSION_CONGRATULATIONS_______ 24, 40
    LVL__WAIT 4
    LVL__END

Level4:
.intro:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C + 8
    LVL__WAIT 4
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 12
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A - 3
    LVL__WAIT 4
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_D
    LVL__WAIT 4
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A + 8
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_B
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A + 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B
    LVL__WAIT 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D - 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_C
    LVL__WAIT 4
    LVL__BALLOON_CARRIER_NORMAL_RIGHT____ SPAWN_Y_B
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_C + 24
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_C + 12
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_A + 12
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_B + 7
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_C + 5
    LVL__WAIT 12
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A
.birdWallsIntro:
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_A
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D
    LVL__WAIT 2
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
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_B + 2
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_A + 2
    LVL__REPT 1, .birdWallsBody
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
    LVL__WAIT 2
    LVL__BALLOON_CARRIER_PROJECTILE_RIGHT SPAWN_Y_A
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_B + 8
    LVL__WAIT 2
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__WAIT 2
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_C
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_D
    LVL__WAIT 4
    LVL__BOMB_DIRECT_____________________ MIDDLE_SCREEN
.trick2:
    LVL__POINT_BALLOON_EASY______________ MIDDLE_SCREEN - 20
    LVL__POINT_BALLOON_MEDIUM____________ MIDDLE_SCREEN + 20
    LVL__WAIT 3
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__BALLOON_CARRIER_PROJECTILE_LEFT_ SPAWN_Y_D - 4
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
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 6
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
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN - 18
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN + 12
.outro:
    LVL__WAIT 16
    LVL__VICTORY_SONG
    LVL__WAIT 8
    LVL__EXPLOSION_CONGRATULATIONS_______ 60, 60
    LVL__EXPLOSION_CONGRATULATIONS_______ 46, 106
    LVL__EXPLOSION_CONGRATULATIONS_______ 36, 40
    LVL__WAIT 4
    LVL__END

; Showdown Levels

Level5:
.intro:
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_C
    LVL__WAIT 8
    LVL__BIRD_EASY_LEFT__________________ SPAWN_Y_D - 8
    LVL__BIRD_EASY_RIGHT_________________ SPAWN_Y_A
    LVL__BALLOON_CARRIER_BOMB_RIGHT______ SPAWN_Y_B + 4
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__POINT_BALLOON_HARD______________ MIDDLE_SCREEN
    LVL__WAIT 3
    LVL__BALLOON_CARRIER_BOMB_LEFT_______ SPAWN_Y_B + 4
    LVL__WAIT 8
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_A
    LVL__BOMB_FOLLOW_____________________ SPAWN_X_C - 4
    LVL__WAIT 8
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_D + 4
    LVL__BOMB_DIRECT_____________________ SPAWN_X_D + 4
    LVL__POINT_BALLOON_MEDIUM____________ SPAWN_X_B - 4
    LVL__BOMB_DIRECT_____________________ SPAWN_X_B - 4
    LVL__WAIT 8
.trick1:
    LVL__POINT_BALLOON_EASY______________ SPAWN_X_A - 10
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
.trick2:
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
    LVL__POINT_BALLOON_HARD______________ SPAWN_X_A
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
    LVL__WAIT 16
    LVL__VICTORY_SONG
    LVL__WAIT 8
    LVL__EXPLOSION_CONGRATULATIONS_______ 90, 130
    LVL__EXPLOSION_CONGRATULATIONS_______ 84, 50
    LVL__EXPLOSION_CONGRATULATIONS_______ 60, 90
    LVL__WAIT 4
    LVL__END

Level6:
    LVL__WAIT_BOSS
.outro:
    LVL__WAIT 6
    LVL__VICTORY_SONG
    LVL__WAIT 8
    LVL__EXPLOSION_CONGRATULATIONS_______ 40, 74
    LVL__EXPLOSION_CONGRATULATIONS_______ 20, 30
    LVL__EXPLOSION_CONGRATULATIONS_______ 38, 40
    LVL__EXPLOSION_CONGRATULATIONS_______ 20, 130
    LVL__EXPLOSION_CONGRATULATIONS_______ 38, 116
    LVL__WAIT 4
    LVL__GAME_WON

; Handler and Initializer

InitializeNewLevel::
    xor a ; ld a, 0
    ld [wLevelWaitCounter], a
    ld [wLevelWaitBoss], a
    ld [wLevelRepeatCounter], a

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

    ; Update enemy number
    ld a, [hli]
    ldh [hEnemyNumber], a
    ld b, a
    ; Update variant
    ld a, [hli]
    ldh [hEnemyVariant], a
    ; Update enemy Y/X
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ; Spawns
    ld a, b
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
    cp a, LEVEL_VICTORY_SONG_KEY
    jr z, .victorySong
    cp a, LEVEL_END_KEY
    jr z, .end
    cp a, GAME_WON_KEY
    jp z, .won
    cp a, LEVEL_REPEAT_KEY
    jr z, .repeat
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
    jr nz, .waitBossEnd
    call WaitBossUpdate
    ret
.waitBossEnd:
    inc hl
    ld a, l
    ld [wLevelDataAddress], a
    ld a, h
    ld [wLevelDataAddress+1], a
    ret
.victorySong:
    inc hl
    ld a, l
    ld [wLevelDataAddress], a
    ld a, h
    ld [wLevelDataAddress+1], a
    call ClearSound
    ld hl, levelWonTheme
	jp hUGE_init
.repeat:
    ; Next instructions: times to repeat and address
    inc hl
    ld a, [wLevelRepeatCounter]
    cp a, [hl]
    jr nc, .repeatEnd
    inc a
    ld [wLevelRepeatCounter], a
    inc hl
    ld a, [hli]
    ld [wLevelDataAddress], a
    ld a, [hl]
    ld [wLevelDataAddress+1], a
    ret
.repeatEnd:
    inc hl
    inc hl
    inc hl
    ld a, l
    ld [wLevelDataAddress], a
    ld a, h
    ld [wLevelDataAddress+1], a
    xor a ; ld a, 0
    ld [wLevelRepeatCounter], a
    ret
.end:
    ld a, [wLevel] 
    inc a
    ld [wLevel], a 
    jp StageClear
.won:
    call FadeOutPalettes
    ret z
    jp GameWon