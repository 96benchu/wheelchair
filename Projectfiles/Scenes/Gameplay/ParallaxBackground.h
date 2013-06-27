/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim, Andreas Loew 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 * 
 * modfied by Benjamin Encz for MakeGamesWithUs
 */

//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com

/** 
 This Node consists of multiple Sprites scrolling with different speed.
 */
#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ParallaxBackground : CCNode 
{
	CCSpriteBatchNode* spriteBatch;

	NSUInteger numStripes;

	CCArray* speedFactors;
	float scrollSpeed;

	CGSize screenSize;
    
    CCNode *backgroundNode;
}

@end
