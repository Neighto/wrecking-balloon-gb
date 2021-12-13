# Makefile for assembling Wrecking Balloon

GAME_NAME	:= 	WRECKINGBALLOON

SRC_DIR		:=	src
INC_DIR		:=	$(SRC_DIR)/include
OBJ_DIR		:=	obj
BIN_DIR		:=	bin
OUTPUT		:=	$(BIN_DIR)/$(GAME_NAME)
SRC_ASM		:=	$(wildcard $(SRC_DIR)/*.asm)
OBJ_FILES	:=	$(addprefix $(BIN_DIR)/$(OBJ_DIR)/, $(SRC_ASM:src/%.asm=%.o))

.PHONY: all clean

all: fix
	
fix: build
	rgbfix -p0 -v $(OUTPUT).gb

build: $(OBJ_FILES)
	rgblink -m $(OUTPUT).map -n $(OUTPUT).sym -o $(OUTPUT).gb $(OBJ_FILES)
	
$(BIN_DIR)/$(OBJ_DIR)/%.o : $(SRC_DIR)/%.asm
	rgbasm -i $(INC_DIR) -o $@ $<

# Use clean if there are changes to the inc files
clean: 
	rm -r $(BIN_DIR)/$(OBJ_DIR)/*