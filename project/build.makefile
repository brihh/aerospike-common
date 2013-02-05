###############################################################################
##  BUILD VARIABLES                                                          ##
###############################################################################

export CFLAGS =
export LDFLAGS =
export ARFLAGS =

###############################################################################
##  BUILD ENVIRONMENT                                                        ##
###############################################################################

ROOT = $(CURDIR)
NAME = $(shell basename $(ROOT))
OS = $(shell uname)
ARCH = $(shell arch)
DISTRO_NAME = $(shell lsb_release -is)
DISTRO_VERS = $(shell lsb_release -rs)

PROJECT = project
MODULES = modules
SOURCE  = src
TARGET  = target

SUBMODULES = $(filter-out .%, $(wildcard $(MODULES)/*))

###############################################################################
##  BUILD TOOLS                                                              ##
###############################################################################

CC = gcc
CC_FLAGS =

LD = gcc
LD_FLAGS =

AR = ar
AR_FLAGS =

###############################################################################
##  SOURCE PATHS                                                             ##
###############################################################################

SOURCE_PATH = $(SOURCE)
SOURCE_MAIN = $(SOURCE_PATH)/main
SOURCE_INCL = $(SOURCE_PATH)/include
SOURCE_TEST = $(SOURCE_PATH)/test

VPATH = $(SOURCE_MAIN) $(SOURCE_INCL)

LIB_PATH = 
INC_PATH = $(SOURCE_INCL)

###############################################################################
##  TARGET PATHS                                                             ##
###############################################################################

ifeq ($(shell test -e $(PROJECT)/target.$(DISTRO_NAME)-$(DISTRO_VERS)-$(ARCH).makefile && echo 1), 1)
PLATFORM = $(DISTRO_NAME)-$(DISTRO_VERS)-$(ARCH)
include $(PROJECT)/target.$(PLATFORM).makefile
else
ifeq ($(shell test -e $(PROJECT)/target.$(DISTRO_NAME)-$(ARCH).makefile && echo 1), 1)
PLATFORM = $(DISTRO_NAME)-$(ARCH)
include $(PROJECT)/target.$(PLATFORM).makefile
else
ifeq ($(shell test -e $(PROJECT)/target.$(OS)-$(ARCH).makefile && echo 1), 1)
PLATFORM = $(OS)-$(ARCH)
include $(PROJECT)/target.$(PLATFORM).makefile
else
ifeq ($(shell test -e project/target.$(OS)-noarch.makefile && echo 1), 1)
PLATFORM = $(OS)-noarch
include $(PROJECT)/target.$(PLATFORM).makefile
else
PLATFORM = $(OS)-$(ARCH)
endif
endif
endif
endif

TARGET_PATH = $(TARGET)
TARGET_BASE = $(TARGET_PATH)/$(PLATFORM)
TARGET_BIN 	= $(TARGET_BASE)/bin
TARGET_DOC 	= $(TARGET_BASE)/doc
TARGET_LIB 	= $(TARGET_BASE)/lib
TARGET_OBJ 	= $(TARGET_BASE)/obj
TARGET_INCL = $(TARGET_BASE)/include

###############################################################################
##  FUNCTIONS                                                                ##
###############################################################################

#
# Builds an object, library, archive or executable using the dependencies specified for the target.
# 
# x: [dependencies]
#   $(call <command>, include_paths, library_paths, libraries, flags)
#
# Commands:
# 		build 			- Automatically determine build type based on target name.
# 		object 			- Build an object: .o
# 		library 		- Build a dynamic shared library: .so
# 		archive 		- Build a static library (archive): .a
#		executable 		- Build an executable
# 
# Arguments:
#		include_paths	- Space separated list of search paths for include files.
#						  Relative paths are relative to the project root.
#		library_paths	- Space separated list of search paths for libraries.
#						  Relative paths are relative to the project root.
#		libraries		- space separated list of libraries.
#		flags 			- space separated list of linking flags.
#
# You can optionally define variables, rather than arguments as:
#
#	X_inc_path = [include_paths]
#	X_lib_path = [library_paths]
#	X_lib = [libraries]
# 	X_flags = [flags]
#
# Where X is the name of the build target.
#

define build
	$(if $(filter .o,$(suffix $@)), 
		$(call object, $(1),$(2),$(3),$(4)),
		$(if $(filter .so,$(suffix $@)), 
			$(call library, $(1),$(2),$(3),$(4)),
			$(if $(filter .a,$(suffix $@)), 
				$(call archive, $(1),$(2),$(3),$(4)),
				$(call executable, $(1),$(2),$(3),$(4))
			)
		)
	)
endef

define executable
	@if [ ! -d `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(strip $(CC) \
		$(addprefix -I, $(SUBMODULES:%=%/$(SOURCE_INCL))) \
		$(addprefix -I, $(INC_PATH)) \
		$(addprefix -L, $(SUBMODULES:%=%/$(TARGET_LIB))) \
		$(addprefix -L, $(LIB_PATH)) \
		$(addprefix -l, $(LIBRARIES)) \
		$(LD_FLAGS) \
		$(LDFLAGS) \
		-o $@ \
		$^ \
		$(INPUT) \
	)
endef

define archive
	@if [ ! -d `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(strip $(AR) \
		rcs \
		$(AR_FLAGS) \
		$@ \
		$^ \
		$(INPUT) \
	)
endef

define library
	@if [ ! -d `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(strip $(CC) -shared \
		$(addprefix -I, $(SUBMODULES:%=%/$(SOURCE_INCL))) \
		$(addprefix -I, $(INC_PATH)) \
		$(addprefix -L, $(SUBMODULES:%=%/$(TARGET_LIB))) \
		$(addprefix -L, $(LIB_PATH)) \
		$(addprefix -l, $(LIBRARIES)) \
		$(LD_FLAGS) \
		-o $@ \
		$^ \
		$(INPUT) \
	)
endef

define object
	@if [ ! -d `dirname $@` ]; then mkdir -p `dirname $@`; fi
	$(strip $(CC) \
		$(addprefix -I, $(SUBMODULES:%=%/$(SOURCE_INCL))) \
		$(addprefix -I, $(INC_PATH)) \
		$(addprefix -L, $(SUBMODULES:%=%/$(TARGET_LIB))) \
		$(addprefix -L, $(LIB_PATH)) \
		$(CC_FLAGS) \
		-o $@ \
		-c $^ \
		$(INPUT) \
	)
endef

define make_each
	@for i in $(1); do \
		make -C $$i $(2);\
	done;
endef

###############################################################################
##  COMMON TARGETS                                                           ##
###############################################################################

$(TARGET_PATH):
	mkdir $@

$(TARGET_BASE): | $(TARGET_PATH)
	mkdir $@

$(TARGET_BIN): | $(TARGET_BASE)
	mkdir $@

$(TARGET_DOC): | $(TARGET_BASE)
	mkdir $@

$(TARGET_LIB): | $(TARGET_BASE)
	mkdir $@

$(TARGET_OBJ): | $(TARGET_BASE)
	mkdir $@

.PHONY: info
info:
	@echo
	@echo "  NAME:     " $(NAME) 
	@echo "  OS:       " $(OS)
	@echo "  ARCH:     " $(ARCH)
	@echo "  DISTRO:   " $(DISTRO_NAME)"-"$(DISTRO_VERS)
	@echo
	@echo "  PATHS:"
	@echo "      source:     " $(SOURCE)
	@echo "      target:     " $(TARGET_BASE)
	@echo "      includes:   " $(INC_PATH)
	@echo "      libraries:  " $(LIB_PATH)
	@echo "      submodules: " $(SUBMODULES)
	@echo
	@echo "  COMPILER:"
	@echo "      command:    " $(CC)
	@echo "      flags:      " $(CC_FLAGS)
	@echo
	@echo "  LINKER:"
	@echo "      command:    " $(LD)
	@echo "      flags:      " $(LD_FLAGS)
	@echo
	@echo "  ARCHIVER:"
	@echo "      command:    " $(AR)
	@echo "      flags:      " $(AR_FLAGS)
	@echo

.PHONY: clean
clean: 
	@rm -rf $(TARGET)
	$(call make_each, $(SUBMODULES), clean)


.PHONY: $(TARGET_OBJ)/%.o
$(TARGET_OBJ)/%.o : %.c | $(TARGET_OBJ) 
	$(object)


.DEFAULT_GOAL := all
