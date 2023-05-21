include "hUGE.inc"

SECTION "game over theme", ROMX

gameOverTheme::
db 7
dw order_cnt
dw outOfOrder, order2, outOfOrder, outOfOrder
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 2
order2: dw P0

P0:
 dn C_4,1,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn B_3,1,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn A_3,1,$C0C
 dn ___,0,$000
 dn ___,0,$E00
 dn B_3,2,$E02
 dn B_3,1,$C0E
 dn A_3,1,$C0C
 dn ___,0,$E00
 dn F#3,1,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn STOP_SONG,0,0