INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"
INCLUDE "tileConstants.inc"

SECTION "bullet vars", HRAM
    hPlayerBulletFlags:: DB ; BIT #: [0=active] [1=direction]
    hPlayerBulletY:: DB
    hPlayerBulletX:: DB

SECTION "bullet", ROM0

InitializeBullet::
    xor a ; ld a, 0
    ldh [hPlayerBulletFlags], a
    ldh [hPlayerBulletY], a
    ldh [hPlayerBulletX], a
    ret

; SPAWN
SpawnBullet::
    call BulletSound
    ldh a, [hPlayerY2]
    add 5
    ldh [hPlayerBulletY], a
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
    jr z, .spawnFromRight
.spawnFromLeft:
    ldh a, [hPlayerX2]
    sub 3
    ldh [hPlayerBulletX], a
.leftOAM:
    ldh a, [hPlayerBulletY]
    ld [hli], a
    ldh a, [hPlayerBulletX]
    ld [hli], a
    ld a, PLAYER_BULLET_TILE
    ld [hli], a
    ld a, OAMF_PAL0 | OAMF_XFLIP
    ld [hl], a
    ret
.spawnFromRight:
    ldh a, [hPlayerX2]
    add 12
    ldh [hPlayerBulletX], a
.rightOAM:
    ldh a, [hPlayerBulletY]
    ld [hli], a
    ldh a, [hPlayerBulletX]
    ld [hli], a
    ld a, PLAYER_BULLET_TILE
    ld [hli], a
    ld a, OAMF_PAL0
    ld [hl], a
    ret
  
ClearBullet::
    xor a ; ld a, 0
    ldh [hPlayerBulletFlags], a
    ld hl, wPlayerBulletOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret
  
; UPDATE
BulletUpdate::

.checkAlive:
    ldh a, [hPlayerBulletFlags]
    and PLAYER_BULLET_FLAG_ACTIVE_MASK
    ret z
.isAlive:

.checkOffscreen:
    ldh a, [hPlayerBulletX]
    cp a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    jr c, .endOffscreen
.offscreen:
    jp ClearBullet
.endOffscreen:

.checkMove:
    ldh a, [hGlobalTimer]
    and PLAYER_BULLET_TIME
    ret nz
.move:
    ldh a, [hPlayerBulletFlags]
    and PLAYER_BULLET_FLAG_DIRECTION_MASK
    ldh a, [hPlayerBulletX]
    ld b, PLAYER_BULLET_SPEED
    jr z, .moveRight
.moveLeft:
    sub b
    jr .updateMove
.moveRight:
    add b
    ; jr .updateMove
.updateMove:
    ldh [hPlayerBulletX], a
    ld [wPlayerBulletOAM+1], a
.endMove:
    ret