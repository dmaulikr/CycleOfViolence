//
//  COVGameHistoryViewController.h
//  CycleOfViolence
//
//  Created by John Phillpot on 4/25/14.
//
//

#import "COVGame.h"
#import "COVQueryTableViewController.h"

@interface COVGameHistoryViewController : COVQueryTableViewController

// Method overrides from COVQueryTableViewController and UITableViewController
- (id)initWithCoder:(NSCoder *)aDecoder;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

// Retrieve all games that the user has played and have ended (either by aborting or completing).
- (PFQuery *)queryForTable;
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object;

@end
