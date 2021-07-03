SECTION "header", ROM0

    NINTENDO_LOGO

; $0134 - $013E: The title, in upper-case letters, followed by zeroes.
DB "BITNENFER "
DS 7 ; padding
; $013F - $0142: The manufacturer code.
DS 4
; $0143: Gameboy Color compatibility flag.    
DB $00
; $0144 - $0145: "New" Licensee Code, a two character name.
DB "OK"
; $0146: Super Gameboy compatibility flag.
DB $00
; $0147: Cartridge type. Either no ROM or MBC5 is recommended.
DB $00
; $0148: Rom size.
DB $00
; $0149: Ram size.
DB $00
; $014A: Destination code.
DB $01
; $014B: Old licensee code.
DB $33
; $014C: ROM version number
DB $00
; $014D: Header checksum.
DB $FF
; $014E- $014F: Global checksum.
DW $FACE