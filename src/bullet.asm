INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"

SECTION "bullet vars", HRAM
hPlayerBulletFlags:: DB ; BIT #: [0=active] [1=direction]
hPlayerBulletY:: DB
hPlayerBulletX:: DB
hPlayerBulletSpeed:: DB

SECTION "bullet", ROM0

InitializeBullet::
    xor a ; ld a, 0
    ldh [hPlayerBulletFlags], a
    ldh [hPlayerBulletY], a
    ldh [hPlayerBulletX], a
    ldh [hPlayerBulletSpeed], a
    ret

; *************************************************************
; SPAWN
; *************************************************************
SpawnBullet::
    ; Get Y pos
    ldh a, [hPlayerY2]
    add 5
    ldh [hPlayerBulletY], a
    ; Get speed (Fire super bullet if player is boosting)
    ldh a, [hPlayerSpeed]
    cp a, PLAYER_DEFAULT_SPEED
    jr z, .normalBullet
.superBullet:
    call FastBulletSound ; Out of place but call special sound here
    ld a, PLAYER_BULLET_BOOST_SPEED
    ld b, OAMF_PAL1
    jr .updateSpeed
.normalBullet:
    ld a, PLAYER_BULLET_SPEED
    ld b, OAMF_PAL0
    ; jr .updateSpeed
.updateSpeed:
    ldh [hPlayerBulletSpeed], a
    ; Update flags
    ldh a, [hPlayerFlags]
    bit PLAYER_FLAG_DIRECTION_BIT, a
    ldh a, [hPlayerBulletFlags]
    jr z, .updateFlags
.spawnBulletRight:
    set PLAYER_BULLET_FLAG_DIRECTION_BIT, a
.updateFlags:
    set PLAYER_BULLET_FLAG_ACTIVE_BIT, a
    ldh [hPlayerBulletFlags], a
    ; Add to OAM
    ld hl, wPlayerBulletOAM
    ldh a, [hPlayerX2]
    jr z, .spawnFromRight
.spawnFromLeft:
    sub 3
    ldh [hPlayerBulletX], a
    ld a, b
    or OAMF_XFLIP
    ld b, a
    jr .updateOAM
.spawnFromRight:
    add 12
    ldh [hPlayerBulletX], a
    ; jr .updateOAM
.updateOAM:
    ldh a, [hPlayerBulletY]
    ld [hli], a
    ldh a, [hPlayerBulletX]
    ld [hli], a
    ld a, PLAYER_BULLET_TILE
    ld [hli], a
    ld a, b
    ld [hl], a
    ; Sound
    jp BulletSound
  
ClearBullet::
    xor a ; ld a, 0
    ldh [hPlayerBulletFlags], a
    ld hl, wPlayerBulletOAM
    ld bc, 4
    jp ResetHLInRange
  
; *************************************************************
; UPDATE
; *************************************************************
BulletUpdate::

    ;
    ; Check alive
    ;
    ldh a, [hPlayerBulletFlags]
    and PLAYER_BULLET_FLAG_ACTIVE_MASK
    ret z
.isAlive:

    ;
    ; Check offscreen
    ;
    ldh a, [hPlayerBulletX]
    cp a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    jp nc, ClearBullet

    ;
    ; Check move
    ;
    ldh a, [hGlobalTimer]
    and PLAYER_BULLET_TIME
    ret nz
    ; Can move
    ldh a, [hPlayerBulletFlags]
    and PLAYER_BULLET_FLAG_DIRECTION_MASK
    ldh a, [hPlayerBulletSpeed]
    ld b, a
    ldh a, [hPlayerBulletX]
    jr z, .moveRight
.moveLeft:
    sub b
    jr .updateMove
.moveRight:
    add b
    ; jr .updateMove
.updateMove:
    ldh [hPlayerBulletX], a
    ld [wPlayerBulletOAM + 1], a
    ret