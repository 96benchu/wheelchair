//
//  MissionsNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "MissionsNode.h"
#import "Mission.h"
#import "STYLES.h"
#import "StyleManager.h"
#import "CCControlButton.h"
#import "CCScale9Sprite.h"
#import "CCBackgroundColorNode.h"
#import "CCNinePatchBackgroundNode.h"
#import "CCSprite+scaleSpriteToFitContentSize.h"
#import "CCLabelTTF+adjustToFitRequiredSize.h"

#define MISSIONS_PANEL_MARGIN_LEFT 15

#define TAG_LABEL 1
#define TAG_THUMBNAIL 2
#define TAG_CHECKBOX 3
#define TAG_CHECKMARK 4

#define DIVIDER_WIDTH 3

@implementation MissionsNode


- (id)initWithMissions:(NSArray *)m
{
    self = [super init];
    
    if (self) {
        missions = [m copy];
        numberOfRows = [m count];
        missionNodes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Node Lifecyle

- (void)onExit
{
    [super onExit];
    
    [self removeAllChildren];
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];

    [self displayMissions];
    
    if (self.usesScaleSpriteBackground)
    {
        CCScale9Sprite *backgroundScaleSprite = [StyleManager scaleSpriteWhiteBackgroundSolidBlackBorder];
        backgroundNode = backgroundScaleSprite;
    } else
    {
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:@"recap_background.png"];
        backgroundNode = backgroundSprite;
    }
    
    backgroundNode.contentSize = self.contentSize;
    backgroundNode.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
    // move to the deepest possible layer
    [self addChild:backgroundNode z:MAX_INT * (-1)];
}


#pragma mark - UI generation

- (void)displayMissions
{
    // calculate additional height, which exists, because the mission cells are stacked into each other
    float additionalHeight = (numberOfRows -1) * DIVIDER_WIDTH;
    
    // this variable helps aligning the different missions centered and divides the available height between all missions
    float yPosition = self.contentSize.height - (0.5 * ((self.contentSize.height+additionalHeight) / numberOfRows));
    
    [missionNodes removeAllObjects];
    
    for (int i = 0; i < numberOfRows; i++) {
        Mission *mission = [missions objectAtIndex:i];
        
        CCNinePatchBackgroundNode *missionNode = [CCNinePatchBackgroundNode node];
        missionNode.backgroundScaleSprite = [StyleManager scaleSpriteMissionCell];
        
        missionNode.contentSize = CGSizeMake(self.contentSize.width, ((self.contentSize.height+additionalHeight) / numberOfRows));
        missionNode.anchorPoint = ccp(0.5, 0.5);
        
        missionNode.position = ccp(self.contentSize.width/ 2, yPosition);
        
        // add label for mission description
        CCLabelTTF *missionLabel = [CCLabelTTF labelWithString:mission.missionDescription
                                                      fontName:DEFAULT_FONT
                                                      fontSize:FONT_SIZE_MISSIONS];
        missionLabel.color = DEFAULT_FONT_COLOR;
        missionLabel.tag = TAG_LABEL;
        missionLabel.position = ccp(missionNode.contentSize.width / 2, missionNode.contentSize.height / 2);
        [missionLabel adjustToFitRequiredSize:CGSizeMake(missionNode.contentSize.width * 0.6, missionLabel.contentSize.height)];
        [missionNode addChild:missionLabel];
        
        // add mission thumbnail
        CCSprite *missionThumbnail = [CCSprite spriteWithFile:mission.thumbnailFileName];
        missionThumbnail.contentSize = CGSizeMake(missionNode.contentSize.height * 0.8, missionNode.contentSize.height * 0.8);
        missionThumbnail.tag = TAG_THUMBNAIL;
        missionThumbnail.anchorPoint = ccp(0, 0);
        missionThumbnail.position = ccp(5, missionNode.contentSize.height * 0.1);
        [missionThumbnail scaleSpriteToFitContentSize];
        [missionNode addChild:missionThumbnail];
        
        // add completion checkmark
        CCSprite *missionCheckbox = [CCSprite spriteWithFile:@"checkbox.png"];
        missionCheckbox.tag = TAG_CHECKBOX;
        [missionNode addChild:missionCheckbox];
        missionCheckbox.position = ccp(missionNode.contentSize.width - 16, (missionNode.contentSize.height / 2) + 4);
        
        // add checkbox (initially hidden)
        CCSprite *checkmark = [CCSprite spriteWithFile:@"checkmark.png"];
        checkmark.tag = TAG_CHECKMARK;
        checkmark.visible = FALSE;
        checkmark.position = missionCheckbox.position;
        [missionNode addChild:checkmark];
        
        [self addChild:missionNode];
        [missionNodes addObject:missionNode];
        
        // subtract DIVIDER_WIDTH to stack cells into each other and avoid double sized border lines
        yPosition -= missionNode.contentSize.height - DIVIDER_WIDTH;
    }
}

- (void)refreshWithMission:(NSArray *)missionsNew
{
    NSAssert([missions count] == [missionsNew count], @"MissionsNode can only be updated with the same amount of missions");
    
    for (unsigned int i = 0; i < [missions count]; i++)
    {
        Mission *mission = [missions objectAtIndex:i];
        Mission *newMission = [missionsNew objectAtIndex:i];
        
        if ([mission isEqual:newMission])
        {
            // quit this loop iteration, if both missions are the same
            continue;
        }
        
        // otherwise get the node, that needs to be update (has the same index as the mission)
        CCNinePatchBackgroundNode *missionNode = [missionNodes objectAtIndex:i];

        [self replaceMissionOnMissionsNode:missionNode withMission:newMission];
    }
    
    // in the last step, assign the new missions
    missions = [missionsNew copy];
}

- (void)replaceMissionOnMissionsNode:(CCNinePatchBackgroundNode *)missionNode withMission:(Mission*)mission
{
    // initial and final position
    CGPoint targetPositionOnScreen = missionNode.position;
    
    // position not on the sceen
    CGPoint targetPositionOffScreen = ccp(self.contentSize.width + missionNode.contentSize.width + 50, missionNode.position.y);
    
    // 1) run particle effect and add checkmark
    CCSprite *checkbox = (CCSprite *) [missionNode getChildByTag:TAG_CHECKBOX];
    CCParticleSystem* system = [CCParticleSystemQuad particleWithFile:@"fx-explosion.plist"];
    // Set some parameters that can't be set in Particle Designer
    system.positionType = kCCPositionTypeFree;
    system.autoRemoveOnFinish = YES;
    system.position = checkbox.position;
    [missionNode addChild:system];
    CCFiniteTimeAction *waitParticleAndCheckmark = [CCMoveTo actionWithDuration:2.f position:missionNode.position];

    // 2) add checkmark, to show that mission is completed
    [[missionNode getChildByTag:TAG_CHECKMARK] setVisible:TRUE];
    
    // 3) move of sceen
    CCMoveTo *moveOffScreen = [CCMoveTo actionWithDuration:1.f position:targetPositionOffScreen];
    id easeMoveOffScreen = [CCEaseBounceOut actionWithAction:moveOffScreen];
    
    // 4) wait
    // use a CCMoveTo as 'wait' action
    CCAction *wait = [CCMoveTo actionWithDuration:0.5f position:missionNode.position];
    
    // 5) replace the mission displayed on the cell
    // action to replace the content on the missionsCell
    CCCallBlock *replaceMission = [CCCallBlock actionWithBlock:^{
        CCLabelTTF *descriptionLabel = (CCLabelTTF *) [missionNode getChildByTag:TAG_LABEL];
        CCSprite *thumbnailSprite = (CCSprite *) [missionNode getChildByTag:TAG_THUMBNAIL];
        
        // update mission text
        descriptionLabel.fontSize = FONT_SIZE_MISSIONS;
        descriptionLabel.string = mission.missionDescription;
        [descriptionLabel adjustToFitRequiredSize:CGSizeMake(missionNode.contentSize.width * 0.6, descriptionLabel.contentSize.height)];
        descriptionLabel.position = ccp(missionNode.contentSize.width / 2, missionNode.contentSize.height / 2);

        // update sprite
        CCTexture2D *missionTexture = [[CCTextureCache sharedTextureCache] addImage:mission.thumbnailFileName];
        thumbnailSprite.texture = missionTexture;
        thumbnailSprite.position = ccp(5, missionNode.contentSize.height * 0.1);
        [thumbnailSprite scaleSpriteToFitContentSize];
        
        // remove the checkmark, since we have a new unfulfilled mission
        [[missionNode getChildByTag:TAG_CHECKMARK] setVisible:FALSE];
    }];
    
    // 6) move back on screen
    CCMoveTo *moveOnScreen = [CCMoveTo actionWithDuration:1.f position:targetPositionOnScreen];
    id easeMoveOnScreen = [CCEaseBackInOut actionWithAction:moveOnScreen];
    
    CCSequence *replacementSequence = [CCSequence actions:waitParticleAndCheckmark, easeMoveOffScreen, replaceMission, wait, easeMoveOnScreen, nil];
    
    [missionNode runAction:replacementSequence];
}


- (void)updateCheckmarks
{
    NSAssert([missions count] == [missionNodes count], @"Mission nodes have to be displayed, before checkmarks can be updated");
    
    for (unsigned int i = 0; i < [missions count]; i++)
    {
        Mission *m = [missions objectAtIndex:i];
        CCSprite *missionNode = [missionNodes objectAtIndex:i];
        [[missionNode getChildByTag:TAG_CHECKMARK] setVisible:m.successfullyCompleted];
    }
}

@end
