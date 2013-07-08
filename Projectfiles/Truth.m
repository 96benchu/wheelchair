//
//  Truth.m
//  Wheelchair
//
//  Created by Ben on 02/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Truth.h"

@implementation Truth
static Truth *sharedData = nil;

+(Truth*) sharedData
{
    //If our singleton instance has not been created (first time it is being accessed)
    if(sharedData == nil)
    {
        //create our singleton instance
        sharedData = [[Truth alloc] init];
        
        //collections (Sets, Dictionaries, Arrays) must be initialized
        //Note: our class does not contain properties, only the instance does
        //self.arrayOfDataToBeStored is invalid
        }
    
    //if the singleton instance is already created, return it
    return sharedData;
}
@end
