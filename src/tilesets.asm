SECTION "tilesets", ROM0

PlayerSpriteTiles::
    INCBIN "incbin/sprite/Player.2bpp"
    INCBIN "incbin/sprite/PlayerFalling.2bpp"
    INCBIN "incbin/sprite/PlayerInvincible.2bpp"
    ; INCBIN "incbin/sprite/PlayerHappy.2bpp"
    INCBIN "incbin/sprite/Pop1.2bpp"
    INCBIN "incbin/sprite/Pop2.2bpp"
    INCBIN "incbin/sprite/Bullet.2bpp"
PlayerSpriteTilesEnd::

EnemyTiles::
    INCBIN "incbin/sprite/EnemyCactus.2bpp"
    INCBIN "incbin/sprite/EnemyCactusFalling.2bpp"
    INCBIN "incbin/sprite/Bird1.2bpp"
    INCBIN "incbin/sprite/Bird2.2bpp"
    INCBIN "incbin/sprite/Bomb.2bpp"
    INCBIN "incbin/sprite/Explosion2.2bpp"
    INCBIN "incbin/sprite/Bird3.2bpp"
EnemyTilesEnd::

Level1Tiles::
    INCBIN "incbin/background/City.2bpp"
Level1TilesEnd::

CloudsTiles::
    INCBIN "incbin/background/Clouds.2bpp"
CloudsTilesEnd::

SECTION "tilesets 2", ROMX

PorcupineTiles::
    INCBIN "incbin/sprite/porcu.2bpp"
PorcupineTilesEnd::

OpeningCutsceneTiles::
    INCBIN "incbin/background/OpeningCutscene.2bpp"
OpeningCutsceneTilesEnd::

OpeningCutsceneSpriteTiles::
    INCBIN "incbin/background/Man_Wave.2bpp"
    INCBIN "incbin/background/Man_Wave2.2bpp"
OpeningCutsceneSpriteTilesEnd::

IntermissionTiles::
    INCBIN "incbin/background/StageClear.2bpp"
IntermissionTilesEnd::

Level2Tiles::
    INCBIN "incbin/background/Desert.2bpp"
Level2TilesEnd::

Level3Tiles::
    ; INCBIN "incbin/background/Sunset.2bpp"
Level3TilesEnd::

CountdownTiles::
    INCBIN "incbin/sprite/Bubble1.2bpp"
    INCBIN "incbin/sprite/Bubble2.2bpp"
    INCBIN "incbin/sprite/Bubble3.2bpp"
    INCBIN "incbin/sprite/BalloonGeneric.2bpp"
CountdownTilesEnd::

WindowTiles::
    INCBIN "incbin/window/Window.2bpp"
    INCBIN "incbin/window/WindowNumbers.2bpp"
WindowTilesEnd::

MenuTiles::
    INCBIN "incbin/sprite/MenuSprite.2bpp"
MenuTilesEnd::

MenuTitleTiles::
    INCBIN "incbin/background/Menu.2bpp"
MenuTitleTilesEnd::