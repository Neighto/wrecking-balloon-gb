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
itSquareinst1: db 8,0,240,128
itSquareinst2: db 8,64,240,128
itSquareinst3: db 8,128,240,128
itSquareinst4: db 8,192,240,128
itSquareinst5: db 8,0,241,128
itSquareinst6: db 8,64,241,128
itSquareinst7: db 8,128,241,128
itSquareinst8: db 8,192,241,128
itSquareinst9: db 8,128,240,128
itSquareinst10: db 8,128,240,128
itSquareinst11: db 8,128,240,128
itSquareinst12: db 8,128,240,128
itSquareinst13: db 8,128,240,128
itSquareinst14: db 8,128,240,128
itSquareinst15: db 8,128,240,128


wave_instruments::
itWaveinst1: db 0,32,0,128
itWaveinst2: db 0,32,1,128
itWaveinst3: db 0,32,2,128
itWaveinst4: db 0,32,3,128
itWaveinst5: db 0,32,4,128
itWaveinst6: db 0,32,5,128
itWaveinst7: db 0,32,6,128
itWaveinst8: db 0,32,7,128
itWaveinst9: db 0,32,8,128
itWaveinst10: db 0,32,9,128
itWaveinst11: db 0,32,10,128
itWaveinst12: db 0,32,11,128
itWaveinst13: db 0,32,12,128
itWaveinst14: db 0,32,13,128
itWaveinst15: db 0,32,14,128


noise_instruments::
; itNoiseinst1: db 240,0,0,0,0,0,0,0
; itNoiseinst2: db 240,0,0,0,0,0,0,0
; itNoiseinst3: db 240,0,0,0,0,0,0,0
; itNoiseinst4: db 240,0,0,0,0,0,0,0
; itNoiseinst5: db 240,0,0,0,0,0,0,0
; itNoiseinst6: db 240,0,0,0,0,0,0,0
; itNoiseinst7: db 240,0,0,0,0,0,0,0
; itNoiseinst8: db 240,0,0,0,0,0,0,0
; itNoiseinst9: db 240,0,0,0,0,0,0,0
; itNoiseinst10: db 240,0,0,0,0,0,0,0
; itNoiseinst11: db 240,0,0,0,0,0,0,0
; itNoiseinst12: db 240,0,0,0,0,0,0,0
; itNoiseinst13: db 240,0,0,0,0,0,0,0
; itNoiseinst14: db 240,0,0,0,0,0,0,0
; itNoiseinst15: db 240,0,0,0,0,0,0,0

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
