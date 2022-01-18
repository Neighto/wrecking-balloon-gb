SECTION "tilesets", ROMX

PlayerSpriteTiles::
    INCBIN "incbin/sprite/Player.2bpp"
    INCBIN "incbin/sprite/PlayerFalling.2bpp"
    INCBIN "incbin/sprite/PlayerInvincible.2bpp"
    ; INCBIN "incbin/sprite/PlayerHappy.2bpp"
    INCBIN "incbin/sprite/Pop1.2bpp"
    INCBIN "incbin/sprite/Pop2.2bpp"
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

PorcupineTiles::
    INCBIN "incbin/sprite/porcu.2bpp"
PorcupineTilesEnd::

BackgroundTiles::
    INCBIN "incbin/background/Classic_Map.2bpp"
    ; INCBIN "incbin/background/Sunset.2bpp"
    INCBIN "incbin/background/World2.2bpp"
BackgroundTilesEnd::

ClassicParkTiles::
    INCBIN "incbin/background/Man_Wave.2bpp"
    INCBIN "incbin/background/Man_Wave2.2bpp"
ClassicParkTilesEnd::

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
    DB $BD,$3C,$7E,$42,$FF,$A5,$FF,$99
    DB $7E,$42,$FF,$FF,$FF,$FF,$7E,$7E
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
MenuTilesEnd::

MenuTitleTiles::
    INCBIN "incbin/background/WB.2bpp"
MenuTitleTilesEnd::