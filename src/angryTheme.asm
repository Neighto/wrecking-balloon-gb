include "hUGE.inc"

SECTION "angry theme", ROMX

angryTheme::
db 6
dw order_cnt
dw order1, order2, order3, order4
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 14
order1: dw PE,PE,PE,PE,PE,PE,PE
order2: dw P1,P3,P5,P5,P3,P5,P5
order3: dw P2,P4,P6,P7,P4,P6,P7
order4: dw PE,PE,PE,PE,PE,PE,PE

P1:
 dn G_4,1,$C0C
 dn ___,0,$E00
 dn G_4,1,$C0C
 dn ___,0,$A03
 dn ___,0,$E00
 dn G#4,1,$C0C
 dn ___,0,$E00
 dn A_4,1,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn C_5,2,$C0C
 dn ___,0,$A03
 dn ___,0,$001
 dn ___,0,$010
 dn ___,0,$001
 dn ___,0,$E00
 dn ___,0,$000
 dn D_5,2,$C0C
 dn ___,0,$000
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn D_5,2,$C0C
 dn ___,0,$E00
 dn C_5,2,$C0C
 dn ___,0,$A03
 dn ___,0,$E00
 dn ___,0,$000
 dn G_4,2,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn D_5,2,$C0C
 dn ___,0,$000
 dn D_5,2,$E02
 dn D_5,2,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$001
 dn ___,0,$001
 dn ___,0,$001
 dn ___,0,$001
 dn ___,0,$001
 dn ___,0,$001
 dn ___,0,$E00
 dn ___,0,$B00

P2:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$C10
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
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn D_5,2,$C10
 dn ___,0,$000
 dn F_4,2,$C10
 dn D_5,2,$C10
 dn ___,0,$000
 dn F_4,2,$C10
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn F_4,2,$C10
 dn ___,0,$E04
 dn G_4,2,$C10
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$B00

P3:
 dn G_4,1,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn D_5,2,$C0C
 dn ___,0,$A03
 dn ___,0,$E00
 dn D_5,2,$C0C
 dn ___,0,$000
 dn G_4,2,$C0C
 dn ___,0,$E04
 dn ___,0,$000
 dn ___,0,$000
 dn D_5,2,$10A
 dn ___,0,$A20
 dn ___,0,$A20
 dn ___,0,$000
 dn ___,0,$A04
 dn ___,0,$A04
 dn G_4,2,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn C_5,2,$C0C
 dn ___,0,$A03
 dn D_5,2,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn C_5,2,$C0C
 dn D_5,2,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn C_5,2,$20C
 dn ___,0,$000
 dn ___,0,$000
 dn C_5,2,$220
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn D_5,2,$C0C
 dn ___,0,$A03
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_5,2,$C0C
 dn ___,0,$A03
 dn ___,0,$A01
 dn ___,0,$002
 dn ___,0,$002
 dn ___,0,$000
 dn A_4,2,$C0C
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G#4,2,$C0C
 dn ___,0,$000
 dn ___,0,$E00
 dn G_4,3,$C0C
 dn ___,0,$A03
 dn ___,0,$A01
 dn ___,0,$002

P4:
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn ___,0,$000

P5:
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,1,$C0C
 dn ___,0,$A03
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn C_5,1,$C0C
 dn ___,0,$A03
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_4,1,$C0C
 dn ___,0,$A03
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
 dn ___,0,$B00

P6:
 dn D_5,2,$C10
 dn ___,0,$000
 dn F_4,2,$C10
 dn D_5,2,$C10
 dn ___,0,$000
 dn F_4,2,$C10
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn F_4,2,$C10
 dn ___,0,$E04
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn F_4,2,$C10
 dn G_4,2,$C10
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$B00

P7:
 dn D_5,2,$C10
 dn ___,0,$000
 dn F_4,2,$C10
 dn D_5,2,$C10
 dn ___,0,$000
 dn F_4,2,$C10
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn C_5,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn F_4,2,$C10
 dn ___,0,$E04
 dn G_4,2,$C10
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$B00