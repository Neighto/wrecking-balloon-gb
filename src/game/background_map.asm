; BACKGROUND_MAP
;
; Map Source File.
;
; Info:
;   Section       : Background_Map
;   Bank          : 0
;   Map size      : 32 x 18
;   Tile set      : tiles.gbr
;   Plane count   : 1 plane (8 bits)
;   Plane order   : Tiles are continues

SECTION "background map", ROMX

BackgroundMap:: 
    INCBIN "incbin/Classic_Map.tilemap"
BackgroundMapEnd::