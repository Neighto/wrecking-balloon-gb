INCLUDE "playerConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "bullet vars", WRAM0
    wPlayerBulletY:: DB
    wPlayerBulletX:: DB
    wPlayerBulletAlive:: DB
    wPlayerBulletRight:: DB

SECTION "bullet", ROM0

InitializeBullet::
    xor a ; ld a, 0
    ld [wPlayerBulletY], a
    ld [wPlayerBulletX], a
    ld [wPlayerBulletAlive], a
    ld a, 1
    ld [wPlayerBulletRight], a
    ret

SpawnBullet::
    call BulletSound
    ld a, 1 
    ld [wPlayerBulletAlive], a
    ldh a, [hPlayerY2]
    add 5
    ld [wPlayerBulletY], a
    ld hl, wPlayerBulletOAM
    ldh a, [hPlayerLookRight]
    ld [wPlayerBulletRight], a
    cp a, 0
    jr nz, .spawnFromRight
.spawnFromLeft:
    ldh a, [hPlayerX2]
    sub 3
    ld [wPlayerBulletX], a
.leftOAM:
    ld a, [wPlayerBulletY]
    ld [hli], a
    ld a, [wPlayerBulletX]
    ld [hli], a
    ld [hl], PLAYER_BULLET_TILE
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    ret
.spawnFromRight:
    ldh a, [hPlayerX2]
    add 12
    ld [wPlayerBulletX], a
.rightOAM:
    ld a, [wPlayerBulletY]
    ld [hli], a
    ld a, [wPlayerBulletX]
    ld [hli], a
    ld [hl], PLAYER_BULLET_TILE
    inc l
    ld [hl], OAMF_PAL0
    ret
  
ClearBullet::
    xor a ; ld a, 0
    ld [wPlayerBulletAlive], a
    ld hl, wPlayerBulletOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ret
  
BulletUpdate::
.checkAlive:
    ld a, [wPlayerBulletAlive]
    cp a, 0
    ret z
.isAlive:

.checkOffscreen:
    ld a, [wPlayerBulletX]
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
    ld a, [wPlayerBulletRight]
    cp a, 0
    ld a, [wPlayerBulletX]
    jr nz, .moveRight
.moveLeft:
    sub PLAYER_BULLET_SPEED
    ld [wPlayerBulletX], a
    ld [wPlayerBulletOAM+1], a
    ret
.moveRight:
    add PLAYER_BULLET_SPEED
    ld [wPlayerBulletX], a
    ld [wPlayerBulletOAM+1], a
.endMove:
    ret