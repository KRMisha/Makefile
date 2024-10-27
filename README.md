<p align="center">
    <img height=128 src="https://github.com/isocpp/logos/blob/master/cpp_logo.png?raw=true" alt="C++ logo" />
</p>

# Makefile

A cross-platform C++ Makefile for any project!

## Features

- **Cross-platform**: works on Linux, macOS, and Windows
- **Automatic**: all source files are automatically found and compiled
- **Efficient**: only the modified files are recompiled and their dependencies are automatically generated
- **Debug and release** configurations
- **Configurable**: easily add libraries or change compilation settings
- **Package manager**-compatible (Conan and vcpkg)
- **Testing** with the library of your choice
- **Formatting** with clang-format
- **Linting** with clang-tidy
- **Generate documentation** from Doxygen comments
- Built-in generation of `compile_commands.json`
- Compatible with VS Code's [Makefile Tools extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.makefile-tools)

See the [table of contents](#table-of-contents) at the end.

## Prerequisites

### GCC & Make

> Alternatively, Clang can be used instead of GCC (see [here](#using-a-different-compiler)). The instructions below will focus on GCC.

- Linux:
    - Debian/Ubuntu: `sudo apt install build-essential`
    - Fedora: `sudo dnf install gcc-c++ make`
    - Arch: `sudo pacman -S base-devel`
- macOS:
    1. Run the following command: `xcode-select --install`
    2. In the window which pops up, click "Install" and follow the instructions.
- Windows:
    1. Install MinGW-w64 from [WinLibs.com](https://winlibs.com/).
    2. Add the path to MinGW-64's `bin` directory to Windows's system `PATH` environment variable.
        > You will need to use `mingw32-make` instead of `make` each time the `make` command is used in this README.
    3. Install Git Bash by installing [Git for Windows](https://git-scm.com/downloads).
        > You will need to use **Git Bash** instead of PowerShell or `cmd.exe` each time the `make` command is used in this README.

### Optional dependencies

- For formatting: [clang-format](https://clang.llvm.org/docs/ClangFormat.html)
- For linting: [clang-tidy](https://clang.llvm.org/extra/clang-tidy/)
- For generating documentation: [Doxygen](https://www.doxygen.nl/index.html) and [Graphviz](https://graphviz.org/)

## Usage

### Overview of commands

```console
$ make help
Usage: make target... [options]...

Targets:
  all             Build executable and tests (debug configuration by default) (default target)
  run             Build and run executable (debug configuration by default)
  test            Build and run tests (debug configuration by default)
  copyassets      Copy assets to executable directory for selected platform and configuration
  cleanassets     Clean assets from executable directories (all platforms)
  clean           Clean build directory (all platforms)
  compdb          Generate JSON compilation database (compile_commands.json)
  format          Format source code using clang-format
  format-check    Check that source code is formatted using clang-format
  lint            Lint source code using clang-tidy
  lint-fix        Lint and fix source code using clang-tidy
  docs            Generate documentation with Doxygen
  help            Print this information
  printvars       Print Makefile variables for debugging

Options:
  release=1       Run target using release configuration rather than debug

Note: the above options affect the following targets: all, run, test, copyassets, compdb, printvars
```

### Building

```sh
make
```

This will compile the executable (and optionally, tests) and output it inside the current `bin` directory (`build/<platform>/<configuration>/bin`). This is equivalent to `make all`.

#### Using a different compiler

By default, all builds use GCC. To use another compiler, override the `CXX` variable when invoking `make`. For example, to use Clang:

```sh
make CXX=clang++
```

### Running

```sh
make run
```

This will run the executable, rebuilding it first if it was out of date. The working directory will be the executable's directory, i.e. the current `bin` directory.

### Testing

If your project contains tests, you can run them with the following command:

```sh
make test
```

This will run the test executable, rebuilding it first if it was out of date. The working directory will be the current `bin` directory.

See [here](#setting-up-tests) for information on setting up tests for your project.

### Assets

#### Copying assets

To add files to be copied next to the executable's output location, simply add them to the `assets` directory. Then, use the following command:

```sh
make copyassets
```

This will copy the contents of `assets` to the current `bin` directory, preserving their folder structure.

#### Platform-specific assets

If you have certain assets which you wish to only copy for certain platforms, you can do the following:

1. Create an `assets_os/<platform>` directory at the root of the project. The `<platform>` directory should be named either `linux`, `macos`, or `windows` based on the desired platform for the assets.
2. Inside this new directory, add all the assets to be copied only for this platform.

You can then use the `make copyassets` command as usual.

The files copied to the current `bin` directory will be the combination of the files in `assets` and `assets_os`, with files in `assets_os` overwriting those in `assets` in case of naming clashes.

> The `assets_os` directory is useful for holding Windows DLLs which need to be copied next to the executable (using `assets_os/windows`).

#### Cleaning assets

```sh
make cleanassets
```

This will remove all the files in all `bin` directories, except for executables and tests.

### Cleaning

```sh
make clean
```

This will remove the entire `build` directory.

### Options

Options can be specified when building, running, testing, and copying assets. These will modify the settings used to build the executable (and optionally, tests) and affect what is considered the current `bin` directory when running a command.

#### Release configuration

By default, builds use the debug configuration. To build for release (including optimizations), add the `release=1` option when invoking `make`:

```sh
make release=1
```

To use the `release` version of the executable, `release=1` must also be specified when running or when copying assets. For example:

```sh
make copyassets run release=1
```

### Generating a JSON compilation database

Some language servers and tools, like clangd or clang-tidy, rely on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) (`compile_commands.json`). To generate this file, use the following command:

```sh
make compdb
```

This will create the compilation database in `build/compile_commands.json`. You should rerun this command any time you add files to your project.

### Formatting

```sh
make format
```

This will format all files (both sources and headers) using clang-format according to the options set in `.clang-format`.

To only verify if the files are correctly formatted, use the following command:

```sh
make format-check
```

This will return exit code `1` if any files are not formatted.

### Linting

```sh
make lint
```

This will lint all files (both sources and headers) using clang-tidy according to the options set in `.clang-tidy`. This will return exit code `1` if any files have lint errors.

To apply the suggested fixes to errors found by clang-tidy, use the following command:

```sh
make lint-fix
```

### Generating documentation

Documentation can be generated from [documentation comments](https://www.doxygen.nl/manual/docblocks.html) using Doxygen.

#### First time use

1. Create a new `docs` directory at the root of the project.
2. Generate a new Doxyfile in `docs/Doxyfile`:

    ```sh
    cd docs
    doxygen -g
    ```

    Or, to use the graphical wizard instead:

    ```sh
    cd docs
    doxywizard
    ```

#### Updating the documentation

```sh
make docs
```

This will generate the documentation according to the rules found in `docs/Doxyfile` and output it in the `docs` directory.

## Adding libraries

There are several ways to add a library to your project.

### Using a package manager

For more complex projects, using a package manager is the recommended way to add libraries. This method ensures that your libraries are managed consistently across platforms.

#### [Conan](https://conan.io/)

You can integrate Conan with the Makefile by using the [MakeDeps generator](https://docs.conan.io/2/reference/tools/gnu/makedeps.html).

1. Install Conan using `pip`:

    ```sh
    pip install conan
    ```

2. Create a Conan profile:

    ```sh
    conan profile detect --force
    ```

    The path of the generated profile can be found using `conan profile path default`. You can edit this file and set `compiler.cppstd` to your desired C++ standard (e.g. `compiler.cppstd=20`).

3. Create a `conanfile.txt` at the root of the project:

    ```ini
    [requires]
    # Add dependencies...

    [generators]
    MakeDeps
    ```

4. Edit the Makefile:

    ```makefile
    # Conan
    CONAN_DEFINE_FLAG = -D
    CONAN_INCLUDE_DIR_FLAG = -isystem
    CONAN_LIB_DIR_FLAG = -L
    CONAN_BIN_DIR_FLAG = -L
    CONAN_LIB_FLAG = -l
    CONAN_SYSTEM_LIB_FLAG = -l
    include $(BUILD_DIR_ROOT)/conandeps.mk

    # Sources (searches recursively inside the source directory)
    [...]

    # Includes
    INCLUDE_DIR =
    INCLUDES := $(addprefix -I,$(SRC_DIR) $(INCLUDE_DIR)) $(CONAN_INCLUDE_DIRS)

    # C preprocessor settings
    CPPFLAGS = $(INCLUDES) -MMD -MP $(CONAN_DEFINES)

    [...]

    # Linker flags
    LDFLAGS = $(CONAN_LIB_DIRS)

    # Libraries to link
    LDLIBS = $(CONAN_LIBS) $(CONAN_SYSTEM_LIBS)

    [...]

    # Generate Conan dependencies
    $(BUILD_DIR_ROOT)/conandeps.mk: conanfile.txt
        @echo "Generating: $@"
        @conan install . --output-folder=build --build=missing

    # Build executable
    [...]
    ```

See [this gist](https://gist.github.com/KRMisha/99099d3c38efb038ff3b39e3c1bd6880) for an example of the modifications to make.

#### [vcpkg](https://vcpkg.io/en/)

You can integrate vcpkg with the Makefile by using the [manual integration](https://learn.microsoft.com/en-us/vcpkg/users/buildsystems/manual-integration).

1. Add vcpkg as a submodule:

    ```sh
    git submodule add https://github.com/Microsoft/vcpkg.git
    ```

2. Run the bootstrap script to build vcpkg:

    ```sh
    ./vcpkg/bootstrap-vcpkg.sh
    ```

3. Create a `vcpkg.json` at the root of the project:

    ```jsonc
    {
        "dependencies": [
            // Add dependencies...
        ]
    }
    ```

4. Install the dependencies listed in `vcpkg.json`:

    ```sh
    ./vcpkg/vcpkg install
    ```

    Note: on Windows, you should set the target and host triplet to the [MinGW triplet](https://learn.microsoft.com/en-us/vcpkg/users/platforms/mingw). This can be done by setting the following environment variables *before* running the previous command:

    ```sh
    export VCPKG_DEFAULT_TRIPLET=x64-mingw-static
    export VCPKG_DEFAULT_HOST_TRIPLET=x64-mingw-static
    ```

5. Edit the Makefile:

    ```makefile
    # Platform-specific settings
    ifeq ($(OS),windows)
        [...]

        # Windows-specific settings
        INCLUDES += -isystem vcpkg_installed/x64-mingw-static/include
        LDFLAGS += -Lvcpkg_installed/x64-mingw-static/lib
        LDLIBS += # Add libraries with -l...
    else ifeq ($(OS),macos)
        # macOS-specific settings
        INCLUDES += -isystem vcpkg_installed/x64-osx/include
        LDFLAGS += -Lvcpkg_installed/x64-osx/lib
        LDLIBS += # Add libraries with -l...
    else ifeq ($(OS),linux)
        # Linux-specific settings
        INCLUDES += -isystem vcpkg_installed/x64-linux/include
        LDFLAGS += -Lvcpkg_installed/x64-linux/lib
        LDLIBS += # Add libraries with -l...
    endif
    ```

See [this gist](https://gist.github.com/KRMisha/7c19c73b2833f54f2d84bc7bb3ae788c) for an example of the modifications to make.

### Header-only library

Header-only libraries are composed solely of header files. This way, no separate compilation or linking is necessary.

1. If this is the first library you are adding, create a new `external` directory at the root of the project.
2. Inside the `external` directory, create a `<library-name>` sudirectory to contain the library's header files.
3. Download the library's header files and add them to `external/<library-name>`.
4. Add the library's header files to the preprocessor's search path: add `-isystem external/<library-name>` to the `INCLUDES` variable (line 28 of the Makefile).

### Library installed system-wide

Some libraries can be installed system-wide, using your system's package manager. For example:

- On macOS, using [Homebrew](https://brew.sh/) or [MacPorts](https://www.macports.org/)
- On Debian/Ubuntu, using `apt`
- On Fedora, using `dnf`
- On Arch Linux, using `pacman`

These system package managers install dependencies in a default system-wide directory, such as `/usr/lib` and `/usr/include` on Linux. Some important system-wide libraries may also come preinstalled on your system.

Relying on a system package manager for your libraries can make it less straightforward for other developers using a different platform to start working on your project. Nevertheless, this can be a quick way for you to start using a library, especially if this library is already required by the system.

1. Use your system package manager to install the library's development package. Often, development packages will have the `-dev` or `-devel` suffix.
2. Link with the library: add `-l<library-name>` to the `LDLIBS` variable (line 44 of the Makefile).

    Depending on the library, more than one library name may need to be added with the `-l` option. Refer to your library's documentation for the names to use with the `-l` option in this step.

    Note: for macOS, you may need to link your library using `-framework` rather than `-l`.

### Library built from source

Alternatively, if a library is not available in any package manager, you can build it from source or download its compiled artifacts and add them to your project.

1. If this is the first library you are adding, create a new `external` directory at the root of the project.
2. Inside the `external` directory, create a `<library-name>` sudirectory to contain the library's files.
3. Build or download the library's compiled files and add them to `external/<library-name>`.

    You may instead prefer to add the library as a Git submodule inside the `external` directory to make updates easier.

4. Add the library's header files to the preprocessor's search path: add `-isystem /<library-name>/include` to the `INCLUDES` variable (line 28 of the Makefile).
5. Add the library's compiled files to the linker's search path: add `-Lexternal/<library-name>/lib` to the `LDFLAGS` variable (line 40 of the Makefile).
6. Link with the library: add `-l<library-name>` to the `LDLIBS` variable (line 44 of the Makefile).

    Depending on the library, more than one library name may need to be added with the `-l` option. Refer to your library's documentation for the names to use with the `-l` option in this step.

    Note: for macOS, you may need to link your library using `-framework` rather than `-l`.

Note that the folder structure inside `external/<library-name>` will vary from one library to the next. In the above instructions:

- The `include` subdirectory refers to a directory containing all of the library's header files.
- The `lib` subdirectory refers to a directory containing all of the library's compiled files (e.g. `.so`, `.a`, `.lib`, `.framework`, etc.). If you have chosen to build the library from source, you should copy the output of the compiled library to the `lib` directory.

These directories may be named differently: refer to your library's documentation for more information.

## Setting up tests

1. Create a new `tests` directory at the root of the project to hold your test source files.
2. Pick your preferred C++ testing framework. For example:
    - [Catch2](https://github.com/catchorg/Catch2) (recommended)
    - [doctest](https://github.com/doctest/doctest)
    - [GoogleTest](https://github.com/google/googletest)
3. Make the testing framework available to your project using one of the methods described in [adding libraries](#adding-libraries).

    Using a package manager such as [Conan](#conan) or [vcpkg](#vcpkg) is the recommended way to add this library.

    However, do not add the flags for the library to the `INCLUDES`, `LDFLAGS`, or `LDLIBS` variables. This is because only tests should link against the test framework library, not the main executable. See the next step for how to do this.

    > For the simplest possible setup, you may instead prefer to use doctest, which is available as a [single header file](#header-only-library).

4. Add the necessary flags to link with the library, as described in your chosen method for adding libraries, but with the following replacements:

    - Use `TEST_INCLUDES` (line 29) instead of `INCLUDES` (line 28) to add the library's header files to the preprocessor's search path.
    - Use `TEST_LDFLAGS` (line 41) instead of `LDFLAGS` (line 40) to add the library's compiled files to the linker's search path (if applicable).
    - Use `TEST_LDLIBS` (line 45) instead of `LDLIBS` (line 44) to link with the library (if applicable).

    The `TEST_INCLUDES`, `TEST_LDFLAGS`, and `TEST_LDLIBS` variables apply only to tests. These are appended to the regular `INCLUDES`, `LDFLAGS`, and `LDLIBS` variables when building the tests.

5. Add at least one test source file to the `tests` directory.

See [this gist](https://gist.github.com/KRMisha/7f796201167780f7e5ae2217445836f2) for an example using Catch2 with Conan.

Once this is done, running `make` (or `make all`) will now build both the executable and tests. To build and run the tests, use `make test`.

> The test executable is built from all the source files under both `tests` and `src`, except for `src/main.cpp`. This means you can test any functions defined in `src`, as long as these are not defined in `src/main.cpp`.

## Configuration

### Frequently changed settings

The following table presents an overview of the most commonly changed settings of the Makefile:

| Configuration                                                                                        | Variable                                       | Line       |
|------------------------------------------------------------------------------------------------------|------------------------------------------------|------------|
| Change the output executable name                                                                    | `EXEC`                                         | 6          |
| Select the C++ compiler (e.g. `g++` or `clang++`)                                                    | `CXX`                                          | 35         |
| Add preprocessor settings (e.g. `-D<macro-name>`)                                                    | `CPPFLAGS`                                     | 32         |
| Change C++ compiler settings (useful for setting the C++ standard version)                           | `CXXFLAGS`                                     | 36         |
| Add/remove compiler warnings                                                                         | `WARNINGS`                                     | 37         |
| Add includes for libraries common to all platforms (e.g. `-isystem external/<library-name>/include`) | `INCLUDES`                                     | 28         |
| Add linker flags for libraries common to all platforms (e.g. `-Lexternal/<library-name>/lib`)        | `LDFLAGS`                                      | 40         |
| Add libraries common to all platforms (e.g. `-l<library-name>`)                                      | `LDLIBS`                                       | 44         |
| Add includes/linker flags/libraries for specific platforms                                           | `INCLUDES`, `LDFLAGS`, `LDLIBS`                | 61-80      |
| Add additional includes/linker flags/libraries for tests                                             | `TEST_INCLUDES`, `TEST_LDFLAGS`, `TEST_LDLIBS` | 29, 41, 45 |

All the configurable options are defined between lines 1-80. For most uses, the Makefile should not need to be modified beyond line 80.

### Platform-specific library configuration

The section on [adding libraries](#adding-libraries) explains how to add a library using the common `INCLUDES`, `LDFLAGS`, and `LDLIBS` variables which are shared between all platforms. However, in some cases, a library may need to be linked differently by platform. Examples of such platform-specific library configurations include:

- Adding a library needed only for code enabled on a certain platform
- Using `-framework` over `-l` to link a library on macOS
- Specifying a different path for a library's compiled files with `-L`

The Makefile is designed to support these kinds of platform-specific configurations alongside one another.

Lines 61-80 of the Makefile contain platform-specific `INCLUDES`, `LDFLAGS`, and `LDLIBS` variables which should be used for this purpose. To add a library for a certain platform, simply add the options to the variables under the comment indicating the platform.

> The common `INCLUDES` (line 28), `LDFLAGS` (line 40), and `LDLIBS` (line 44) variables should only contain options which are identical for all platforms. Any platform-specific options should instead be specified using lines 61-80.

### Separate directories for headers and sources

By default, your project's header files should be placed under `src`, next to their associated source files. Headers which are only used by tests should be placed under `tests`.

However, if you wish to place your header files in a separate directory from your source files, you can do so by setting the `INCLUDE_DIR` variable (line 27 of the Makefile):

```makefile
INCLUDE_DIR = include
```

This will add the `include` directory to the preprocessor's search path.

This can be useful when developing a library: in this configuration, your library's public headers should be placed under `include`, and its private headers under `src`.

## Project layout

```text
.
├── assets
│   └── <assets>
├── assets_os
│   └── linux | macos | windows
│       └── <assets>
├── build
│   └── linux | macos | windows
│       └── debug | release
│           ├── bin
│           │   ├── executable
│           │   └── <assets>
│           └── obj
│               ├── **/*.o
│               └── **/*.d
├── docs
│   ├── Doxyfile
│   └── **/*.html
├── include (optional)
│   └── **/*.h
├── src
│   ├── main.cpp
│   ├── **/*.cpp
│   └── **/*.h
├── tests
│   ├── **/*.cpp
│   └── **/*.h
├── .clang-format
├── .clang-tidy
├── .gitattributes
├── .gitignore
├── Makefile
└── README.md
```

## License

[MIT](https://opensource.org/licenses/MIT)

To comply with the terms of the MIT license in your project, simply copy-pasting the entire contents of the provided [`LICENSE`](LICENSE) file as a comment at the top of the Makefile is sufficient. By doing so, you do not need to include the `LICENSE` file directly since it is is now contained in the Makefile. You can then reuse the `LICENSE` filename for your own license if you wish.

## Table of contents

- [Features](#features)
- [Prerequisites](#prerequisites)
    - [GCC \& Make](#gcc--make)
    - [Optional dependencies](#optional-dependencies)
- [Usage](#usage)
    - [Overview of commands](#overview-of-commands)
    - [Building](#building)
        - [Using a different compiler](#using-a-different-compiler)
    - [Running](#running)
    - [Testing](#testing)
    - [Assets](#assets)
        - [Copying assets](#copying-assets)
        - [Platform-specific assets](#platform-specific-assets)
        - [Cleaning assets](#cleaning-assets)
    - [Cleaning](#cleaning)
    - [Options](#options)
        - [Release configuration](#release-configuration)
    - [Generating a JSON compilation database](#generating-a-json-compilation-database)
    - [Formatting](#formatting)
    - [Linting](#linting)
    - [Generating documentation](#generating-documentation)
        - [First time use](#first-time-use)
        - [Updating the documentation](#updating-the-documentation)
- [Adding libraries](#adding-libraries)
    - [Using a package manager](#using-a-package-manager)
        - [Conan](#conan)
        - [vcpkg](#vcpkg)
    - [Header-only library](#header-only-library)
    - [Library installed system-wide](#library-installed-system-wide)
    - [Library built from source](#library-built-from-source)
- [Setting up tests](#setting-up-tests)
- [Configuration](#configuration)
    - [Frequently changed settings](#frequently-changed-settings)
    - [Platform-specific library configuration](#platform-specific-library-configuration)
    - [Separate directories for headers and sources](#separate-directories-for-headers-and-sources)
- [Project layout](#project-layout)
- [License](#license)
- [Table of contents](#table-of-contents)
