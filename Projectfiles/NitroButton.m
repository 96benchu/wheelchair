//
//  NitroButton.m
//  Wheelchair
//
//  Created by Ben on 08/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "NitroButton.h"

@implementation NitroButton

-(id)initWithButtonImage
{
    self = [super initWithFile:@"button-top.png"];
    [self scheduleUpdate];
    
    return self;
}

@end
