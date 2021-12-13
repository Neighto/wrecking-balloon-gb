# Makefile for assembling Wrecking Balloon

GAME_NAME	:= 	WRECKINGBALLOON

SRC_DIR		:=	src
INC_DIR		:=	$(SRC_DIR)/include
OBJ_DIR		:=	obj
BIN_DIR		:=	bin
OUTPUT		:=	$(BIN_DIR)/$(GAME_NAME)
SRC_ASM		:=	$(wildcard $(SRC_DIR)/*.asm)
OBJ_FILES	:=	$(addprefix $(BIN_DIR)/$(OBJ_DIR)/, $(SRC_ASM:src/%.asm=%.o))

ASSETS_DIR	:=  assets
IMG_DIR		:= images

.PHONY: all clean tileset tilemap

all: fix
	
fix: build
	rgbfix -p0 -v $(OUTPUT).gb

build: $(OBJ_FILES)
	rgblink -m $(OUTPUT).map -n $(OUTPUT).sym -o $(OUTPUT).gb $(OBJ_FILES)
	
$(BIN_DIR)/$(OBJ_DIR)/%.o : $(SRC_DIR)/%.asm
	rgbasm -i $(INC_DIR) -o $@ $<

# Use to make a tileset (ex: make arg={png_path_from_images} tileset)
# Special case used flag -u instead of -m for doing countdown numbers
tileset: 
	rgbgfx -u -h -o incbin/$(arg).2bpp  $(ASSETS_DIR)/$(IMG_DIR)/$(arg).png

# Use to make a tilemap and tileset (ex: make arg={png_path_from_images} tilemap)
tilemap: 
	rgbgfx -u -t incbin/$(arg).tilemap -o incbin/$(arg).2bpp  $(ASSETS_DIR)/$(IMG_DIR)/$(arg).png

# Use clean if there are changes to the inc files
clean: 
	rm -r $(BIN_DIR)/$(OBJ_DIR)/*