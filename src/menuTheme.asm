include "hUGE.inc"

SECTION "menu theme", ROMX

menuTheme::
db 8
dw order_cnt
dw order1, order2, order3, outOfOrder
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 8
order1: dw P3,PE,PE,PE
order2: dw P1,P2,P1,P1
order3: dw P2,P1,P3,P2

P1:
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn A_5,3,$C08
 dn ___,0,$E00
 dn B_5,3,$C08
 dn ___,0,$E00
 dn A_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn D_5,3,$C08
 dn ___,0,$E00
 dn G_5,3,$C08
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_5,3,$C08
 dn ___,0,$E00

P2:
 dn G_4,2,$C0B
 dn ___,0,$E04
 dn ___,0,$000
 dn D_5,2,$C0B
 dn ___,0,$E04
 dn ___,0,$000
 dn D_5,2,$C0B
 dn ___,0,$E04
 dn ___,0,$000
 dn B_4,2,$C0B
 dn ___,0,$E04
 dn ___,0,$000
 dn A_4,2,$C0B
 dn ___,0,$000
 dn ___,0,$E02
 dn ___,0,$000
 dn E_5,2,$113
 dn ___,0,$E02
 dn ___,0,$000
 dn D_5,1,$C0B
 dn ___,0,$E04
 dn ___,0,$000
 dn D_5,1,$C0B
 dn ___,0,$E04
 dn ___,0,$000
 dn E_5,1,$C0B
 dn ___,0,$E04
 dn ___,0,$000
 dn A_4,1,$C0B
 dn ___,0,$000
 dn ___,0,$E02
 dn ___,0,$000
 dn F#5,2,$113
 dn ___,0,$E02
 dn G_5,2,$113
 dn ___,0,$472
 dn ___,0,$E02
 dn ___,0,$000
 dn D_5,2,$C0B
 dn ___,0,$E04
 dn ___,0,$000
 dn B_4,2,$C0B
 dn ___,0,$E04
 dn ___,0,$000
 dn A_4,2,$C0B
 dn ___,0,$000
 dn ___,0,$104
 dn ___,0,$102
 dn ___,0,$102
 dn ___,0,$102
 dn ___,0,$102
 dn ___,0,$102
 dn ___,0,$102
 dn ___,0,$102
 dn ___,0,$102
 dn ___,0,$102
 dn ___,0,$102
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn A_4,2,$C0B
 dn ___,0,$E00

P3:
 dn ___,0,$000
 dn G_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$A30
 dn G_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$A01
 dn ___,0,$E00
 dn ___,0,$000
 dn A_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$E00
 dn B_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn G_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$A30
 dn G_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$A01
 dn ___,0,$E00
 dn ___,0,$000
 dn B_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$E00
 dn A_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn G_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$A30
 dn G_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$A01
 dn ___,0,$E00
 dn ___,0,$000
 dn A_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$E00
 dn B_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn G_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$A30
 dn G_5,2,$C08
 dn ___,0,$A02
 dn ___,0,$A01
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000

menuThemeShort::
    db 9
    dw order_cntShort
    dw order1Short, order2Short, outOfOrder, outOfOrder
    dw duty_instruments, wave_instruments, noise_instruments
    dw routines
    dw waves 

    order_cntShort: db 2
    order1Short: dw P1
    order2Short: dw P2