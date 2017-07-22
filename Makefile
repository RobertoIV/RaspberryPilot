# /******************************************************************************
# The Makefile in RaspberryPilot project is placed under the MIT license
#
# Copyright (c) 2016 jellyice1986 (Tung-Cheng Wu)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ******************************************************************************/

CC = $(CROSS_COMPILE)gcc
RM = rm -rf 
PWD	= ${shell pwd}
SUBDIR = Module
LIB_PATH = -L$(PWD)/Module/bin
OUTPUT_DIR = bin
OBJ_DIR = obj
LIB = -lModule_RaspberryPilot -lwiringPi -lm -lpthread
PROCESS = RaspberryPilot
TARGET_PROCESS = $(OUTPUT_DIR)/$(PROCESS)
RASPBERRYPILOT_CFLAGS += $(DEFAULT_CFLAGS) -Wno-unused-function

include $(PWD)/config.mk

INCLUDES = \
	-I. \
	-I${PWD}/Module/PCA9685/core/inc \
	-I${PWD}/Module/MPU6050/core/inc

LIB_SRCS = \
	commonLib.c \
	i2c.c \
	securityMechanism.c \
	ahrs.c \
	motorControl.c \
	systemControl.c \
	pid.c \
	kalmanFilter.c \
	smaFilter.c \
	altHold.c \
	radioControl.c \
	flyControler.c \
	raspberryPilotMain.c

ifeq ($(CONFIG_ALTHOLD_MS5611_SUPPORT),y)
	INCLUDES += \
		-I${PWD}/Module/MS5611/core/inc
else	
	ifeq ($(CONFIG_ALTHOLD_SRF02_SUPPORT),y)
		INCLUDES += \
			-I${PWD}/Module/SRF02/core/inc
	else	
		ifeq ($(CONFIG_ALTHOLD_VL53L0X_SUPPORT),y)
				INCLUDES += \
					-I${PWD}/Module/VL53l0x/core/inc \
					-I${PWD}/Module/VL53l0x/platform/inc
		endif	
	endif	
endif	
	
LIB_OBJS = $(LIB_SRCS:%.c=$(OBJ_DIR)/%.o)	

.PHONY: all
all: $(TARGET_PROCESS)

$(TARGET_PROCESS): $(SUBDIR) $(LIB_OBJS)
	@echo "\033[32mMake RaspberryPilot all...\033[0m"
	mkdir -p $(dir $@)
	$(CC) $(LIB_OBJS) $(LIB) $(LIB_PATH) $(INCLUDES) -o $@

$(OBJ_DIR)/%.o: $(PWD)/%.c
	mkdir -p $(dir $@)
	@echo "\033[32mCompiling RaspberryPilot $@...\033[0m"	
	$(CC) -c -o $@ $< $(RASPBERRYPILOT_CFLAGS) $(INCLUDES) $(LIB) $(LIB_PATH) 

.PHONY: $(SUBDIR)
$(SUBDIR):
	make -C $@ 

.PHONY: clean	
clean:
	@echo "\033[32mCleaning RaspberryPilot clean...\033[0m"
	-find -name "*.o" -type f | xargs $(RM)
	-find -name "*.a" -type f | xargs $(RM)
	-find -name "$(OBJ_DIR)" -type d | xargs $(RM)
	-find -name "$(OUTPUT_DIR)" -type d | xargs $(RM)
	-find -name "$(PROCESS)" -type f | xargs $(RM)

.PHONY: updateScript
updateScript:
	update-rc.d RaspberryPilot remove
	$(RM) /etc/init.d/RaspberryPilot
	cp RaspberryPilot.sh /etc/init.d/RaspberryPilot
	chmod 755 /etc/init.d/RaspberryPilot
	update-rc.d RaspberryPilot defaults

.PHONY: removeScript
removeScript:
	update-rc.d RaspberryPilot remove
	$(RM) /etc/init.d/RaspberryPilot






