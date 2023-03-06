SECTION "tilemaps", ROM0

; CUTSCENES

ManMap::
    INCBIN "incbin/background/Man.tilemap"
ManMapEnd::

ManForEndingMap::
    INCBIN "incbin/background/ManForEnding.tilemap"
ManForEndingMapEnd::

CartMap::
    INCBIN "incbin/background/Cart.tilemap"
CartMapEnd::

LampMap::
    INCBIN "incbin/background/Lamp.tilemap"
LampMapEnd::

HydrantMap::
    INCBIN "incbin/background/Hydrant.tilemap"
HydrantMapEnd::

ScoreboardsMap::
    INCBIN "incbin/background/Scoreboards.tilemap"
ScoreboardsMapEnd::

StageClearFooterMap::
    INCBIN "incbin/background/StageClearFooter.tilemap"
StageClearFooterMapEnd::

LevelCityMap:: 
    INCBIN "incbin/background/City.tilemap"
LevelCityMapEnd::

LevelDesertMap::
    INCBIN "incbin/background/Desert.tilemap"
LevelDesertMapEnd::

LevelShowdownMap::
    INCBIN "incbin/background/Showdown.tilemap"
LevelShowdownMapEnd::

TitleMap::
    INCBIN "incbin/background/Title.tilemap"
TitleMapEnd::

ModesMap::
    INCBIN "incbin/background/Modes.tilemap"
ModesMapEnd::

WindowMap::
    INCBIN "incbin/window/Window.tilemap"
WindowMapEnd::

ScoreTextMap::
    DB $D9, $DA, $DB, $DC, $DD, $DE
ScoreTextMapEnd::

TotalTextMap::
    DB $F5, $DB, $F5, $F1, $F6, $DE
TotalTextMapEnd::

CloudsMap::
    INCBIN "incbin/background/Clouds.tilemap"
CloudsMapEnd::

SunMap::
    INCBIN "incbin/background/Sun.tilemap"
SunMapEnd::

CityPlaneMap:: 
    INCBIN "incbin/background/CityPlane.tilemap"
CityPlaneMapEnd::

UFOMap:: 
    INCBIN "incbin/background/UFO.tilemap"
UFOMapEnd::

ShowdownWaterMap::
    INCBIN "incbin/background/ShowdownWater.tilemap"
ShowdownWaterMapEnd::