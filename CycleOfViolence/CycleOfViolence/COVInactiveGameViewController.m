//
//  COVInactiveGameViewController.m
//  CycleOfViolence
//
//  Created by Reyna Hulett on 3/6/14.
//
//

#import "COVInactiveGameViewController.h"

@interface COVInactiveGameViewController ()

@property (weak, nonatomic) IBOutlet UILabel *targetDisplay;
@property (weak, nonatomic) IBOutlet UILabel *countdown;
@property (weak, nonatomic) IBOutlet UIButton *leaveButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@end

@implementation COVInactiveGameViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Don't allow users to return to the home screen while they are in a game.
        self.navigationItem.hidesBackButton = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get the current user and game.
    PFUser *currUser = [PFUser currentUser];
    COVGame *currGame = (COVGame *)[PFQuery getObjectOfClass:@"COVGame"
                                                    objectId:currUser[@"currentGameID"]];
    
    // Set the view controller to display the current game.
    self.targetDisplay.text = [NSString stringWithFormat:
                               @"You are in the game \"%@,\" which hasn't started yet.",
                               currGame.name];
    
    // Show the countdown until the game starts.
    NSTimeInterval timeToStart = [currGame.startTime timeIntervalSinceNow];
    if (timeToStart <= 0) {
        self.countdown.text = @"Starting soon...";
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
        NSString *date = [dateFormatter stringFromDate:currGame.startTime];
        self.countdown.text = [NSString stringWithFormat:@"Game starts %@",
                               date];
    }
    
    
    // Show the buttons selectively.
    // If we're the manager...
    if ([currUser.objectId isEqualToString: currGame.gameManagerId]){
        [self.leaveButton setTitle:@"Delete Game" forState:UIControlStateNormal];
        // We cannot start the game until it's time.
        if (timeToStart > 0) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
            NSString *date = [dateFormatter stringFromDate:currGame.startTime];
            self.countdown.text = [NSString stringWithFormat:@"May start %@",
                                   date];
            [self.startButton setTitle:@"Start Game" forState:UIControlStateNormal];
            [self.startButton setEnabled:NO];
        } else {
            self.countdown.text = @"Hey manager! Please start the game";
            [self.startButton setTitle:@"Start Game" forState:UIControlStateNormal];
            [self.startButton setEnabled:YES];
        }
        
    }
    else {
        // Disable the 'start game' button
        [self.startButton setEnabled:NO];
        // Make the text appropriate for the 'Leave Game" button
        [self.leaveButton setTitle:@"Leave Game" forState:UIControlStateNormal];
    }
    
}


- (IBAction)buttonTapped:(id)sender
{
    PFUser *currUser = [PFUser currentUser];
    COVGame *currGame = (COVGame *)[PFQuery getObjectOfClass:@"COVGame"
                                                    objectId:currUser[@"currentGameID"]];
    
    if(sender == self.startButton) {
        // Start the game!
        NSLog(@"startButton tapped");
        
        // Disable buttons during operation
        [self.startButton setEnabled:NO];
        [self.leaveButton setEnabled:NO];
        
        
        [currGame startGame];
        [currGame saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Sucessfully saved in background.");
                
                // Since user is no longer in the game, return them to the home screen.
                [self performSegueWithIdentifier:@"toHomeScreenFromInactive" sender:self];
                
            } else {
                NSLog(@"Failed to save in background.");
                [[[UIAlertView alloc] initWithTitle:@"Cloud save failed"
                                            message:@"Please try again some other time."
                                           delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
            }
        }];
        
        // ReEnable button if operation failed
        [self.startButton setEnabled:YES];
        [self.leaveButton setEnabled:YES];
    }
    else if (sender == self.leaveButton) {
        NSLog(@"leaveButton tapped");
        
        
        // Disable button during operation
        [self.leaveButton setEnabled:NO];
        
        // This button either lets a user leave the game, or it deletes the game if
        // the user is the manager
        if ([currUser.objectId isEqualToString: currGame.gameManagerId]) {
            [currGame abortGame];
        }
        else {
            [currGame removePlayer:currUser];
            // If we abandon a game before it begins, we don't want it to show up
            // in our history.
            [currUser[@"gameHistory"] removeObjectAtIndex:0];
            
            // Game not yet started, so decrease total number of players.
            --currGame.numberOfPlayers;
            
            // Update Parse cloud storage.
            [currGame saveInBackground];
        }
        
        // Update the currentGameID in the User who left, or the manager who deleted the game.
        currUser[@"currentGameID"] = [NSNull null];
        [currUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Sucessfully saved in background.");
                
                // Since user is no longer in the game, return them to the home screen.
                [self performSegueWithIdentifier:@"toHomeScreenFromInactive" sender:self];
                
            } else {
                NSLog(@"Failed to save in background.");
                [[[UIAlertView alloc] initWithTitle:@"Cloud save failed"
                                            message:@"Please try again some other time."
                                           delegate:nil
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] show];
            }
        }];
        
        
        // Re-enable button during operation
        [self.leaveButton setEnabled:YES];
    }
}

@end
