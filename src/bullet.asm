INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "bullet vars", HRAM
    hPlayerBulletY:: DB
    hPlayerBulletX:: DB
    hPlayerBulletAlive:: DB
    hPlayerBulletDirection:: DB ; right=0 left=1

SECTION "bullet", ROMX

InitializeBullet::
    xor a ; ld a, 0
    ldh [hPlayerBulletY], a
    ldh [hPlayerBulletX], a
    ldh [hPlayerBulletAlive], a
    ldh [hPlayerBulletDirection], a
    ret

; SPAWN
SpawnBullet::
    call BulletSound
    ld a, 1 
    ldh [hPlayerBulletAlive], a
    ldh a, [hPlayerY2]
    add 5
    ldh [hPlayerBulletY], a
    ld hl, wPlayerBulletOAM
    ldh a, [hPlayerFlags]
    and PLAYER_FLAG_DIRECTION_MASK
    ldh [hPlayerBulletDirection], a
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
    ldh [hPlayerBulletAlive], a
    ld hl, wPlayerBulletOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret
  
; UPDATE
BulletUpdate::

.checkAlive:
    ldh a, [hPlayerBulletAlive]
    cp a, 0
    ret z
.isAlive:

.checkOffscreen:
    ldh a, [hPlayerBulletX]
    ld b, a 
    ld a, SCRN_X + OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr nc, .endOffscreen
    ld a, SCRN_VX - OFF_SCREEN_ENEMY_BUFFER
    cp a, b
    jr c, .endOffscreen
.offscreen:
    jp ClearBullet
.endOffscreen:

.checkMove:
    ldh a, [hGlobalTimer]
    and PLAYER_BULLET_TIME
    ret nz
.move:
    ldh a, [hPlayerBulletDirection]
    cp a, 0
    ldh a, [hPlayerBulletX]
    jr z, .moveRight
.moveLeft:
    sub PLAYER_BULLET_SPEED
    ldh [hPlayerBulletX], a
    ld [wPlayerBulletOAM+1], a
    ret
.moveRight:
    add PLAYER_BULLET_SPEED
    ldh [hPlayerBulletX], a
    ld [wPlayerBulletOAM+1], a
.endMove:
    ret