//
//  StyleManager.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "StyleManager.h"
#import "STYLES.h"
#import "CCScale9Sprite.h"

@implementation StyleManager

+ (CCControlButton *)defaultRecapSceneTabButtonWithTitle:(NSString *)title {
    CCControlButton *controllButton = [CCControlButton buttonWithTitle:title fontName:DEFAULT_FONT fontSize:16];
    
    CCScale9Sprite *backgroundSprite = [self scaleSpriteWhiteBackgroundSolidBlackBorder_NoBorderBottom];
    backgroundSprite.contentSize = controllButton.contentSize;
    backgroundSprite.position = ccp(controllButton.contentSize.width / 2, controllButton.contentSize.height / 2);
    
    CCScale9Sprite *backgroundSpriteSelected = [self scaleSpriteBlackSharpBottomCorner];
    backgroundSpriteSelected.contentSize = controllButton.contentSize;
    backgroundSpriteSelected.position = ccp(controllButton.contentSize.width / 2, controllButton.contentSize.height / 2);
    
    [controllButton setBackgroundSprite:backgroundSprite forState:CCControlStateNormal];
    [controllButton setTitleColor:DEFAULT_FONT_COLOR forState:CCControlStateNormal];

    [controllButton setBackgroundSprite:backgroundSpriteSelected forState:CCControlStateSelected];
    [controllButton setTitleColor:WHITE_FONT_COLOR forState:CCControlStateSelected];
    
    controllButton.zoomOnTouchDown = TRUE;
    
    return controllButton;
}


+ (CCScale9Sprite *)scaleSpriteMissionCell
{
    return  [[CCScale9Sprite alloc] initWithFile:@"topMissionCellBackground.png" capInsets:CGRectMake(10, 10, 40, 40)];
}


+ (CCScale9Sprite *)scaleSpriteWhiteBackgroundSolidBlackBorder
{
    return  [[CCScale9Sprite alloc] initWithFile:@"9patch_whiteBackground.png" capInsets:CGRectMake(10, 10, 40, 40)];
}

+ (CCScale9Sprite *)scaleSpriteWhiteBackgroundSolidBlackBorder_NoBorderBottom
{
    return  [[CCScale9Sprite alloc] initWithFile:@"9patch_tab_normal.png" capInsets:CGRectMake(10, 10, 40, 40)];
}

+ (CCScale9Sprite *)scaleSpriteWhiteBackgroundSolidBlackBorder_NoBorderTop
{
    return  [[CCScale9Sprite alloc] initWithFile:@"9patch_whiteBackground_noBorderTop.png" capInsets:CGRectMake(10, 10, 40, 40)];
}

+ (CCScale9Sprite *)scaleSpriteBlackSharpBottomCorner
{
    return  [[CCScale9Sprite alloc] initWithFile:@"9patch_tab_pressed.png" capInsets:CGRectMake(10, 10, 40, 40)];
}

+ (CCScale9Sprite *)playButton
{
    return [[CCScale9Sprite alloc] initWithFile:@"button_playbutton.png" capInsets:CGRectMake(0, 0, 134, 134)];
}

+ (CCScale9Sprite *)goOnPopUpBackground
{
    return [[CCScale9Sprite alloc] initWithFile:@"keepgoing.png" capInsets:CGRectZero];
}

@end
