INCLUDE "points.inc"
INCLUDE "balloonCactusConstants.inc"
INCLUDE "hardware.inc"
INCLUDE "macro.inc"

    ; POINT BALLOON
    ; wEnemyActive
    ; wEnemyY
    ; wEnemyX
    ; wEnemyOAM
    ; wEnemyAlive
    ; wEnemyPopping
    ; wEnemyPoppingFrame
    ; wEnemyPoppingTimer

POINT_BALLOON_STRUCT_SIZE EQU 8
POINT_BALLOON_SPRITE_MOVE_WAIT_TIME EQU %00000001

SECTION "point balloon vars", WRAM0
PointBalloonStart:
    pointBalloon:: DS POINT_BALLOON_STRUCT_SIZE*4
PointBalloonEnd:

SECTION "point balloon", ROMX

UpdateBalloonPosition:
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
    ret

InitializePointBalloon::
    push hl
    push bc
    RESET_IN_RANGE pointBalloon, PointBalloonEnd - PointBalloonStart
    pop bc
    pop hl
    ret

RequestPointBalloonSpace:
    ; Returns a as 0 or 1 where 0 is failed and 1 is succeeded
    ; Returns hl as address of free space
    push bc
    ld hl, pointBalloon
    ld bc, (PointBalloonEnd - PointBalloonStart) / POINT_BALLOON_STRUCT_SIZE
.loop:
    ld a, [hl] ; Active
    cp a, 0
    jr nz, .checkLoop
    ; Inactive and free
    ld a, 1
    jr .end
.checkLoop:
    ADD_TO_HL POINT_BALLOON_STRUCT_SIZE
    dec bc
    ld a, b 
    or a, c
    jr nz, .loop
    ; All active
    xor a ; ld a, 0
.end:
    pop bc
    ret

SpawnPointBalloon::
    ; argument b = Y spawn
    ; argument c = X spawn
    push af
    push hl
    push de
    call RequestPointBalloonSpace
    LD_DE_HL
    cp a, 0
    jr z, .end
.availableSpace:
    call InitializeEnemyStructVars
    call SetPointBalloonEnemyStruct

    ; Set Active and Alive
    ld a, 1
    ld [wEnemyActive], a
    ld [wEnemyAlive], a

    ; Set Coordinates
    ld a, b
    ld [wEnemyY], a
    ld a, c
    ld [wEnemyX], a

    ; Request OAM
    ld b, 2
	call RequestOAMSpaceOffset
	ld [wEnemyOAM], a

.balloonLeft:
    SET_HL_TO_ADDRESS_WITH_BC wOAM, wEnemyOAM
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    ld [hli], a
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1
.balloonRight:
    inc l
    ld a, [wEnemyY]
    ld [hli], a
    ld a, [wEnemyX]
    add 8
    ld [hli], a
    ld [hl], ENEMY_BALLOON_TILE
    inc l
    ld [hl], OAMF_PAL1 | OAMF_XFLIP
.setStruct:
    LD_HL_DE
    call SetPointBalloonEnemyStruct
.end:
    pop de
    pop hl
    pop af
    ret

FloatPointBalloonUp:
    ld a, [wEnemyY]
    dec a
    ld [wEnemyY], a
    call UpdateBalloonPosition
    ret

PopBalloonAnimation:
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
    ; Popped left - frame 1
    SET_HL_TO_ADDRESS wOAM+2, wEnemyOAM
    ld [hl], $8A
    inc l
    ld [hl], %00000000
    ; Popped right - frame 1
    SET_HL_TO_ADDRESS wOAM+6, wEnemyOAM
    ld [hl], $8A
    inc l
    ld [hl], OAMF_XFLIP
    ld hl, wEnemyPoppingFrame
    ld [hl], 2
    ret
.clear:
    call ClearEnemy
.end:
    ret

ClearEnemy:
    ; Remove sprites
    xor a ; ld a, 0
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hl], a
    ; Reset variables
    ld [wEnemyActive], a
    ld [wEnemyPopping], a
    ld [wEnemyPoppingFrame], a 
    ld [wEnemyPoppingTimer], a 
    ret

GetPointBalloonEnemyStruct:
    ; argument hl = start of free enemy struct
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

SetPointBalloonEnemyStruct:
    ; argument hl = start of free enemy struct
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

PointBalloonUpdate::
    push bc
    push de
    push hl
    push af
    ld bc, (PointBalloonEnd - PointBalloonStart) / POINT_BALLOON_STRUCT_SIZE
.loop:
    SET_HL_TO_ADDRESS pointBalloon, wEnemyOffset
    call GetPointBalloonEnemyStruct
    
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
    and	POINT_BALLOON_SPRITE_MOVE_WAIT_TIME
    jr nz, .checkLoop
    call FloatPointBalloonUp
    call CollisionPointBalloon
    ; Check offscreen
    push bc
    ld a, [wEnemyY]
    ld b, a
    call OffScreenYEnemies
    pop bc
    cp a, 0
    jr z, .checkLoop
.offScreen:
    call ClearEnemy
    jr .checkLoop
.popped:
    ; Check if we need to play popping animation
    ld a, [wEnemyPopping]
    cp a, 0
    jr z, .checkLoop
    call PopBalloonAnimation
.checkLoop:
    SET_HL_TO_ADDRESS pointBalloon, wEnemyOffset
    call SetPointBalloonEnemyStruct
    ld a, [wEnemyOffset]
    add a, POINT_BALLOON_STRUCT_SIZE
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

DeathOfPointBalloon:
    ; Death
    xor a ; ld a, 0
    ld [wEnemyAlive], a ; WARNING MIGHT NOT BE SET TO CORRECT BALLOON
    ; Points
    ld d, POINT_BALLOON_POINTS
    call AddPoints
    ; Animation trigger
    ld a, 1 
    ld [wEnemyPopping], a
    ; Sound
    call PopSound
    ret

CollisionPointBalloon:
    push bc
    push hl
    push af
    SET_HL_TO_ADDRESS wOAM, wEnemyOAM
    LD_BC_HL
    SET_HL_TO_ADDRESS wOAM, wPlayerCactusOAM
    xor a ; ld a, 0
    call CollisionCheck
    cp a, 0
    call nz, DeathOfPointBalloon
    pop af
    pop hl
    pop bc
    ret