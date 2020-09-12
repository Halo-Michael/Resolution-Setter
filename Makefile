export TARGET = iphone:clang:13.0:9.0
export ARCHS = armv7 arm64 arm64e
export VERSION = 0.7.3
export DEBUG = no
Package = com.michael.resolutionsetter
CC = xcrun -sdk ${THEOS}/sdks/iPhoneOS13.0.sdk clang -arch armv7 -arch arm64 -arch arm64e -miphoneos-version-min=9.0 -framework CoreFoundation
LDID = ldid

.PHONY: all clean

all: clean resolution preferenceloaderBundle
	mkdir $(Package)_$(VERSION)_iphoneos-arm
	mkdir $(Package)_$(VERSION)_iphoneos-arm/DEBIAN
	cp control $(Package)_$(VERSION)_iphoneos-arm/DEBIAN
	mkdir $(Package)_$(VERSION)_iphoneos-arm/usr
	mkdir $(Package)_$(VERSION)_iphoneos-arm/usr/bin
	mv resolution $(Package)_$(VERSION)_iphoneos-arm/usr/bin
	ln -s resolution $(Package)_$(VERSION)_iphoneos-arm/usr/bin/res
	mkdir $(Package)_$(VERSION)_iphoneos-arm/Library
	mkdir $(Package)_$(VERSION)_iphoneos-arm/Library/PreferenceLoader
	mkdir $(Package)_$(VERSION)_iphoneos-arm/Library/PreferenceLoader/Preferences
	cp preferenceloaderBundle/entry.plist $(Package)_$(VERSION)_iphoneos-arm/Library/PreferenceLoader/Preferences/ResolutionSetter.plist
	mkdir $(Package)_$(VERSION)_iphoneos-arm/Library/PreferenceBundles
	mv preferenceloaderBundle/.theos/obj/ResolutionSetter.bundle $(Package)_$(VERSION)_iphoneos-arm/Library/PreferenceBundles
	dpkg -b $(Package)_$(VERSION)_iphoneos-arm

resolution: clean
	$(CC) resolution.c -o resolution
	strip resolution
	$(LDID) -Sentitlements.xml resolution

preferenceloaderBundle: clean
	cd preferenceloaderBundle && make

clean:
	rm -rf com.michael.resolutionsetter_* preferenceloaderBundle/.theos
	rm -f resolution
