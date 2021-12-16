SECTION "tilemaps", ROMX

BackgroundMap:: 
    INCBIN "incbin/background/Classic_Map.tilemap"
BackgroundMapEnd::

MenuMap::
    INCBIN "incbin/background/WB.tilemap"
MenuMapEnd::

WindowMap::
    DB $40,$41,$42,$43,$44,$45,$46,$47,$47,$47
    DB $47,$47,$47,$40,$40,$40,$47,$46,$47,$40
    ; INCBIN "incbin/Window.tilemap" ; Need to offset tileset in creation
WindowMapEnd::