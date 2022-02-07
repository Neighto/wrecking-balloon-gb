SECTION "stage clear vars", WRAM0
    wStageClearTimer:: DB

SECTION "stage clear", ROMX

InitializeStageClear::
    ld a, 20
    ld [wStageClearTimer], a
    ret

UpdateStageClear::
    ld a, [wGlobalTimer]
    and %00001111
    cp a, 0
    jr nz, .end
    ld a, [wStageClearTimer]
    dec a 
    ld [wStageClearTimer], a
    cp a, 0
    jp z, SetupNextLevel
.end:
    call _hUGE_dosound
    ret