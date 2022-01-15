INCLUDE "points.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

BIRD_STRUCT_SIZE EQU 8
BIRD_STRUCT_AMOUNT EQU 2
BIRD_DATA_SIZE EQU BIRD_STRUCT_SIZE * BIRD_STRUCT_AMOUNT

BIRD_SPRITE_MOVE_WAIT_TIME EQU %00000011
BIRD_SPRITE_DESCENDING_TIME EQU %00001111
BIRD_FALLING_WAIT_TIME EQU %00000001
BIRD_HORIZONTAL_SPEED EQU 2
BIRD_VERTICAL_SPEED EQU 1
BIRD_FLAP_UP_SPEED EQU 5
BIRD_RESPAWN_TIME EQU 80

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
    ; Argument b = Y spawn
    ; Argument c = X spawn
    push af
    push hl
    push de
    ld hl, bird
    ld d, BIRD_STRUCT_AMOUNT
    ld e, BIRD_STRUCT_SIZE
    call RequestRAMSpace ; Returns HL
    LD_DE_HL
    cp a, 0
    jp z, .end
.availableSpace:
    call InitializeEnemyStructVars
    call SetStruct
    LD_HL_BC ; Arguments now in HL
    ld b, 3
	call RequestOAMSpace
    cp a, 0
    jp z, .end
.availableOAMSpace:
    ld a, b
    ld [wEnemyOAM], a
    ld a, 1
    ld [wEnemyActive], a
    ld [wEnemyAlive], a
    ld a, h
    ld [wEnemyY], a
    ld a, l
    ld [wEnemyX], a
    cp a, SCRN_X / 2
    jr c, .isLeftside
.isRightside:
    ld a, 1
    ld [wEnemyRightside], a ; TODO needs to influence direction
    ; Bird left
    SET_HL_TO_ADDRESS_WITH_BC wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], $92
    inc l
    ld [hl], %00000000
    ; Bird middle
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], $98
    inc l
    ld [hl], %00000000
    ; Bird right
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], $9A
    inc l
    ld [hl], %00000000
    jr .setStruct
.isLeftside:
    ; Bird left
    SET_HL_TO_ADDRESS_WITH_BC wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], $9A
    inc l
    ld [hl], OAMF_XFLIP
    ; Bird middle
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], $98
    inc l
    ld [hl], OAMF_XFLIP
    ; Bird right
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], $92
    inc l
    ld [hl], OAMF_XFLIP
.setStruct:
    LD_HL_DE
    call SetStruct
.end:
    pop de
    pop hl
    pop af
    ret

BirdAnimate:
    push hl
    push af
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr nz, .frame1
.frame0:
    ld a, [global_timer]
    and 7 ; bird_flapping_speed
    jp nz, .end
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $98
    ld a, [wEnemyRightside]
    cp a, 0
    jr nz, .frame0FacingLeft
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    jr .frame0FacingEnd
.frame0FacingLeft:
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
.frame0FacingEnd:
    ld [hl], $9A
    ld hl, wEnemyPoppingFrame
    ld [hl], 1
    jr .end
.frame1:
    ld a, [global_timer]
    and %00111111 ; bird_flapping_speed
    jp nz, .end
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $94
    ld a, [wEnemyRightside]
    cp a, 0
    jr nz, .frame1FacingLeft
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    jr .frame1FacingEnd
.frame1FacingLeft:
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
.frame1FacingEnd:
    ld [hl], $96
    ld hl, wEnemyPoppingFrame
    ld [hl], 0
    DECREMENT_POS wEnemyY, BIRD_FLAP_UP_SPEED
.end:
    pop af
    pop hl
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
    push hl
    push af
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ; Update Y
    ld a, [wEnemyY]
    ld [hli], a
    ; Update X
    ld a, [wEnemyX]
    ld [hl], a
  
    SET_HL_TO_ADDRESS wOAM+4, wEnemyOAM
    ; Update Y
    ld a, [wEnemyY]
    ld [hli], a
    ; Update X
    ld a, [wEnemyX]
    add 8
    ld [hl], a

    SET_HL_TO_ADDRESS wOAM+8, wEnemyOAM
    ; Update Y
    ld a, [wEnemyY]
    ld [hli], a
    ; Update X
    ld a, [wEnemyX]
    add 16
    ld [hl], a
    pop af
    pop hl
    ret

Move:
    push hl
    push af
    ld a, [wEnemyRightside]
    cp a, 0
    jr z, .moveRight
.moveLeft:
    DECREMENT_POS wEnemyX, BIRD_HORIZONTAL_SPEED
    jr .moveDown
.moveRight:
    INCREMENT_POS wEnemyX, BIRD_HORIZONTAL_SPEED
.moveDown:
    ld a, [global_timer]
    and BIRD_SPRITE_DESCENDING_TIME
    jr nz, .moveEnd
    INCREMENT_POS wEnemyY, BIRD_VERTICAL_SPEED
.moveEnd:
    call BirdAnimate
    call UpdateBirdPosition
.end:
    pop af
    pop hl
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
    push bc
    push hl
    push af
.checkHitPlayer
    ld a, [wPlayerAlive]
    cp a, 0
    jr z, .end
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+4, wEnemyOAM
    ld a, 1
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
.end:
    pop af
    pop hl
    pop bc
    ret

BirdUpdate:: ; I wonder if these updates should all have a timer cooldown?
    push hl
    push bc
    push af
    push de
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
    ; Check if we can move and collide
    ld a, [global_timer]
    and	BIRD_SPRITE_MOVE_WAIT_TIME
    jr nz, .checkLoop
    call Move
    call CollisionBird
    ; Check offscreen
    push bc
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
    pop de
    pop af
    pop bc
    pop hl
    ret