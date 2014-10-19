//
//  STAddRoutineWithTimersTableViewController.m
//  stacktimer
//
//  Created by Niket Shah on 19/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import "STAddRoutineWithTimersTableViewController.h"
#import "STTimerTableViewCell.h"
#import "Timer.h"
#import "Routine.h"
#import "STRoutine.h"

@interface STAddRoutineWithTimersTableViewController ()

@property (strong, nonatomic) NSArray *timers;

@end

@implementation STAddRoutineWithTimersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    STRoutine *routineManager = [[STRoutine alloc] init];
    [routineManager addNewRoutineWithName:self.title withCompletionBlock:^(BOOL success) {
        if (success) {
            for (NSDictionary *timerDictionary in self.routine[@"timers"]) {
                STRoutine *routineManager2 = [[STRoutine alloc] init];
                Timer *timer = [Timer MR_createEntity];
                timer.position = timerDictionary[@"position"];
                timer.actionOnCompletion = timerDictionary[@"actionOnCompletion"];
                timer.time = timerDictionary[@"time"];
                [routineManager2 addTimer:timer toRoutineWithName:self.title withCompletionBlock:nil];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"WHAAAAAT!!?!?!");
        }
    }];
    
}


- (void)setRoutine:(NSDictionary *)routine {
    _routine = routine;
    self.timers = routine[@"timers"];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.timers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STTimerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timerCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(STTimerTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *timer = [self.timers objectAtIndex:indexPath.row];
    cell.timerLabel.timerType = MZTimerLabelTypeTimer;
    cell.time = (int)([timer[@"time"] integerValue] / 1000);
    [cell.timerLabel setCountDownTime:cell.time];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
