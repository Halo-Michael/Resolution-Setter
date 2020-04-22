TARGET = Resolution Setter
VERSION = 0.5.0
CC = xcrun -sdk iphoneos clang -arch armv7 -arch arm64 -arch arm64e -miphoneos-version-min=9.0
LDID = ldid

.PHONY: all clean

all: clean postinst resolution
	mkdir com.michael.resolutionsetter_$(VERSION)_iphoneos-arm
	mkdir com.michael.resolutionsetter_$(VERSION)_iphoneos-arm/DEBIAN
	cp control com.michael.resolutionsetter_$(VERSION)_iphoneos-arm/DEBIAN
	mv postinst com.michael.resolutionsetter_$(VERSION)_iphoneos-arm/DEBIAN
	mkdir com.michael.resolutionsetter_$(VERSION)_iphoneos-arm/usr
	mkdir com.michael.resolutionsetter_$(VERSION)_iphoneos-arm/usr/bin
	mv resolution/.theos/obj/resolution com.michael.resolutionsetter_$(VERSION)_iphoneos-arm/usr/bin
	ln -s resolution com.michael.resolutionsetter_$(VERSION)_iphoneos-arm/usr/bin/res
	dpkg -b com.michael.resolutionsetter_$(VERSION)_iphoneos-arm

postinst: clean
	$(CC) postinst.c -o postinst
	strip postinst
	$(LDID) -Sentitlements.xml postinst

resolution: clean
	sh make-resolution.sh

clean:
	rm -rf com.michael.resolutionsetter_* resolution/.theos
	rm -f postinst