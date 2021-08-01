; BACKGROUND_TILES

; Info:
;   Section              : Background_Tiles
;   Format               : Gameboy 4 color.
;   Tile size            : 8 x 8

SECTION "background tiles", ROM0

; Start of tile array.
BackgroundTiles::
DB $28,$28,$50,$50,$40,$40,$40,$48
DB $80,$BD,$98,$FF,$68,$6F,$07,$07
DB $00,$00,$00,$00,$01,$01,$02,$02
DB $04,$04,$08,$08,$08,$08,$08,$08
DB $00,$00,$60,$60,$98,$98,$04,$04
DB $05,$05,$02,$02,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $E0,$E0,$10,$10,$08,$08,$04,$04
DB $00,$00,$00,$00,$00,$00,$00,$03
DB $01,$D7,$02,$FE,$C4,$FC,$38,$38
DB $02,$02,$01,$07,$01,$4F,$06,$DE
DB $C8,$F8,$30,$30,$00,$00,$00,$00
BackgroundTilesEnd::