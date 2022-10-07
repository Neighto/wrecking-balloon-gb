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
    wLevelWaitCounter:: DB
    wLevelWaitBoss:: DB
    wLevelDataAddress:: DS 2

SECTION "level data", ROM0

; LEVEL INSTRUCTIONS *************************************

; City Levels

Level1:
    GAME_WON
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_EASY_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_EASY_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B, OFFSCREEN_RIGHT, CARRIER_NORMAL_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C + 4, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_A, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_HARD_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_EASY_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A, OFFSCREEN_LEFT, CARRIER_NORMAL_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_C, OFFSCREEN_RIGHT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 5
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D - 8, BALLOON_EASY_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_EASY_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM + 2, SPAWN_X_A, BALLOON_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM - 6, SPAWN_X_D, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM + 4, SPAWN_X_B - 4, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM - 12, SPAWN_X_C + 4, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B - 2, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B - 16, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A + 2, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_C + 8, OFFSCREEN_LEFT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C + 2, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C + 16, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D - 2, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_D - 8, OFFSCREEN_RIGHT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C - 6, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C - 19, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B - 3, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B - 19, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B + 4, OFFSCREEN_LEFT, CARRIER_NORMAL_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A, OFFSCREEN_RIGHT, CARRIER_NORMAL_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A - 8, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_D, OFFSCREEN_RIGHT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 5
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 8, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D - 10, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B, OFFSCREEN_LEFT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 3
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 32, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B + 64, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B + 32, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 5
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_HARD_VARIANT
    ; Could add here, about 55 seconds now
    LEVEL_WAIT 11
    LEVEL_VICTORY_SONG
    LEVEL_WAIT 8
    LEVEL_SPAWN EXPLOSION, 40, 40, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 30, 90, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 42, 112, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_WAIT 4
    LEVEL_END
    
Level2:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 6, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A, OFFSCREEN_RIGHT, CARRIER_NORMAL_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 8, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B - 8, OFFSCREEN_LEFT, CARRIER_NORMAL_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, 76, BALLOON_HARD_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B + 16, OFFSCREEN_RIGHT, CARRIER_NORMAL_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B - 18, OFFSCREEN_RIGHT + 4, CARRIER_NORMAL_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C + 6, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 6, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A + 6, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, 76, BALLOON_EASY_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B, OFFSCREEN_LEFT, CARRIER_PROJECTILE_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_EASY_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A, OFFSCREEN_RIGHT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 3
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D - 8, BALLOON_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 1, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A + 2, BALLOON_HARD_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C + 3, BALLOON_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A + 3, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_C, OFFSCREEN_RIGHT, CARRIER_PROJECTILE_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 3, BALLOON_HARD_VARIANT
    LEVEL_WAIT 10
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A + 4, OFFSCREEN_LEFT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM - 4, SPAWN_X_D - 16, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D - 32, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D + 4, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A - 12, BALLOON_EASY_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A - 12, BALLOON_EASY_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 12, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, MIDDLE_SCREEN - 8, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 12, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, MIDDLE_SCREEN - 8, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 8, BALLOON_EASY_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 8, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C + 8, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C + 8, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 10
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A + 6, OFFSCREEN_LEFT, CARRIER_PROJECTILE_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN - 4, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B + 8, OFFSCREEN_RIGHT, CARRIER_PROJECTILE_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A + 4, BALLOON_HARD_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_D - 4, OFFSCREEN_RIGHT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_A, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_HARD_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A, OFFSCREEN_LEFT, CARRIER_PROJECTILE_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_D - 1, OFFSCREEN_RIGHT, CARRIER_PROJECTILE_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C + 2, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_C - 8, OFFSCREEN_LEFT, CARRIER_PROJECTILE_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A - 4, BALLOON_EASY_VARIANT
    LEVEL_WAIT 3
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A + 4, BALLOON_HARD_VARIANT
    ; Could add here, about 1 minute now
    LEVEL_WAIT 16
    LEVEL_VICTORY_SONG
    LEVEL_WAIT 8
    LEVEL_SPAWN EXPLOSION, 46, 108, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 34, 40, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 40, 74, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_WAIT 4
    LEVEL_END

; Desert Levels

Level3:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A - 8, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_EASY_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 3, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 3, BALLOON_EASY_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BALLOON_HARD_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BIRD, SPAWN_Y_C + 8, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_A - 8, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B - 8, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C - 8, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D, BOMB_FOLLOW_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_B, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B - 12, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C, BOMB_FOLLOW_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BIRD, SPAWN_Y_A, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_EASY_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_D, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D - 7, BALLOON_HARD_VARIANT
    LEVEL_WAIT 3
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A + 5, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_A + 8, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 5, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_B + 16, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_WAIT 5
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A - 2, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 5
    LEVEL_SPAWN BIRD, SPAWN_Y_A, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_B, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 16, BALLOON_HARD_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_A, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BALLOON_EASY_VARIANT
    LEVEL_WAIT 3
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 4, BALLOON_HARD_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_A + 5, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 20, BALLOON_HARD_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_C + 5, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B + 36, BALLOON_HARD_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 8, BALLOON_HARD_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B - 4, OFFSCREEN_RIGHT, CARRIER_NORMAL_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN BIRD, SPAWN_Y_A - 2, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_D, OFFSCREEN_RIGHT + 4, BIRD_EASY_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A + 12, BALLOON_EASY_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BIRD, SPAWN_Y_B + 8, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 8, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BIRD, SPAWN_Y_C + 12, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A, OFFSCREEN_LEFT, CARRIER_PROJECTILE_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BIRD, SPAWN_Y_A, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_A, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 8, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_D, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_WAIT 1
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A, OFFSCREEN_RIGHT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM + 6, MIDDLE_SCREEN - 16, BALLOON_HARD_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM - 18, MIDDLE_SCREEN + 16, BALLOON_HARD_VARIANT
    ; Could add here, about 1 minute now
    LEVEL_WAIT 16
    LEVEL_VICTORY_SONG
    LEVEL_WAIT 8
    LEVEL_SPAWN EXPLOSION, 20, 120, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 46, 114, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 24, 40, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_WAIT 4
    LEVEL_END

Level4:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C + 3, BALLOON_EASY_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A + 12, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A - 3, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B, OFFSCREEN_RIGHT, CARRIER_NORMAL_VARIANT
    LEVEL_WAIT 5
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C + 24, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A + 12, OFFSCREEN_LEFT, CARRIER_PROJECTILE_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C - 4, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C + 10, BALLOON_EASY_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_A, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_HARD_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 6, BALLOON_EASY_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN BIRD, SPAWN_Y_D, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A - 4, BALLOON_EASY_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BIRD, SPAWN_Y_C, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B - 10, OFFSCREEN_RIGHT, CARRIER_FOLLOW_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A - 16, BALLOON_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A, OFFSCREEN_RIGHT, CARRIER_PROJECTILE_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_B + 8, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BIRD, SPAWN_Y_D, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BALLOON_HARD_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_EASY_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B - 16, BALLOON_EASY_VARIANT
    LEVEL_WAIT 3
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_HARD_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_D - 4, OFFSCREEN_LEFT, CARRIER_PROJECTILE_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B - 16, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C + 16, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 6, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A - 8, OFFSCREEN_LEFT, CARRIER_FOLLOW_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_A, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BIRD, SPAWN_Y_B + 10, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B - 4, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BIRD, SPAWN_Y_D - 8, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BALLOON_EASY_VARIANT
    LEVEL_WAIT 6
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D - 4, BALLOON_HARD_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_A + 12, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B - 16, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BALLOON_HARD_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN + 16, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN BIRD, SPAWN_Y_D - 8, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_A, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_C - 12, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_WAIT 3
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 4, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 4
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BALLOON_HARD_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN - 18, BALLOON_HARD_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN + 12, BALLOON_HARD_VARIANT
    LEVEL_WAIT 16
    LEVEL_VICTORY_SONG
    LEVEL_WAIT 8
    LEVEL_SPAWN EXPLOSION, 60, 60, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 46, 106, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 36, 40, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_WAIT 4
    LEVEL_END

; Showdown Levels

Level5:
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_HARD_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B, OFFSCREEN_RIGHT, CARRIER_BOMB_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_D - 8, OFFSCREEN_LEFT, BIRD_EASY_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_A, OFFSCREEN_RIGHT, BIRD_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, MIDDLE_SCREEN, BALLOON_HARD_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D + 12, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 20
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_EASY_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_A, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C, BOMB_DIRECT_VARIANT
    LEVEL_WAIT 2
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B, BOMB_DIRECT_VARIANT
    ; continue editing
    ; LEVEL_SPAWN PROJECTILE, SPAWN_Y_A, OFFSCREEN_LEFT + 12, BIRD_EASY_VARIANT
    ; LEVEL_WAIT 8

    LEVEL_WAIT 8
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D, BOMB_DIRECT_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_EASY_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 16
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_HARD_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B, OFFSCREEN_RIGHT, CARRIER_PROJECTILE_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_C, OFFSCREEN_LEFT, CARRIER_BOMB_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_C, BALLOON_MEDIUM_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_EASY_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_A, BALLOON_HARD_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_D, BOMB_FOLLOW_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_A, OFFSCREEN_LEFT, CARRIER_FOLLOW_VARIANT
    LEVEL_SPAWN BIRD, SPAWN_Y_C, OFFSCREEN_RIGHT, BIRD_HARD_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_B, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_D, BALLOON_EASY_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN BIRD, SPAWN_Y_A, OFFSCREEN_LEFT, BIRD_HARD_VARIANT
    LEVEL_SPAWN BALLOON_CARRIER, SPAWN_Y_B, OFFSCREEN_LEFT, CARRIER_BOMB_VARIANT
    LEVEL_WAIT 8
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM-2, SPAWN_X_A, BALLOON_HARD_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM-6, SPAWN_X_B, BALLOON_HARD_VARIANT
    LEVEL_SPAWN BOMB, OFFSCREEN_BOTTOM, SPAWN_X_C, BOMB_FOLLOW_VARIANT
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM-4, SPAWN_X_D, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 16
    LEVEL_SPAWN POINT_BALLOON, OFFSCREEN_BOTTOM, SPAWN_X_B, BALLOON_MEDIUM_VARIANT
    LEVEL_WAIT 16
    LEVEL_VICTORY_SONG
    LEVEL_WAIT 8
    LEVEL_SPAWN EXPLOSION, 90, 130, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 84, 50, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 60, 90, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_WAIT 4
    LEVEL_END

Level6:
    LEVEL_WAIT_BOSS
    LEVEL_WAIT 6
    LEVEL_VICTORY_SONG
    LEVEL_WAIT 8
    LEVEL_SPAWN EXPLOSION, 40, 74, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 20, 30, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 38, 40, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 20, 130, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_SPAWN EXPLOSION, 38, 116, EXPLOSION_CONGRATULATIONS_VARIANT
    LEVEL_WAIT 4
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
    ld a, [hli]
    ; Update enemy number
    ldh [hEnemyNumber], a ; TODO this should just be done in the spawn for that given enemy
    ld b, a
    ; Update enemy Y/X
    ld a, [hli]
    ldh [hEnemyY], a
    ld a, [hli]
    ldh [hEnemyX], a
    ld a, [hli]
    ; Update variant
    ld [hEnemyVariant], a
    ld a, b
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
	call hUGE_init
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