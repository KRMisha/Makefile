<p align="center">
    <img height=128 src="https://github.com/isocpp/logos/blob/master/cpp_logo.png?raw=true" />
</p>

# Makefile

A cross-platform C++ Makefile for any project!

## Features

- **Cross-platform**: works on Linux, macOS, and Windows (32- and 64-bit)
- **Automatic**: all source files are automatically found and compiled
- **Efficient**: only the modified files are recompiled and their dependencies are automatically generated
- **Debug and release** configurations
- **Configurable**: easily add libraries or change compilation settings
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
    1. Install Mingw-w64 via [SourceForge](https://sourceforge.net/projects/mingw-w64/).
    2. Add the path to Mingw-64's `bin` directory to Windows's system `PATH` environment variable.
        > You will need to use `mingw32-make` instead of `make` each time the `make` command is used in this README.
    3. Install Git Bash by installing [Git for Windows](https://git-scm.com/downloads).
        > You will need to use **Git Bash** over PowerShell or cmd.exe each time the `make` command is used in this README.

### Optional dependencies

- For formatting: [clang-format](https://clang.llvm.org/docs/ClangFormat.html)
- For linting: [clang-tidy](https://clang.llvm.org/extra/clang-tidy/)
- For generating documentation: [Doxygen](https://www.doxygen.nl/index.html) and [Graphviz](https://graphviz.org/)

## Usage

### Overview of commands

```
$ make help
Usage: make target... [options]...

Targets:
  all             Build executable (debug mode by default) (default target)
  install         Install packaged program to desktop (debug mode by default)
  run             Build and run executable (debug mode by default)
  copyassets      Copy assets to executable directory for selected platform and configuration
  cleanassets     Clean assets from executable directories (all platforms)
  clean           Clean build and bin directories (all platforms)
  compdb          Generate JSON compilation database (compile_commands.json)
  format          Format source code using clang-format
  lint            Lint source code using clang-tidy
  lint-fix        Lint and fix source code using clang-tidy
  docs            Generate documentation with Doxygen
  help            Print this information
  printvars       Print Makefile variables for debugging

Options:
  release=1       Run target using release configuration rather than debug
  win32=1         Build for 32-bit Windows (valid when built on Windows only)

Note: the above options affect the all, install, run, copyassets, compdb, and printvars targets
```

### Building

```sh
make
```

This will compile the executable and output it inside the `bin` directory. This is equivalent to `make all`.

#### Using a different compiler

By default, all builds use GCC. To use another compiler, override the `CXX` variable when invoking `make`. For example, to use Clang:

```sh
make CXX=clang++
```

### Running

```sh
make run
```

This will run the executable, rebuilding it first if it was out of date.

### Assets

#### Copying assets

To add files to be copied next to the executable's output location, simply add them to the `assets` directory. Then, use the following command:

```sh
make copyassets
```

This will copy the contents of `assets` to the current `bin` directory, preserving their folder structure.

If you have certain assets which you wish to only copy for certain platforms, you can do the following:
1. Create an `assets_os/<platform>` directory at the root of the project. The `<platform>` directory should be named either `linux`, `macos`, `windows32`, or `windows64` based on the desired platform for the assets.
2. Inside this new directory, add all the assets to be copied only for this platform.
3. Use the `make copyassets` command as usual. The files copied to the current `bin` directory will be the combination of the files in `assets` and `assets_os`, with files in `assets_os` overwriting those in `assets` in case of naming clashes.

> The `assets_os` directory is useful for holding Windows DLLs which need to be copied next to the executable (using `assets_os/windows64` or `assets_os/windows32`, depending on the target version).

#### Cleaning assets

```sh
make cleanassets
```

This will remove all the files in all `bin` directories except the executables.

### Cleaning

```sh
make clean
```

This will remove the entire `build` and `bin` directories.

### Options

Certain options can be specified when building, running, and copying assets. These will modify the settings used to build the executable and affect what is considered the current `bin` directory when running a command.

#### Release

By default, builds are in debug mode. To build for release (including optimizations), add the `release=1` option when invoking `make`.

```sh
make release=1
```

To use the `release` version of the executable, `release=1` must also be specified when running or when copying assets. For example:

```sh
make copyassets run release=1
```

#### 32-bit (Windows only)

By default, builds on Windows target 64-bit. To build a 32-bit executable, add the `win32=1` option when invoking `make`.

```sh
make win32=1
```

This can also be combined with the `release=1` option to build for 32-bit release.

> Don't forget to also specify `win32=1` when running or when copying assets!

### Generating a JSON compilation database

Some language servers and tools, like clangd or clang-tidy, rely on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) (`compile_commands.json`). To generate this file, use the following command:

```sh
make compdb
```

This will create the compilation database in `build/compile_commands.json`.

### Formatting

```sh
make format
```

This will format all files in the `src` and `include` directories using clang-format according to the options set in `.clang-format`.

### Linting

```sh
make lint
```

This will lint all files in the `src` and `include` directories using clang-tidy according to the options set in `.clang-tidy`.

To apply the suggested fixes to errors found by clang-tidy, use the following command:

```sh
make lint-fix
```

### Generating documentation

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

For more complex projects, using a package manager is the recommended way to add libraries. This method ensures that your libraries are managed identically across platforms.

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

5. Edit the Makefile:

    ```makefile
    # OS-specific settings
    ifeq ($(OS),windows)
        [...]

        ifeq ($(win32),1)
            # Windows 32-bit settings
            INCLUDES += -Ivcpkg_installed/x86-windows/include
            LDFLAGS += -Lvcpkg_installed/x86-windows/lib
            LDLIBS += # Add libraries with -l...
        else
            # Windows 64-bit settings
            INCLUDES += -Ivcpkg_installed/x86-windows/include
            LDFLAGS += -Lvcpkg_installed/x86-windows/lib
            LDLIBS += # Add libraries with -l...
        endif
    else ifeq ($(OS),macos)
        # macOS-specific settings
        INCLUDES += -Ivcpkg_installed/x64-osx/include
        LDFLAGS += -Lvcpkg_installed/x64-osx/lib
        LDLIBS += # Add libraries with -l...
    else ifeq ($(OS),linux)
        # Linux-specific settings
        INCLUDES += -Ivcpkg_installed/x64-linux/include
        LDFLAGS += -Lvcpkg_installed/x64-linux/lib
        LDLIBS += # Add libraries with -l...
    endif
    ```

See [this gist](https://gist.github.com/KRMisha/7c19c73b2833f54f2d84bc7bb3ae788c) for an example of the modifications to make.

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

    The path of the generated profile can be found using `conan profile path default`. You can edit this file and set `compiler.cppstd` to your desired C++ standard.

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
    CONAN_INCLUDE_DIR_FLAG = -I
    CONAN_LIB_DIR_FLAG = -L
    CONAN_BIN_DIR_FLAG = -L
    CONAN_LIB_FLAG = -l
    CONAN_SYSTEM_LIB_FLAG = -l
    include $(BUILD_DIR_ROOT)/conandeps.mk
    [...]
    # Includes
    INCLUDE_DIR = include
    INCLUDES := -I$(INCLUDE_DIR) $(CONAN_INCLUDE_DIRS)

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
    ```

See [this gist](https://gist.github.com/KRMisha/99099d3c38efb038ff3b39e3c1bd6880) for an example of the modifications to make.

### Header-only library

Header-only libraries are composed solely of header files. This way, no separate compilation or linking is necessary.

1. If this is the first library you are adding, create a new `external` directory at the root of the project.
2. Inside the `external` directory, create a `<library-name>` sudirectory to contain the library's header files.
3. Download the library's header files and add them to `external/<library-name>`.
4. Add the library's header files to the preprocessor's search path: add `-Iexternal/<library-name>` to the `INCLUDES` variable at line 21 of the Makefile.

### Library installed system-wide

Some libraries can be installed system-wide, using your system's package manager. For example:
- On macOS, using [Homebrew](https://brew.sh/) or [MacPorts](https://www.macports.org/)
- On Debian/Ubuntu, using `apt`
- On Fedora, using `dnf`
- On Arch Linux, using `pacman`

These system package managers install dependencies in a default system-wide directory, such as `/usr/lib` and `/usr/include` on Linux. Some important system-wide libraries may also come preinstalled on your system.

Relying on a system package manager for your libraries can make it less straightforward for developers across platforms to start working on your project. Nevertheless, they can be a quick way to start using a library, especially if this library is already required by the system.

1. Use your system package manager to install the library's development package. Often, these will have the `-dev` or `-devel` suffix.
2. Link with the library: add `-l<library-name>` to the `LDLIBS` variable at line 35 of the Makefile.

    Depending on the library, more than one library name may need to be added with the `-l` flag. Refer to your library's documentation for the names to use with the `-l` flag in this step.

    Note: for macOS, you may need to link your library using `-framework` rather than `-l`.

### Library built from source

Alternatively, if the library is not available in any package manager, you can build it from source or download its compiled artifacts and add them to your project.

1. If this is the first library you are adding, create a new `external` directory at the root of the project.
2. Inside the `external` directory, create a `<library-name>` sudirectory to contain the library's files.
3. Build or download the library's compiled files and add them to `external/<library-name>`.

    You may wish to instead add the library as a Git submodule inside the `external` directory to make updates easier.

4. Add the library's header files to the preprocessor's search path: add `-Iexternal/<library-name>/include` to the `INCLUDES` variable at line 21 of the Makefile.
5. Add the library's compiled files to the linker's search path: add `-Lexternal/<library-name>/lib` to the `LDFLAGS` variable at line 32 of the Makefile.
6. Link with the library: add `-l<library-name>` to the `LDLIBS` variable at line 35 of the Makefile.

    Depending on the library, more than one library name may need to be added with the `-l` flag. Refer to your library's documentation for the names to use with the `-l` flag in this step.

    Note: for macOS, you may need to link your library using `-framework` rather than `-l`.

Note that the folder structure inside `external/<library-name>` will vary from one library to the next. In these instructions:
- The `include` subdirectory refers to a directory containing all of the library's header files.
- The `lib` subdirectory refers to a directory containing all of the library's compiled files (e.g. `.so`, `.a`, `.lib`, `.framework`, etc.). If you have chosen to build the library from source, you should copy the output of the compiled library to the `lib` directory.
These directories may be named differently: refer to your library's documentation for more information.

## Configuration

### Frequently changed settings

The following table presents an overview of the most commonly changed settings of the Makefile:

| Configuration                                                                                 | Variable                          | Line  |
|-----------------------------------------------------------------------------------------------|-----------------------------------|-------|
| Change the output executable name                                                             | `EXEC`                            | 6     |
| Select the C++ compiler (e.g. `g++` or `clang++`)                                             | `CXX`                             | 27    |
| Add preprocessor settings (e.g. `-D<macro-name>`)                                             | `CPPFLAGS`                        | 24    |
| Change C++ compiler settings (useful for setting the C++ standard version)                    | `CXXFLAGS`                        | 28    |
| Add/remove compilation warnings                                                               | `WARNINGS`                        | 29    |
| Add includes for libraries common to all platforms (e.g. `-Iexternal/<library-name>/include`) | `INCLUDES`                        | 21    |
| Add linker flags for libraries common to all platforms (e.g. `-Lexternal/<library-name>/lib`) | `LDFLAGS`                         | 32    |
| Add libraries common to all platforms (e.g. `-l<library-name>`)                               | `LDLIBS`                          | 35    |
| Add includes/linker flags/libraries for specific platforms                                    | `INCLUDES` - `LDFLAGS` - `LDLIBS` | 51-82 |

All the configurable options are defined between lines 1-82. For most uses, the Makefile should not need to be modified beyond line 82.

### Platform-specific library configuration

The previous sections explain how to configure a library using the common `INCLUDES`, `LDFLAGS`, and `LDLIBS` variables which are shared between all platforms. However, in some cases, the library may need to be linked differently by platform. Examples of such platform-specific library configurations include:
- Adding a library needed only for code enabled on a certain platform
- Using `-framework` over `-l` to link a library on macOS
- Specifying a different path for a library's compiled files with `-L`

The Makefile is designed to support these kinds of platform-specific configurations alongside one another.

Lines 51-82 of the Makefile contain platform-specific `INCLUDES`, `LDFLAGS`, and `LDLIBS` variables which should be used for this purpose. To configure a library for a certain platform, simply add the options to the variables under the comment indicating the platform.

> The common `INCLUDES` (line 21), `LDFLAGS` (line 32), and `LDLIBS` (line 35) variables should only contain options which are identical for all platforms. Any platform-specific options should instead be specified using lines 51-82.

## Project hierarchy

```
.
├── assets
│   └── <assets>
├── assets_os
│   └── linux | macos | windows32 | windows64
│       └── <assets>
├── bin
│   └── linux | macos | windows32 | windows64
│       └── debug | release
│           ├── executable
│           └── <assets>
├── build
│   └── linux | macos | windows32 | windows64
│       └── debug | release
│           ├── **/*.o
│           └── **/*.d
├── docs
│   ├── Doxyfile
│   └── **/*.html
├── include
│   └── **/*.h
├── src
│   ├── main.cpp
│   └── **/*.cpp
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
- [Prerequisites](#prerequites)
    - [GCC & Make](#gcc-&-make)
    - [Optional dependencies](#optional-dependencies)
- [Usage](#usage)
    - [Overview of commands](#overview-of-commands)
    - [Building](#building)
        - [Using a different compiler](#using-a-different-compiler)
    - [Running](#running)
    - [Assets](#assets)
        - [Copying assets](#copying-assets)
        - [Cleaning assets](#cleaning-assets)
    - [Cleaning](#cleaning)
    - [Options](#options)
        - [Release](#release)
        - [32-bit (Windows only)](#32-bit-(windows-only))
    - [Generating a JSON compilation database](#generating-a-json-compilation-database)
    - [Formatting](#formatting)
    - [Linting](#linting)
    - [Generating documentation](#generating-documentation)
        - [First time use](#first-time-use)
        - [Updating the documentation](#updating-the-documentation)
- [Adding libraries](#adding-libraries)
    - [Using a package manager](#using-a-package-manager)
        - [vcpkg](#vcpkg)
        - [Conan](#conan)
    - [Header-only library](#header-only-library)
    - [Library installed system-wide](#library-installed-system-wide)
    - [Library built from source](#library-built-from-source)
- [Configuration](#configuration)
    - [Frequently changed settings](#frequently-changed-settings)
    - [Platform-specific library configuration](#platform-specific-library-configuration)
- [Project hierarchy](#project-hierarchy)
- [License](#license)
