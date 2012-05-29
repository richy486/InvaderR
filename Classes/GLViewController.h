//
//  GLViewController.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLView.h"

#import "Game.h"
#include "Text.h"

#ifdef USE_GAMECENTER
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#endif

#ifdef TWITTER
#import "SA_OAuthTwitterController.h"
@class SA_OAuthTwitterEngine;
#endif

#ifdef USE_GAMECENTER
@class GameCenterManager;
#endif
@interface GLViewController : UIViewController <GLViewDelegate
#ifdef USE_GAMECENTER
, GameCenterManagerDelegate
, GKLeaderboardViewControllerDelegate
#endif
, UINavigationControllerDelegate
#ifdef TWITTER
, SA_OAuthTwitterControllerDelegate
#endif
>
{
#ifdef TWITTER
	SA_OAuthTwitterEngine* m_twitEngine;
#endif
	bool m_pauseGame;
    
#ifdef USE_GAMECENTER
	GameCenterManager* gameCenterManager;
    GKLeaderboardViewController *_lbl;
    UIViewController *_lbViewController;
#endif
}

#ifdef USE_GAMECENTER
@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, retain) GKLeaderboardViewController *lb;
@property (nonatomic, retain) UIViewController *lbViewController;
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event;

- (void)statusUpdate;
- (void)postScore;
- (void)resumeAfterStatusUpdate;

- (void) submitHighScore;
- (IBAction)showLeaderboard;

@end
