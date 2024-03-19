######################################
# target
######################################
TARGET = DMAFlash
OI_ROOT=$(OI_DIR)
######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
OPT = -O0

#######################################
# paths
#######################################
# Build path
APP_DIR = $(shell pwd)
BUILD9_DIR = build9
LLVM_ROOT = $(OI_ROOT)llvm9/
GCC_ROOT = $(OI_ROOT)gcc/bins/
SVF_ROOT = $(OI_ROOT)SVF/
######################################
# source
######################################
# C sources
C_SOURCES = \
	../../Src/main.c \
	../../Src/stm32f4xx_it.c \
	../../Src/system_stm32f4xx.c \
	../../Src/stm32f4xx_hal_msp.c \
	../../../Drivers/stm32f4xx_hal_uart.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_hcd.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_i2c_ex.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rtc.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_spi.c \
	../../../Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_ll_usb.c  \
	../../../Drivers/BSP/STM32F4-Discovery/stm32f4_discovery.c \
	../../../mbedtls-2.2.1/library/sha256.c 

# ASM sources
ASM_SOURCES = \
../../SW4STM32/startup_stm32f407xx.s 

#######################################
# binaries
#######################################
AS = $(LLVM_ROOT)build/bin/llvm-as
OP = $(LLVM_ROOT)build/bin/opt
CC = $(LLVM_ROOT)build/bin/clang
CP = $(LLVM_ROOT)build/bin/llvm-objcopy
SZ = $(LLVM_ROOT)build/bin/llvm-size
DIS = $(LLVM_ROOT)build/bin/llvm-dis
OBJDUMP = $(GCC_ROOT)/bin/arm-none-eabi-objdump
NM  = $(GCC_ROOT)/bin/arm-none-eabi-nm
WPA = $(SVF_ROOT)Release-build/bin/wpa
DVF = $(SVF_ROOT)Release-build/bin/dvf

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m4
# fpu
FPU = -mfpu=fpv4-sp-d16
# float-abi
FLOAT-ABI = -mfloat-abi=soft
# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)


# macros for gcc

# C defines
# C_DEFS = -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO -DTIMER_BASELINE
C_DEFS = -DUSE_HAL_DRIVER -DSTM32F407xx -DUSE_STM32F4_DISCO

# C includes
C_INCLUDES = \
	-I../../inc \
	-I ../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include \
	-I ../../../Drivers/STM32F4xx_HAL_Driver/Inc \
	-I ../../../Drivers \
	-I ../../../Drivers/BSP/STM32F4-Discovery \
	-I ../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include \
	-I ../../../Drivers/CMSIS/Include \
	-I ../../../mbedtls-2.2.1/include/mbedtls

C_INCLUDES += -I $(GCC_ROOT)/arm-none-eabi/include
# compile gcc flags
ASFLAGS = $(MCU)  $(C_INCLUDES) $(OPT) -Wall -target arm-none-eabi 

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections -target arm-none-eabi -fshort-enums \
--sysroot=$(ARM_NONE_EABI_PATH)arm-none-eabi -ffreestanding -fno-builtin -fno-exceptions
# CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections -target arm-none-eabi -fshort-enums \
# --sysroot=$(ARM_NONE_EABI_PATH)arm-none-eabi -ffreestanding -fno-builtin -fno-exceptions -fprofile-arcs -ftest-coverage
ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2 
# CFLAGS += -DOI_TRACE
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = STM32F407VGTx_FLASH
LLVMGOLD =  $(LLVM_ROOT)build/lib/LLVMgold.so
# libraries
# LIBS = -lgcov -lc -lm -lgcc -lnosys 
LIBS = -lc -lm -lgcc -lnosys 
#-lnosys 
LIBDIR = \
-L $(GCC_ROOT)lib/gcc/arm-none-eabi/6.3.1/thumb/v7e-m \
-L $(GCC_ROOT)arm-none-eabi/lib/thumb/v7e-m \
-L $(GCC_ROOT)lib/gcc/arm-none-eabi/6.3.1/thumb/v7e-m \
-I $(GCC_ROOT)arm-none-eabi/include
LDFLAGS =   -T$(LDSCRIPT).ld $(LIBDIR) $(LIBS) \
-plugin=$(LLVMGOLD) \
--plugin-opt=O0 \
--plugin-opt=save-temps \
--plugin-opt=-float-abi=soft \
--plugin-opt=-mcpu=cortex-m4 \
--plugin-opt=-defuse \
--gc-sections

LDFLAGS_TRACE = -T$(LDSCRIPT).ld $(LIBDIR) $(LIBS) \
-plugin=$(LLVMGOLD) \
--plugin-opt=O0 \
--plugin-opt=save-temps \
--plugin-opt=-float-abi=soft \
--plugin-opt=-mcpu=cortex-m4 \
--plugin-opt=-opectrace \
--gc-sections

all: $(BUILD9_DIR)/$(TARGET).elf


#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD9_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
ASMOBJECTS += $(addprefix $(BUILD9_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD9_DIR)/%.o: %.c Makefile | $(BUILD9_DIR)
	$(CC) -flto -c $(CFLAGS)  $< -o $@

$(BUILD9_DIR)/%.o: %.s Makefile | $(BUILD9_DIR)
	$(CC) -flto -c $(ASFLAGS) $< -o $@


$(BUILD9_DIR)/$(TARGET).elf:$(ASMOBJECTS) $(OBJECTS) Makefile
	# build the baseline app(*.elf) with its bitcodes and load_store inst for each function
	# echo "==============\n\n\n"
	# echo "$(WPA) -ander -stat=true -print-fp -dump-callgraph $(BUILD9_DIR)/$(TARGET).elf.0.5.precodegen.bc > build9/ander_funcptr.txt"
	# echo "\n\n\n=============="
	$(GCC_ROOT)bin/arm-none-eabi-ld $(ASMOBJECTS) $(OBJECTS) $(LDFLAGS) > $(APP_DIR)/$(BUILD9_DIR)/$(TARGET)_def_use.output 2>&1 -o $@
	$(WPA) -ander -stat=true -print-fp -dump-callgraph $(BUILD9_DIR)/$(TARGET).elf.0.5.precodegen.bc > build9/ander_funcptr.txt
	mv $(APP_DIR)/callgraph_final.dot $(APP_DIR)/$(BUILD9_DIR)/callgraph_final.dot
	python3 $(OI_ROOT)compiler/analysis/scripts/format_callgraph.py -in $(APP_DIR)/$(BUILD9_DIR)/callgraph_final.dot -out $(APP_DIR)/$(BUILD9_DIR)/callgraph_format.dot
	# $(OP) -mem2reg $(BUILD9_DIR)/$(TARGET).elf.0.5.precodegen.bc -o $(BUILD9_DIR)/$(TARGET).elf.0.5.precodegen.opt

	$(SZ) $@
	${NM} -S $@ > $(BUILD9_DIR)/$(TARGET).map
	$(DIS) $(APP_DIR)/$(BUILD9_DIR)/$(TARGET).elf.0.5.precodegen.bc -o $(APP_DIR)/$(BUILD9_DIR)/$(TARGET).elf.0.5.precodegen.ll
	${DVF} -cxt -query=all -maxcxt=3 -print-all-pts  $(APP_DIR)/$(BUILD9_DIR)/$(TARGET).elf.0.5.precodegen.bc > $(APP_DIR)/$(BUILD9_DIR)/$(TARGET).pts
	pwd
	# Analysis
	python3 $(OI_ROOT)compiler/analysis/scripts/parse_load_store.py \
		-a $(TARGET) \
		-b ./$(BUILD9_DIR)/


$(BUILD9_DIR):
	mkdir $@
	cp ./Entry_functions.json $@/
	cp ./gv_2_peripheral.json $@/

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD9_DIR)

#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD9_DIR)/*.d)

# *** EOF ***