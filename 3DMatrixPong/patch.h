//
//  patch.h
//  Straight_C_3DAsciiPong
//
//  Created by Patrick Cossette on 12/4/14.
//  Copyright (c) 2014 Patrick. All rights reserved.
//

#import <AppKit/AppKit.h>


#ifndef Straight_C_3DAsciiPong_patch_h
#define Straight_C_3DAsciiPong_patch_h


@interface NSTouch ()
- (id)_initWithPreviousTouch:(NSTouch *)touch newPhase:(NSTouchPhase)phase position:(CGPoint)position     isResting:(BOOL)isResting force:(double)force;
@end

#endif
