INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "OAM vars", WRAM0[OAM_VAR_ADDRESS]
    ; Player OAM is separate because we should not have to request it in case there's not enough space to spawn
wPlayerCactusOAM:: DS PLAYER_CACTUS_OAM_COUNT * OAM_ATTRIBUTES_COUNT
wPlayerBalloonOAM:: DS PLAYER_BALLOON_OAM_COUNT * OAM_ATTRIBUTES_COUNT
wPlayerBulletOAM:: DS PLAYER_BULLET_OAM_COUNT * OAM_ATTRIBUTES_COUNT
wOAM:: DS GENERAL_OAM_COUNT * OAM_ATTRIBUTES_COUNT

SECTION "OAM DMA routine", ROM0

; Move DMA routine to HRAM
CopyDMARoutine::
    ld hl, hOAMDMA
    ld bc, DMARoutine
    ld de, DMARoutineEnd - DMARoutine
    jp MEMCPY

; Arg: A = Address for DMA transfer source
DMARoutine:
    ldh [rDMA], a
    ld a, 40
.wait
    dec a
    jr nz, .wait
    ret
DMARoutineEnd:

OAMDMA::
    ; Call DMA subroutine to copy the bytes to OAM for sprites begin to draw
    ld a, HIGH(OAM_VAR_ADDRESS)
    jp hOAMDMA

SECTION "OAM DMA", HRAM
hOAMDMA:: DS DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to