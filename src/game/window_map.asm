; WINDOW_MAP

; Info:
;   Section       : Tilemap
;   Bank          : 0
;   Map size      : 20 x 1
;   Tile set      : C:\Users\natha\Documents\GitHub\wrecking-balloon-gb\assets\window_tiles.gbr
;   Plane count   : 0.5 plane (4 bits)
;   Plane order   : Tiles are continues

WindowWidth  EQU 20
WindowHeight EQU 1
WindowBank   EQU 0

SECTION "window map", ROM0

WindowMap::
    DB $40,$41,$42,$43,$44,$45,$47,$47,$47,$47
    DB $47,$47,$51,$51,$46,$45,$47,$51,$51,$51
WindowMapEnd::