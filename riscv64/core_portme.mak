# Copyright 2018 Embedded Microprocessor Benchmark Consortium (EEMBC)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# Original Author: Shay Gal-on

#File: core_portme.mak

# Flag: OUTFLAG
#	Use this flag to define how to to get an executable (e.g -o)
OUTFLAG= -o
# Flag: CC
#	Use this flag to define compiler to use
CC = /home/llvm-project/build/bin/clang 
# Flag: CFLAGS
#	Use this flag to define compiler options. Note, you can add compiler options from the command line using XCFLAGS="other flags"
PORT_CFLAGS = --target=riscv64-unknown-linux-gnu -Os -march=rv64g --sysroot=/opt/riscv/sysroot -L  /opt/riscv/lib/gcc/riscv64-unknown-linux-gnu/14.2.0
FLAGS_STR = "$(PORT_CFLAGS) $(XCFLAGS) $(XLFLAGS) $(LFLAGS_END)"
CFLAGS = $(PORT_CFLAGS) -I$(PORT_DIR) -I. -DFLAGS_STR=\"$(FLAGS_STR)\"
# Flag: NO_LIBRT
#	Define if the platform does not provide a librt
ifndef NO_LIBRT
#Flag: LFLAGS_END
#	Define any libraries needed for linking or other flags that should come at the end of the link line (e.g. linker scripts). 
#	Note: On certain platforms, the default clock_gettime implementation is supported but requires linking of librt.
#LFLAGS_END += -lrt 
endif
# Flag: PORT_SRCS #	Port specific source files can be added here 
PORT_SRCS = $(PORT_DIR)/core_portme.c
# Flag: EXTRA_DEPENDS
#	Port specific extra build dependencies.
#	Some ports inherit from us, so ensure this Makefile is always a dependency.
#EXTRA_DEPENDS += /core_portme.mak
# Flag: LOAD
#	Define this flag if you need to load to a target, as in a cross compile environment.

# Flag: RUN
#	Define this flag if running does not consist of simple invocation of the binary.
#	In a cross compile environment, you need to define this.

#For flashing and using a tera term macro, you could use
#LOAD = flash ADDR 
#RUN =  ttpmacro coremark.ttl

#For copying to target and executing via SSH connection, you could use
#LOAD = scp $(OUTFILE)  user@target:~
#RUN = ssh user@target -c  

#For native compilation and execution
LOAD = echo Loading done
RUN = /home/qemu/bin/qemu-riscv64 -L /opt/riscv/sysroot

OEXT = .o
EXE = .exe

# Flag: SEPARATE_COMPILE
# Define if you need to separate compilation from link stage. 
# In this case, you also need to define below how to create an object file, and how to link.
ifdef SEPARATE_COMPILE

LD		= gcc
OBJOUT 	= -o
LFLAGS 	=
OFLAG 	= -o
COUT 	= -c
# Flag: PORT_OBJS
# Port specific object files can be added here
PORT_OBJS = $(PORT_DIR)/core_portme$(OEXT)
PORT_CLEAN = *$(OEXT)

$(OPATH)%$(OEXT) : %.c
	$(CC) $(CFLAGS) $(XCFLAGS) $(COUT) $< $(OBJOUT) $@

$(OPATH)$(PORT_DIR)/%$(OEXT) : posix/%.c
	$(CC) $(CFLAGS) $(XCFLAGS) $(COUT) $< $(OBJOUT) $@

endif

# Target: port_prebuild
# Generate any files that are needed before actual build starts.
# E.g. generate profile guidance files. Sample PGO generation for gcc enabled with PGO=1
#  - First, check if PGO was defined on the command line, if so, need to add -fprofile-use to compile line.
#  - Second, if PGO reference has not yet been generated, add a step to the prebuild that will build a profile-generate version and run it.
#  Note - Using REBUILD=1 
#
# Use make PGO=1 to invoke this sample processing.

ifdef PGO
 ifeq (,$(findstring $(PGO),gen))
  PGO_STAGE=build_pgo_gcc
  CFLAGS+=-fprofile-use
 endif
 PORT_CLEAN+=*.gcda *.gcno gmon.out
endif

.PHONY: port_prebuild
port_prebuild: $(PGO_STAGE)

.PHONY: build_pgo_gcc
build_pgo_gcc:
	$(MAKE) PGO=gen XCFLAGS="$(XCFLAGS) -fprofile-generate -DTOTAL_DATA_SIZE=1200" ITERATIONS=10 gen_pgo_data REBUILD=1
	
# Target: port_postbuild
# Generate any files that are needed after actual build end.
# E.g. change format to srec, bin, zip in order to be able to load into flash
.PHONY: port_postbuild
port_postbuild:

# Target: port_postrun
# 	Do platform specific after run stuff. 
#	E.g. reset the board, backup the logfiles etc.
.PHONY: port_postrun
port_postrun:

# Target: port_prerun
# 	Do platform specific after run stuff. 
#	E.g. reset the board, backup the logfiles etc.
.PHONY: port_prerun
port_prerun:

# Target: port_postload
# 	Do platform specific after load stuff. 
#	E.g. reset the reset power to the flash eraser
.PHONY: port_postload
port_postload:

# Target: port_preload
# 	Do platform specific before load stuff. 
#	E.g. reset the reset power to the flash eraser
.PHONY: port_preload
port_preload:

# FLAG: OPATH
# Path to the output folder. Default - current folder.
OPATH = ./
MKDIR = mkdir -p

# FLAG: PERL
# Define perl executable to calculate the geomean if running separate.
PERL=/usr/bin/perl
