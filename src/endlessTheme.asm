include "hUGE.inc"

SECTION "endless theme", ROMX

endlessTheme::
db 8
dw order_cnt
dw outOfOrder, order2, order3, outOfOrder
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 12
order2: dw P1,P2,P1,P3,P1,P4
order3: dw P5,wPE,P5,wPE,P5,wPE

P1:
 dn D_5,2,$C0A
 dn ___,0,$A02
 dn ___,0,$A30
 dn ___,0,$A01
 dn E_5,2,$C0A
 dn ___,0,$A02
 dn ___,0,$A30
 dn ___,0,$A01
 dn F#5,2,$C0A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_5,2,$C0A
 dn ___,0,$000
 dn F#5,2,$C0A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$B00

P2:
 dn A_5,2,$C0A
 dn ___,0,$000
 dn E_5,2,$C0A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$B00

P3:
 dn A_5,2,$C0A
 dn ___,0,$000
 dn D_5,2,$C0A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$B00

P4:
 dn A_5,2,$C08
 dn ___,0,$000
 dn C_6,2,$C08
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_5,2,$C08
 dn ___,0,$000
 dn A_5,2,$C08
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_5,2,$C08
 dn ___,0,$000
 dn A_5,2,$C08
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$E00
 dn ___,0,$B00

P5:
 dn D_4,2,$C08
 dn ___,0,$000
 dn E_5,2,$C08
 dn D_4,2,$C08
 dn E_5,2,$C08
 dn D_4,2,$C08
 dn E_5,2,$C08
 dn D_5,2,$C08
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000