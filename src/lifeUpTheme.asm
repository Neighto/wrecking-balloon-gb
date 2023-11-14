; include "hUGE.inc"

; SECTION "life up theme", ROMX

; lifeUpTheme::
; db 7
; dw order_cnt
; dw order1, outOfOrder, outOfOrder, outOfOrder
; dw duty_instruments, wave_instruments, noise_instruments
; dw routines
; dw waves

; order_cnt: db 2
; order1: dw P0

; P0:
;  dn C_5,9,$C0F
;  dn ___,0,$000
;  dn ___,0,$E00
;  dn STOP_SONG,0,0