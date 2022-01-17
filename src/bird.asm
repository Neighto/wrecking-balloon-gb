INCLUDE "points.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

BIRD_STRUCT_SIZE EQU 8
BIRD_STRUCT_AMOUNT EQU 2
BIRD_DATA_SIZE EQU BIRD_STRUCT_SIZE * BIRD_STRUCT_AMOUNT
BIRD_OAM_SPRITES EQU 3
BIRD_OAM_BYTES EQU BIRD_OAM_SPRITES * 4
BIRD_MOVE_TIME EQU %00000011
BIRD_COLLISION_TIME EQU %00001000

BIRD_SOARING_TIME EQU %00000111
BIRD_FLAPPING_TIME EQU %00111111
BIRD_SPRITE_DESCENDING_TIME EQU %00001111
BIRD_FALLING_WAIT_TIME EQU %00000001
BIRD_HORIZONTAL_SPEED EQU 2
BIRD_VERTICAL_SPEED EQU 1
BIRD_FLAP_UP_SPEED EQU 5

SECTION "bird vars", WRAM0
    bird:: DS BIRD_DATA_SIZE

SECTION "bird", ROMX

InitializeBird::
    push hl
    push bc
    RESET_IN_RANGE bird, BIRD_DATA_SIZE
    pop bc
    pop hl
    ret

GetStruct:
    ; Argument hl = start of free enemy struct
    push af
    ld a, [hli]
    ld [wEnemyActive], a
    ld a, [hli]
    ld [wEnemyY], a
    ld a, [hli]
    ld [wEnemyX], a
    ld a, [hli]
    ld [wEnemyOAM], a
    ld a, [hli]
    ld [wEnemyAlive], a
    ld a, [hli]
    ld [wEnemyRightside], a
    ld a, [hli]
    ld [wEnemyFalling], a
    ld a, [hl]
    ld [wEnemyPoppingFrame], a ; flapping frame
    pop af
    ret

SetStruct:
    ; Argument hl = start of free enemy struct
    push af
    ld a, [wEnemyActive]
    ld [hli], a
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld a, [wEnemyOAM]
    ld [hli], a
    ld a, [wEnemyAlive]
    ld [hli], a
    ld a, [wEnemyRightside]
    ld [hli], a
    ld a, [wEnemyFalling]
    ld [hli], a
    ld a, [wEnemyPoppingFrame]
    ld [hl], a
    pop af
    ret

SpawnBird::
    push af
    push hl
    push de
    push bc
    ld hl, bird
    ld d, BIRD_STRUCT_AMOUNT
    ld e, BIRD_STRUCT_SIZE
    call RequestRAMSpace ; hl now contains free RAM space address
    cp a, 0
    jp z, .end
.availableSpace:
    ld b, BIRD_OAM_BYTES
	call RequestOAMSpace ; b now contains OAM address
    cp a, 0
    jp z, .end
.availableOAMSpace:
    LD_DE_HL
    call InitializeEnemyStructVars
    call SetStruct
    ld a, b
    ld [wEnemyOAM], a
    LD_BC_DE
    ld a, 1
    ld [wEnemyActive], a
    ld [wEnemyAlive], a
    ld a, [wEnemyX]
    cp a, SCRN_X / 2
    jr c, .isLeftside
.isRightside:
    ld a, 1
    ld [wEnemyRightside], a
.birdLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], $92
    inc l
    ld [hl], OAMF_PAL0
.birdMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], $98
    inc l
    ld [hl], OAMF_PAL0
.birdRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], $9A
    inc l
    ld [hl], OAMF_PAL0
    jr .setStruct
.isLeftside:
.leftBirdLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], $9A
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.leftBirdMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], $98
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.leftBirdRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], $92
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.setStruct:
    LD_HL_BC
    call SetStruct
.end:
    pop bc
    pop de
    pop hl
    pop af
    ret

BirdRightsideFlap:
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr nz, .flapping
.soaring:
    ld a, [global_timer]
    and BIRD_SOARING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $98
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], $9A
    ld hl, wEnemyPoppingFrame
    ld [hl], 1
    ret
.flapping:
    ld a, [global_timer]
    and BIRD_FLAPPING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $94
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], $96
    ld hl, wEnemyPoppingFrame
    ld [hl], 0
    DECREMENT_POS wEnemyY, BIRD_FLAP_UP_SPEED
    ret

BirdLeftsideFlap:
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr nz, .flapping
.soaring:
    ld a, [global_timer]
    and BIRD_SOARING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $98
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], $9A
    ld hl, wEnemyPoppingFrame
    ld [hl], 1
    ret
.flapping:
    ld a, [global_timer]
    and BIRD_FLAPPING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $94
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], $96
    ld hl, wEnemyPoppingFrame
    ld [hl], 0
    DECREMENT_POS wEnemyY, BIRD_FLAP_UP_SPEED
    ret

Clear:
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    call InitializeEnemyStructVars
    ret

UpdateBirdPosition:
.birdLeft:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    inc l
    inc l
.birdMiddle:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    inc l
    inc l
.birdRight:
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hl], a
    ret

Move:
    ld a, [wEnemyRightside]
    cp a, 0
    jr z, .isLeftside
.isRightside:
    DECREMENT_POS wEnemyX, BIRD_HORIZONTAL_SPEED
    call BirdRightsideFlap
    jr .moveDown
.isLeftside:
    INCREMENT_POS wEnemyX, BIRD_HORIZONTAL_SPEED
    call BirdLeftsideFlap
.moveDown:
    ld a, [global_timer]
    and BIRD_SPRITE_DESCENDING_TIME
    jr nz, .moveEnd
    INCREMENT_POS wEnemyY, BIRD_VERTICAL_SPEED
.moveEnd:
    call UpdateBirdPosition
    ret

BirdFall:
    push hl
    push af
    INCREMENT_POS wEnemyY, 2
    call UpdateBirdPosition
.checkOffscreenY:
    ld a, [wEnemyY]
    ld b, a
    call OffScreenYEnemies
    cp a, 0
    jr z, .end
    xor a ; ld a, 0
    ld [wEnemyFalling], a
    call Clear
.end:
    pop af
    pop hl
    ret

DeathOfBird::
    ; Death
    xor a ; ld a, 0
    ld [wEnemyAlive], a
    ; Points
    ld d, BIRD_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1
    ld [wEnemyFalling], a
    ; Sound
    call ExplosionSound
    ; Screaming bird
    ld a, [wEnemyRightside]
    cp a, 0
    jr z, .facingRight
.facingLeft:
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], $A6
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $A8
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], $AA
    ret
.facingRight:
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], $AA
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $A8
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], $A6
    ret

CollisionBird:
.checkHitPlayer
    ld a, [wPlayerAlive]
    cp a, 0
    ret z
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+4, wEnemyOAM
    ld a, 1
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
    ret

BirdUpdate::
    ld bc, BIRD_STRUCT_AMOUNT
    xor a ; ld a, 0
    ld [wEnemyOffset], a ; TODO, we can remove enemy offset this if we optimize this code
.loop:
    SET_HL_TO_ADDRESS bird, wEnemyOffset
    call GetStruct

    ; Check active
    ld a, [wEnemyActive]
    cp a, 0
    jr z, .checkLoop
    ; Check if alive
    ld a, [wEnemyAlive]
    cp a, 0
    jr z, .isDead
.isAlive:
    ; Check if we can move
    ld a, [global_timer]
    and	BIRD_MOVE_TIME
    call z, Move
    ; Check if we can collide
    ld a, [global_timer]
    and	BIRD_COLLISION_TIME
    push bc
    call z, CollisionBird
    ; Check offscreen
    ld a, [wEnemyX]
    ld b, a
    call OffScreenXEnemies
    pop bc
    cp a, 0
    jr z, .checkLoop
.offScreen:
    call Clear
    jr z, .checkLoop
.isDead:
    ; Check if we need to play falling
    ld a, [wEnemyFalling]
    cp a, 0
    jr z, .checkLoop
    ld a, [global_timer]
    and BIRD_FALLING_WAIT_TIME
    jr nz, .checkLoop
    call BirdFall
.checkLoop:
    SET_HL_TO_ADDRESS bird, wEnemyOffset
    call SetStruct
    ld a, [wEnemyOffset]
    add a, BIRD_STRUCT_SIZE
    ld [wEnemyOffset], a    
    dec bc
    ld a, b
    or a, c
    jr nz, .loop
.end:
    xor a ; ld a, 0
    ld [wEnemyOffset], a
    ret