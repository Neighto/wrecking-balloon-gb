SECTION "point balloon", ROMX

; balloons will spawn and fly upward AND can be popped
POINT_BALLOON_START_X EQU 120
POINT_BALLOON_START_Y EQU 120

InitializePointBalloon::
    ; Balloon Left
    ld HL, point_balloon
    ld [HL], POINT_BALLOON_START_Y
    inc L
    ld [HL], POINT_BALLOON_START_X
    inc L
    ld [HL], $86
    inc L
    ld [HL], %00000000
    ; Balloon Right
    ld HL, point_balloon+4
    ld [HL], POINT_BALLOON_START_Y
    inc L
    ld [HL], POINT_BALLOON_START_X + 8
    inc L
    ld [HL], $86
    inc L
    ld [HL], %00100000
    ret

DecrementPosition:
    ; hl = address
    ld a, 1
    cpl 
    inc a
    add [hl]
    ld [hl], a
    ret

FloatPointBalloonUp:
    ld hl, point_balloon
    call DecrementPosition
    ld hl, point_balloon+4
    call DecrementPosition
    ret

PointBalloonMovement::
    ld a, [movement_timer]
    and	%00000011
    jr nz, .end
    call FloatPointBalloonUp
.end:
    ret

PopPointBalloonAnimation:
    ret

CollisionCheck::
    ld a, [collision_timer]
	inc	a
	ld [collision_timer], a
	and	%00001000
    jr nz, .end

    ; CHECK Y
    ld hl, point_balloon
    ld a, [hl]
    ld hl, player_cactus
    cp a, [hl]
    jr nc, .tryOtherY
    ; cactus_y > balloon_y
    add 16
    cp a, [hl]
    jr c, .tryOtherY
    ; cactus_y < balloon_y'
    jr .checkX

.tryOtherY
    ; also check OR cactus_y' !!!
    ld hl, player_cactus
    ld a, [hl]
    add 16 ; a = cactus_y'
    ld c, a
    ld hl, point_balloon
    ld a, [hl]
    cp a, c
    jr nc, .end
    ; cactus_y'[c'] > balloon_y[a]
    add 16
    cp a, c
    jr c, .end
    ; cactus_y'[c'] < balloon_y'[a']

.checkX:
    ; CHECK X
    ld hl, point_balloon+1
    ld a, [hl]
    ld hl, player_cactus+1
    cp a, [hl]
    jr nc, .tryOtherX
    ; cactus_x > balloon_x
    add 16
    cp a, [hl]
    jr c, .tryOtherX
    ; cactus_x < balloon_x'
    jr .doSomething

.tryOtherX:
    ; also check OR cactus_x' !!!
    ld hl, player_cactus+1
    ld a, [hl]
    add 16 ; a = cactus_y'
    ld c, a
    ld hl, point_balloon+1
    ld a, [hl]
    cp a, c
    jr nc, .end
    ; cactus_x'[c'] > balloon_x[a]
    add 16
    cp a, c
    jr c, .end
    ; cactus_x'[c'] < balloon_x'[a']

.doSomething:
    call VBlankHScroll
.end:
    ret
