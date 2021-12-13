SECTION "window tiles", ROMX

WindowTiles::
    INCBIN "incbin/window/Window.2bpp"
    INCBIN "incbin/window/WindowNumbers.2bpp"
WindowTilesEnd::

; rgbgfx -u -t incbin/Window.tilemap -o incbin/Window.2bpp assets/GIMP/Window/Window.png