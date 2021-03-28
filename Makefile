VERSION = 0.8.0
Package = com.michael.resolutionsetter
CC = xcrun -sdk ${THEOS}/sdks/iPhoneOS13.0.sdk clang -arch armv7 -arch arm64 -arch arm64e -miphoneos-version-min=9.0 -fobjc-arc
LDID = ldid

.PHONY: all clean

all: clean resolution ResolutionSetterRootListController
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
	cp entry.plist $(Package)_$(VERSION)_iphoneos-arm/Library/PreferenceLoader/Preferences/ResolutionSetter.plist
	mkdir $(Package)_$(VERSION)_iphoneos-arm/Library/PreferenceBundles
	cp -r Resources $(Package)_$(VERSION)_iphoneos-arm/Library/PreferenceBundles/ResolutionSetter.bundle
	mv ResolutionSetter $(Package)_$(VERSION)_iphoneos-arm/Library/PreferenceBundles/ResolutionSetter.bundle
	dpkg -b $(Package)_$(VERSION)_iphoneos-arm

resolution: clean
	$(CC) resolution.m -o resolution
	strip resolution
	$(LDID) -Sentitlements.xml resolution

ResolutionSetterRootListController: clean
	$(CC) -dynamiclib -install_name /Library/PreferenceBundles/ResolutionSetter.bundle/ResolutionSetter -I${THEOS}/vendor/include/ -framework UIKit ${THEOS}/sdks/iPhoneOS13.0.sdk/System/Library/PrivateFrameworks/Preferences.framework/Preferences.tbd ResolutionSetterRootListController.m -o ResolutionSetter
	strip -x ResolutionSetter
	$(LDID) -S ResolutionSetter

clean:
	rm -rf com.michael.resolutionsetter_*
	rm -f resolution ResolutionSetter
