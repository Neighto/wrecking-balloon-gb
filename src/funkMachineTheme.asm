include "src/include/hUGE.inc"

SECTION "funk machine theme", ROMX

funkMachineTheme::
db 6
dw order_cnt
dw order1, order2, order3, order4
dw duty_instruments, wave_instruments, noise_instruments
dw routines
dw waves

order_cnt: db 16
order1: dw P3,P3,P3,P3,P3,P3,P3,P3
order2: dw P0,P8,P9,P8,P0,P8,P9,P8
order3: dw P1,P1,P1,P1,P1,P1,P1,P1
order4: dw P3,P3,P3,P3,P3,P3,P3,P3

P0:
 dn C_6,1,$102
 dn D_6,0,$308
 dn ___,0,$477
 dn ___,0,$400
 dn C_6,1,$000
 dn ___,0,$000
 dn D_6,1,$C06
 dn ___,0,$000
 dn A_5,1,$000
 dn ___,0,$000
 dn F_5,1,$000
 dn ___,0,$000
 dn G_5,1,$000
 dn ___,0,$000
 dn A_5,0,$302
 dn ___,0,$302
 dn ___,0,$302
 dn ___,0,$302
 dn G_5,1,$000
 dn ___,0,$000
 dn F_5,1,$000
 dn ___,0,$000
 dn D_5,1,$000
 dn D_5,1,$C06
 dn F_5,1,$102
 dn G_5,0,$308
 dn F_5,1,$000
 dn ___,0,$000
 dn E_5,1,$000
 dn ___,0,$000
 dn F_5,1,$000
 dn ___,0,$000
 dn E_5,1,$000
 dn ___,0,$000
 dn C_5,1,$000
 dn ___,0,$000
 dn E_5,1,$C06
 dn ___,0,$000
 dn A_4,1,$000
 dn ___,0,$000
 dn C_5,1,$C06
 dn ___,0,$000
 dn A_4,1,$000
 dn ___,0,$000
 dn C_5,1,$000
 dn C_5,1,$C06
 dn C_5,1,$102
 dn D_5,0,$306
 dn ___,0,$306
 dn ___,0,$306
 dn A_4,1,$000
 dn ___,0,$C06
 dn C_5,1,$000
 dn ___,0,$000
 dn D_5,1,$000
 dn D_5,1,$C06
 dn E_5,1,$000
 dn F_5,0,$308
 dn E_5,0,$308
 dn ___,0,$000
 dn D_5,1,$000
 dn ___,0,$000
 dn C_5,1,$000
 dn ___,0,$000

P1:
 dn D_3,1,$C0F
 dn D_3,1,$C04
 dn D_4,2,$C0F
 dn ___,0,$000
 dn D_3,2,$C0F
 dn D_3,3,$C04
 dn D_3,3,$C0F
 dn D_3,4,$C04
 dn D_4,4,$C0F
 dn D_4,5,$C04
 dn D_3,5,$C0F
 dn D_3,6,$C04
 dn C_4,6,$C0F
 dn ___,0,$000
 dn D_4,7,$C0F
 dn D_4,7,$C04
 dn D_3,8,$C0F
 dn D_3,8,$C04
 dn D_4,9,$C0F
 dn ___,0,$000
 dn D_3,9,$C0F
 dn D_3,8,$C04
 dn D_3,8,$C0F
 dn D_3,7,$C04
 dn D_4,7,$C0F
 dn D_4,6,$C04
 dn D_3,6,$C0F
 dn D_3,5,$C04
 dn C_4,5,$C0F
 dn ___,0,$000
 dn D_4,4,$C0F
 dn D_4,4,$C04
 dn D_3,3,$C0F
 dn D_3,3,$C04
 dn D_4,2,$C0F
 dn ___,0,$000
 dn D_3,2,$C0F
 dn D_3,1,$C04
 dn D_3,1,$C0F
 dn D_3,2,$C04
 dn D_4,2,$C0F
 dn D_4,3,$C04
 dn D_3,3,$C0F
 dn D_3,4,$C04
 dn C_4,4,$C0F
 dn ___,0,$000
 dn D_4,5,$C0F
 dn D_4,5,$C04
 dn D_3,6,$C0F
 dn D_3,6,$C04
 dn D_4,7,$C0F
 dn ___,0,$000
 dn D_3,7,$C0F
 dn D_3,8,$C04
 dn D_3,8,$C0F
 dn D_3,9,$C04
 dn D_4,9,$C0F
 dn D_4,8,$C04
 dn D_3,8,$C0F
 dn D_3,7,$C04
 dn C_4,7,$C0F
 dn ___,0,$000
 dn D_4,6,$C0F
 dn D_4,6,$C04

P3:
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

P8:
 dn D_5,1,$000
 dn ___,0,$000
 dn A_4,1,$000
 dn ___,0,$000
 dn C_5,1,$C06
 dn ___,0,$000
 dn D_5,1,$000
 dn ___,0,$000
 dn A_4,1,$000
 dn ___,0,$000
 dn C_5,1,$C06
 dn ___,0,$000
 dn D_5,1,$000
 dn ___,0,$000
 dn A_4,1,$000
 dn ___,0,$000
 dn C_5,1,$C06
 dn ___,0,$000
 dn D_5,1,$000
 dn ___,0,$000
 dn A_4,1,$000
 dn ___,0,$000
 dn C_5,1,$C06
 dn ___,0,$000
 dn D_5,1,$000
 dn C_5,1,$000
 dn D_5,1,$000
 dn ___,0,$000
 dn E_5,1,$000
 dn D_5,1,$000
 dn E_5,1,$000
 dn ___,0,$000
 dn F_5,1,$000
 dn ___,0,$000
 dn E_5,1,$000
 dn ___,0,$000
 dn F_5,1,$C06
 dn ___,0,$000
 dn F_5,1,$000
 dn ___,0,$000
 dn G_5,1,$000
 dn ___,0,$000
 dn F_5,1,$C06
 dn ___,0,$000
 dn G_5,1,$102
 dn A_5,0,$308
 dn D_5,1,$000
 dn ___,0,$000
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn ___,0,$423
 dn C_5,1,$000
 dn ___,0,$000
 dn D_5,1,$000
 dn D_5,1,$C06

P9:
 dn E_5,1,$102
 dn F_5,0,$308
 dn E_5,0,$304
 dn ___,0,$304
 dn D_5,1,$000
 dn ___,0,$000
 dn C_5,1,$000
 dn C_5,1,$C10
 dn D_5,1,$000
 dn ___,0,$000
 dn A_5,0,$338
 dn ___,0,$000
 dn G_5,1,$C10
 dn ___,0,$000
 dn A_5,1,$000
 dn ___,0,$000
 dn A_5,1,$C10
 dn ___,0,$000
 dn G_5,1,$000
 dn ___,0,$000
 dn A_5,1,$C10
 dn ___,0,$000
 dn F_5,1,$000
 dn ___,0,$000
 dn E_5,1,$000
 dn ___,0,$000
 dn F_5,1,$000
 dn ___,0,$000
 dn E_5,1,$000
 dn ___,0,$000
 dn C_5,1,$000
 dn ___,0,$000
 dn A_4,1,$000
 dn ___,0,$222
 dn A_4,1,$000
 dn ___,0,$000
 dn C_5,1,$000
 dn ___,0,$000
 dn D_5,1,$000
 dn ___,0,$472
 dn ___,0,$474
 dn ___,0,$476
 dn C_5,1,$000
 dn ___,0,$000
 dn D_5,1,$000
 dn ___,0,$000
 dn E_5,1,$000
 dn E_5,1,$C10
 dn E_5,1,$000
 dn F_5,0,$304
 dn E_5,0,$304
 dn ___,0,$304
 dn D_5,1,$000
 dn ___,0,$000
 dn C_5,1,$000
 dn ___,0,$000
 dn D_5,1,$000
 dn ___,0,$000
 dn A_4,0,$328
 dn ___,0,$000
 dn A_5,0,$328
 dn ___,0,$328
 dn G_5,1,$101
 dn A_5,0,$308

duty_instruments:
itSquareinst1: db 8,0,240,128
itSquareinst2: db 8,0,242,128
itSquareinst3: db 8,128,240,128
itSquareinst4: db 8,128,240,128
itSquareinst5: db 8,128,240,128
itSquareinst6: db 8,128,240,128
itSquareinst7: db 8,128,112,128
itSquareinst8: db 8,128,240,128
itSquareinst9: db 8,128,240,128
itSquareinst10: db 8,128,240,128
itSquareinst11: db 8,128,240,128
itSquareinst12: db 8,128,240,128
itSquareinst13: db 8,128,240,128
itSquareinst14: db 8,128,240,128
itSquareinst15: db 8,128,240,128

wave_instruments:
itWaveinst1: db 0,32,0,128
itWaveinst2: db 0,32,1,128
itWaveinst3: db 0,32,2,128
itWaveinst4: db 0,32,3,128
itWaveinst5: db 0,32,4,128
itWaveinst6: db 0,32,5,128
itWaveinst7: db 0,32,6,128
itWaveinst8: db 0,32,7,128
itWaveinst9: db 0,32,8,128
itWaveinst10: db 0,32,0,128
itWaveinst11: db 0,32,0,128
itWaveinst12: db 0,32,0,128
itWaveinst13: db 0,32,0,128
itWaveinst14: db 0,32,0,128
itWaveinst15: db 0,32,0,128

waves:
wave0: db 255,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0
wave1: db 255,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
wave2: db 255,255,0,0,0,0,0,0,0,0,0,0,0,0,0,0
wave3: db 255,255,255,0,0,0,0,0,0,0,0,0,0,0,0,0
wave4: db 255,255,255,255,0,0,0,0,0,0,0,0,0,0,0,0
wave5: db 255,255,255,255,255,0,0,0,0,0,0,0,0,0,0,0
wave6: db 255,255,255,255,255,255,0,0,0,0,0,0,0,0,0,0
wave7: db 255,255,255,255,255,255,255,0,0,0,0,0,0,0,0,0
wave8: db 255,255,255,255,255,255,255,255,0,0,0,0,0,0,0,0
wave9: db 255,255,255,255,255,255,255,255,255,0,0,0,0,0,0,0
wave10: db 133,38,183,213,8,205,165,238,196,221,49,186,19,192,78,167
wave11: db 197,33,72,96,103,160,24,128,66,209,136,28,140,178,64,180
wave12: db 142,157,51,38,4,232,167,32,107,213,134,225,225,90,39,84
wave13: db 94,52,176,57,35,91,89,80,88,229,102,163,77,85,148,115
wave14: db 92,37,144,147,238,109,99,29,225,224,90,174,109,180,217,90
wave15: db 81,146,36,194,90,129,185,83,233,9,90,78,66,109,0,238