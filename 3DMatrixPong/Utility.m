//
//  Utility.m
//  Straight_C_3DAsciiPong
//
//  Created by Patrick Cossette on 9/22/14.
//  Copyright (c) 2014 Patrick. All rights reserved.
//

//This file is for Mac OS X Specific functions

#import "Utility.h"
#import <AppKit/AppKit.h>

@implementation Utility

//Attempt to get screen size. This seems to fail on retina devices - not in use
float screenWidth(){
    return [[NSScreen mainScreen] frame].size.width;
}

float screenHeight(){
    return [[NSScreen mainScreen] frame].size.height;
}

CGSize screenResolution(){
    
    //NSScreen *screen = [NSScreen mainScreen];
    //NSDictionary *description = [screen deviceDescription];
    //NSSize displayPixelSize = [[description objectForKey:NSDeviceSize] sizeValue];
    
    NSRect rect = [[NSScreen mainScreen] convertRectFromBacking:[[NSScreen mainScreen] frame]];
    
    NSLog(@"Rect: %.2f, %.2f", rect.size.width, rect.size.height);
    
    return rect.size;
    
    //NSLog(@"Description dict: %@", description);
    
    //CGSize displayPhysicalSize = CGDisplayScreenSize([[description objectForKey:@"NSScreenNumber"] unsignedIntValue]);
    //return CGSizeMake(0.0f, 0.0f);
}

float screenScale(){
    //NSScreen *screen = [[NSScreen alloc] init];
    //return [screen backingScaleFactor];
    
    NSLog(@"Visible Frame: %.2f x %.2f", [[NSScreen mainScreen] frame].size.width, [[NSScreen mainScreen] frame].size.height);
    
    float displayScale = 1;
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
        NSArray *screens = [NSScreen screens];
        for (int i = 0; i < [screens count]; i++) {
            float s = [[screens objectAtIndex:i] backingScaleFactor];
            if (s > displayScale)
                displayScale = s;
        }
    }
    
    return displayScale;
}

//getcwd from unistd.h seems to return the home directory instead of the actual CWD
const char *currentWorkingDirectory(){
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    return [appPath cStringUsingEncoding:NSUTF8StringEncoding];
}

@end
