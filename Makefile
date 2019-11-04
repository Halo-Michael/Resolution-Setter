TARGET = Resolution Setter
VERSION = 0.3.1
CC = xcrun -sdk iphoneos clang -arch armv7 -arch arm64 -miphoneos-version-min=9.0
LDID = ldid

.PHONY: all clean

all: clean resolution
	mkdir com.michael.resolutionsetter-$(VERSION)_iphoneos-arm
	mkdir com.michael.resolutionsetter-$(VERSION)_iphoneos-arm/DEBIAN
	cp control com.michael.resolutionsetter-$(VERSION)_iphoneos-arm/DEBIAN
	mkdir com.michael.resolutionsetter-$(VERSION)_iphoneos-arm/usr
	mkdir com.michael.resolutionsetter-$(VERSION)_iphoneos-arm/usr/bin
	mv resolution com.michael.resolutionsetter-$(VERSION)_iphoneos-arm/usr/bin
	ln -s resolution res
	mv res com.michael.resolutionsetter-$(VERSION)_iphoneos-arm/usr/bin
	dpkg -b com.michael.resolutionsetter-$(VERSION)_iphoneos-arm

resolution: clean
	$(CC) resolution.c -o resolution
	strip resolution
	$(LDID) -Sentitlements.xml resolution

clean:
	rm -rf com.michael.resolutionsetter-*
	rm -f resolution
