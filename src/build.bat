@echo off

if  not exist "..\lib\windows" mkdir ..\lib\windows

cl -nologo -MT -TC -O2 -c mikktspace.c
lib -nologo mikktspace.obj -out:..\lib\windows\mikktspace.lib

del *.obj
