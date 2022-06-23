INCLUDE "hardware.inc"
INCLUDE "enemyConstants.inc"

BOSS_KILLER_WAIT_TIME EQU %01111111
BOSS_KILLER_FREQUENCY EQU %00000111

SECTION "endless vars", WRAM0
    wEndlessTimer:: DB

SECTION "endless", ROMX

InitializeEndlessVars::
    xor a ; ld a, 0
    ld [wEndlessTimer], a
    ret

BossKiller::
    ; spawn balloon carrier
    ldh a, [hGlobalTimer]
    and BOSS_KILLER_WAIT_TIME
    ret nz
    ld a, [wEndlessTimer]
    inc a
    ld [wEndlessTimer], a
    and BOSS_KILLER_FREQUENCY
    ret nz

.spawnBalloonCarrier:
    ld a, BALLOON_CARRIER
    ldh [hEnemyNumber], a
    ld a, ANVIL_VARIANT
    ldh [hEnemyVariant], a
    ld a, 28
    ldh [hEnemyY], a
    ld a, 0
    ldh [hEnemyX], a
    call SpawnBalloonCarrier
    ret