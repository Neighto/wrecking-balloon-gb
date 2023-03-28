include "src/include/hUGE.inc"

SECTION "Song Data Common", ROMX

PE::
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

; May need to make larger if a song exceeds this length
outOfOrder:: dw PE,PE,PE,PE,PE,PE,PE,PE,PE,PE,PE,PE
   
duty_instruments::
itSquareinst1:
db 8
db 0
db 240
dw 0
db 128

itSquareinst2:
db 8
db 64
db 240
dw 0
db 128

itSquareinst3:
db 8
db 128
db 240
dw 0
db 128

itSquareinst4:
db 8
db 192
db 240
dw 0
db 128

itSquareinst5:
db 8
db 0
db 241
dw 0
db 128

itSquareinst6:
db 8
db 64
db 241
dw 0
db 128

itSquareinst7:
db 8
db 128
db 241
dw 0
db 128

itSquareinst8:
db 8
db 192
db 241
dw 0
db 128

itSquareinst9:
db 8
db 128
db 240
dw 0
db 128

itSquareinst10:
db 8
db 128
db 240
dw 0
db 128

itSquareinst11:
db 8
db 128
db 240
dw 0
db 128

itSquareinst12:
db 8
db 128
db 240
dw 0
db 128

itSquareinst13:
db 8
db 128
db 240
dw 0
db 128

itSquareinst14:
db 8
db 128
db 240
dw 0
db 128

itSquareinst15:
db 8
db 128
db 240
dw 0
db 128
   
wave_instruments::
itWaveinst1:
db 0
db 32
db 0
dw 0
db 128

itWaveinst2:
db 0
db 32
db 1
dw 0
db 128

itWaveinst3:
db 0
db 32
db 2
dw 0
db 128

itWaveinst4:
db 0
db 32
db 3
dw 0
db 128

itWaveinst5:
db 0
db 32
db 4
dw 0
db 128

itWaveinst6:
db 0
db 32
db 5
dw 0
db 128

itWaveinst7:
db 0
db 32
db 6
dw 0
db 128

itWaveinst8:
db 0
db 32
db 7
dw 0
db 128

itWaveinst9:
db 0
db 32
db 8
dw 0
db 128

itWaveinst10:
db 0
db 32
db 9
dw 0
db 128

itWaveinst11:
db 0
db 32
db 10
dw 0
db 128

itWaveinst12:
db 0
db 32
db 11
dw 0
db 128

itWaveinst13:
db 0
db 32
db 12
dw 0
db 128

itWaveinst14:
db 0
db 32
db 13
dw 0
db 128

itWaveinst15:
db 0
db 32
db 14
dw 0
db 128
   
noise_instruments::
    ; Noise channel never used

routines::
    ; Removed for space (I don't use routines)
   
waves::
wave0: db 0,0,255,255,255,255,255,255,255,255,255,255,255,255,255,255
wave1: db 0,0,0,0,255,255,255,255,255,255,255,255,255,255,255,255
wave2: db 0,0,0,0,0,0,0,0,255,255,255,255,255,255,255,255
wave3: db 0,0,0,0,0,0,0,0,0,0,0,0,255,255,255,255
wave4: db 0,1,18,35,52,69,86,103,120,137,154,171,188,205,222,239
wave5: db 254,220,186,152,118,84,50,16,18,52,86,120,154,188,222,255
wave6: db 122,205,219,117,33,19,104,189,220,151,65,1,71,156,221,184
wave7: db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
wave8: db 254,252,250,248,246,244,242,240,242,244,246,248,250,252,254,255
wave9: db 254,221,204,187,170,153,136,119,138,189,241,36,87,138,189,238
wave10: db 132,17,97,237,87,71,90,173,206,163,23,121,221,32,3,71
wave11: db 123,91,6,51,46,93,173,180,213,226,186,104,34,68,139,177
wave12: db 151,217,154,203,22,30,132,21,164,236,12,182,149,50,119,126
wave13: db 124,102,214,40,21,14,12,204,115,113,131,39,89,157,56,237
wave14: db 162,231,165,129,167,122,237,43,154,80,197,198,172,104,33,201
wave15: db 237,135,35,65,156,100,123,20,88,10,181,236,73,156,190,154   