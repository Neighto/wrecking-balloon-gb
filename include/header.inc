SECTION "vblank IRQ", ROM0[$40]
VBLANK_VECT:
	reti

SECTION	"LCD IRQ", ROM0[$48]
LCD_VECT:
	reti

SECTION "header", ROM0[$100]
	nop
	call START

	; 0104-0133 - Nintendo Logo
	NINTENDO_LOGO
	; 0134-0143 - Title
	DB "WREKN-BLN  "
	; 013F-0142 - Manufacturer Code
	DB "    "
	; 0143 - CGB Flag
	DB $00 ; DMG
	; 0144-0145 - License Code
	DW $00
	; 0146 - SGB Flag
	DB $00 ; No SGB functions
	; 0147 - Cartridge Type
	DB $00 ; ROM Only
	; 0148 - ROM Size
	DB $00 ; 32Kbyte
	; 0149 - RAM Size
	DB $00 ; No RAM
	; 014A - Destination Code
	DB $01 ; Non-Japanese
	; 014B - License Code
	DB $33 ; New
	; 014C - Mask ROM Version Number
	DB $00
	; 014D - Header Checksum
	DB $00 ; RGBFIX Handles This!
	; 014E-014F - Global Checksum
	DW $00 ; RGBFIX Handles This!