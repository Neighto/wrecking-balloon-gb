SECTION "point balloon", ROMX

; balloons will spawn and fly upward AND can be popped
POINT_BALLOON_START_X EQU 120
POINT_BALLOON_START_Y EQU 120

InitializePointBalloon::
    ; Initialize Variables
    ld hl, point_balloon_alive
    ld [hl], 1
    ld hl, point_balloon_popping
    ld [hl], 0
    ld hl, point_balloon_y
    ld [hl], POINT_BALLOON_START_Y
    ld hl, point_balloon_x
    ld [hl], POINT_BALLOON_START_X
    ld hl, point_balloon_popping_frame
    ld [hl], 0
    ld hl, balloon_pop_timer
    ld [hl], 0
    ld hl, balloon_pop_timer+1
    ld [hl], 0
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
    ; ld a, 1
    ; cpl 
    ; inc a
    ; add [hl]
    ; ld [hl], a

    ld a, [point_balloon_y]
    dec a
    ld [hl], a
    ; please make better
    ld hl, point_balloon_y
    ld [hl], a

    ret

FloatPointBalloonUp:
    ld hl, point_balloon
    ld a, [hl]
    dec a
    ld [hl], a
    ld hl, point_balloon_y
    ld [hl], a

    ld hl, point_balloon+4
    ld a, [hl]
    dec a
    ld [hl], a
    ld hl, point_balloon_y
    ld [hl], a
    ret

PointBalloonUpdate::
    ; check if alive
    ld a, [point_balloon_alive]
    and 1
    jr z, .popped
    ; check if we can move
    ld a, [movement_timer]
    and	%00000011
    jr nz, .popped
    call FloatPointBalloonUp
    ret
.popped:
    ; check if we need to play popping animation
    ld a, [point_balloon_popping]
    and 1
    jr z, .end
    call PopBalloonAnimation
.end
    ret

PopBalloonAnimation:
    ; check what frame we are on
    ld a, [point_balloon_popping_frame]
    cp a, 0
    jp z, .frame0

    ld a, [balloon_pop_timer]
	inc	a
	ld [balloon_pop_timer], a
    cp a, 30
    jr z, .special
    ret

.special:
    ld a, 0
    ld [balloon_pop_timer], a

    ; check what frame we are on
    ld a, [point_balloon_popping_frame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret

.frame0:
    ; Popped Left - Frame 0
    ld HL, balloon_pop
    ld a, [point_balloon_y]
    ld [HL], a
    inc L
    ld a, [point_balloon_x]
    ld [HL], a
    inc L
    ld [HL], $88
    inc L
    ld [HL], %00000000
    ; Popped Right - Frame 0
    ld HL, balloon_pop+4
    ld a, [point_balloon_y]
    ld [HL], a
    inc L
    ld a, [point_balloon_x]
    add 8
    ld [HL], a
    inc L
    ld [HL], $88
    inc L
    ld [HL], %00100000
    ld hl, point_balloon_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Popped Left - Frame 1
    ld HL, balloon_pop
    ld a, [point_balloon_y]
    ld [HL], a
    inc L
    ld a, [point_balloon_x]
    ld [HL], a
    inc L
    ld [HL], $8A
    inc L
    ld [HL], %00000000
    ; Popped Right - Frame 1
    ld HL, balloon_pop+4
    ld a, [point_balloon_y]
    ld [HL], a
    inc L
    ld a, [point_balloon_x]
    add 8
    ld [HL], a
    inc L
    ld [HL], $8A
    inc L
    ld [HL], %00100000
    ld hl, point_balloon_popping_frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    ld hl, balloon_pop
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    ld hl, point_balloon_popping
    ld [hl], 0
    ld hl, balloon_pop_timer
    ld [hl], 0
    ld hl, point_balloon_popping_frame
    ld [hl], 0
.end:
    ret

DeathOfPointBalloon:
    ; death
    ld hl, point_balloon_alive
    ld [hl], 0
    ; animation trigger
    ld hl, point_balloon_popping
    ld [hl], 1
    ; remove from sprites
    ld hl, point_balloon
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    inc l
    ld [hl], 0
    ; TODO: for some reason I don't have to clear from point_balloon+4 ??
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
