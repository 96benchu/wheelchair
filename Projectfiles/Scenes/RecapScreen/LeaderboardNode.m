//
//  LeaderboardNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "LeaderboardNode.h"
#import "CCBackgroundColorNode.h"
#import "CCControlButton.h"
#import "Leaderboard.h"
#import "STYLES.h"
#import "CCScale9Sprite.h"
#import "StyleManager.h"
#import "CCNinePatchBackgroundNode.h"
#import "CCLabelTTF+adjustToFitRequiredSize.h"

#define LEADERBOARD_TITLE_WIDTH 22
#define LEADERBOARD_ENTRY_FONT_SIZE 11
#define DISPLAY_AMOUNT_GLOBAL_RANK (unsigned int) 4
#define DISPLAY_AMOUNT_FRIENDS_RANK (unsigned int) 4
#define LEADERBOARD_PANEL_MARGIN_LEFT 4

@interface LeaderboardNode()

// helper method for adding a leaderboard entry. Uses the layoutingYPosition variable to determine yPosition for Layout.
- (void)addLeaderboardEntryToNode:(CCNode *)node withName:(NSString *)name nameSuffix:(NSString *)nameSuffix rank:(int)rank score:(int)score;

// helper method for adding a custom string leaderboard entry. Uses the layoutingYPosition variable to determine yPosition for Layout.
- (void)addLeaderboardEntryToNode:(CCNode *)node withString:(NSString *)string;

// method which creates entries for different leaderboards. Currently friend and global leaderboard. 
- (void)createLeaderboardEntriesForLeaderboard:(NSArray *)leaderboard amountOfEntries:(unsigned int)amountOfEntries node:(CCNode *)node facebookRequired:(BOOL)facebookRequired;

// creates the nodes for local and global leaderboard. In seperate methode, since it needs to be called whenever content is reloaded
- (void)createLeaderboardNodes;

// takes the scoreboard and structures it into global scoreboard, friends scoreboard, etc.
- (void)structureScoreboardEntries:(NSDictionary *)scoreboardArg;

// called when the fb login button
- (void)fbLoginButtonPressed;

// fblogin completed
- (void)facebookLoginCompleted:(NSString *)response;

// helper method, since a MGWU action with callback, cannot be called from within a callback method
- (void)submitScoreDelayed;

// called when the 'invite further friends' button is pressed on the friends leaderboard
- (void)inviteMoreFriendsButtonPressed;

@end

@implementation LeaderboardNode


- (id)initWithScoreBoard:(NSDictionary *)scoreboardArg
{
    self = [super init];
    
    if (self)
    {
        [self structureScoreboardEntries:scoreboardArg];
        self.backgroundSprite = [CCSprite spriteWithFile:@"leaderboard_background.png"];
    }
    
    return self;
}

- (void)reloadWithScoreBoard:(NSDictionary *)scoreboardArg
{
    [self structureScoreboardEntries:scoreboardArg];
    
    [self removeChild:friendsLeaderBoardNode];
    [self removeChild:globalLeaderBoardNode];
    
    [self createLeaderboardNodes];
    
    layoutingYPosition = (friendsLeaderBoardNode.contentSize.height) - 5;
    // display the configured amount of leaderboard entries, if enough entries are available
    [self createLeaderboardEntriesForLeaderboard:friendsScoreboard amountOfEntries:DISPLAY_AMOUNT_FRIENDS_RANK node:friendsLeaderBoardNode facebookRequired:TRUE];
    
    layoutingYPosition = (globalLeaderBoardNode.contentSize.height) - 5;
    [self createLeaderboardEntriesForLeaderboard:globalScoreboard amountOfEntries:DISPLAY_AMOUNT_GLOBAL_RANK node:globalLeaderBoardNode facebookRequired:FALSE];
}

- (void)structureScoreboardEntries:(NSDictionary *)scoreboardArg
{
    scoreboard = scoreboardArg;
    globalScoreboard = [scoreboard objectForKey:@"all"];
    friendsScoreboard = [scoreboard objectForKey:@"friends"];
    personalEntry = [scoreboard objectForKey:@"user"];
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    [self createLeaderboardNodes];
    
    layoutingYPosition = (friendsLeaderBoardNode.contentSize.height) - 5;
    // display the configured amount of leaderboard entries, if enough entries are available
    [self createLeaderboardEntriesForLeaderboard:friendsScoreboard amountOfEntries:DISPLAY_AMOUNT_FRIENDS_RANK node:friendsLeaderBoardNode facebookRequired:TRUE];
    
    layoutingYPosition = (globalLeaderBoardNode.contentSize.height) - 5;
    [self createLeaderboardEntriesForLeaderboard:globalScoreboard amountOfEntries:DISPLAY_AMOUNT_GLOBAL_RANK node:globalLeaderBoardNode facebookRequired:FALSE];
}

- (void)tabWillAppear
{
    // only load the highscores once on the recap screen, do not reload them every time the leaderboard is displayed
    if (scoreboard == nil)
    {
        [MGWU getHighScoresForLeaderboard:HIGHSCORE_LEADERBOARD withCallback:@selector(receivedScores:) onTarget:self];
    }
}

- (void)createLeaderboardEntriesForLeaderboard:(NSArray *)leaderboard amountOfEntries:(unsigned int)amountOfEntries node:(CCNode *)node facebookRequired:(BOOL)facebookRequired
{
    unsigned int displayAmount = MIN(amountOfEntries, [leaderboard count]);
    
    if (displayAmount == 0)
    {
        // we cannot display anything, so we leave the methode here.
        if (facebookRequired)
        {
            // add info, that user needs to login to facebook before accessing friends leaderboard
            [self addLeaderboardEntryToNode:node withString:@"You are not logged in with Facebook."];
            [self addLeaderboardEntryToNode:node withString:@"Login with FB to see your friend's rank."];
            
            // add a login button for the user
            CCControlButton *fbLoginButton = [CCControlButton buttonWithTitle:@"Facebook Login" fontName:DEFAULT_FONT fontSize:14];
            [fbLoginButton addTarget:self action:@selector(fbLoginButtonPressed) forControlEvents:CCControlEventTouchUpInside];
            [fbLoginButton setTitleColor:ccc3(0, 0, 0) forState:CCControlStateNormal];
            fbLoginButton.position = ccp(node.contentSize.width / 2, node.contentSize.height / 2);
            [node addChild:fbLoginButton];
        } else 
        {
            [self addLeaderboardEntryToNode:node withString:@"Currently no entries available."];
        }
        
        return;
    }
    
    if (facebookRequired && [MGWU canInviteFriends])
    {
        // decrease the amount of displayed entries by one, if all entries will be filled, since we need to add the invite further friends button
        // if we anyway have less entries then possible we do not need to decrease the displayed amount of entries
        if (displayAmount >= amountOfEntries)
        {
            displayAmount--;
        }
    }
    
    BOOL playerContainedInTopRanks = FALSE;
    
    // add global entries
    for (unsigned int i = 0; i < displayAmount; i++)
    {
        // get the leaderboard entry for the current rank
        NSDictionary *leaderboardEntry = [leaderboard objectAtIndex:i];
        
        NSString *name = [leaderboardEntry objectForKey:@"name"];
        NSString *nameSuffix = @"";
        NSNumber *score = [leaderboardEntry objectForKey:@"score"];
        
        int rank = i+1;
        
        if (rank == [[personalEntry objectForKey:@"rank"] intValue])
        {
            // this means the player is contained in the top rank players and does not need to be displayed seperately
            playerContainedInTopRanks = TRUE;
            name = [Leaderboard userName];
            nameSuffix = @" (you)";
            // increase the amount of displayed entries by one, since we don't need to show a seperate personal entry
            // only increase, if enough entries are available
            if (displayAmount < [leaderboard count])
            {
                displayAmount ++;
            }
        }
        
        [self addLeaderboardEntryToNode:node withName:name nameSuffix:nameSuffix rank:rank score:[score intValue]];
    }
    
    // add personal entry for the player at last position
    NSString *highscoreString = nil;
    
    if (!playerContainedInTopRanks)
    {
        if (personalEntry)
        {
            // if personal entry for the player is available in the leaderboard, and he is not within the top rank, display a seperate entry
            NSString *name = [Leaderboard userName];
            NSString *nameSuffix = @" (you)";
            NSNumber *score = [personalEntry objectForKey:@"score"];
            NSNumber *globalRank = [personalEntry objectForKey:@"rank"];
            highscoreString = [NSString stringWithFormat:@"%d. %@%@: %d", [globalRank intValue], name, nameSuffix, [score intValue]];
            [self addLeaderboardEntryToNode:self withName:nameSuffix nameSuffix:nameSuffix rank:[globalRank intValue] score:[score intValue]];
        }
        else
        {
            highscoreString = @"No highscore submitted yet.";
            [self addLeaderboardEntryToNode:node withString:highscoreString];
        }
    }
    
    if (facebookRequired && [MGWU canInviteFriends])
    {
        // add an invite further friends button to the friends leaderboard
        CCControlButton *inviteMoreFriendsButton = [[CCControlButton alloc] initWithBackgroundSprite:[StyleManager scaleSpriteWhiteBackgroundSolidBlackBorder]];
        [inviteMoreFriendsButton setTitleTTF:DEFAULT_FONT forState:CCControlStateNormal];
        [inviteMoreFriendsButton setTitleTTFSize:LEADERBOARD_ENTRY_FONT_SIZE forState:CCControlStateNormal];
        [inviteMoreFriendsButton setTitleColor:DEFAULT_FONT_COLOR forState:CCControlStateNormal];
        [inviteMoreFriendsButton setTitle:@"Invite more Friends to challenge!" forState:CCControlStateNormal];
        
        inviteMoreFriendsButton.anchorPoint = ccp(0, 1);
        inviteMoreFriendsButton.position = ccp(LEADERBOARD_PANEL_MARGIN_LEFT + LEADERBOARD_TITLE_WIDTH, layoutingYPosition);
        [node addChild:inviteMoreFriendsButton];
        layoutingYPosition -= inviteMoreFriendsButton.contentSize.height;
        
        [inviteMoreFriendsButton addTarget:self action:@selector(inviteMoreFriendsButtonPressed) forControlEvents:CCControlEventTouchUpInside];
    }
}

- (void)addLeaderboardEntryToNode:(CCNode *)node withName:(NSString *)name nameSuffix:(NSString *)nameSuffix rank:(int)rank score:(int)score
{
    // TODO: Make sure name and score fit on to the leaderboard
    NSString *highscoreString = [NSString stringWithFormat:@"%d. %@%@: %d", rank, name, nameSuffix, score];
    
    CCLabelTTF *leaderboardEntryLabel = [CCLabelTTF labelWithString:highscoreString
                                                           fontName:DEFAULT_FONT
                                                           fontSize:LEADERBOARD_ENTRY_FONT_SIZE];
    leaderboardEntryLabel.color = DEFAULT_FONT_COLOR;
    leaderboardEntryLabel.anchorPoint = ccp(0, 1);
    leaderboardEntryLabel.position = ccp(LEADERBOARD_PANEL_MARGIN_LEFT + LEADERBOARD_TITLE_WIDTH, layoutingYPosition);
    [leaderboardEntryLabel adjustToFitRequiredSize:CGSizeMake(node.contentSize.width, leaderboardEntryLabel.contentSize.height)];
    [node addChild:leaderboardEntryLabel];
    layoutingYPosition -= leaderboardEntryLabel.contentSize.height;
}

- (void)addLeaderboardEntryToNode:(CCNode *)node withString:(NSString *)string
{
    CCLabelTTF *leaderboardEntryLabel = [CCLabelTTF labelWithString:string
                                                           fontName:DEFAULT_FONT
                                                           fontSize:LEADERBOARD_ENTRY_FONT_SIZE];
    leaderboardEntryLabel.color = DEFAULT_FONT_COLOR;
    leaderboardEntryLabel.anchorPoint = ccp(0, 1);
    leaderboardEntryLabel.position = ccp(LEADERBOARD_PANEL_MARGIN_LEFT + LEADERBOARD_TITLE_WIDTH, layoutingYPosition);
    [node addChild:leaderboardEntryLabel];
    layoutingYPosition -= leaderboardEntryLabel.contentSize.height;
}

- (void)createLeaderboardNodes
{
    /***** Friends Leaderboard Node ********/
    friendsLeaderBoardNode = [CCNinePatchBackgroundNode node];
    friendsLeaderBoardNode.anchorPoint = ccp(0,1);
    friendsLeaderBoardNode.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height / 2);
    friendsLeaderBoardNode.position = ccp(0, self.contentSize.height);
    [self addChild:friendsLeaderBoardNode];
    
    /***** Global Leaderboard Node ********/
    globalLeaderBoardNode = [CCNinePatchBackgroundNode node];
    globalLeaderBoardNode.anchorPoint = ccp(0,1);
    globalLeaderBoardNode.contentSize = CGSizeMake(self.contentSize.width, self.contentSize.height / 2);
    globalLeaderBoardNode.position = ccp(0, self.contentSize.height / 2);
    [self addChild:globalLeaderBoardNode];
}

- (void)fbLoginButtonPressed
{
    [MGWU loginToFacebookWithCallback:@selector(facebookLoginCompleted:) onTarget:self];
}

- (void)facebookLoginCompleted:(NSString *)response
{
    if ([response isEqualToString:@"Success"])
    {
        [self performSelector:@selector(submitScoreDelayed) withObject:nil afterDelay:0.01f];
    }
}

- (void)submitScoreDelayed
{
    [MGWU getHighScoresForLeaderboard:HIGHSCORE_LEADERBOARD withCallback:@selector(receivedScores:) onTarget:self];
}

- (void)receivedScores:(NSDictionary*)scores
{
    [self reloadWithScoreBoard:scores];
}

- (void)inviteMoreFriendsButtonPressed
{
    NSString *challengeTitle = [NSString stringWithFormat:@"I challenge you in MGWU Runner Template! Checkout that awesome game. Can you beat my score of %d ?", [Leaderboard personalRecordRunningDistance]];
    
    [MGWU inviteFriendsWithMessage:challengeTitle];
}

@end
