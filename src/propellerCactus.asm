INCLUDE "points.inc"
INCLUDE "hardware.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "macro.inc"

PROPELLER_START_X EQU 105
PROPELLER_START_Y EQU 55

SECTION "propellerCactusVars", WRAM0
    wPropeller_x: DB
    wPropeller_y: DB
    wPropeller_frame: DB
    wPropeller_respawn_timer: DB
    wPropeller_alive: DB
    wPropeller_spawn_right: DB
    wPropeller_speed: DB


SECTION "propellerCactus", ROMX

InitializePropellerCactus::
    xor a ; ld a, 0
    ld hl, wPropeller_frame
    ld [hl], a
    ld hl, wPropeller_respawn_timer
    ld [hl], a
    ld hl, wPropeller_alive
    ld [hl], a
    ld hl, wPropeller_spawn_right
    ld [hl], a
    ld hl, wPropeller_speed
    ld [hl], a
    ld hl, wPropeller_x
    ld [hl], PROPELLER_START_X
    ld hl, wPropeller_y
    ld [hl], PROPELLER_START_Y
    ret

SpawnPropellerCactus:
    xor a ; ld a, 0
    ld [wPropeller_respawn_timer], a    
    call InitializePropellerCactus
    ld a, 1
    ld [wPropeller_alive], a
.topLeft:
    ld hl, wPropellerCactus
    ld a, [wPropeller_y]
    ld [hli], a
    ld a, [wPropeller_x]
    ld [hli], a
    ld [hl], $D0
    inc l
    ld [hl], %00000000
.topMiddle:
    ld hl, wPropellerCactus+4
    ld a, [wPropeller_y]
    ld [hli], a
    ld a, [wPropeller_x]
    add 8
    ld [hli], a
    ld [hl], $D4
    inc l
    ld [hl], %00000000
.topMiddle2:
    ld hl, wPropellerCactus+8
    ld a, [wPropeller_y]
    ld [hli], a
    ld a, [wPropeller_x]
    add 16
    ld [hli], a
    ld [hl], $D8
    inc l
    ld [hl], %00000000
.topRight:
    ld hl, wPropellerCactus+12
    ld a, [wPropeller_y]
    ld [hli], a
    ld a, [wPropeller_x]
    add 24
    ld [hli], a
    ld [hl], $DC
    inc l
    ld [hl], %00000000
.bottomLeft:
    ld hl, wPropellerCactus+16
    ld a, [wPropeller_y]
    add 16
    ld [hli], a
    ld a, [wPropeller_x]
    ld [hli], a
    ld [hl], $D2
    inc l
    ld [hl], %00000000
.bottomMiddle:
    ld hl, wPropellerCactus+20
    ld a, [wPropeller_y]
    add 16
    ld [hli], a
    ld a, [wPropeller_x]
    add 8
    ld [hli], a
    ld [hl], $D6
    inc l
    ld [hl], %00000000
.bottomMiddle2:
    ld hl, wPropellerCactus+24
    ld a, [wPropeller_y]
    add 16
    ld [hli], a
    ld a, [wPropeller_x]
    add 16
    ld [hli], a
    ld [hl], $DA
    inc l
    ld [hl], %00000000
.bottomRight:
    ld hl, wPropellerCactus+28
    ld a, [wPropeller_y]
    add 16
    ld [hli], a
    ld a, [wPropeller_x]
    add 24
    ld [hli], a
    ld [hl], $DE
    inc l
    ld [hl], %00000000
    ret

PropellerCactusUpdate::
    ; Check if alive
    ld a, [wPropeller_alive]
    and 1
    jr z, .popped
    ; Check if we can move
    ld a, [global_timer]
    and	ENEMY_SPRITE_MOVE_WAIT_TIME
    jr nz, .end
    ; call MovePropellerCactus
    ret
.popped:
    ; Can we respawn
    ld a, [wPropeller_respawn_timer]
    inc a
    ld [wPropeller_respawn_timer], a
    cp a, 100
    jr nz, .respawnSkip
    call SpawnPropellerCactus
.respawnSkip:
    ; Check if we need to play popping animation
    ; ld a, [enemy_popping]
    ; and 1
    ; jr z, .notPopping
    ; call PopBalloonAnimation
.notPopping:
    ; Check if we need to drop the cactus
    ; ld a, [enemy_falling]
    ; and 1
    ; jr z, .end
    ; call CactusFalling
.end
    ret