INCLUDE "points.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

BOMB_START_Y EQU 150
BOMB_SPAWN_A EQU 40
BOMB_SPAWN_B EQU 60
BOMB_SPAWN_C EQU 80
BOMB_SPAWN_D EQU 110
BOMB_DEFAULT_SPEED EQU 1

BOMB_SPRITE_MOVE_WAIT_TIME EQU %00000001

SECTION "bomb vars", WRAM0
    wBombOAM:: DB
    bomb_x:: DB
    bomb_y:: DB
    bomb_respawn_timer:: DB
    bomb_alive:: DB
    bomb_speed:: DB
    bomb_popping:: DB
    bomb_popping_frame:: DB
    bomb_pop_timer:: DB

SECTION "bomb", ROMX

UpdateBombPosition:
    push hl
    push af
    SET_HL_TO_ADDRESS wOAM, wBombOAM
    ; Update Y
    ld a, [bomb_y]
    ld [hli], a
    ; Update X
    ld a, [bomb_x]
    ld [hl], a
  
    SET_HL_TO_ADDRESS wOAM+4, wBombOAM
    ; Update Y
    ld a, [bomb_y]
    ld [hli], a
    ; Update X
    ld a, [bomb_x]
    add 8
    ld [hl], a

    SET_HL_TO_ADDRESS wOAM+8, wBombOAM
    ; Update Y
    ld a, [bomb_y]
    ld [hli], a
    ; Update X
    ld a, [bomb_x]
    add 16
    ld [hl], a
    pop af
    pop hl
    ret

SetSpawnPoint:
    push hl
    push af
    ld hl, bomb_x
    ld a, 4
    call RANDOM
    cp a, 0
    jr z, .spawnA
    cp a, 1
    jr z, .spawnB
    cp a, 2
    jr z, .spawnC
    cp a, 3
    jr z, .spawnD
.spawnA:
    ld [hl], BOMB_SPAWN_A
    jr .end
.spawnB:
    ld [hl], BOMB_SPAWN_B
    jr .end
.spawnC:
    ld [hl], BOMB_SPAWN_C
    jr .end
.spawnD:
    ld [hl], BOMB_SPAWN_D
.end:
    pop af
    pop hl
    ret

InitializeBomb::
    push af
    xor a ; ld a, 0
    ld [bomb_alive], a
    ld [bomb_respawn_timer], a
    ld [bomb_popping], a
    ld [bomb_popping_frame], a
    ld [bomb_pop_timer], a
    ld a, BOMB_SPAWN_A ; placeholder
    ld [bomb_x], a
    ld a, BOMB_START_Y
    ld [bomb_y], a
    ld a, BOMB_DEFAULT_SPEED
    ld [bomb_speed], a
    pop af
    ret

SpawnBomb:
    push af
    call InitializeBomb
    call SetSpawnPoint
    ld a, 1
    ld [bomb_alive], a

    ; Request OAM
    ld b, 3
    call RequestOAMSpaceOffset
    ld [wBombOAM], a

.balloonLeft:
    ; Balloon left
    SET_HL_TO_ADDRESS wOAM, wBombOAM
    ld a, [bomb_y]
    ld [hli], a
    ld a, [bomb_x]
    ld [hli], a
    ld a, $9C
    ld [hl], a
    inc l
    ld [hl], %00000000
.balloonRight:
    ; Balloon right
    inc l
    ld a, [bomb_y]
    ld [hli], a
    ld a, [bomb_x]
    add 8
    ld [hli], a
    ld a, $9C
    ld [hl], a
    inc l
    ld [hl], OAMF_XFLIP
.bombSpace:
    ; Keep out of sight
    inc l
    ld a, 1
    ld [hli], a
    ld [hli], a
    ld a, $00
    ld [hl], a
    inc l
    ld [hl], %00000000
.end:
    pop af
    ret

FloatBombUp:
    ld hl, bomb_y
    ld a, [bomb_speed]
    cpl
    add [hl]
    ld [hl], a
    call UpdateBombPosition
    ret

ClearBomb:
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, wBombOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret

BombUpdate::
    ; Check if alive
    ld a, [bomb_alive]
    cp a, 0
    jr z, .popped
    ; Check if we can move
    ld a, [global_timer]
    and	BOMB_SPRITE_MOVE_WAIT_TIME
    jr nz, .end
    call FloatBombUp
.checkOffscreen: ; TODO all moving entities should have this...
    ld a, [bomb_y]
    ld b, a
    call OffScreenYEnemies
    cp a, 0
    jr z, .end
    call ClearBomb
    xor a ; ld a, 0
    ld [bomb_alive], a
    ret
.popped:
    ; Can we respawn
    ld a, [bomb_respawn_timer]
    inc a
    ld [bomb_respawn_timer], a
    cp a, 150
    jr nz, .respawnSkip
    call SpawnBomb
.respawnSkip:
    ; Check if we need to play popping animation
    ld a, [bomb_popping]
    cp a, 0
    call nz, ExplosionAnimation
.end:
    ret

DeathOfBomb::
    ; Death
    xor a ; ld a, 0
    ld hl, bomb_alive
    ld [hl], a
    ; Animation trigger
    ld hl, bomb_popping
    ld [hl], 1
    ; Sound
    ; call ExplosionSound ; conflicts with the other sound
    ret

ExplosionAnimation:
    ; Check what frame we are on
    ld a, [bomb_popping_frame]
    cp a, 0
    jr z, .frame0

    ld a, [bomb_pop_timer]
	inc	a
	ld [bomb_pop_timer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    jp nz, .end
    ; Can do next frame
    ; Check what frame we are on
    ld a, [bomb_popping_frame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .frame2
    cp a, 3
    jp z, .frame3
    cp a, 4
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, wBombOAM
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, wBombOAM
    ld [hl], $88
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, bomb_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Explosion left
    SET_HL_TO_ADDRESS wOAM+1, wBombOAM
    ld a, [bomb_x]
    sub 4
    ld [hl], a
    inc l
    ld a, $9E
    ld [hl], a
    ; Explosion middle
    SET_HL_TO_ADDRESS wOAM+5, wBombOAM
    ld a, [bomb_x]
    add 4
    ld [hl], a
    inc l
    ld a, $A0
    ld [hl], a
    ; Explosion right
    SET_HL_TO_ADDRESS wOAM+9, wBombOAM
    ld a, [bomb_x]
    add 12
    ld [hl], a
    inc l
    ld a, $9E
    ld [hl], a
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, bomb_popping_frame
    ld [hl], 2
    ret
.frame2:
    ; Flip palette
    SET_HL_TO_ADDRESS wOAM+3, wBombOAM
    ld [hl], OAMF_PAL1
    SET_HL_TO_ADDRESS wOAM+7, wBombOAM
    ld [hl], OAMF_PAL1
    SET_HL_TO_ADDRESS wOAM+11, wBombOAM
    ld [hl], OAMF_PAL1 | OAMF_XFLIP
    ld hl, bomb_popping_frame
    ld [hl], 3
    ret
.frame3:
    ; Flip palette
    SET_HL_TO_ADDRESS wOAM+3, wBombOAM
    ld [hl], OAMF_PAL0
    SET_HL_TO_ADDRESS wOAM+7, wBombOAM
    ld [hl], OAMF_PAL0
    SET_HL_TO_ADDRESS wOAM+11, wBombOAM
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    ld hl, bomb_popping_frame
    ld [hl], 4
    ret
.clear:
    ; Remove sprites
    call ClearBomb
    ; Reset variables
    ld hl, bomb_popping
    ld [hl], a
    ld hl, bomb_pop_timer
    ld [hl], a
    ld hl, bomb_popping_frame
    ld [hl], a
.end:
    ret
