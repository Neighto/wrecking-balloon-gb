include "hUGE.inc"

SECTION "showdown theme", ROMX

showdownTheme::
db 8
dw order_cnt
dw outOfOrder, order2, order3, outOfOrder
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 24
order2: dw P1,P3,P5,P3,P2,P4,P1,P3,P5,P3,P6,P4
order3: dw P2,P4,P6,P4,P1,P3,P2,P4,P6,P4,P5,P3

P1:
 dn G#5,2,$C07
 dn G#5,2,$C08
 dn G#5,2,$C09
 dn G#5,2,$C0A
 dn G#5,2,$C0B
 dn G#5,2,$C0C
 dn G#5,2,$C0D
 dn ___,0,$103
 dn F#5,2,$C0C
 dn F#5,2,$C0D
 dn G#5,2,$C0C
 dn G#5,2,$C0D
 dn B_5,2,$C0C
 dn B_5,2,$C0D
 dn G#5,2,$C07
 dn G#5,2,$C08
 dn G#5,2,$C09
 dn G#5,2,$C0A
 dn G#5,2,$C0B
 dn G#5,2,$C0C
 dn G#5,2,$C0D
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$103
 dn F#5,2,$C0C
 dn ___,0,$A10
 dn G#5,2,$C0C
 dn ___,0,$A10
 dn C#6,2,$C0C
 dn ___,0,$A10
 dn G#5,2,$C07
 dn G#5,2,$C08

P2:
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,1,$C0A
 dn B_4,2,$C0A
 dn B_4,1,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn C#5,1,$C0A
 dn C#5,2,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,1,$C0A
 dn B_4,2,$C0A
 dn B_4,1,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn C#5,1,$C0A
 dn C#5,2,$E06
 dn ___,0,$B00

P3:
 dn G#5,2,$C09
 dn G#5,2,$C0A
 dn G#5,2,$C0B
 dn G#5,2,$C0C
 dn G#5,2,$C0D
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$A01
 dn ___,0,$A01
 dn ___,0,$A01
 dn ___,0,$A01
 dn ___,0,$A01
 dn ___,0,$A01
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$E00
 dn C#6,2,$C0C
 dn C#6,1,$C0C
 dn C#6,2,$C0C
 dn C#6,2,$C0A
 dn C#6,2,$C0C
 dn C#6,1,$C0C
 dn C#6,2,$C0C
 dn C#6,2,$C0A
 dn C#6,1,$C0C
 dn E_6,2,$C0C
 dn E_6,1,$C0C
 dn E_6,1,$C0A
 dn C#6,2,$C0C
 dn F#6,1,$C0C
 dn F#6,2,$C0C
 dn B_5,2,$C0A

P4:
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,1,$C0A
 dn B_4,2,$C0A
 dn B_4,1,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn C#5,1,$C0A
 dn C#5,2,$C0A
 dn ___,0,$E00
 dn C#5,2,$C0A
 dn C#5,1,$C0A
 dn C#5,2,$C0A
 dn ___,0,$E00
 dn C#5,2,$C0A
 dn C#5,1,$C0A
 dn C#5,2,$C0A
 dn ___,0,$E00
 dn C#5,1,$C0A
 dn E_5,2,$C0A
 dn E_5,1,$C0A
 dn ___,0,$E00
 dn C#5,2,$C0A
 dn F#5,1,$C0A
 dn F#5,2,$E06
 dn ___,0,$B00

P5:
 dn G#4,2,$C07
 dn G#4,2,$C08
 dn G#4,2,$C09
 dn G#4,2,$C0A
 dn G#4,2,$C0B
 dn G#4,2,$C0C
 dn G#4,2,$C0D
 dn ___,0,$103
 dn C#5,2,$C0C
 dn C#5,2,$C0D
 dn B_4,2,$C07
 dn B_4,2,$C08
 dn B_4,2,$C09
 dn B_4,2,$C0A
 dn C#5,2,$C0C
 dn C#5,2,$C0D
 dn G#4,2,$C07
 dn G#4,2,$C08
 dn G#4,2,$C09
 dn G#4,2,$C0A
 dn G#4,2,$C0B
 dn ___,0,$000
 dn ___,0,$000
 dn ___,0,$103
 dn B_4,2,$C0C
 dn B_4,2,$C0D
 dn C#5,2,$C0C
 dn C#5,2,$C0D
 dn B_4,2,$C0C
 dn B_4,2,$C0D
 dn G#4,2,$C07
 dn G#5,2,$C08

P6:
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,1,$C0A
 dn B_4,2,$C0A
 dn B_4,1,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn C#5,1,$C0A
 dn C#5,2,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn G#4,1,$C0A
 dn G#4,2,$C0A
 dn ___,0,$E00
 dn G#4,1,$C0A
 dn B_4,2,$C0A
 dn B_4,1,$C0A
 dn ___,0,$E00
 dn G#4,2,$C0A
 dn C#5,1,$C0A
 dn C#5,2,$E06
 dn ___,0,$B00