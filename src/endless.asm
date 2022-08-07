INCLUDE "hardware.inc"
INCLUDE "enemyConstants.inc"

BOSS_KILLER_START_TIME EQU %0001100
BOSS_KILLER_WAIT_TIME EQU %00111111

SECTION "endless vars", WRAM0
    wEndlessTimer:: DB

SECTION "endless", ROMX

InitializeEndlessVars::
    ld a, BOSS_KILLER_START_TIME
    ld [wEndlessTimer], a
    ret

BossKiller::
    ld a, [wEndlessTimer]
    inc a
    ld [wEndlessTimer], a
    and BOSS_KILLER_WAIT_TIME
    ret nz
    call FindBalloonCarrier
    ret nz
    ; TODO BOB ANVIL
.spawnBalloonCarrier:
    ld a, BALLOON_CARRIER
    ldh [hEnemyNumber], a
    ld a, CARRIER_ANVIL_VARIANT
    ldh [hEnemyVariant], a
    xor a ; ld a, 0
    ldh [hEnemyY], a
    ld a, 80
    ldh [hEnemyX], a
    call SpawnBalloonCarrier
    ret