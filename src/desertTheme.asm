include "src/include/hUGE.inc"

SECTION "desert theme", ROMX

desertTheme::
db 8
dw order_cnt
dw order1, order2, order3, order4
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 4
order1: dw PE,PE
order2: dw P1,PE
order3: dw P2,P2
order4: dw PE,PE

P1:
 dn C_5,2,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$E00
 dn ___,0,$000
 dn C_5,2,$C0C
 dn ___,0,$000
 dn D#5,4,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn D#5,2,$C0C
 dn G_5,2,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn F_5,2,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$001
 dn ___,0,$001
 dn G_5,2,$C0C
 dn ___,0,$000
 dn F_5,2,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn D#5,2,$C0C
 dn C_5,2,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$A04
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_4,2,$C0C
 dn ___,0,$A03
 dn D#4,2,$C0C
 dn ___,0,$A03
 dn C_4,2,$C0C
 dn ___,0,$A03
 dn D#4,2,$C0C
 dn ___,0,$E00

P2:
 dn C_5,2,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_5,2,$C0A
 dn C_5,2,$C0A
 dn C_5,2,$C0A
 dn ___,0,$E00
 dn C_4,1,$C05
 dn C_4,1,$C05
 dn C_4,1,$C05
 dn C_4,1,$C05
 dn C_4,1,$C05
 dn G_4,2,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,2,$C0A
 dn G_4,2,$C0A
 dn G_4,2,$C0A
 dn ___,0,$E00
 dn G_3,1,$C05
 dn G_3,1,$C05
 dn G_3,1,$C05
 dn G_3,1,$C05
 dn G_3,1,$C05
 dn F_5,2,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn F_5,2,$C0A
 dn F_5,2,$C0A
 dn F_5,2,$C0A
 dn ___,0,$E00
 dn F_4,1,$C05
 dn F_4,1,$C05
 dn F_4,1,$C05
 dn F_4,1,$C05
 dn F_4,1,$C05
 dn C_5,2,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_5,2,$C0A
 dn C_5,2,$C0A
 dn C_5,2,$C0A
 dn ___,0,$E00
 dn C_4,1,$C05
 dn C_4,1,$C05
 dn C_4,1,$C05
 dn C_4,1,$C05
 dn C_4,1,$C05
 dn C_5,2,$C0A
 dn ___,0,$E00
 dn D#5,2,$C0A
 dn ___,0,$E00
 dn C_5,2,$C0A
 dn ___,0,$E00
 dn D#5,2,$C0A
 dn ___,0,$E00