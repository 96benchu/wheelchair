/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "AppDelegate.h"
#import "Game.h"

@implementation AppDelegate

-(void) initializationComplete
{
#ifdef KK_ARC_ENABLED
	CCLOG(@"ARC is enabled");
#else
	CCLOG(@"ARC is either not available or not enabled");
#endif
    
    [MGWU loadMGWU:@"comashudesairunnerTemplateUltraLongSuperSecretKey"];
}

-(id) alternateView
{
	return nil;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // attempt to extract a token from the url
    return [MGWU handleURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[[CCDirector sharedDirector] runningScene] stopAllActions];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // call on didEnterForeground for the currently active scene
    if ([[[CCDirector sharedDirector] runningScene] respondsToSelector:@selector(didEnterForeground)])
    {
        id currentScene = (id) [[CCDirector sharedDirector] runningScene];
        [currentScene performSelector:@selector(didEnterForeground)];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // restart the animations once the app enters the foreground
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // ensure that no animations are running when app enters background - otherwise this will lead to a crash
	[[CCDirector sharedDirector] stopAnimation];
}

@end
