OS=$(shell uname)

ifeq ($(OS), Darwin)
all: Darwin
else
all: unix
endif

unix:
	mkdir -p ../lib
	$(CC) -c -O2 -Os -fPIC mikktspace.c
	$(AR) rcs ../lib/mikktspace.a mikktspace.o
	rm *.o

darwin:
	mkdir -p ../lib/darwin
	$(CC) -arch x86_64 -c -O2 -Os -fPIC mikktspace.c -o mikktspace-x86_64.o -mmacosx-version-min=10.12
	$(CC) -arch arm64  -c -O2 -Os -fPIC mikktspace.c -o mikktspace-arm64.o -mmacosx-version-min=10.12
	lipo -create mikktspace-x86_64.o mikktspace-arm64.o -output ../lib/darwin/mikktspace.a
	rm *.o
