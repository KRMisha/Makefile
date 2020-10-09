<p align="center">
    <img height=128 src="https://github.com/isocpp/logos/blob/master/cpp_logo.png?raw=true" />
</p>

# Makefile
A cross-platform C++ Makefile for any project!

## Table of Contents

- [Features](#features)
- [Project hierarchy](#project-hierarchy)
- [Prerequisites](#prerequites)
    - [GCC & Make](#gcc-&-make)
    - [Optional dependencies](#optional-dependencies)
- [Usage](#usage)
    - [Overview of commands](#overview-of-commands)
    - [Building](#building)
        - [Using a different compiler](#using-a-different-compiler)
    - [Running](#running)
    - [Copying assets](#copying-assets)
    - [Cleaning](#cleaning)
        - [Removing the copied assets from the current `bin` directory](#removing-the-copied-assets-from-the-current-bin-directory)
        - [Removing the entire `build` and `bin` directories](#removing-the-entire-build-and-bin-directories)
    - [Options](#options)
        - [Release](#release)
        - [32-bit (Windows only)](#32-bit-(windows-only))
    - [Formatting](#formatting)
    - [Generating documentation](#generating-documentation)
        - [First time use](#first-time-use)
        - [Updating the documentation](#updating-the-documentation)
- [License](#license)

## Features

- **Cross-platform**: works on Linux, macOS, and Windows (32- and 64-bit)
- **Automatic**: all source files are automatically found and compiled
- **Efficient**: only the modified files are recompiled and their dependencies are automatically generated
- **Debug and release** configurations
- **Configurable**: easily add libraries or change compilation settings
- **Format source files** thanks to clang-format
- **Generate documentation** from Doxygen comments

## Project hierarchy

```
.
├── assets
│   └── <assets>
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
  clean           Clean build and bin directories (all platforms)
  cleanassets     Clean assets from executable directories (all platforms)
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

### Copying assets

To add files to be copied next to the executable's output location, simply add them to the `assets` directory. Then, use the following command:

```sh
make copyassets
```

This will copy the contents of `assets` to the current `bin` directory, preserving their folder structure.

### Cleaning

#### Removing the copied assets from the current `bin` directory

```sh
make cleanassets
```

This will remove all the files in the current `bin` directory except the executable.

#### Removing the entire `build` and `bin` directories

```sh
make clean
```

### Options

Certain options can be specified when building, running, and copying or cleaning assets. These will modify the settings used to build the executable and affect what is considered the current `bin` directory when running a command.

#### Release

By default, builds are in debug mode. To build for release (including optimizations), add the `release=1` option when invoking `make`.

```sh
make release=1
```

To use the `release` version of the executable, `release=1` must also be specified when running, or copying/cleaning assets. For example:

```sh
make copyassets run release=1
```

#### 32-bit (Windows only)

By default, builds on Windows target 64-bit. To build a 32-bit executable, add the `win32=1` option when invoking `make`.

```sh
make win32=1
```

This can also be combined with the `release=1` option to build for 32-bit release.

> Don't forget to also specify `win32=1` when running or dealing with assets!

### Formatting

```sh
make format
```

This will format all files in the `src` and `include` directories using clang-format according to the rules found in `.clang-format`.

### Generating documentation

#### First time use

1. Create a new `doc` folder at the root of the project.
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

## License

[MIT](https://opensource.org/licenses/MIT)
