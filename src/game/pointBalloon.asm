SECTION "point balloon", ROMX

; balloons will spawn and fly upward AND can be popped
POINT_BALLOON_START_X EQU 120
POINT_BALLOON_START_Y EQU 120

InitializePointBalloon::
    ; Initialize Variables
    ld hl, point_balloon_alive
    ld [hl], 1
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

PointBalloonUpdate::
    ; check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .end
    ; check if we can move
    ld a, [movement_timer]
    and	%00000011
    jr nz, .end
    call FloatPointBalloonUp
.end:
    ret

PopBalloonAnimation:
    ; at specific X and Y => spawn balloon pop sprites
    ; run for a second, then clear it
    ; Popped Left - Frame 1
    ; ld HL, balloon_pop
    ; ld [HL], 120 ; Y
    ; inc L
    ; ld [HL], 120 ; X
    ; inc L
    ; ld [HL], $88
    ; inc L
    ; ld [HL], %00000000
    ; ; Popped Right - Frame 1
    ; ld HL, balloon_pop+4
    ; ld [HL], 120 ; Y
    ; inc L
    ; ld [HL], 120 + 8 ; X
    ; inc L
    ; ld [HL], $88
    ; inc L
    ; ld [HL], %00100000
    ret

DeathOfPointBalloon:
    ; death
    ld hl, point_balloon_alive
    ld [hl], 0
    ; animation
    call PopBalloonAnimation
    ; remove from sprites
    ld hl, point_balloon
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    ld hl, point_balloon+4
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    ret

CollisionCheck::
    ld a, [collision_timer]
	inc	a
	ld [collision_timer], a
	and	%00001000
    jr nz, .end

    ; check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .end

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
    call DeathOfPointBalloon
.end:
    ret
