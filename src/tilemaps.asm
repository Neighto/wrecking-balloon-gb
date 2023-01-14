SECTION "tilemaps", ROM0

CutsceneMap::
    INCBIN "incbin/background/Cutscene.tilemap"
CutsceneMapEnd::

ScoreboardsMap::
    INCBIN "incbin/background/Scoreboards.tilemap"
ScoreboardsMapEnd::

ManForEndingMap::
    INCBIN "incbin/background/ManForEnding.tilemap"
ManForEndingMapEnd::

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
    DB $F6, $DB, $F6, $F2, $F7, $DE
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