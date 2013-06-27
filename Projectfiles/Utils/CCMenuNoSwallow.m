//
//  CCMenuNoSwallow.m
//  MGWU_SideScroller
//
//  Created by Brian Chu on 1/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCMenuNoSwallow.h"

@implementation CCMenuNoSwallow

/****WARNING: This overrides the registerWithTouchDispatcher method of CCMenu.
 If other categories override the same method, conflicts WILL arise.
 In such cases, use method swizzling.
 *****/

#ifdef __CC_PLATFORM_IOS
//prevents touch swallowing
-(void) registerWithTouchDispatcher
{
	CCDirector *director = [CCDirector sharedDirector];
	[[director touchDispatcher] addTargetedDelegate:self priority:kCCMenuHandlerPriority swallowsTouches:NO];
}
#endif
@end
