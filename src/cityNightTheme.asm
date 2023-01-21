include "hUGE.inc"

SECTION "city night theme", ROMX

cityNightTheme::
db 8
dw order_cnt
dw order1, order2, order3, order4
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 8
order1: dw PE,PE,PE,PE
order2: dw P1,P3,P2,P4
order3: dw P2,P4,P1,P3
order4: dw PE,PE,PE,PE

P1:
 dn D_5,2,$C0A
 dn E_5,2,$C0A
 dn D_5,2,$C0A
 dn A_5,2,$C0A
 dn ___,0,$A02
 dn ___,0,$A02
 dn G_5,2,$C0A
 dn ___,0,$E00
 dn G_5,2,$C08
 dn ___,0,$E00
 dn A_5,2,$C0A
 dn ___,0,$E00
 dn D_5,2,$C08
 dn ___,0,$E00
 dn D_5,2,$C0A
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$104
 dn E_5,2,$C0A
 dn A_5,2,$C0A
 dn E_5,2,$C0A
 dn B_5,2,$C0A
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$A02
 dn ___,0,$A02
 dn B_5,2,$C0A
 dn ___,0,$E00
 dn B_5,2,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn D_5,2,$C0A
 dn E_5,2,$C0A
 dn D_5,2,$C0A
 dn E_5,2,$C0A
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$A02
 dn D_5,2,$C0A
 dn ___,0,$E00
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
 dn D_5,2,$C0A
 dn ___,0,$E00
 dn D_5,2,$C0A
 dn ___,0,$E00

P2:
 dn D_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_4,1,$C0A
 dn D_4,1,$C0A
 dn ___,0,$000
 dn D_4,1,$C0A
 dn A_3,2,$C0A
 dn B_3,2,$C0A
 dn A_3,2,$C0A
 dn D_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_4,1,$C0A
 dn D_4,1,$C0A
 dn ___,0,$000
 dn D_4,1,$C0A
 dn A_3,2,$C0A
 dn B_3,2,$C0A
 dn A_3,2,$C0A
 dn E_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_4,1,$C0A
 dn E_4,1,$C0A
 dn ___,0,$000
 dn E_4,1,$C0A
 dn B_3,2,$C0A
 dn C#4,2,$C0A
 dn B_3,2,$C0A
 dn D_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_4,1,$C0A
 dn D_4,1,$C0A
 dn ___,0,$000
 dn D_4,1,$C0A
 dn A_3,2,$C0A
 dn B_3,2,$C0A
 dn A_3,2,$C0A
 dn D_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_4,1,$C0A
 dn D_4,1,$C0A
 dn ___,0,$000
 dn D_4,1,$C0A
 dn A_3,2,$C0A
 dn B_3,2,$C0A
 dn A_3,2,$C0A
 dn D_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000

P3:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_5,2,$C0A
 dn ___,0,$E00
 dn D_5,2,$C0A
 dn ___,0,$E00
 dn B_4,2,$C0A
 dn D_5,2,$C0A
 dn ___,0,$E00
 dn D_5,2,$C0A
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$E00
 dn ___,0,$000
 dn A_5,2,$C0A
 dn ___,0,$E00
 dn D_5,2,$C0A
 dn ___,0,$E00
 dn B_4,2,$C0A
 dn E_5,2,$C0A
 dn ___,0,$E00
 dn E_5,2,$C0A
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$E00
 dn ___,0,$000
 dn E_5,2,$C0A
 dn ___,0,$E00
 dn G_5,2,$C0A
 dn ___,0,$E00
 dn A_5,2,$C0A
 dn ___,0,$E00
 dn E_5,2,$C0A
 dn G_5,2,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn G_5,2,$C0A
 dn ___,0,$E00
 dn D_6,2,$C0A
 dn A_5,2,$C0A
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$A02
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_5,2,$C0A
 dn D_5,2,$C09
 dn D_5,2,$C08
 dn D_5,2,$C07
 dn D_5,2,$C06
 dn D_5,2,$C05
 dn D_5,2,$C0A
 dn ___,0,$108

P4:
 dn ___,0,$000
 dn D_4,1,$C0A
 dn D_4,1,$C0A
 dn ___,0,$000
 dn D_4,1,$C0A
 dn A_3,2,$C0A
 dn B_3,2,$C0A
 dn A_3,2,$C0A
 dn D_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_4,1,$C0A
 dn D_4,1,$C0A
 dn ___,0,$000
 dn D_4,1,$C0A
 dn A_3,2,$C0A
 dn B_3,2,$C0A
 dn A_3,2,$C0A
 dn D_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_4,1,$C0A
 dn D_4,1,$C0A
 dn ___,0,$000
 dn D_4,1,$C0A
 dn A_3,2,$C0A
 dn B_3,2,$C0A
 dn A_3,2,$C0A
 dn D_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_4,1,$C0A
 dn D_4,1,$C0A
 dn ___,0,$000
 dn D_4,1,$C0A
 dn A_3,2,$C0A
 dn B_3,2,$C0A
 dn A_3,2,$C0A
 dn E_4,1,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_4,1,$C0A
 dn E_4,1,$C0A
 dn ___,0,$000
 dn E_4,1,$C0A
 dn B_3,2,$C0A
 dn C#4,2,$C0A
 dn B_3,2,$C0A
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000