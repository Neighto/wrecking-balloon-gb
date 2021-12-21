SECTION "tilemaps", ROM0

BackgroundMap:: 
    INCBIN "incbin/background/Classic_Map.tilemap"
BackgroundMapEnd::

World2Map::
    INCBIN "incbin/background/World2.tilemap"
World2MapEnd::

MenuMap::
    INCBIN "incbin/background/WB.tilemap"
MenuMapEnd::

WindowMap::
    DB $E0,$EA,$E8,$EA,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,    $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
    DB $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E9,$E9,$E9,$E9,$E9,$E9,$E0,$E0,$E0,$E7,$E6,$E9,$E0,    $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
    ; INCBIN "incbin/window/Window.tilemap" ; Need to offset tileset in creation
WindowMapEnd::