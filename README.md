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
    - [Clang-format (optional - for formatting)](#clang-format-(optional---for-formatting))
    - [Doxygen & Graphviz (optional - for generating documentation)](#doxygen-&-graphviz-(optional---for-generating-documentation))
- [Usage](#usage)
    - [Overview of commands](#overview-of-commands)
    - [Building](#building)
        - [Building for release](#building-for-release)
        - [Building for 32-bit (Windows-only)](#building-for-32-bit-(windows-only))
        - [Building using Clang instead of GCC](#building-using-clang-instead-of-gcc)
    - [Copying assets](#copying-assets)
    - [Running](#running)
    - [Cleaning](#cleaning)
        - [Removing the copied assets from the current `bin` directory](#removing-the-copied-assets-from-the-current-bin-directory)
        - [Removing the entire `build` and `bin` directories](#removing-the-entire-build-and-bin-directories)
    - [Formatting](#formatting)
    - [Generating documentation](#generating-documentation)
        - [First time use](#first-time-use)
        - [Updating the documentation](#updating-the-documentation)

## Features

- **Cross-platform**: works on Linux, macOS, and Windows (32- and 64-bit)
- **Simple**: all source files are automatically found and compiled
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
│       ├── debug
│       │   ├── executable
│       │   └── <assets>
│       └── release
│           ├── executable
│           └── <assets>
├── build
│   └── linux | macos | windows32 | windows64
│       ├── **/*.o
│       └── **/*.d
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

> Alternatively, Clang can be used instead of GCC. The instructions below will focus on GCC.

- Linux:
    - Debian/Ubuntu:

        ```sh
        sudo apt install build-essential
        ```

    - Fedora:

        ```sh
        sudo dnf install gcc-c++ make
        ```

    - Arch:

        ```sh
        sudo pacman -S base-devel
        ```

- macOS:
    1. Open the "Terminal" application.
    2. Run the following command:

        ```sh
        xcode-select --install
        ```

    3. In the window which pops up, click "Install" and follow the instructions.
- Windows:
    1. Install Mingw-w64 via [SourceForge](https://sourceforge.net/projects/mingw-w64/).
    2. Add the path to Mingw-64's `bin` folder to the Windows `PATH` environment variable.
        > For Windows & Mingw-w64, you will need to use `mingw32-make` instead of `make` each time the `make` command is used in this README.
    3. Install Git Bash by installing [Git for Windows](https://git-scm.com/downloads).
        > For Windows, you will need to use **Git Bash** over PowerShell or cmd.exe each time the `make` command is used in this README.

### Clang-format *(optional - for formatting)*

> This step is optional and is only needed to run the `make format` command.

- Linux:
    - Debian/Ubuntu:

        ```sh
        sudo apt install clang-format
        ```

    - Fedora:

        ```sh
        sudo dnf install clang
        ```

    - Arch:

        ```sh
        sudo pacman -S clang-format
        ```

- macOS:

    Install the pre-built binary for macOS from [LLVM's downloads page](https://releases.llvm.org/download.html).

- Windows:

    Install the pre-built binary for Windows from [LLVM's downloads page](https://releases.llvm.org/download.html).

### Doxygen & Graphviz *(optional - for generating documentation)*

> This step is optional and is only needed to run the `make doc` command.

- Linux:
    - Debian/Ubuntu:

        ```sh
        sudo apt install doxygen graphviz
        ```

    - Fedora:

        ```sh
        sudo dnf install doxygen graphviz
        ```

    - Arch:

        ```sh
        sudo pacman -S doxygen graphviz
        ```

- macOS:
    1. Doxygen: download and run the installer (.dmg) for macOS from [Doxygen's downloads page](doxygen.nl/download.html).
    2. Graphviz:

        ```sh
        brew install graphviz
        ```

- Windows:
    1. Doxygen: download and run the setup (.exe) for Windows from [Doxygen's downloads page](doxygen.nl/download.html).
    2. Graphviz: install the pre-built stable package for Windows from [Graphviz's downloads page](https://graphviz.org/download/).

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

#### Building for release

By default, builds are in debug mode. To build for release (including optimizations), add the `release=1` option when invoking `make`.

```sh
make release=1
```

#### Building for 32-bit (Windows-only)

By default, builds on Windows are 64-bit. To build a 32-bit executable, add the `win32=1` option when invoking `make`.

```sh
make win32=1
```

This can also be combined with the `release=1` option:
```sh
make release=1 win32=1
```

> 

#### Building using Clang instead of GCC

By default, all builds use GCC. To use another compiler, override the `CXX` variable when invoking `make`. For example, to use Clang:

```sh
make CXX=clang++
```

### Copying assets

To add files to be copied next to the executable's output location, simply add them to the `assets` directory. To copy them next to the executable, use the following command:

```sh
make copyassets
```

This will copy all the files and folders from the `assets` directory to the current `bin` directory, preserving their folder structure.

### Running

```
make run
```

> If the executable is out of date, `make run` will first rebuild it.

To run with up-to-date assets in a single command, use the following:

```sh
make copyassets run
```

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

This will remove the entire `build` and `bin` directories.

To clean and rebuild in a single command, use the following:

```sh
make clean all
```

To clean, copy assets, rebuild, and run in a single command, use the following:

```sh
make clean copyassets run
```

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

This will generate the documentation according to the rules found in `doc/Doxyfile` and output it in the `doc` directory .
