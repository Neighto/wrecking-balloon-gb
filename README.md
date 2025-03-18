# Wrecking Balloon GB
A homebrew Game Boy game.

Play as an unlikely duo: an angry cactus strung to a happy balloon.
Together, they embark on an epic adventure through the sky - popping any balloons in their way.

The game is a challenging autoscrolling shoot 'em up where you pop enemy balloons with your cactus and avoid getting popped yourself!

![Wrecking Balloon Cover](https://github.com/Neighto/wrecking-balloon-gb/blob/c052ea66e99ccdbd566bb3b863bd732ea48d1b90/assets/WB_Cover.png)

The game ROM is packed into a **32KB file**. The PCB requires no MBC or battery.

## Play
The game is available on [Itch.io](https://neighto.itch.io/wrecking-balloon). 
- Playable in the browser on PC or mobile
- Playable on actual hardware with the downloadable ROM file

## Build
Install [RGBDS](https://github.com/gbdev/rgbds) and run:
```sh
  make clean && make
```

## Credits
- [RGBDS](https://github.com/gbdev/rgbds) – Assembler/linker
- [hUGEDriver](https://github.com/SuperDisk/hUGEDriver) – Music driver
- [BGB](https://bgb.bircd.org/) – Emulator
- [gbdev.io](https://gbdev.io/) - Game Boy development resources
