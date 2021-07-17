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
    ; If any point of x + 16, to y + 32 
    ; Hits a point inside Cactus, do something

    ; CHECK Y
    ld hl, player_cactus
    ld a, [hl]
    ld hl, point_balloon
    cp a, [hl]
    jr c, .end
    ; cactus_y > balloon_y
    cp a, [hl+32]
    jr nc, .end
    call VBlankHScroll
    ; CHECK X
.end:
    ret
