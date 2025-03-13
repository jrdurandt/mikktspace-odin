# MikkTSpace bindings for Odin

[MikkTSpace](https://github.com/mmikk/MikkTSpace) bindings for [Odin]()

MikkTSpace algorithm used to generate tangent and normal maps. Implemented by Morten S. Mikkelsen. Used in many great tools such as Blender and Godot. See [here](http://www.mikktspace.com/) for more information.

> mikktspace used under MIT License, included in source files

## Build:

### Linux:

Makefile
```
cd src
make
```

Zig
```
zig build -Dtarget=x86_64-linux
```

### Windows:

Batch
```
cd src
./build.bat
```

Zig
```
zig build -Dtarget=x86_64-windows
```

### MacOS (Darwin):

Make
```
cd src
make
```

Zig
```
zig build -Dtarget=x86_64-macos
zig build -Dtarget=arm64-macos
```
