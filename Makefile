TARGET = Resolution Setter

.PHONY: all clean

all:
	dpkg -b com.michael.resolutionsetter_*/

clean:
	rm -rf com.michael.resolutionsetter_*.deb
