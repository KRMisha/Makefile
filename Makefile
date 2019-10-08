################################################################################
##### Variables and settings
################################################################################

# Project name
EXEC = project

# Build, bin and install directories (conserve root directories for clean)
BUILD_DIR_ROOT = build
BUILD_DIR := $(BUILD_DIR_ROOT)
BIN_DIR_ROOT = bin
BIN_DIR := $(BIN_DIR_ROOT)
INSTALL_DIR := ~/Desktop/$(EXEC)

# Sources (searches recursively inside the source directory)
SRC_DIR = src
SRCS := $(sort $(shell find $(SRC_DIR) -name '*.cpp'))

# Includes
INCLUDE_DIR = include
INCLUDES := -I$(INCLUDE_DIR)

# C preprocessor settings
CPPFLAGS := -MMD -MP $(INCLUDES)

# C++ compiler settings
CXX = g++
CXXFLAGS = -std=c++17
WARNINGS = -Wall -Wpedantic -Wextra

# Linker flags
LDFLAGS =

# Libraries to link
LDLIBS =

# Target OS detection
ifeq ($(OS),Windows_NT) # OS is a preexisting environment variable on Windows
	OS = windows
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Darwin)
		OS = macos
	else ifeq ($(UNAME),Linux)
		OS = linux
	else
    	$(error OS not supported by this Makefile)
	endif
endif

# OS-specific build and bin directories
BUILD_DIR := $(BUILD_DIR)/make_$(OS)
BIN_DIR := $(BIN_DIR)/$(OS)
ifeq ($(OS),windows)
	# Windows 32-bit
	ifeq ($(win32),1)
		BUILD_DIR := $(BUILD_DIR)32
		BIN_DIR := $(BIN_DIR)32
	# Windows 64-bit
	else
		BUILD_DIR := $(BUILD_DIR)64
		BIN_DIR := $(BIN_DIR)64
	endif
endif

# OS-specific compilation and linking settings
ifeq ($(OS),windows)
	# Add .exe extension to executable
	EXEC := $(EXEC).exe

	# Link everything statically on Windows (including libgcc and libstdc++)
	LDFLAGS += -static

	# Disable console output on release builds
	ifeq ($(release),1)
		LDFLAGS += -mwindows
	endif

	# 32-bit flags
	ifeq ($(win32),1)
		CXXFLAGS += -m32
	# 64-bit flags
	else
		CXXFLAGS += -m64
	endif
endif

# OS-specific assets-copying script selection
ifeq ($(OS),windows)
	ifeq ($(win32),1)
		ifeq ($(release),1)
			COPY_ASSETS_SCRIPT = copy_assets_windows32_r.sh
		else
			COPY_ASSETS_SCRIPT = copy_assets_windows32_d.sh
		endif
	else
		ifeq ($(release),1)
			COPY_ASSETS_SCRIPT = copy_assets_windows64_r.sh
		else
			COPY_ASSETS_SCRIPT = copy_assets_windows64_d.sh
		endif
	endif
else ifeq ($(OS),macos)
	ifeq ($(release),1)
		COPY_ASSETS_SCRIPT = copy_assets_macos_r.sh
	else
		COPY_ASSETS_SCRIPT = copy_assets_macos_d.sh
	endif
else ifeq ($(OS),linux)
	ifeq ($(release),1)
		COPY_ASSETS_SCRIPT = copy_assets_linux_r.sh
	else
		COPY_ASSETS_SCRIPT = copy_assets_linux_d.sh
	endif
endif

# Debug (default) and release modes settings
ifeq ($(release),1)
	BUILD_DIR := $(BUILD_DIR)/release
	BIN_DIR := $(BIN_DIR)/release
	CXXFLAGS += -O3
	CPPFLAGS += -DNDEBUG
else
	BUILD_DIR := $(BUILD_DIR)/debug
	BIN_DIR := $(BIN_DIR)/debug
	CXXFLAGS += -O0 -g
endif

# Objects and dependencies
OBJS := $(SRCS:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

################################################################################
##### Targets
################################################################################

.PHONY: all
all: $(BIN_DIR)/$(EXEC)

# Build executable
$(BIN_DIR)/$(EXEC): $(OBJS)
	@echo "Building executable: $@"
	@mkdir -p $(@D)
	@$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

# Compile C++ source files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@echo "Compiling: $<"
	@mkdir -p $(@D)
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(WARNINGS) -c $< -o $@

# Include automatically-generated dependencies
-include $(DEPS)

# Install packaged program
.PHONY: install
install: all copyassets
	@echo "Packaging program to $(INSTALL_DIR)"
	@mkdir -p $(INSTALL_DIR); cp -r $(BIN_DIR)/. $(INSTALL_DIR)

# Build and run
.PHONY: run
run: all
	@echo "Starting program: $(BIN_DIR)/$(EXEC)"
	@cd ./$(BIN_DIR); ./$(EXEC)

# Copy assets to bin directory for selected platform
.PHONY: copyassets
copyassets:
	@echo "Copying assets with script: $(COPY_ASSETS_SCRIPT)"
	@./scripts/$(COPY_ASSETS_SCRIPT) 2> /dev/null

# Clean build and bin directories for all platforms
.PHONY: clean
clean:
	@echo "Cleaning $(BUILD_DIR_ROOT) and $(BIN_DIR_ROOT) directories"
	@$(RM) -r $(BUILD_DIR_ROOT)
	@$(RM) -r $(BIN_DIR_ROOT)

# Clean all assets from bin directories for all platforms
.PHONY: cleanassets
cleanassets:
	@echo "Cleaning assets for all platforms"
	@./scripts/clean_assets.sh

# Run clang-format on source code
.PHONY: format
format:
	@echo "Running clang-format"
	@clang-format -i $$(find $(SRC_DIR) $(INCLUDE_DIR) -name '*.cpp' -o -name '*.h' -o -name '*.inl')

# Generate documentation with Doxygen
.PHONY: doc
doc:
	@echo "Generating documentation"
	@doxygen doc/Doxyfile

# Print help information
.PHONY: help
help:
	@echo "Usage: make target... [options]..."
	@echo
	@echo "Targets:"
	@echo "  all             Build executable (debug mode by default)"
	@echo "  install         Install packaged program to desktop (debug mode by default)"
	@echo "  run             Build and run executable (debug mode by default)"
	@echo "  copyassets      Copy assets to executable directory for selected platform"
	@echo "  clean           Clean build and bin directories (all platforms)"
	@echo "  cleanassets     Clean assets from executable directories (all platforms)"
	@echo "  format          Run clang-format on source code"
	@echo "  doc             Generate documentation with Doxygen"
	@echo "  help            Print this information"
	@echo "  printvars       Print Makefile variables for debugging"
	@echo
	@echo "Options:"
	@echo "  release=1       Build using release configuration rather than debug"
	@echo "  win32=1         Build for 32-bit Windows (valid when built on Windows only)"
	@echo
	@echo "Note: options affect all, install, run, copyassets, and printvars targets"

# Print Makefile variables
.PHONY: printvars
printvars:
	@echo OS: $(OS)
	@echo EXEC: $(EXEC)
	@echo BUILD_DIR: $(BUILD_DIR)
	@echo BIN_DIR: $(BIN_DIR)
	@echo INSTALL_DIR: $(INSTALL_DIR)
	@echo SRC_DIR: $(SRC_DIR)
	@echo SRCS: $(SRCS)
	@echo INCLUDE_DIR: $(INCLUDE_DIR)
	@echo INCLUDES: $(INCLUDES)
	@echo CXX: $(CXX)
	@echo CPPFLAGS: $(CPPFLAGS)
	@echo CXXFLAGS: $(CXXFLAGS)
	@echo WARNINGS: $(WARNINGS)
	@echo LDFLAGS: $(LDFLAGS)
	@echo LDLIBS: $(LDLIBS)
	@echo COPY_ASSETS_SCRIPT: $(COPY_ASSETS_SCRIPT)
