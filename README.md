# MikkTSpace bindings for Odin

[MikkTSpace](https://github.com/mmikk/MikkTSpace) bindings for [Odin]()

MikkTSpace algorithm used to generate tangent and normal maps. Implemented by Morten S. Mikkelsen. Used in many great tools such as Blender and Godot. See [here](http://www.mikktspace.com/) for more information.

> mikktspace used under MIT License, included in source files

Includes a simplified wrapper to use the library functions.
A lot of it has been adapted from Godot's usage of MikkTSpace.
The function allocates tangents and bitanget, caller needs and delete tangent and bitangent data after.
See test for usage example.

## Build:
Linux/macOS: `make -C src`
Windows: `src/build.bat`
