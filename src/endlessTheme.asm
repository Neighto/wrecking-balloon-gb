include "hUGE.inc"

SECTION "endless theme", ROMX

endlessTheme::
db 6
dw order_cnt
dw outOfOrder, order2, order3, outOfOrder
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 36
order2: dw P1,P2,P12,P1,P3,P12,P9,P9,P4,P5,P6,P11,P5,P8,P11,P10,P10,P7
order3: dw P5,P6,P11,P5,P8,P11,P10,P10,P7,P5,P6,P11,P5,P8,P11,P9,P9,wPE

P1:
 dn D_5,2,$C0C
 dn ___,0,$A04
 dn ___,0,$E00
 dn ___,0,$000
 dn E_5,2,$C0C
 dn ___,0,$A04
 dn ___,0,$E00
 dn ___,0,$000
 dn F#5,2,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn E_5,2,$C0C
 dn ___,0,$000
 dn F#5,2,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$208
 dn ___,0,$000
 dn A_5,2,$C0C
 dn ___,0,$B00

P2:
 dn E_5,2,$C0C
 dn ___,0,$B00

P3:
 dn D_5,2,$C0C
 dn ___,0,$B00

P4:
 dn A_5,2,$C0C
 dn ___,0,$A04
 dn C_6,2,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn B_5,2,$C0C
 dn ___,0,$A04
 dn A_5,2,$C0C
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn G_5,2,$C0C
 dn ___,0,$A04
 dn B_5,2,$C0C
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
 dn ___,0,$A06
 dn ___,0,$B00

P5:
 dn D_5,3,$C0A
 dn ___,0,$C08
 dn E_5,1,$C08
 dn ___,0,$C04
 dn E_5,3,$C0A
 dn ___,0,$C08
 dn ___,0,$000
 dn E_5,1,$C08
 dn F#5,3,$C0A
 dn E_5,1,$C08
 dn ___,0,$C04
 dn E_5,1,$C08
 dn E_5,3,$C0A
 dn ___,0,$C04
 dn F#5,3,$C0A
 dn ___,0,$C04
 dn D_5,1,$C08
 dn ___,0,$C04
 dn D_5,1,$C08
 dn ___,0,$000
 dn A_5,3,$C08
 dn ___,0,$B00

P6:
 dn E_5,3,$C08
 dn ___,0,$B00

P7:
 dn A_5,3,$C0A
 dn ___,0,$C04
 dn C_6,3,$C0A
 dn ___,0,$C04
 dn D_5,1,$C08
 dn ___,0,$C04
 dn D_5,1,$C08
 dn ___,0,$C04
 dn B_5,3,$C0A
 dn ___,0,$C04
 dn A_5,3,$C0A
 dn ___,0,$C04
 dn D_5,1,$C08
 dn ___,0,$C04
 dn D_5,1,$C08
 dn ___,0,$C04
 dn G_5,3,$C0A
 dn ___,0,$C04
 dn B_5,3,$C0A
 dn ___,0,$C04
 dn A_5,1,$C08
 dn ___,0,$C04
 dn A_5,1,$C08
 dn ___,0,$C04
 dn A_5,1,$C08
 dn ___,0,$C04
 dn A_5,1,$C08
 dn ___,0,$C04
 dn A_5,1,$C08
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$B00

P8:
 dn D_5,3,$C08
 dn ___,0,$B00

P9:
 dn D_5,2,$C0C
 dn ___,0,$E00
 dn E_5,2,$C0C
 dn ___,0,$E00
 dn F#5,2,$C0C
 dn ___,0,$C08
 dn ___,0,$C04
 dn ___,0,$E04
 dn E_5,2,$C0C
 dn ___,0,$C08
 dn F#5,2,$C0C
 dn ___,0,$E00
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$B00

P10:
 dn E_5,1,$C08
 dn ___,0,$C04
 dn E_5,1,$C08
 dn ___,0,$C04
 dn F#5,3,$C0A
 dn ___,0,$C04
 dn E_5,1,$C08
 dn ___,0,$C04
 dn E_5,3,$C0A
 dn ___,0,$C04
 dn F#5,3,$C0A
 dn ___,0,$C04
 dn E_5,1,$C08
 dn ___,0,$C04
 dn E_5,1,$C08
 dn ___,0,$C04

P11:
 dn E_5,1,$C08
 dn ___,0,$C04
 dn E_5,1,$C08
 dn ___,0,$C04
 dn E_5,1,$C08
 dn ___,0,$C04
 dn E_5,1,$C08
 dn ___,0,$B00

P12:
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$A04
 dn ___,0,$E00
 dn ___,0,$B00