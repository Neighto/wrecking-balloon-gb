INCLUDE "tileConstants.inc"
INCLUDE "hardware.inc"

SECTION "tilemaps", ROM0

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

; "S" "C" "O" "R" "E" ":"
ScoreTextMap::
    DB $D9, $DA, $DB, $DC, $DD, $DE
ScoreTextMapEnd::

; "T" "O" "T" "A" "L" ":"
TotalTextMap::
    DB $F5, $DB, $F5, $F1, $F6, $DE
TotalTextMapEnd::

; "T" "O" "P" ":"
TopTextMap::
    DB $F5, $DB, $FB, $DE
TopTextMapEnd::

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

ShowdownMountainsMap::
    INCBIN "incbin/background/ShowdownMountains.tilemap"
ShowdownMountainsMapEnd::

PorcupineMap::
    ; Top row
    DB PORCUPINE_TILE_1, OAMF_PAL0
    DB PORCUPINE_FACE_LEFT_TILE_1, OAMF_PAL0
    DB PORCUPINE_FACE_LEFT_TILE_2, OAMF_PAL0
    DB PORCUPINE_TILE_1, OAMF_PAL0 | OAMF_XFLIP
    ; Bottom row
    DB PORCUPINE_TILE_2, OAMF_PAL0
    DB PORCUPINE_TILE_3, OAMF_PAL0
    DB PORCUPINE_TILE_3, OAMF_PAL0 | OAMF_XFLIP
    DB PORCUPINE_TILE_2, OAMF_PAL0 | OAMF_XFLIP
    ; String
    DB STRING_TILE, OAMF_PAL0
PorcupineMapEnd::

PorcupineExpressionLeftMap::
    DB PORCUPINE_FACE_LEFT_TILE_1, OAMF_PAL0
    DB PORCUPINE_FACE_LEFT_TILE_2, OAMF_PAL0
PorcupineExpressionLeftMapEnd::

PorcupineExpressionRightMap::
    DB PORCUPINE_FACE_LEFT_TILE_2, OAMF_PAL0 | OAMF_XFLIP
    DB PORCUPINE_FACE_LEFT_TILE_1, OAMF_PAL0 | OAMF_XFLIP
PorcupineExpressionRightMapEnd::

PorcupineExpressionConfidentMap::
    DB PORCUPINE_CONFIDENT_FACE_TILE, OAMF_PAL0
    DB PORCUPINE_CONFIDENT_FACE_TILE, OAMF_PAL0 | OAMF_XFLIP
PorcupineExpressionConfidentMapEnd::

PorcupineExpressionScaredMap::
    DB PORCUPINE_SCARED_FACE_TILE, OAMF_PAL0
    DB PORCUPINE_SCARED_FACE_TILE, OAMF_PAL0 | OAMF_XFLIP
PorcupineExpressionScaredMapEnd::

PorcupineFeetMap::
    DB PORCUPINE_TILE_3_FEET_ALT, OAMF_PAL0
    DB PORCUPINE_TILE_3_FEET_ALT, OAMF_PAL0 | OAMF_XFLIP
PorcupineFeetMapEnd::