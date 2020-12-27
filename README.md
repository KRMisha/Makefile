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
- **Format source files** thanks to clang-format
- **Generate documentation** from Doxygen comments

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
  format          Run clang-format on source code
  doc             Generate documentation with Doxygen
  help            Print this information
  printvars       Print Makefile variables for debugging

Options:
  release=1       Run target using release configuration rather than debug
  win32=1         Build for 32-bit Windows (valid when built on Windows only)

Note: the above options affect all, install, run, copyassets, and printvars targets
```

### Building

```
make
```

This will compile the executable and output it inside the `bin` directory. This is equivalent to `make all`.

#### Using a different compiler

By default, all builds use GCC. To use another compiler, override the `CXX` variable when invoking `make`. For example, to use Clang:

```sh
make CXX=clang++
```

### Running

```
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
1. Create an `assets_os/<platform>` directory at the root of the project. The `<project>` directory should be named either `linux`, `macos`, `windows32`, or `windows64` based on the desired platform for the assets.
2. Inside this new directory, add all the assets to be copied only for this platform.
3. Use the `make copyassets` command as usual. The files copied to the current `bin` directory will be the combination of the files in `assets` and `assets_os`, with files in `assets_os` overwriting those in `assets` in case of naming clashes.

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

### Formatting

```sh
make format
```

This will format all files in the `src` and `include` directories using clang-format according to the rules found in `.clang-format`.

### Generating documentation

#### First time use

1. Create a new `doc` directory at the root of the project.
2. Generate a new Doxyfile in `doc/Doxyfile`:

    ```sh
    cd doc
    doxygen -g
    ```

    Or, to use the graphical wizard instead:

    ```sh
    cd doc
    doxywizard
    ```

#### Updating the documentation

```sh
make doc
```

This will generate the documentation according to the rules found in `doc/Doxyfile` and output it in the `doc` directory.

## Configuration

### Adding a library

1. Create a new `libs` directory at the root of the project if this is the first library to be added to your project. Conversely, if you have previously added a library, this directory will already exist.
2. Inside the `libs` directory, create a `<library-name>` subdirectory to contain the library's files.
3. Download the necessary files for your chosen library and add them to `libs/<library-name>`.

    Depending on the type of library (e.g. traditional vs header-only), the folder structure inside `libs/<library-name>` will vary. Refer to your chosen library's documentation for more information.

4. Include the library's header files: add `-Ilibs/<library-name>/include` to the `INCLUDES` variable at line 21 of the Makefile.

    The `include` part of the path above refers to a directory containing all the library's header files. Note that he actual location of the header files will depend on the layout of the library files you added in step 3 and may thus be named differently. For a header-only library, for example, the header files may be directly located in `libs/<library-name>`.

5. Specify the library's compiled files: add `-Llibs/<library-name>/lib` to the `LDFLAGS` variable at line 32 of the Makefile.

    The `lib` part of the path above refers to a directory containing all the library's compiled files (`.so`, `.a`, `.lib`, `.framework`, or any type of file depending on the platform). Just like in step 4, it's important to note that the actual location of the compiled files will depend on the layout of the library you added in step 3 and may thus be named differently.

    For a header-only library, this step is not needed as no library files need to be linked.

    You may also have chosen to build the library from source in step 3. In that case, the `lib` directory should contain the output of the compiled library. Refer to your library's documentation for more information.

6. Add the library's name to link it during compilation: add `-l<library-name>` to the `LDLIBS` variable at line 35 of the Makefile.

    Depending on the library, more than one library name may need to be added with the `-l` flag. Refer to your library's documentation for the names to use with the `-l` flag in this step.

    For a header-only library, this step is not needed as no library files need to be linked.

    > Note: for macOS, you may need to link your library using `-framework` rather than `-l`.

Everything should now be good to go!

#### Platform-specific library configuration

The steps above show how to configure a library using the common `INCLUDES`, `LDFLAGS`, and `LDLIBS` variables which are shared between all platforms. However, in many cases, the library may need to be linked differently by platform. Examples of such platform-specific library configurations include:
- Adding a library needed only for code enabled on a certain platform
- Using `-framework` over `-l` to link a library on macOS
- Specifying a different path for a library's compiled files with `-L`

The Makefile is designed to support these kinds of platform-specific configurations alongside one another.

Lines 51-87 of the Makefile contain platform-specific `INCLUDES`, `LDFLAGS`, and `LDLIBS` variables which should be used for this purpose. To configure a library for a certain platform, simply add the options to the variables under the comment indicating the platform.

> The common `INCLUDES` (line 21), `LDFLAGS` (line 32), and `LDLIBS` (line 35) variables should only contain options which are identical for all platforms. Any platform-specific options should instead be specified using lines 51-87.

### Frequently changed settings

In addition to adding libraries, you may wish to tweak the Makefile's configuration. The following table presents an overview of the most commonly changed settings of the Makefile.

| Configuration                                                                             | Variable                          | Line  |
|-------------------------------------------------------------------------------------------|-----------------------------------|-------|
| Change the output executable name                                                         | `EXEC`                            | 6     |
| Select the C++ compiler (e.g. `g++` or `clang++`)                                         | `CXX`                             | 27    |
| Add preprocessor settings (e.g. `-D<macro-name>`)                                         | `CPPFLAGS`                        | 24    |
| Change C++ compiler settings (useful for setting C++ version)                             | `CXXFLAGS`                        | 28    |
| Add/remove compilation warnings                                                           | `WARNINGS`                        | 29    |
| Add includes for libraries common to all platforms (e.g. `-Ilibs/<library-name>/include`) | `INCLUDES`                        | 21    |
| Add linker flags for libraries common to all platforms (e.g. `-Llibs/<library-name>/lib`) | `LDFLAGS`                         | 32    |
| Add libraries common to all platforms (e.g. `-l<library-name>`)                           | `LDLIBS`                          | 35    |
| Add includes/linker flags/libraries for specific platforms                                | `INCLUDES` - `LDFLAGS` - `LDLIBS` | 51-87 |

All the configurable options are defined between lines 1-87. For most uses, the Makefile should not need to be modified beyond line 87.

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
├── doc
│   ├── Doxyfile
│   └── **/*.html
├── include
│   └── **/*.h
├── libs
│   └── <external library name>
│       ├── bin
│       ├── include
│       └── lib
├── src
│   ├── main.cpp
│   └── **/*.cpp
├── .clang-format
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
    - [Formatting](#formatting)
    - [Generating documentation](#generating-documentation)
        - [First time use](#first-time-use)
        - [Updating the documentation](#updating-the-documentation)
- [Configuration](#configuration)
    - [Adding a library](#adding-a-library)
        - [Platform-specific library configuration](#platform-specific-library-configuration)
    - [Frequently changed settings](#frequently-changed-settings)
- [Project hierarchy](#project-hierarchy)
- [License](#license)
