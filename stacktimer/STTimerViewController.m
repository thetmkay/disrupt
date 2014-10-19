//
//  STTimerViewController.m
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import "STTimerViewController.h"
#import "STAddTimerViewController.h"
#import "MZTimerLabel.h"
#import "STTimerTableViewCell.h"
#import "Timer.h"
#import "Routine.h"

@interface STTimerViewController () <MZTimerLabelDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSInteger currentIndexPath;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic) BOOL paused;
@property (nonatomic) BOOL finished;

@end

@implementation STTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        Routine *routine = [Routine MR_findFirstByAttribute:@"nameForRoutine" withValue:self.title];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Timer" inManagedObjectContext:[routine managedObjectContext]]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"routine == %@", routine]];
        fetchRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES], nil];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[routine managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}


- (IBAction)addTimerButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"addTimerSegue" sender:self];
}

#pragma mark - Table View Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STTimerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timerCell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(STTimerTableViewCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    Timer *timer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.timerLabel.timerType = MZTimerLabelTypeTimer;
    cell.time = (int)([timer.time integerValue] / 1000);
    [cell.timerLabel setCountDownTime:cell.time];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%@", NSStringFromCGSize
          (self.tableView.frame.size));
    NSInteger numberOfRows = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    return numberOfRows;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(STTimerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - buttons

- (IBAction)startPressed:(id)sender {
    if ([self.startButton.titleLabel.text isEqualToString:@"Start"]) {
        if (self.finished) {
            [self resetButtonPressed:self];
        }
        if (self.paused) {
            [self unPause];
        } else {
            [self startNextTimer];
        }
        [self.startButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [self pauseTimer];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (void)pauseTimer {
    NSIndexPath *indexPath = [[[NSIndexPath alloc] initWithIndex:0] indexPathByAddingIndex:self.currentIndexPath - 1];
    STTimerTableViewCell *cell = (STTimerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.timerLabel pause];
    self.paused = YES;
}

- (void)unPause {
    NSIndexPath *indexPath = [[[NSIndexPath alloc] initWithIndex:0] indexPathByAddingIndex:self.currentIndexPath - 1];
    STTimerTableViewCell *cell = (STTimerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.timerLabel start];
    self.paused = NO;
}

- (void)startNextTimer {
    if (self.currentIndexPath >= 0 && self.currentIndexPath < [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]) {
        NSIndexPath *indexPath = [[[NSIndexPath alloc] initWithIndex:0] indexPathByAddingIndex:self.currentIndexPath];
        STTimerTableViewCell *cell = (STTimerTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.timerLabel.delegate = self;
        [cell.timerLabel start];
        self.currentIndexPath++;
    }
}

- (IBAction)resetButtonPressed:(id)sender {
    self.paused = NO;
    self.currentIndexPath = 0;
    self.finished = NO;
    [self.tableView reloadData];
}


#pragma mark - timer delegate

- (void)timerLabel:(MZTimerLabel *)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime {
    [self startNextTimer];
    if (self.currentIndexPath >= [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]) {
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        self.finished = YES;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"addTimerSegue"]) {
        UINavigationController *nvc = [segue destinationViewController];
        STAddTimerViewController *vc = (STAddTimerViewController *)nvc.topViewController;
        vc.nameForRoutine = self.title;
    }
}


@end
