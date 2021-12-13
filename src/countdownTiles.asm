SECTION "countdown tiles", ROMX

CountdownTiles::
    INCBIN "incbin/Bubble1.2bpp"
    INCBIN "incbin/Bubble2.2bpp"
    INCBIN "incbin/Bubble3.2bpp"
    INCBIN "incbin/BalloonGeneric.2bpp"
CountdownTilesEnd::

;rgbgfx -t -u -h -o incbin/Bubble1.2bpp assets/GIMP/Sprites/Bubble1.png
;^no -t needed, can use -m to remove mirror dupes