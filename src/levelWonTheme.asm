include "hUGE.inc"

SECTION "level won theme", ROMX

levelWonTheme::
db 7
dw order_cnt
dw outOfOrder, order2, order3, outOfOrder
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 2
order2: dw P1
order3: dw P2

P1:
    dn ___,0,$000
    dn ___,0,$000
    dn ___,0,$000
    dn ___,0,$000
    dn C_5,3,$C0C
    dn F_5,2,$940
    dn ___,0,$E00
    dn C_5,3,$C0C
    dn D_5,2,$940
    dn ___,0,$E00
    dn C_5,3,$C0C
    dn F_5,2,$940
    dn ___,0,$E00
    dn ___,0,$000
    dn C_5,3,$C0C
    dn D_5,2,$940
    dn ___,0,$002
    dn F_5,2,$C0C
    dn ___,0,$E00
    dn STOP_SONG,0,0

P2:
    dn ___,0,$000
    dn ___,0,$000
    dn ___,0,$000
    dn ___,0,$000
    dn C_5,2,$C07
    dn F_5,2,$C07
    dn ___,0,$000
    dn C_5,2,$C07
    dn ___,0,$E00
    dn ___,0,$000
    dn C_5,2,$C07
    dn F_5,2,$C07
    dn ___,0,$E00
    dn ___,0,$000
    dn C_5,2,$C07
    dn ___,0,$E00
    dn ___,0,$000
    dn F_5,2,$C07
    dn ___,0,$E00
    dn STOP_SONG,0,0