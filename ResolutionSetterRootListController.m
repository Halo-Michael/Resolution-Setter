#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface ResolutionSetterRootListController : PSListController

@end

@implementation ResolutionSetterRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    [super setPreferenceValue:value specifier:specifier];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    if ([[specifier propertyForKey:@"key"] isEqual:@"canvas_height"] || [[specifier propertyForKey:@"key"] isEqual:@"canvas_width"]) {
        return [[[NSUserDefaults alloc] _initWithSuiteName:@"com.apple.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:[specifier propertyForKey:@"key"]];
    }
    return [super readPreferenceValue:specifier];
}

-(void)setresolution {
    [self.view endEditing:YES];
    BOOL notSetHeight = [[[[NSUserDefaults alloc] _initWithSuiteName:@"com.apple.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:@"canvas_height"] isEqual:[[[NSUserDefaults alloc] _initWithSuiteName:@"com.michael.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:@"canvas_height"]], notSetWidth = [[[[NSUserDefaults alloc] _initWithSuiteName:@"com.apple.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:@"canvas_width"] isEqual:[[[NSUserDefaults alloc] _initWithSuiteName:@"com.michael.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:@"canvas_width"]];
    if (!notSetHeight || !notSetWidth) {
        id canvas_height = nil, canvas_width = nil;
        if (notSetHeight) {
            canvas_height = [[[NSUserDefaults alloc] _initWithSuiteName:@"com.apple.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:@"canvas_height"];
        } else {
            canvas_height = [[[NSUserDefaults alloc] _initWithSuiteName:@"com.michael.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:@"canvas_height"];
        }
        if (notSetWidth) {
            canvas_width = [[[NSUserDefaults alloc] _initWithSuiteName:@"com.apple.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:@"canvas_width"];
        } else {
            canvas_width = [[[NSUserDefaults alloc] _initWithSuiteName:@"com.michael.iokit.IOMobileGraphicsFamily" container:[NSURL URLWithString:@"file:///private/var/mobile"]] objectForKey:@"canvas_width"];
        }
        if (canvas_height != nil && canvas_width != nil) {
            system([[NSString stringWithFormat:@"resolution %@ %@ -y", canvas_height, canvas_width] UTF8String]);
        }
    }
}

@end
