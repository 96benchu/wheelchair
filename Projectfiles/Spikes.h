//
//  Spikes.h
//  Wheelchair
//
//  Created by Ben on 25/06/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "CCLayer.h"

@interface Spikes : CCSprite

{

}
@property (nonatomic, assign) CGPoint velocity;
-(id)initWithSpikeImage;
- (void)updateRunningMode:(ccTime)delta;
@end
