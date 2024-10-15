################################################################################
#### Variables and settings
################################################################################

# Executable name
EXEC = program

# Build, bin, and assets directories (BUILD_DIR_ROOT and BIN_DIR_ROOT are used by the clean target)
BUILD_DIR_ROOT = build
BIN_DIR_ROOT = bin
ASSETS_DIR = assets
ASSETS_OS_DIR := $(ASSETS_DIR)_os

# Sources (searches recursively inside the source directory)
SRC_DIR = src
SRCS := $(sort $(shell find $(SRC_DIR) -name '*.cpp'))

# Includes
INCLUDE_DIR = include
INCLUDES := -I$(INCLUDE_DIR)

# C preprocessor settings
CPPFLAGS = $(INCLUDES) -MMD -MP

# C++ compiler settings
CXX = g++
CXXFLAGS = -std=c++20
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

# OS-specific settings
ifeq ($(OS),windows)
	# Link libgcc and libstdc++ statically on Windows
	LDFLAGS += -static-libgcc -static-libstdc++

	# Windows-specific settings
	INCLUDES +=
	LDFLAGS +=
	LDLIBS +=
else ifeq ($(OS),macos)
	# macOS-specific settings
	INCLUDES +=
	LDFLAGS +=
	LDLIBS +=
else ifeq ($(OS),linux)
	# Linux-specific settings
	INCLUDES +=
	LDFLAGS +=
	LDLIBS +=
endif

################################################################################
#### Final setup
################################################################################

# Add .exe extension to executable on Windows
ifeq ($(OS),windows)
	EXEC := $(EXEC).exe
endif

# OS-specific build, bin, and assets directories
BUILD_DIR := $(BUILD_DIR_ROOT)/$(OS)
BIN_DIR := $(BIN_DIR_ROOT)/$(OS)
ASSETS_OS_DIR := $(ASSETS_OS_DIR)/$(OS)

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
COMPDBS := $(OBJS:.o=.json)

# All files (sources and headers)
FILES := $(shell find $(SRC_DIR) $(INCLUDE_DIR) -name '*.cpp' -o -name '*.h' -o -name '*.hpp' -o -name '*.inl')

################################################################################
#### Targets
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

# Include automatically generated dependencies
-include $(DEPS)

# Build and run
.PHONY: run
run: all
	@echo "Starting program: $(BIN_DIR)/$(EXEC)"
	@cd $(BIN_DIR) && ./$(EXEC)

# Copy assets to bin directory for selected platform
.PHONY: copyassets
copyassets:
	@echo "Copying assets from $(ASSETS_DIR) and $(ASSETS_OS_DIR) to $(BIN_DIR)"
	@mkdir -p $(BIN_DIR)
	@cp -r $(ASSETS_DIR)/. $(BIN_DIR)/
	@cp -r $(ASSETS_OS_DIR)/. $(BIN_DIR)/ 2> /dev/null || :

# Clean all assets from bin directories for all platforms
.PHONY: cleanassets
cleanassets:
	@echo "Cleaning assets for all platforms"
	@find $(BIN_DIR_ROOT) -mindepth 3 ! -name $(EXEC) -delete

# Clean build and bin directories for all platforms
.PHONY: clean
clean:
	@echo "Cleaning $(BUILD_DIR_ROOT) and $(BIN_DIR_ROOT) directories"
	@$(RM) -r $(BUILD_DIR_ROOT)
	@$(RM) -r $(BIN_DIR_ROOT)

.PHONY: compdb
compdb: $(BUILD_DIR_ROOT)/compile_commands.json

# Generate JSON compilation database (compile_commands.json) by merging fragments
$(BUILD_DIR_ROOT)/compile_commands.json: $(COMPDBS)
	@echo "Generating: $@"
	@mkdir -p $(@D)
	@printf "[\n" > $@
	@sed -e '$$s/$$/,/' -s $(COMPDBS) | sed -e '$$s/,$$//' -e 's/^/    /' >> $@
	@printf "]\n" >> $@

# Generate JSON compilation database fragments from source files
$(BUILD_DIR)/%.json: $(SRC_DIR)/%.cpp
	@mkdir -p $(@D)
	@printf "\
	{\n\
	    \"directory\": \"$(CURDIR)\",\n\
	    \"command\": \"$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(WARNINGS) -c $< -o $(basename $@).o\",\n\
	    \"file\": \"$<\"\n\
	}\n" > $@

# Run clang-format on source code
.PHONY: format
format:
	@echo "Running clang-format"
	@clang-format -i $(FILES)

# Dry-run clang-format on source code to check for formatting errors
.PHONY: format-check
format-check:
	@echo "Checking clang-format"
	@clang-format --dry-run --Werror $(FILES)

# Run clang-tidy on source code
.PHONY: lint
lint: compdb
	@echo "Running clang-tidy"
	@clang-tidy -p $(BUILD_DIR_ROOT) --warnings-as-errors='*' $(FILES)

# Run clang-tidy on source code and fix found errors
.PHONY: lint-fix
lint-fix: compdb
	@echo "Running clang-tidy --fix"
	@clang-tidy -p $(BUILD_DIR_ROOT) --fix $(FILES)

# Generate documentation with Doxygen
.PHONY: docs
docs:
	@echo "Generating documentation"
	@doxygen docs/Doxyfile

# Print help information
.PHONY: help
help:
	@printf "\
	Usage: make target... [options]...\n\
	\n\
	Targets:\n\
	  all             Build executable (debug mode by default) (default target)\n\
	  run             Build and run executable (debug mode by default)\n\
	  copyassets      Copy assets to executable directory for selected platform and configuration\n\
	  cleanassets     Clean assets from executable directories (all platforms)\n\
	  clean           Clean build and bin directories (all platforms)\n\
	  compdb          Generate JSON compilation database (compile_commands.json)\n\
	  format          Format source code using clang-format\n\
	  format-check    Check that source code is formatted using clang-format\n\
	  lint            Lint source code using clang-tidy\n\
	  lint-fix        Lint and fix source code using clang-tidy\n\
	  docs            Generate documentation with Doxygen\n\
	  help            Print this information\n\
	  printvars       Print Makefile variables for debugging\n\
	\n\
	Options:\n\
	  release=1       Run target using release configuration rather than debug\n\
	\n\
	Note: the above options affect the all, run, copyassets, compdb, and printvars targets\n"

# Print Makefile variables
.PHONY: printvars
printvars:
	@printf "\
	OS: \"$(OS)\"\n\
	EXEC: \"$(EXEC)\"\n\
	BUILD_DIR: \"$(BUILD_DIR)\"\n\
	BIN_DIR: \"$(BIN_DIR)\"\n\
	ASSETS_DIR: \"$(ASSETS_DIR)\"\n\
	ASSETS_OS_DIR: \"$(ASSETS_OS_DIR)\"\n\
	SRC_DIR: \"$(SRC_DIR)\"\n\
	SRCS: \"$(SRCS)\"\n\
	INCLUDE_DIR: \"$(INCLUDE_DIR)\"\n\
	INCLUDES: \"$(INCLUDES)\"\n\
	CXX: \"$(CXX)\"\n\
	CPPFLAGS: \"$(CPPFLAGS)\"\n\
	CXXFLAGS: \"$(CXXFLAGS)\"\n\
	WARNINGS: \"$(WARNINGS)\"\n\
	LDFLAGS: \"$(LDFLAGS)\"\n\
	LDLIBS: \"$(LDLIBS)\"\n"

# Made by Misha Krieger-Raynauld (https://github.com/KRMisha/Makefile)
