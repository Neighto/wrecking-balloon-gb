# Simple makefile for assembling and linking a GB program.
rwildcard		=	$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))
BUILD_DIR		:=	build
PROJECT_NAME	?=	wreckballoon
OUTPUT			:=	$(BUILD_DIR)/$(PROJECT_NAME)
SRC_DIR			:=	src
INC_DIR			:=	include
SRC_ASM			:=	$(call rwildcard, $(SRC_DIR)/, *.asm)
OBJ_FILES		:=	$(addprefix $(BUILD_DIR)/obj/, $(SRC_ASM:src/%.asm=%.o))
OBJ_DIRS 		:=	$(sort $(addprefix $(BUILD_DIR)/obj/, $(dir $(SRC_ASM:src/%.asm=%.o))))
ASM_FLAGS		:=	-i $(INC_DIR)

.PHONY: all clean

all: fix
	
fix: build
	rgbfix -p0 -v $(OUTPUT).gb

build: $(OBJ_FILES)
	rgblink -m $(OUTPUT).map -n $(OUTPUT).sym -o $(OUTPUT).gb $(OBJ_FILES)
	
$(BUILD_DIR)/obj/%.o : src/%.asm | $(OBJ_DIRS)
	rgbasm $(ASM_FLAGS) -o $@ $<

$(OBJ_DIRS): 
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)

print-%  : ; @echo $* = $($*)