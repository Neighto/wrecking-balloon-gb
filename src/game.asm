INCLUDE "constants.inc"
INCLUDE "hardware.inc"
INCLUDE "tileConstants.inc"
INCLUDE "macro.inc"
INCLUDE "balloonConstants.inc"

COUNTDOWN_START_X EQU 80
COUNTDOWN_START_Y EQU 50
COUNTDOWN_SPEED EQU %00011111
COUNTDOWN_BALLOON_POP_SPEED EQU %00000111
COUNTDOWN_3_TILE_1 EQU $36
COUNTDOWN_3_TILE_2 EQU $38
COUNTDOWN_2_TILE_1 EQU $32
COUNTDOWN_2_TILE_2 EQU $34
COUNTDOWN_1_TILE_1 EQU $2E
COUNTDOWN_1_TILE_2 EQU $30
COUNTDOWN_NEUTRAL_BALLOON_TILE EQU $3A

SECTION "game vars", WRAM0
    wCountdownFrame:: DB

SECTION "game", ROM0

InitializeGame::
	xor a ; ld a, 0
	ld [wHandWavingFrame], a
	ld [wCountdownFrame], a
    ret
    
LoadLevel1Graphics::
	call LoadPlayerTiles
	call LoadWindow
	call LoadEnemyTiles

	ld bc, Level1Tiles
	ld hl, _VRAM9000
	ld de, Level1TilesEnd - Level1Tiles
	call MEMCPY
	ld bc, Level1Map
	ld hl, _SCRN0
	ld de, Level1MapEnd - Level1Map
	call MEMCPY
	ret
	ret

LoadLevel2Graphics::
	call LoadPlayerTiles
	call LoadWindow
    call LoadEnemyTiles ; Later might want to change loaded enemies

	ld bc, Level2Tiles
	ld hl, _VRAM9000
	ld de, Level2TilesEnd - Level2Tiles
	call MEMCPY
	ld bc, Level2Map
	ld hl, _SCRN0
	ld de, Level2MapEnd - Level2Map
	call MEMCPY
    ret

TryToUnpause::
	xor a ; ld a, 0
	ld hl, wPaused
	cp a, [hl]
	jr z, .end
	; Is paused
    call ClearSound
	call ReadInput
	ld a, [wControllerPressed]
	call JOY_START
	jr z, .end
	xor a ; ld a, 0
	ld [hl], a ; pause
.end:
	ret

SpawnCountdown::
	ld b, 2
	call RequestOAMSpace
    cp a, 0
    jr z, .end
    ld a, b
	ld [wOAMGeneral1], a
	SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X
    ld [hli], a
    ld [hl], EMPTY_TILE
    inc l
    inc l
    ld a, COUNTDOWN_START_Y
    ld [hli], a
    ld a, COUNTDOWN_START_X+8
    ld [hli], a
    ld [hl], EMPTY_TILE
.end:
	ret

Countdown::
    ld a, [wCountdownFrame]
    cp a, 7
    jr c, .countdown
.hasCountedDown:
    ld a, 1
    ret
.countdown:
    ld a, [wCountdownFrame]
    cp a, 4
    jr nc, .balloonPop
    ld a, [wGlobalTimer]
    and COUNTDOWN_SPEED
    jp nz, .end
    jr .frames
.balloonPop:
    ld a, [wGlobalTimer]
    and COUNTDOWN_BALLOON_POP_SPEED
    jp nz, .end
.frames:
    ld a, [wCountdownFrame]
    cp a, 0
    jp z, .frame0
    cp a, 1
    jp z, .frame1
    cp a, 2
    jp z, .frame2
    cp a, 3
    jp z, .frame3
    cp a, 4
    jp z, .frame4
    cp a, 5
    jp z, .frame5
    cp a, 6
    jp z, .remove
    jp .end
.frame0:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_3_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_3_TILE_2
    jp .endFrame
.frame1:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_2_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_2_TILE_2
    jp .endFrame
.frame2:
    call PercussionSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_1_TILE_1
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_1_TILE_2
    jr .endFrame
.frame3:
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], COUNTDOWN_NEUTRAL_BALLOON_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], COUNTDOWN_NEUTRAL_BALLOON_TILE
    inc l 
    ld [hl], OAMF_XFLIP
    jr .endFrame
.frame4:
    call PopSound
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_0_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_0_TILE
    jr .endFrame
.frame5:
    SET_HL_TO_ADDRESS wOAM+2, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_1_TILE
    SET_HL_TO_ADDRESS wOAM+6, wOAMGeneral1
    ld [hl], POP_BALLOON_FRAME_1_TILE
    jr .endFrame
.remove:
    ; todo make erase func for oam
    SET_HL_TO_ADDRESS wOAM, wOAMGeneral1
    xor a ; ld a, 0
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
    ld [hli], a
.endFrame:
    ld a, [wCountdownFrame]
    inc a 
    ld [wCountdownFrame], a
.end:
    xor a ; ld a, 0
    ret

UpdateSprites:
    call PlayerUpdate
    call BulletUpdate
    call PointBalloonUpdate
    call BalloonCactusUpdate
    call BombUpdate
    call BirdUpdate
    call PorcupineUpdate
    ret

UpdateGameCountdown::
    call RefreshWindow
    call IncrementScrollOffset
    call FadeInPalettes
	cp a, 0
	ret z
    call Countdown
    cp a, 0
    jp nz, GameLoop
    ret

UpdateGame::
	call TryToUnpause
	ld a, [wPaused]
	cp a, 0
    ret nz
    call UpdateSprites
    call LevelDataManager
    call RefreshWindow
    call IncrementScrollOffset
    call _hUGE_dosound
    ret