INCLUDE "points.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

BOMB_STRUCT_SIZE EQU 8
BOMB_STRUCT_AMOUNT EQU 2
BOMB_DATA_SIZE EQU BOMB_STRUCT_SIZE * BOMB_STRUCT_AMOUNT
BOMB_SPRITE_MOVE_WAIT_TIME EQU %00000001
BOMB_DEFAULT_SPEED EQU 1

SECTION "bomb vars", WRAM0
    bomb:: DS BOMB_DATA_SIZE

SECTION "bomb", ROMX

InitializeBomb::
    push hl
    push bc
    RESET_IN_RANGE bomb, BOMB_DATA_SIZE
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
    ld [wEnemyPopping], a
    ld a, [hli]
    ld [wEnemyPoppingFrame], a
    ld a, [hl]
    ld [wEnemyPoppingTimer], a
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
    ld a, [wEnemyPopping]
    ld [hli], a
    ld a, [wEnemyPoppingFrame]
    ld [hli], a
    ld a, [wEnemyPoppingTimer]
    ld [hl], a
    pop af
    ret

SpawnBomb::
    ; Argument b = Y spawn
    ; Argument c = X spawn
    push af
    push hl
    push de
    ld hl, bomb
    ld d, BOMB_STRUCT_AMOUNT
    ld e, BOMB_STRUCT_SIZE
    call RequestRAMSpace ; Returns HL
    LD_DE_HL
    cp a, 0
    jr z, .end
.availableSpace:
    call InitializeEnemyStructVars
    call SetStruct
    LD_HL_BC ; Arguments now in HL
    ld b, 3
	call RequestOAMSpace
    cp a, 0
    jr z, .end
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
.balloonLeft:
    ; Balloon left
    SET_HL_TO_ADDRESS_WITH_BC wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld a, $9C
    ld [hl], a
    inc l
    ld [hl], %00000000
.balloonRight:
    ; Balloon right
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld a, $9C
    ld [hl], a
    inc l
    ld [hl], OAMF_XFLIP
.bombSpace:
    ; Keep out of sight
    inc l
    ld a, 1
    ld [hli], a
    ld [hli], a
    ld a, $00
    ld [hl], a
    inc l
    ld [hl], %00000000
.setStruct:
    LD_HL_DE
    call SetStruct
.end:
    pop de
    pop hl
    pop af
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

UpdateBombPosition:
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
    ld hl, wEnemyY
    ld a, BOMB_DEFAULT_SPEED
    cpl
    add [hl]
    ld [hl], a
    call UpdateBombPosition
    ret

DeathOfBomb::
    ; Death
    xor a ; ld a, 0
    ld [wEnemyAlive], a
    ; Animation trigger
    ld a, 1
    ld [wEnemyPopping], a
    ; Sound
    ; call ExplosionSound ; conflicts with the other sound
    ret

CollisionBomb::
    push bc
    push hl
    push af
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    LD_BC_HL
    ld hl, wPlayerCactusOAM
    xor a ; ld a, 0
    call CollisionCheck
    cp a, 0
    call nz, CollisionWithPlayer
    call nz, DeathOfBomb
    pop af
    pop hl
    pop bc
    ret

ExplosionAnimation:
    ; Check what frame we are on
    ld a, [wEnemyPoppingFrame]
    cp a, 0
    jr z, .frame0

    ld a, [wEnemyPoppingTimer]
	inc	a
	ld [wEnemyPoppingTimer], a
    and POPPING_BALLOON_ANIMATION_SPEED
    jp nz, .end
    ; Can do next frame
    ; Check what frame we are on
    ld a, [wEnemyPoppingFrame]
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .frame2
    cp a, 3
    jp z, .frame3
    cp a, 4
    jp z, .clear
    ret

.frame0:
    ; Popped left - frame 0
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], $88
    inc l
    ld [hl], %00000000
    ; Popped right - frame 0
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $88
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, wEnemyPoppingFrame
    ld [hl], 1
    ret
.frame1:
    ; Explosion left
    SET_HL_TO_ADDRESS wOAM+1, wEnemyOAM
    ld a, [wEnemyX]
    sub 4
    ld [hl], a
    inc l
    ld a, $9E
    ld [hl], a
    ; Explosion middle
    SET_HL_TO_ADDRESS wOAM+5, wEnemyOAM
    ld a, [wEnemyX]
    add 4
    ld [hl], a
    inc l
    ld a, $A0
    ld [hl], a
    ; Explosion right
    SET_HL_TO_ADDRESS wOAM+9, wEnemyOAM
    ld a, [wEnemyX]
    add 12
    ld [hl], a
    inc l
    ld a, $9E
    ld [hl], a
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, wEnemyPoppingFrame
    ld [hl], 2
    ret
.frame2:
    ; Flip palette
    SET_HL_TO_ADDRESS wOAM+3, wEnemyOAM
    ld [hl], OAMF_PAL1
    SET_HL_TO_ADDRESS wOAM+7, wEnemyOAM
    ld [hl], OAMF_PAL1
    SET_HL_TO_ADDRESS wOAM+11, wEnemyOAM
    ld [hl], OAMF_PAL1 | OAMF_XFLIP
    ld hl, wEnemyPoppingFrame
    ld [hl], 3
    ret
.frame3:
    ; Flip palette
    SET_HL_TO_ADDRESS wOAM+3, wEnemyOAM
    ld [hl], OAMF_PAL0
    SET_HL_TO_ADDRESS wOAM+7, wEnemyOAM
    ld [hl], OAMF_PAL0
    SET_HL_TO_ADDRESS wOAM+11, wEnemyOAM
    ld [hl], OAMF_PAL0 | OAMF_XFLIP
    ld hl, wEnemyPoppingFrame
    ld [hl], 4
    ret
.clear:
    call Clear
.end:
    ret

BombUpdate::
    push bc
    push de
    push hl
    push af
    ld bc, BOMB_STRUCT_AMOUNT
    xor a ; ld a, 0
    ld [wEnemyOffset], a
.loop:
    SET_HL_TO_ADDRESS bomb, wEnemyOffset
    call GetStruct

    ; Check active
    ld a, [wEnemyActive]
    cp a, 0
    jr z, .checkLoop
    ; Check alive
    ld a, [wEnemyAlive]
    cp a, 0
    jr z, .popped
.isAlive:
    ; Check if we can move and collide
    ld a, [global_timer]
    and	BOMB_SPRITE_MOVE_WAIT_TIME
    jr nz, .checkLoop
    call Move
    call CollisionBomb
    ; Check offscreen
    push bc
    ld a, [wEnemyY]
    ld b, a
    call OffScreenYEnemies
    pop bc
    cp a, 0
    jr z, .checkLoop
.offScreen:
    call Clear
    jr .checkLoop
.popped:
    ; Check if we need to play popping animation
    ld a, [wEnemyPopping]
    cp a, 0
    jr z, .checkLoop
    call ExplosionAnimation
.checkLoop:
    SET_HL_TO_ADDRESS bomb, wEnemyOffset
    call SetStruct
    ld a, [wEnemyOffset]
    add a, BOMB_STRUCT_SIZE
    ld [wEnemyOffset], a    
    dec bc
    ld a, b
    or a, c
    jr nz, .loop
.end:
    xor a ; ld a, 0
    ld [wEnemyOffset], a
    pop af
    pop hl
    pop de
    pop bc
    ret