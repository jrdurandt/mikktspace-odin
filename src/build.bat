@echo off

if not exist "..\lib" mkdir ..\lib

cl -nologo -MT -TC -O2 -c mikktspace.c
lib -nologo mikktspace.obj -out:..\lib\mikktspace.lib

del *.obj
