VERSION = 0.9.0
Package = com.michael.resolutionsetter
ARCHS   = -arch armv7 -arch arm64 -arch arm64e
SDK     = ${THEOS}/sdks/iPhoneOS13.0.sdk
CC      = xcrun -sdk $(SDK) clang $(ARCHS) -miphoneos-version-min=9.0 -O2
OBJCC   = $(CC) -fobjc-arc
SED     = gsed
LDID    = ldid

.PHONY: all clean

all: clean postinst resolution ResolutionSetterRootListController
	mkdir $(Package)_$(VERSION)_iphoneos-arm
	mkdir $(Package)_$(VERSION)_iphoneos-arm/DEBIAN
	cp control $(Package)_$(VERSION)_iphoneos-arm/DEBIAN
	mv postinst $(Package)_$(VERSION)_iphoneos-arm/DEBIAN
	$(SED) -i 's/^Version:\x24/Version: $(VERSION)/g' $(Package)_$(VERSION)_iphoneos-arm/DEBIAN/control
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

postinst: clean
	$(CC) postinst.c -o postinst
	strip postinst
	$(LDID) -Sentitlements.xml postinst

resolution: clean
	$(OBJCC) helpers.m resolution.m -o resolution
	strip resolution
	$(LDID) -Sentitlements.xml resolution

ResolutionSetterRootListController: clean
	$(OBJCC) -F $(SDK)/System/Library/PrivateFrameworks -I ${THEOS}/vendor/include -dynamiclib -install_name /Library/PreferenceBundles/ResolutionSetter.bundle/ResolutionSetter -framework UIKit -framework Preferences ResolutionSetterRootListController.m -o ResolutionSetter
	strip -x ResolutionSetter
	$(LDID) -S ResolutionSetter

clean:
	rm -rf $(Package)_*_iphoneos-arm*
	rm -f postinst resolution ResolutionSetter
