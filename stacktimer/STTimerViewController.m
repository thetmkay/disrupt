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
#import <AudioToolbox/AudioToolbox.h>
#import "YMConstants.h"
#import "YMHTTPClient.h"
#import <Parse/Parse.h>
#import "YMLoginController.h"

#define ACTION_ON_COMPLETE @"actionOnCompletion"

@interface STTimerViewController () <MZTimerLabelDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSInteger currentIndexPath;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic) BOOL paused;
@property (nonatomic) BOOL finished;
@property (nonatomic) BOOL attemptingSampleAPICall;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startButtonItem;
@property (nonatomic) BOOL isPlayButton;

@end

@implementation STTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.attemptingSampleAPICall = NO;
    self.isPlayButton = YES;

    [self.startButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:40.0f]} forState:UIControlStateNormal];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteLogin:) name:YMYammerSDKLoginDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailLogin:) name:YMYammerSDKLoginDidFailNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YMYammerSDKLoginDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YMYammerSDKLoginDidFailNotification object:nil];
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
    cell.timerLabel.timeFormat = @"HH:mm:ss.S";
    [cell.timerLabel setCountDownTime:cell.time];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
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
    if (self.isPlayButton) {
        if (self.finished) {
            [self resetButtonPressed:self];
        }
        if (self.paused) {
            [self unPause];
        } else {
            [self startNextTimer];
        }
        [self.startButton setTitle:@"PAUSE" forState:UIControlStateNormal];
//        self.startButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(startPressed:)];
        self.isPlayButton = NO;
        self.startButtonItem.title = @"PAUSE";
    } else {
        [self pauseTimer];
        [self.startButton setTitle:@"START" forState:UIControlStateNormal];
//        self.startButtonItem.style = UIBarButtonSystemItemPlay;
        self.startButtonItem.title = @"START";
        self.isPlayButton = YES;
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
        [cell.timerLabel reset];
        [cell.timerLabel start];
        self.currentIndexPath++;
    }
}

- (IBAction)shareButtonPressed:(id)sender {
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil message:@"Share your routine with the world!" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction *yammerAction = [UIAlertAction actionWithTitle:@"Yammer" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"share to yammer");
        [self attemptShareToYammer:self];
    }];
    
    UIAlertAction *facebookAction = [UIAlertAction actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"share to facebook");
    }];
    
    UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"share to twitter");
    }];
    
    [alertViewController addAction:cancelAction];
    [alertViewController addAction:yammerAction];
    [alertViewController addAction:facebookAction];
    [alertViewController addAction:twitterAction];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
    
}


- (IBAction)resetButtonPressed:(id)sender {
    self.paused = NO;
    self.currentIndexPath = 0;
    self.finished = NO;
    self.isPlayButton = YES;
    [self.tableView reloadData];
}


#pragma mark - timer delegate

- (void)timerLabel:(MZTimerLabel *)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    if (self.currentIndexPath >= [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects]) {
        [self.startButton setTitle:@"START" forState:UIControlStateNormal];
        self.startButtonItem.title = @"START";
        self.finished = YES;
        [self resetButtonPressed:self];
    } else {
        [self startNextTimer];
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

#pragma mark shareCode 

- (void)login:(id)sender {
    [[YMLoginController sharedInstance] startLogin];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Yammer Sample Code:
// Here's an example of attempting an API call.  First check to see if the authToken is available.
// If it's not available, then the user must login as the first step in acquiring the authToken.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)attemptShareToYammer:(id)sender
{
    // Get the authToken if it exists
    NSString *authToken = [[YMLoginController sharedInstance] storedAuthToken];
    
    // If the authToken exists, then attempt the sample API call.
    if (authToken) {
        
        NSLog(@"authToken: %@", authToken);
        [self shareToYammer: authToken];
        
    } else {
        
        // This is an example of how you might
        self.attemptingSampleAPICall = YES;
        
        // If no auth token is found, go to step one of the login flow.
        // The setPostLoginProcessDelegate is one possible way do something after login.  In this case, we set that delegate
        // to self so that when the login controller is done logging in successfully, the processAfterLogin method
        // is called in this class.  Usually in an application that post-login process will just be an
        // app home page or something similar, so this dynamic delegate is not really necessary, but provides some
        // added flexibility in routing the app to a delegate after login.
        [[YMLoginController sharedInstance] startLogin];
    }
}

// Once we know the authToken exists, attempt an actual API call
- (void)shareToYammer:(NSString *)authToken
{
    NSLog(@"Getting User Info");
    
    
    // The YMHTTPClient uses a "baseUrl" with paths appended.  The baseUrl looks like "https://www.yammer.com"
    NSURL *baseURL = [NSURL URLWithString: YAMMER_BASE_URL];
    
    // Query params (in this case there are no params, but if there were, this is how you'd add them)
    NSDictionary *params = @{@"threaded": @"extended", @"limit": @30};
    
    YMHTTPClient *client = [[YMHTTPClient alloc] initWithBaseURL:baseURL authToken:authToken];

    
    // the postPath is where the path is appended to the baseUrl
    // the params are the query params
    [client getPath:@"/api/v1/users/current.json"
         parameters:params
            success:^(id responseObject) {
                NSLog(@"Sample API Call JSON: %@", responseObject);
                [self postToYammerWithTokenAndUser:authToken user:responseObject];
            }
            failure:^(NSError *error) {
                
                NSLog(@"error: %@", error);
                
                // Replace this with whatever you want.  This is just an example of handling an error with an alert.
                [self showAlertViewForError:error title:@"Error during sample API call"];
            }
     ];
}

- (NSDictionary *)generateRoutineDictionary {
    NSMutableArray *timers = [[NSMutableArray alloc] init];
    Routine *routine = [Routine MR_findFirstByAttribute:@"nameForRoutine" withValue:self.title];
    for (Timer *timer in routine.timers) {
        NSDictionary *timerDictionary = @{@"time":timer.time, ACTION_ON_COMPLETE:@"beep", @"position":timer.position};
        [timers addObject:timerDictionary];
    }
    return @{@"timers":timers, @"name":self.title};
}

- (void)postToYammerWithTokenAndUser:(NSString *)authToken user:(NSDictionary *)user
{
    NSLog(@"Making sample API call");
    
    
//    NSDictionary *timer1 = @{@"time":@"1000",@"actionOnCompletion":@"beep"};
//    NSDictionary *timer2 = @{@"time":@"2000",@"actionOnCompletion":@"beep"};
//    NSDictionary *timer3 = @{@"time":@"4000",@"actionOnCompletion":@"beep"};
//    NSArray *timers = [[NSArray alloc] initWithObjects:timer1,timer2,timer3, nil ];
//    NSString *routineName = @"routinetest";
//    NSDictionary *routine = @{@"timers":timers,@"name":routineName};
    NSDictionary *routine = [self generateRoutineDictionary];
    //    NSError *error;
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:routine options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableString *baseTimerURL = [[NSMutableString alloc] initWithString:@"http://stacktimer.com/timer/"];
    
    PFObject *pfRoutine = [PFObject objectWithClassName:@"Routine"];
    pfRoutine[@"timers"] = routine[@"timers"];
    pfRoutine[@"name"] = self.title;
    pfRoutine[@"user"] = user;
    [pfRoutine save];
    NSLog(@"id %@", pfRoutine.objectId);
    [baseTimerURL appendString:pfRoutine.objectId];
    NSLog(@"timer url %@", baseTimerURL);
    NSURL *timerURL = [NSURL URLWithString:[baseTimerURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // The YMHTTPClient uses a "baseUrl" with paths appended.  The baseUrl looks like "https://www.yammer.com"
    NSURL *baseURL = [NSURL URLWithString: YAMMER_BASE_URL];
    
    NSString *actor_name = [user objectForKey:@"full_name"];
    NSString *actor_email = [[[[user objectForKey:@"contact"] objectForKey:@"email_addresses"] objectAtIndex:0] objectForKey:@"address"];
    NSLog(@"Name %@", actor_name);
    NSLog(@"Email %@", actor_email);
    
    NSDictionary *actor = @{@"name":actor_name,@"email":actor_email};
    NSDictionary *object = @{@"url":timerURL,@"title":@"See Timer", @"type":@"page"};
    
    
    
    // Query params (in this case there are no params, but if there were, this is how you'd add them)
    NSDictionary *activity = @{@"actor": actor, @"object": object, @"message":@"Hey check out!", @"action":@"stacktimer:share"};
    
    NSDictionary *params = @{@"activity":activity};
    
    YMHTTPClient *client = [[YMHTTPClient alloc] initWithBaseURL:baseURL authToken:authToken];
    
    // the postPath is where the path is appended to the baseUrl
    // the params are the query params
    [client postPath:@"/api/v1/activity.json"
          parameters:params
             success:^(id responseObject) {
                 NSLog(@"Sample API Call JSON: %@", responseObject);
             }
             failure:^(NSInteger statusCode, NSError *error) {
                 NSLog(@"activity %@", activity);
                 NSLog(@"status code: %ld", statusCode);
                 NSLog(@"error: %@", error);
                 
                 // Replace this with whatever you want.  This is just an example of handling an error with an alert.
                 [self showAlertViewForError:error title:@"Error during sample API call"];
             }
     ];
}

- (void)showAlertViewForError:(NSError *)error title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:[error description]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Login controller delegate methods

- (void)loginController:(YMLoginController *)loginController didCompleteWithAuthToken:(NSString *)authToken
{
    // Uncomment if you want to use delegate instead of notifications
    //[self handleSuccessWithToken:authToken];
}

- (void)loginController:(YMLoginController *)loginController didFailWithError:(NSError *)error
{
    // Uncomment if you want to use delegate instead of notifications
    //[self handleFailureWithError:error];
}

#pragma mark - Login controller notification handling methods

- (void)didCompleteLogin:(NSNotification *)note
{
    NSString *authToken = note.userInfo[YMYammerSDKAuthTokenUserInfoKey];
    [self handleSuccessWithToken:authToken];
}

- (void)didFailLogin:(NSNotification *)note
{
    NSError *error = note.userInfo[YMYammerSDKErrorUserInfoKey];
    [self handleFailureWithError:error];
}

#pragma mark - Common error/success handling methods

- (void)handleSuccessWithToken:(NSString *)authToken
{
    
    // This is an example of only processing something after login if we were attempting to do something before the
    // login process was triggered.  In this case, we have an attemptingSampleAPICall boolean that tells us we were
    // trying to make the sample API call before login was triggered, so now we can resume that process here.
    if ( self.attemptingSampleAPICall ) {
        
        // Reset the flag so we only come back here during logins that were triggered as part of trying to make the
        // sample API call.
        self.attemptingSampleAPICall = NO;
        
        // If the authToken exists, then attempt the sample API call.
        if (authToken) {
            [self shareToYammer: authToken];
        }
        else {
            NSLog(@"Could not make sample API call.  AuthToken does not exist");
        }
    }
}

- (void)handleFailureWithError:(NSError *)error
{
    // Replace this with whatever you want.  This is just an example of handling an error with an alert.
    [self showAlertViewForError:error title:@"Authentication error"];
}








- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // The correct way to save (http://samwize.com/2014/03/29/how-to-save-using-magicalrecord/)
        Timer *timer = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            Timer *localTimer = [timer MR_inContext:localContext];
            [localTimer MR_deleteEntity];
        }];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new entity and save
    }
}



@end
