//
//  GLViewController.m
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "GLViewController.h"
#import "ConstantsAndMacros.h"
#import "OpenGLCommon.h"

#include "Score.h"
#include "Player.h"

#import "AccelerometerSimulation.h"
#ifdef TWITTER
#import "SA_OAuthTwitterEngine.h"
#endif

#ifdef USE_GAMECENTER
#import "GameCenterManager.h"
#endif

#include <sys/types.h>
#include <sys/sysctl.h>

#define STAT_TRACKER Game::GetInstance()->StatTracker()

@implementation GLViewController

#ifdef USE_GAMECENTER
@synthesize gameCenterManager;
@synthesize lb = _lb;
@synthesize lbViewController = _lbViewController;
#endif

- (void)drawView:(GLView*)view;
{
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glColor4f(1.0, 1.0, 1.0, 1.0);

    glLoadIdentity();
	
	glClearColor(0.0f, 0.0f, 0.0f, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	if (!m_pauseGame)
	{
		Game::GetInstance()->Update();
		Game::GetInstance()->Draw();
	}
	
	if (Game::GetInstance()->GetStatusUpdate())
	{
		Game::GetInstance()->SetStatusUpdate(false);
		m_pauseGame = true;
#ifdef TWITTER
		[self statusUpdate];
#endif
		
#ifdef USE_GAMECENTER
		[self submitHighScore];
	#ifdef TWITTER
	#error resumeAfterStatusUpdate will be called twice
	#endif
		[self resumeAfterStatusUpdate];
#endif
	}
    
    if (Game::GetInstance()->GetGotoGameCentre())
    {
        Game::GetInstance()->SetGotoGameCentre(false);
        [self showLeaderboard];
    }
}

#define kOAuthConsumerKey				@""		//REPLACE ME
#define kOAuthConsumerSecret			@""		//REPLACE ME



- (void) startStats
{
#ifndef DISABLE_STATS
	BOOL sendStats = [[NSUserDefaults standardUserDefaults] boolForKey:@"sendStats"];
	if (sendStats)
	{
		[STAT_TRACKER MakeConnection: Game::GetInstance()->Sig()
												   withKey: Game::GetInstance()->Key()
											    andVersion: Game::GetInstance()->Version()
												   andTime: Game::GetInstance()->unixEpoch()];
		
		
		size_t size;
		sysctlbyname("hw.machine", NULL, &size, NULL, 0);
		char *machine = (char*)malloc(size);
		sysctlbyname("hw.machine", machine, &size, NULL, 0);
		NSString *platform = [NSString stringWithCString:machine  encoding:[NSString defaultCStringEncoding]];
		free(machine);
		
		/*[STAT_TRACKER SendEvent: @"device"
						  value: platform
						andTime: Game::GetInstance()->unixEpoch()];
		*/
		
		// os version
		NSString * v = [[UIDevice currentDevice] systemVersion];
		Log(@"v: %@", v);
		/*[STAT_TRACKER SendEvent: @"os_version"
						  value: v
						andTime: Game::GetInstance()->unixEpoch()];
		*/
		// ---- options ----
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// play music
		BOOL enabled_music = [defaults boolForKey:@"enabled_music"];
		/*[STAT_TRACKER SendEvent: @"enabled_music"
						  value: [NSNumber numberWithBool: enabled_music]
						andTime: Game::GetInstance()->unixEpoch()];
		*/
		// play sound
		BOOL enabled_sound = [defaults boolForKey:@"enabled_sound"];
		/*[STAT_TRACKER SendEvent: @"enabled_sound"
						  value: [NSNumber numberWithBool: enabled_sound]
						andTime: Game::GetInstance()->unixEpoch()];
		*/
		// v1.0 controls
		BOOL old_controls = [defaults boolForKey:@"old_controls"];
		/*[STAT_TRACKER SendEvent: @"enabled_old_controls"
						  value: [NSNumber numberWithBool: old_controls]
						andTime: Game::GetInstance()->unixEpoch()];
		*/
		// trails
		BOOL showTrails = [defaults boolForKey:@"showTrails"];
		/*[STAT_TRACKER SendEvent: @"enabled_trails"
						  value: [NSNumber numberWithBool: showTrails]
						andTime: Game::GetInstance()->unixEpoch()];
        */
        
        [STAT_TRACKER SendEvent:@"startup_settings"
                          value:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                     platform
                                                                     , v
                                                                     , [NSString stringWithFormat:@"%d", enabled_music]
                                                                     , [NSString stringWithFormat:@"%d", enabled_sound]
                                                                     , [NSString stringWithFormat:@"%d", old_controls]
                                                                     , [NSString stringWithFormat:@"%d", showTrails]
                                                                     , nil]
                                                            forKeys:[NSArray arrayWithObjects:
                                                                     @"device"
                                                                     , @"os_version"
                                                                     , @"enabled_music"
                                                                     , @"enabled_sound"
                                                                     , @"enabled_old_controls"
                                                                     , @"enabled_trails"
                                                                     , nil]]
                        andTime: Game::GetInstance()->unixEpoch()];
        
        /*
        [NSArray arrayWithObjects:
         @"device", platform
         , @"os_version", v
         , @"enabled_music", [NSString stringWithFormat:@"%d", enabled_music]
         , @"enabled_sound", [NSString stringWithFormat:@"%d", enabled_sound]
         , @"enabled_old_controls", [NSString stringWithFormat:@"%d", old_controls]
         , @"enabled_trails", [NSString stringWithFormat:@"%d", showTrails]
         , nil];
         */
	}
#endif
}

- (void) loopForStats
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	while (![defaults boolForKey:@"didDisplayStatsMsg"])
	{
		//Log(@"stalling till message disapears");
	}
	
	[self performSelectorOnMainThread:@selector(startStats) withObject:nil waitUntilDone:false]; 
	
	
	[pool drain];
}

-(void)setupView:(GLView*)view
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
	NSString *currentLanguage = [languages objectAtIndex:0];
	
	NSLog(@"Current Locale: %@", [[NSLocale currentLocale] localeIdentifier]);
	NSLog(@"Current language: %@", currentLanguage);
	NSLog(@"Welcome Text: %@", NSLocalizedString(@"WelcomeKey", @""));
/*
	wchar_t text[16];
	int size = sizeof(text);
	
	//std::string.IndexOf("a");
	
	// 0x3040 - 0x30ff
	// 12352 - 12543
	// 256
	
	
// ぁあぃいぅうぇえぉおかがきぎく
// ぐけげこごさざしじすずせぜそぞた
// だちぢっつづてでとどなにぬねのは
// ばぱひびぴふぶぷへべぺほぼぽまみ
// むめもゃやゅゆょよらりるれろゎわ
// ゐゑをんゔゕゖ  ゛゜ゝゞゟ
	
	
	
	
	NSString *aiueo = @"あいうえお aiueo アイウエオ";
	for (int i = 0; i < [aiueo length]; ++i) 
	{
		unichar firstCharacter = [aiueo characterAtIndex: i];
		int scaledDown = firstCharacter >= 12352 ? firstCharacter - 12352 + 256 : firstCharacter;
		Log(@"%@ - %C, %d", [NSString stringWithFormat:@"%x", firstCharacter], firstCharacter, scaledDown);
	}
	
	
	
	
	
	memset(text, 0, size);
	memcpy(text, "あ .", size);
	for (int i = 0; i < size; ++i)
	{
		NSLog(@"%d - %x, %C", i, text[i], text[i]);
	}
	//NSLog(@"%@", [NSString stringWithUTF8String:text]);
	
	*/
	
	
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	 
	glOrthof(0.0f, 320.0f, 480.0f, 0.0f, -1000.0f, 0.0f);
	 
	glViewport(0.0f, 0.0f, (GLsizei)320.0f, (GLsizei)480.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	 
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_COLOR_MATERIAL);
	 
	glClearColor(0.2f, 0.2f, 0.2f, 0.0f);
	 
	glEnable				(GL_BLEND);
	glEnable				(GL_DEPTH_TEST);
	glDepthFunc				(GL_LEQUAL);
	glDisable				(GL_LIGHTING);
	
	glEnable(GL_TEXTURE_2D);
    glBlendFunc(GL_ONE, GL_SRC_COLOR);
	
	// ------
	

	m_pauseGame = false;
	Game::GetInstance()->Init();
	[NSThread detachNewThreadSelector:@selector(loopForStats) toTarget:self withObject:nil];
	
#ifdef USE_GAMECENTER
	if([GameCenterManager isGameCenterAvailable])
	{
		self.gameCenterManager= [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate: self];
		[self.gameCenterManager authenticateLocalUser];
		
		[self.gameCenterManager reloadHighScoresForCategory: @""];
		
	}
	
    [self setLb:nil];
    [self setLbViewController: [[UIViewController alloc] init]];
#endif
}
- (void)dealloc 
{
#ifdef USE_GAMECENTER
    [_lb release];
    [gameCenterManager release];
    [_lbViewController release];
#endif
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!m_pauseGame)
	{
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchLocation = [touch locationInView:self.view];
		Game::GetInstance()->Press(touchLocation.x, touchLocation.y);
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!m_pauseGame)
	{
		Game::GetInstance()->Release();
	}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    self.view.transform = CGAffineTransformIdentity;
	
    for (UIView *subview in self.view.subviews) 
	{
        subview.transform = CGAffineTransformIdentity;
    }
    [UIView commitAnimations];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

#define kFilterFactor 0.05
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	static float prevX=0, prevY=0;
	
	float accelX = acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
}

#ifdef TWITTER
//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username 
{
	Log(@"Authenicated for %@", username);
	[self postScore];
	[self resumeAfterStatusUpdate];
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller 
{
	Log(@"Authentication Failed!");
	[self resumeAfterStatusUpdate];
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller 
{
	Log(@"Authentication Canceled.");
	[self resumeAfterStatusUpdate];
}
//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	Log(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	Log(@"Request %@ failed with error: %@", requestIdentifier, error);
}
#endif
- (void)statusUpdate
{
#ifdef TWITTER
	if (!m_twitEngine)
	{
		m_twitEngine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
		
		m_twitEngine.consumerKey = kOAuthConsumerKey;
		m_twitEngine.consumerSecret = kOAuthConsumerSecret;
		
		[m_twitEngine requestRequestToken];
	}
	
	UIViewController* controller = 
	 [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: m_twitEngine delegate: self 
	  ];//forOrientation: UIInterfaceOrientationLandscapeRight];
	
	if (controller) 
	{
		[self presentModalViewController: controller animated: NO];

	}
	else 
	{
		[self postScore];
		[self resumeAfterStatusUpdate];
	}
#endif
}
- (void)postScore
{
#ifdef TWITTER
	int score = Score::GetInstance()->GetCurrentActualScore();
	[m_twitEngine sendUpdate: [NSString stringWithFormat: @"I shot %d points worth of InvaderRs. %@", score, Game::GetInstance()->unixEpoch()]];
#endif
}


- (void)resumeAfterStatusUpdate
{
	m_pauseGame = false;
	Score::GetInstance()->ResetScore();
	//Player::getInstance()->start(); // RA - testing
}

- (void) submitHighScore
{
#ifdef USE_GAMECENTER
	int score = Score::GetInstance()->GetCurrentActualScore();
	if (score > 0)
	{
		[self.gameCenterManager reportScore: score forCategory: @""];
	}
#endif
}

- (void) scoreReported: (NSError*) error;
{
	if(error == NULL)
	{
		NSLog(@"Game Center - Score submitted");
	}
	else
	{
		NSLog(@"Game Center - Error submitting, Reason: %@", [error localizedDescription]);
	}
}

#ifdef USE_GAMECENTER
- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error;
{
	if (error == NULL)
	{
		int64_t personalBest = leaderBoard.localPlayerScore.value;
		Log(@"Game Center - personalBest: %ld", personalBest);
		if([leaderBoard.scores count] > 0)
		{
			GKScore* allTime= [leaderBoard.scores objectAtIndex: 0];
			[gameCenterManager mapPlayerIDtoPlayer: allTime.playerID];
		}
		
		int highScore = Score::GetInstance()->GetHighScore();
		if (highScore > 0)
		{
			Log(@"stored high score: %d, gamecenter high score: %d", highScore, personalBest);
			if (highScore > personalBest)
			{
				[self.gameCenterManager reportScore: highScore forCategory: @""];
			}
		}
	}
	else
	{
		Log(@"GameCenter Scores Unavailable: %@", [error localizedDescription]);
	}
}


-(IBAction)showLeaderboard
{
    //GKLeaderboardViewController *lb = [[GKLeaderboardViewController alloc] init];
    if([self lb] == nil)
    {
        [self setLb:[[GKLeaderboardViewController alloc] init]];
        self.lb.leaderboardDelegate = self;
        //self.lb.delegate = self;
    }
    //[self presentModalViewController:[self lb] animated:YES];
    //[self.navigationController pushViewController:[self lb] animated:YES];
    
    
    
    [self.view addSubview:[self.lbViewController view]];
    [self.lbViewController presentModalViewController:[self lb] animated: YES];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    //[self dismissModalViewControllerAnimated: NO];
    
    [self.lbViewController dismissModalViewControllerAnimated:YES];
    
    for (UIView *v in [self.view subviews])
    {
        //if([v isMemberOfClass:[UIButton class]])
        {
            [v removeFromSuperview];
        }
    }
    //[self.lbViewController.view removeFromSuperview];
    
    
    //[self onLeaderboardViewDismissed];
    //[viewController release];
    /*
    if ([viewController respondsToSelector:@selector(popViewControllerAnimated:)])
    {
        [(UINavigationController*)viewController popViewControllerAnimated:YES];
    }
    */
    Log(@"Dismiss modal view");
}
#endif

@end
