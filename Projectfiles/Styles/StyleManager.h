//
//  StyleManager.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <Foundation/Foundation.h>
#import "CCControlButton.h"
#import "CCScale9Sprite.h"

/**
 This class provides default styled fonts and UI components.
 */

@interface StyleManager : NSObject

// returns a tab-style button as used in the recap screen
+ (CCControlButton *)defaultRecapSceneTabButtonWithTitle:(NSString *)title;

+ (CCScale9Sprite *)scaleSpriteWhiteBackgroundSolidBlackBorder;

+ (CCScale9Sprite *)scaleSpriteWhiteBackgroundSolidBlackBorder_NoBorderBottom;

+ (CCScale9Sprite *)scaleSpriteWhiteBackgroundSolidBlackBorder_NoBorderTop;

+ (CCScale9Sprite *)scaleSpriteBlackSharpBottomCorner;

+ (CCScale9Sprite *)scaleSpriteMissionCell;

+ (CCScale9Sprite *)playButton;

+ (CCScale9Sprite *)goOnPopUpBackground;


@end
