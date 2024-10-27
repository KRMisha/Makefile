################################################################################
#### Variables and settings
################################################################################

# Executable name
EXEC = program

# Test executable name
TEST_EXEC = tests

# Build directory
BUILD_DIR_ROOT = build

# Assets directories
ASSETS_DIR = assets
ASSETS_OS_DIR := $(ASSETS_DIR)_os

# Executable sources (found recursively inside SRC_DIR)
SRC_DIR = src
SRCS := $(sort $(shell find $(SRC_DIR) -name '*.cpp'))

# Test sources (found recursively inside TEST_DIR if it exists)
TEST_DIR = tests
TEST_SRCS := $(sort $(shell find $(TEST_DIR) -name '*.cpp' 2> /dev/null))

# Includes
INCLUDE_DIR =
INCLUDES = $(addprefix -I,$(SRC_DIR) $(INCLUDE_DIR))
TEST_INCLUDES = -I$(TEST_DIR)

# C preprocessor settings
CPPFLAGS = $(INCLUDES) -MMD -MP

# C++ compiler settings
CXX = g++
CXXFLAGS = -std=c++20
WARNINGS = -Wall -Wpedantic -Wextra

# Linker flags
LDFLAGS =
TEST_LDFLAGS =

# Libraries to link
LDLIBS =
TEST_LDLIBS =

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

# Platform-specific settings
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

# Add .exe extension to executables on Windows
ifeq ($(OS),windows)
	EXEC := $(EXEC).exe
	TEST_EXEC := $(TEST_EXEC).exe
endif

# Platform-specific build and assets directories
BUILD_DIR := $(BUILD_DIR_ROOT)/$(OS)
ASSETS_OS_DIR := $(ASSETS_OS_DIR)/$(OS)

# Debug (default) and release configuration settings
ifeq ($(release),1)
	BUILD_DIR := $(BUILD_DIR)/release
	CPPFLAGS += -DNDEBUG
	CXXFLAGS += -O3
else
	BUILD_DIR := $(BUILD_DIR)/debug
	CXXFLAGS += -O0 -g
endif

# Object and bin directories
OBJ_DIR := $(BUILD_DIR)/obj
BIN_DIR := $(BUILD_DIR)/bin

# Object files
MAIN_SRC = $(SRC_DIR)/main.cpp
MAIN_OBJ := $(MAIN_SRC:%.cpp=$(OBJ_DIR)/%.o)
SRCS_WITHOUT_MAIN := $(filter-out $(MAIN_SRC),$(SRCS))
SRC_OBJS_WITHOUT_MAIN := $(SRCS_WITHOUT_MAIN:%.cpp=$(OBJ_DIR)/%.o)
TEST_OBJS := $(TEST_SRCS:%.cpp=$(OBJ_DIR)/%.o)
ALL_OBJS := $(MAIN_OBJ) $(SRC_OBJS_WITHOUT_MAIN) $(TEST_OBJS)

# Dependency files
DEPS := $(ALL_OBJS:.o=.d)

# Compilation database fragments
COMPDBS := $(ALL_OBJS:.o=.json)

# All files (sources and headers) (for formatting and linting)
FILES := $(shell find $(SRC_DIR) $(TEST_DIR) $(INCLUDE_DIR) -name '*.cpp' -o -name '*.h' -o -name '*.hpp' -o -name '*.inl' 2> /dev/null)

################################################################################
#### Targets
################################################################################

# Disable default implicit rules
.SUFFIXES:

.PHONY: all
all: $(BIN_DIR)/$(EXEC) $(if $(TEST_SRCS),$(BIN_DIR)/$(TEST_EXEC))

# Build executable
$(BIN_DIR)/$(EXEC): $(MAIN_OBJ) $(SRC_OBJS_WITHOUT_MAIN)
	@echo "Building executable: $@"
	@mkdir -p $(@D)
	@$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

# Build tests
$(BIN_DIR)/$(TEST_EXEC): LDFLAGS += $(TEST_LDFLAGS)
$(BIN_DIR)/$(TEST_EXEC): LDLIBS += $(TEST_LDLIBS)
$(BIN_DIR)/$(TEST_EXEC): $(TEST_OBJS) $(SRC_OBJS_WITHOUT_MAIN)
	@echo "Building tests: $@"
	@mkdir -p $(@D)
	@$(CXX) $(LDFLAGS) $^ $(LDLIBS) -o $@

# Compile C++ source files
$(OBJ_DIR)/$(TEST_DIR)/%.o: INCLUDES += $(TEST_INCLUDES)
$(ALL_OBJS): $(OBJ_DIR)/%.o: %.cpp
	@echo "Compiling: $<"
	@mkdir -p $(@D)
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(WARNINGS) -c $< -o $@

# Include automatically-generated dependency files
-include $(DEPS)

# Build and run executable
.PHONY: run
run: $(BIN_DIR)/$(EXEC)
	@echo "Running program: $<"
	@cd $(BIN_DIR) && ./$(EXEC)

# Build and run tests
.PHONY: test
test: $(BIN_DIR)/$(TEST_EXEC)
	@echo "Running tests: $<"
	@cd $(BIN_DIR) && ./$(TEST_EXEC)

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
	@find $(BUILD_DIR_ROOT) -path '*/bin/*' ! -name $(EXEC) ! -name $(TEST_EXEC) -delete

# Clean build directory for all platforms
.PHONY: clean
clean:
	@echo "Cleaning $(BUILD_DIR_ROOT) directory"
	@$(RM) -r $(BUILD_DIR_ROOT)

.PHONY: compdb
compdb: $(BUILD_DIR_ROOT)/compile_commands.json

# Generate JSON compilation database (compile_commands.json) by merging fragments
$(BUILD_DIR_ROOT)/compile_commands.json: $(COMPDBS)
	@echo "Generating: $@"
	@mkdir -p $(@D)
	@printf "[\n" > $@
	@for file in $(COMPDBS); do sed -e '$$s/$$/,/' "$${file}"; done | sed -e '$$s/,$$//' -e 's/^/    /' >> $@
	@printf "]\n" >> $@

# Generate JSON compilation database fragments from source files
$(OBJ_DIR)/$(TEST_DIR)/%.json: INCLUDES += $(TEST_INCLUDES)
$(COMPDBS): $(OBJ_DIR)/%.json: %.cpp
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
	  all             Build executable and tests (debug configuration by default) (default target)\n\
	  run             Build and run executable (debug configuration by default)\n\
	  test            Build and run tests (debug configuration by default)\n\
	  copyassets      Copy assets to executable directory for selected platform and configuration\n\
	  cleanassets     Clean assets from executable directories (all platforms)\n\
	  clean           Clean build directory (all platforms)\n\
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
	Note: the above options affect the following targets: all, run, test, copyassets, compdb, printvars\n"

# Print Makefile variables
.PHONY: printvars
printvars:
	@printf "\
	OS: \"$(OS)\"\n\
	EXEC: \"$(EXEC)\"\n\
	TEST_EXEC: \"$(TEST_EXEC)\"\n\
	BUILD_DIR: \"$(BUILD_DIR)\"\n\
	OBJ_DIR: \"$(OBJ_DIR)\"\n\
	BIN_DIR: \"$(BIN_DIR)\"\n\
	ASSETS_DIR: \"$(ASSETS_DIR)\"\n\
	ASSETS_OS_DIR: \"$(ASSETS_OS_DIR)\"\n\
	SRC_DIR: \"$(SRC_DIR)\"\n\
	SRCS: \"$(SRCS)\"\n\
	TEST_DIR: \"$(TEST_DIR)\"\n\
	TEST_SRCS: \"$(TEST_SRCS)\"\n\
	INCLUDE_DIR: \"$(INCLUDE_DIR)\"\n\
	INCLUDES: \"$(INCLUDES)\"\n\
	TEST_INCLUDES: \"$(TEST_INCLUDES)\"\n\
	CXX: \"$(CXX)\"\n\
	CPPFLAGS: \"$(CPPFLAGS)\"\n\
	CXXFLAGS: \"$(CXXFLAGS)\"\n\
	WARNINGS: \"$(WARNINGS)\"\n\
	LDFLAGS: \"$(LDFLAGS)\"\n\
	TEST_LDFLAGS: \"$(TEST_LDFLAGS)\"\n\
	LDLIBS: \"$(LDLIBS)\"\n\
	TEST_LDLIBS: \"$(TEST_LDLIBS)\"\n"

# Made by Misha Krieger-Raynauld (https://github.com/KRMisha/Makefile)
