INCLUDE "hardware.inc"
INCLUDE "macro.inc"

BIRD_STRUCT_SIZE EQU 9
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

BIRD_TILE_1 EQU $18
BIRD_TILE_2 EQU $1A
BIRD_TILE_2_ALT EQU $1E
BIRD_TILE_3 EQU $1C
BIRD_TILE_3_ALT EQU $20

BIRD_DEAD_TILE_1 EQU $28
BIRD_DEAD_TILE_2 EQU $2A
BIRD_DEAD_TILE_3 EQU $2C

BIRD_POINTS EQU 100

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

SetStruct:
    ; Argument hl = start of free enemy struct
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
    ld [hli], a
    ld a, [wEnemyToDie]
    ld [hl], a
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
    ld [hl], BIRD_TILE_1
    inc l
    ld [hl], OAMF_PAL0
.birdMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], BIRD_TILE_2
    inc l
    ld [hl], OAMF_PAL0
.birdRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], BIRD_TILE_3
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
    ld [hl], BIRD_TILE_3
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.leftBirdMiddle:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], BIRD_TILE_2
    inc l
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
.leftBirdRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 16
    ld [hli], a
    ld [hl], BIRD_TILE_1
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
    ldh a, [hGlobalTimer]
    and BIRD_SOARING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_TILE_2_ALT
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], BIRD_TILE_3_ALT
    ld hl, wEnemyPoppingFrame
    ld [hl], 1
    ret
.flapping:
    ldh a, [hGlobalTimer]
    and BIRD_FLAPPING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], BIRD_TILE_3
    ld hl, wEnemyPoppingFrame
    ld [hl], 0
    DECREMENT_POS wEnemyY, BIRD_FLAP_UP_SPEED
    ret

BirdLeftsideFlap:
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr nz, .flapping
.soaring:
    ldh a, [hGlobalTimer]
    and BIRD_SOARING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_TILE_2_ALT
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], BIRD_TILE_3_ALT
    ld hl, wEnemyPoppingFrame
    ld [hl], 1
    ret
.flapping:
    ldh a, [hGlobalTimer]
    and BIRD_FLAPPING_TIME
    ret nz
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_TILE_2
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], BIRD_TILE_3
    ld hl, wEnemyPoppingFrame
    ld [hl], 0
    DECREMENT_POS wEnemyY, BIRD_FLAP_UP_SPEED
    ret

Clear:
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    xor a ; ld a, 0
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
    ldh a, [hGlobalTimer]
    and BIRD_SPRITE_DESCENDING_TIME
    jr nz, .moveEnd
    INCREMENT_POS wEnemyY, BIRD_VERTICAL_SPEED
.moveEnd:
    call UpdateBirdPosition
    ret

BirdFall:
    push bc
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
    pop bc
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
    ld [hl], BIRD_DEAD_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_3
    ret
.facingRight:
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_3
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_2
    SET_HL_TO_ADDRESS wOAM+10, wEnemyOAM
    ld [hl], BIRD_DEAD_TILE_1
    ret

CollisionBird:
.checkHitPlayer:
    ld bc, wPlayerBalloonOAM
    SET_HL_TO_ADDRESS wOAM+4, wEnemyOAM
    ld e, 8
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
    ret

BirdUpdate::
    ld bc, BIRD_STRUCT_AMOUNT
    xor a ; ld a, 0
    ld [wEnemyOffset], a
.loop:
    ; Get active state
    SET_HL_TO_ADDRESS bird, wEnemyOffset
    ld a, [hli]
    ld [wEnemyActive], a
    ; Check active
    ld a, [wEnemyActive]
    cp a, 0
    jr z, .checkLoop
    ; Get rest of struct
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
    ld a, [hli]
    ld [wEnemyPoppingFrame], a ; flapping frame
    ld a, [hl]
    ld [wEnemyToDie], a
    ; Check if alive
    ld a, [wEnemyAlive]
    cp a, 0
    jr z, .isDead
.isAlive:
    ; Check if we can move
    ldh a, [hGlobalTimer]
    and	BIRD_MOVE_TIME
    call z, Move
    ; Check if we can collide
    ldh a, [hGlobalTimer]
    and	BIRD_COLLISION_TIME
    push bc
    call z, CollisionBird
    ; Check if we should die
    ld a, [wEnemyToDie]
    cp a, 0
    call nz, DeathOfBird
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
    ldh a, [hGlobalTimer]
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
    jp nz, .loop
    ret