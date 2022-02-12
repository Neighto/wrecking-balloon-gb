# Makefile for assembling Wrecking Balloon

GAME_NAME	:= 	WRECKINGBALLOON

SRC_DIR		 :=	src
INC_DIR		 :=	$(SRC_DIR)/include
OBJ_DIR		 :=	obj
BIN_DIR		 :=	bin
OUTPUT		 :=	$(BIN_DIR)/$(GAME_NAME)
SRC_ASM		 :=	$(wildcard $(SRC_DIR)/*.asm)
OBJ_FILES	 :=	$(addprefix $(BIN_DIR)/$(OBJ_DIR)/, $(SRC_ASM:src/%.asm=%.o))

ASSETS_DIR	 := assets
IMG_DIR		 := $(ASSETS_DIR)/graphics
SPRITE_DIR	 := $(IMG_DIR)/sprite
BKGRND_DIR	 := $(IMG_DIR)/background
WINDOW_DIR	 := $(IMG_DIR)/window
SPRITE_FILES := $(foreach file, $(wildcard $(SPRITE_DIR)/*.png), $(basename $(subst $(IMG_DIR)/, ,$(file))))
BKGRND_FILES := $(foreach file, $(wildcard $(BKGRND_DIR)/*.png), $(basename $(subst $(IMG_DIR)/, ,$(file))))
WINDOW_FILES := $(foreach file, $(wildcard $(WINDOW_DIR)/*.png), $(basename $(subst $(IMG_DIR)/, ,$(file))))

.PHONY: all clean tileset tilemap

all: fix
	
fix: build
	rgbfix -p0 -v $(OUTPUT).gb
	@echo "Ran rgbfix - header utility and checksum fixer"

build: $(OBJ_FILES)
	rgblink -m $(OUTPUT).map -n $(OUTPUT).sym -o $(OUTPUT).gb $(OBJ_FILES)
	@echo "Ran rgblink - gameboy linker"
	
$(BIN_DIR)/$(OBJ_DIR)/%.o : $(SRC_DIR)/%.asm
	rgbasm -i $(INC_DIR) -o $@ $<
	@echo "Ran rgbasm - gameboy assembler"

# Use to make a tileset (ex: make path={png_path_from_graphics} flag={-u or -m} tileset)
# Omit path to generate all
# Special case used flag -u instead of -m for doing countdown numbers
tileset: 
ifdef path
	rgbgfx $(flag) -h -o incbin/$(path).2bpp  $(IMG_DIR)/$(path).png
	@echo "Ran rgbgfx - tileset for $(path)"
else
	$(foreach file, $(SPRITE_FILES), rgbgfx $(flag) -h -o incbin/$(file).2bpp $(IMG_DIR)/$(file).png;)
	@echo "Ran rgbgfx - tileset for all"
endif

# Use to make a tilemap and tileset (ex: make path={png_path_from_graphics} tilemap)
# Omit path to generate all
tilemap: 
ifdef path
	rgbgfx -u -t incbin/$(path).tilemap -o incbin/$(path).2bpp $(IMG_DIR)/$(path).png
	@echo "Ran rgbgfx - tilemap for $(path)"
else
	$(foreach file, $(BKGRND_FILES), rgbgfx -u -t incbin/$(file).tilemap -o incbin/$(file).2bpp $(IMG_DIR)/$(file).png;)
	$(foreach file, $(WINDOW_FILES), rgbgfx -u -t incbin/$(file).tilemap -o incbin/$(file).2bpp $(IMG_DIR)/$(file).png;)
	@echo "Ran rgbgfx - tilemap for all"
endif

# Use clean if there are changes to the include files or incbin files
clean: 
	rm -r $(BIN_DIR)/$(OBJ_DIR)/*
	@echo "All clean!"