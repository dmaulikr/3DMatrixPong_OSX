//
//  Utility.h
//  Straight_C_3DAsciiPong
//
//  Created by Patrick Cossette on 9/22/14.
//  Copyright (c) 2014 Patrick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

float screenWidth();
float screenScale();
float screenHeight();
CGSize screenResolution();
const char *currentWorkingDirectory();

@end
