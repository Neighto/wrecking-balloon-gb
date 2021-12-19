SECTION "tilemaps", ROMX

BackgroundMap:: 
    INCBIN "incbin/background/Classic_Map.tilemap"
BackgroundMapEnd::

MenuMap::
    INCBIN "incbin/background/WB.tilemap"
MenuMapEnd::

WindowMap::
    DB $40,$4A,$48,$4A,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,    $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
    DB $40,$41,$42,$43,$44,$45,$46,$49,$49,$49,$49,$49,$49,$40,$40,$40,$47,$46,$49,$40,    $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
    ; INCBIN "incbin/window/Window.tilemap" ; Need to offset tileset in creation
WindowMapEnd::