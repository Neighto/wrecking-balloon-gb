SECTION "tilemaps", ROM0

OpeningCutsceneMap::
    INCBIN "incbin/background/OpeningCutsceneMap.tilemap"
OpeningCutsceneMapEnd::
    
IntermissionMap::
    INCBIN "incbin/background/IntermissionMap.tilemap"
IntermissionMapEnd::

Level1Map:: 
    INCBIN "incbin/background/City.tilemap"
Level1MapEnd::

Level2Map::
    ; INCBIN "incbin/background/City.tilemap"
    ; INCBIN "incbin/background/Sunset.tilemap"
    ; INCBIN "incbin/background/Classic_Map.tilemap"
    ; INCBIN "incbin/background/DesertMap.tilemap"
Level2MapEnd::

MenuMap::
    INCBIN "incbin/background/WB.tilemap"
MenuMapEnd::

WindowMap::
    INCBIN "incbin/window/Window.tilemap"
WindowMapEnd::