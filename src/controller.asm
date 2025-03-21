INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "controller vars", HRAM
hControllerDown:: DB
hControllerPressed:: DB
hPaused:: DB
hPausedTimer:: DB

SECTION "controller", ROM0

InitializeController::
    xor a ; ld a, 0
    ldh [hPaused], a ; can do because 0 = PAUSE_OFF
    ldh [hPausedTimer], a
    ldh [hControllerDown], a
    ldh [hControllerPressed], a
    ret

ReadController::
    ;
    ; D-PAD
    ;
    ld a, P1F_GET_DPAD
    ; Recommended to read multiple times
    ldh [_IO], a
    ldh a, [_IO]
    ldh a, [_IO]
    cpl
    and LOW_HALF_BYTE_MASK
    swap a
    ld b, a ; DPad info stored in b low bits
    ;
    ; BUTTONS
    ;
    ld a, P1F_GET_BTN
    ; Recommended to read multiple times
    ldh [_IO], a
    ldh a, [_IO]
    ldh a, [_IO]
    cpl
    and LOW_HALF_BYTE_MASK
    or b
    ld b, a ; Button info stored in b high bits
    ;
    ; Set controller vars
    ;
    ldh a, [hControllerDown]
    cpl
    and b
    ldh [hControllerPressed], a
    ld a, b
    ldh [hControllerDown], a
    ret