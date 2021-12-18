SECTION "tilemaps", ROMX

BackgroundMap:: 
    INCBIN "incbin/background/Classic_Map.tilemap"
BackgroundMapEnd::

MenuMap::
    INCBIN "incbin/background/WB.tilemap"
MenuMapEnd::

WindowMap::
    DB $40,$41,$42,$43,$42,$41,$44,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,    $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
    DB $40,$45,$46,$47,$48,$42,$44,$4A,$4A,$4A,$4A,$4A,$4A,$40,$40,$40,$49,$44,$4A,$40,    $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
    ; INCBIN "incbin/Window.tilemap" ; Need to offset tileset in creation
WindowMapEnd::