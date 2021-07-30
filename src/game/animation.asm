SECTION "animation", ROMX

PopBalloonAnimation::
    ; Check what frame we are on
    ld a, [point_balloon_popping_frame]
    cp a, 0
    jr z, .frame0

    ld a, [balloon_pop_timer]
	inc	a
	ld [balloon_pop_timer], a
    cp a, 30
    jp nz, .end

    ; Can do next frame
    ; Reset timer
    xor a ; ld a, 0
    ld [balloon_pop_timer], a
    ; Check what frame we are on
    ld a, [point_balloon_popping_frame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    ld hl, balloon_pop
    ld a, [point_balloon_y]
    ld [hl], a
    inc l
    ld a, [point_balloon_x]
    ld [hl], a
    inc l
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    ld hl, balloon_pop+4
    ld a, [point_balloon_y]
    ld [hl], a
    inc l
    ld a, [point_balloon_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $88
    inc l
    ld [hl], %00100000
    ld hl, point_balloon_popping_frame
    ld [hl], 1
    ret
.frame1:
    ; Popped left - frame 1
    ld hl, balloon_pop
    ld a, [point_balloon_y]
    ld [hl], a
    inc l
    ld a, [point_balloon_x]
    ld [hl], a
    inc l
    ld [hl], $8A
    inc l
    ld [hl], %00000000
    ; Popped right - frame 1
    ld hl, balloon_pop+4
    ld a, [point_balloon_y]
    ld [hl], a
    inc l
    ld a, [point_balloon_x]
    add 8
    ld [hl], a
    inc l
    ld [hl], $8A
    inc l
    ld [hl], %00100000
    ld hl, point_balloon_popping_frame
    ld [hl], 2
    ret
.clear:
    ; Remove sprites
    ld a, 0
    ld hl, balloon_pop
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ; Reset variables
    ld hl, point_balloon_popping
    ld [hl], a
    ld hl, balloon_pop_timer
    ld [hl], a
    ld hl, point_balloon_popping_frame
    ld [hl], a
.end:
    ret