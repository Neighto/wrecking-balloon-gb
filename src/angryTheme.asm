include "src/include/hUGE.inc"

SECTION "angry theme", ROMX

angryTheme::
db 6
dw order_cnt
dw order1, order2, order3, order4
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 10
order1: dw PE,PE,PE,PE,PE
order2: dw P1,P5,P9,P5,P9
order3: dw P2,P6,P10,P6,P10
order4: dw PE,PE,PE,PE,PE

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
 dn C_5,1,$C0C
 dn ___,0,$A03
 dn ___,0,$001
 dn ___,0,$010
 dn ___,0,$001
 dn ___,0,$E00
 dn ___,0,$000
 dn D_5,1,$C0C
 dn ___,0,$000
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$A03
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn D_5,1,$C0C
 dn ___,0,$E00
 dn C_5,1,$C0C
 dn ___,0,$A03
 dn ___,0,$E00
 dn ___,0,$000
 dn G_4,1,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn D_5,1,$C0C
 dn ___,0,$000
 dn D_5,1,$E02
 dn D_5,1,$C0C
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
 dn ___,0,$000
 dn G_4,1,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn D_5,1,$C0C
 dn ___,0,$A03
 dn ___,0,$E00
 dn D_5,1,$C0C
 dn ___,0,$E00

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
 dn ___,0,$000
 dn G_4,1,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E04
 dn ___,0,$000
 dn G_4,2,$C10
 dn ___,0,$E00

P5:
 dn G_4,1,$C0C
 dn ___,0,$A03
 dn ___,0,$E00
 dn D_5,1,$10A
 dn ___,0,$A20
 dn ___,0,$A20
 dn ___,0,$000
 dn ___,0,$A04
 dn ___,0,$A04
 dn G_4,1,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn C_5,1,$C0C
 dn ___,0,$A03
 dn D_5,1,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn C_5,1,$C0C
 dn D_5,1,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn C_5,1,$20C
 dn ___,0,$000
 dn ___,0,$000
 dn C_5,1,$220
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn D_5,1,$C0C
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
 dn G_4,2,$C0C
 dn ___,0,$A03
 dn ___,0,$A01
 dn ___,0,$002
 dn ___,0,$002
 dn ___,0,$002
 dn ___,0,$002
 dn ___,0,$002
 dn ___,0,$002
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn ___,0,$000

P6:
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
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P9:
 dn ___,0,$000
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
 dn ___,0,$000
 dn ___,0,$000
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
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

P10:
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
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00