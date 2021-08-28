; BACKGROUND_TILES

; Info:
;   Section              : Background_Tiles
;   Format               : Gameboy 4 color.
;   Tile size            : 8 x 8

SECTION "background tiles", ROM0

; Start of tile array.
BackgroundTiles::
    INCBIN "incbin/Classic_Map.2bpp"
BackgroundTilesEnd::