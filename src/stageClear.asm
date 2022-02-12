STAGE_CLEAR_PAUSE_LENGTH EQU 20

SECTION "stage clear vars", WRAM0
    wStageClearTimer:: DB
    wStageClearFrame:: DB
    wLivesToAdd:: DB

SECTION "stage clear", ROMX

InitializeStageClear::
    ld a, STAGE_CLEAR_PAUSE_LENGTH
    ld [wStageClearTimer], a
    xor a ; ld a, 0
    ld [wStageClearFrame], a
    ld [wLivesToAdd], a
    ret

UpdateStageClear::
    call _hUGE_dosound
    call RefreshStageClear

    ld a, [wGlobalTimer]
    and %00000011
    cp a, 0
    ret nz
    ld a, [wStageClearFrame]
    cp a, 0
    jr z, .pause
    cp a, 1
    jr z, .copyFirstDigitToTotal
    cp a, 2
    jr z, .copyPointsToTotal
    cp a, 3
    jr z, .pause
    cp a, 4
    jr z, .showGainedLives
    ret
.pause:
    ld a, [wStageClearTimer]
    dec a 
    ld [wStageClearTimer], a
    cp a, 0
    ret nz
    ld a, STAGE_CLEAR_PAUSE_LENGTH
    ld [wStageClearTimer], a
    jr .endFrame
.copyFirstDigitToTotal:
    ld a, [wScore]
    and %00001111
    ld d, a
    call AddTotal
    ld a, [wScore]
    and %00001111
    ld d, a
    call DecrementPoints
    jr .endFrame
.copyPointsToTotal:
    call IsScoreZero
    jr z, .endFrame
    ld d, 10
    call AddTotal
    ld d, 10
    call DecrementPoints
    ret
.showGainedLives:
    ld a, 1
    ld [wLivesToAdd], a

    ; For every 100 points get a +1 life
    ret
    ; Lastly jp SetupNextLevel
.endFrame:
    ld a, [wStageClearFrame]
    inc a
    ld [wStageClearFrame], a
    ret

; Pause
; Copy first digit space to total
; Then do sub/add by 10
; Subtract points from score quickly and make a noise
; Add to total
; Show for every 1k points a +1 life