//
//  COVGameMainViewController.h
//  CycleOfViolence
//
//  Created by Chloé Calvarin on 3/6/14.
//
//

#import "COVViewController.h"
#import "COVGame.h"

@interface COVGameMainViewController : COVViewController

// Track the game locally for convenience
@property COVGame *currentGame;

// Method overrides from COVViewController and UIViewController
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)viewDidLoad;
- (void)didReceiveMemoryWarning;

// Own methods
- (IBAction)buttonTapped:(id)sender;
- (void)refreshTarget;


@end
