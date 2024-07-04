OS =$(shell uname)

all: unix

unix:
	mkdir -p ../lib
	$(CC) -c -O2 -Os -fPIC mikktspace.c
	$(AR) rcs ../lib/mikktspace.a mikktspace.o
