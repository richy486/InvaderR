//
//  ___PROJECTNAMEASIDENTIFIER___AppDelegate.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "___PROJECTNAMEASIDENTIFIER___AppDelegate.h"
#import "GLView.h"
#import "ConstantsAndMacros.h"


#import "AccelerometerSimulation.h"
#include "Game.h"
#include "Text.h"
#include "Score.h"
#include "consts.h"

// CONSTANTS
#define kAccelerometerFrequency		100.0 // Hz
#define kFilteringFactor			0.1

#define STAT_TRACKER Game::GetInstance()->StatTracker()

@implementation ___PROJECTNAMEASIDENTIFIER___AppDelegate

@synthesize window;
@synthesize glView;



- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	//float kAccelerometerFrequency = 1.0f;
    [application setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	/*
	// Register for notification when the app shuts down
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myFunc) name:UIApplicationWillTerminateNotification object:nil];
	
	// On iOS 4.0+ only, listen for background notification
	if(&UIApplicationDidEnterBackgroundNotification != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myFunc) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	
	// On iOS 4.0+ only, listen for foreground notification
	if(&UIApplicationWillEnterForegroundNotification != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myFunc) name:UIApplicationWillEnterForegroundNotification object:nil];
	}
	*/
	
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	glView.animationInterval = 1.0 / kRenderingFrequency;
	[glView startAnimation];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *appDefs = [NSMutableDictionary dictionary];
	[appDefs setObject:@"YES" forKey:@"enabled_sound"];
	[appDefs setObject:@"YES" forKey:@"enabled_music"];
	[appDefs setObject:@"NO" forKey:@"old_controls"];
	[appDefs setObject:@"YES" forKey:@"showTrails"];
	[appDefs setObject:@"NO" forKey:@"didDisplayStatsMsg"];
	[appDefs setObject:@"YES" forKey:@"sendStats"];
	
    [defaults registerDefaults:appDefs];	
	
	//NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	BOOL didDisplayStatsMsg = [defaults boolForKey:@"didDisplayStatsMsg"];
	if (!didDisplayStatsMsg)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Statistics" 
														message:@"Do you want to send anonymous game statistics?"
													   delegate:self 
											  cancelButtonTitle:@"No" 
											  otherButtonTitles: @"Yes" , nil];
		[alert show];	
		[alert release];
	}
	
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{ 
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	switch(buttonIndex) 
	{
		case 0:
			[defaults setBool:NO forKey:@"sendStats"];
			
			break;
		case 1:
			[defaults setBool:YES forKey:@"sendStats"];
			
			break;
		default:
			break;
	}
	
	[defaults setBool:YES forKey:@"didDisplayStatsMsg"];
	[defaults synchronize];
}

- (void)applicationWillResignActive:(UIApplication *)application 
{
	glView.animationInterval = 1.0 / kInactiveRenderingFrequency;
}


- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	glView.animationInterval = 1.0 / 60.0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	Log(@"applicationWillTerminate");
    
#ifndef DISABLE_STATS
    BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
	if (sendStats)
	{
		int gameTime = Game::GetInstance()->GetCurrentGameTime();
		Log(@"gameTime: %d", gameTime);
		[STAT_TRACKER SendEvent: @"gt"
						  value: [NSNumber numberWithInt:gameTime]
						andTime: Game::GetInstance()->unixEpoch()];
	}
#endif
    
	delete Score::GetInstance();
	
	Game::GetInstance()->ShutDown();
	delete Game::GetInstance();
	delete TextController::GetInstance();
}

- (void)applicationDidEnterBackground:(UIApplication *)application 
{
	Log(@"applicationDidEnterBackground");
    
#ifndef DISABLE_STATS
    BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
	if (sendStats)
	{
		int gameTime = Game::GetInstance()->GetCurrentGameTime();
		Log(@"gameTime: %d", gameTime);
		[STAT_TRACKER SendEvent: @"gt"
						  value: [NSNumber numberWithInt:gameTime]
						andTime: Game::GetInstance()->unixEpoch()];
	}
#endif
	
	Game::GetInstance()->Suspend();
}

- (void)applicationWillEnterForeground:(UIApplication *)application 
{
	Log(@"applicationWillEnterForeground");
    Game::GetInstance()->ResetGameTime();
	Game::GetInstance()->UnSuspend();
}

- (void)dealloc 
{
	[window release];
	[glView release];
	[super dealloc];
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	//Use a basic low-pass filter to only keep the gravity in the accelerometer values
	accel[0] = acceleration.x * kFilteringFactor + accel[0] * (1.0 - kFilteringFactor);
	accel[1] = acceleration.y * kFilteringFactor + accel[1] * (1.0 - kFilteringFactor);
	accel[2] = acceleration.z * kFilteringFactor + accel[2] * (1.0 - kFilteringFactor);
	
	//Update the accelerometer values for the view
	[glView setAccel:accel];
}



@end
