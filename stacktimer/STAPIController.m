//
//  STAPIController.m
//  stacktimer
//
//  Created by George Nishimura on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//  Based on original code by Yammer

#import "STAPIController.h"
#import "YMConstants.h"
#import "YMHTTPClient.h"

@implementation STAPIController

- (id)init
{
    if (self = [super initWithNibName:@"HomeView" bundle:nil]) {
        _attemptingSampleAPICall = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YMYammerSDKLoginDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YMYammerSDKLoginDidFailNotification object:nil];
}

// This is called by clicking the login button in the sample interface.
- (IBAction)login:(id)sender
{
    [[YMLoginController sharedInstance] startLogin];
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCompleteLogin:) name:YMYammerSDKLoginDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFailLogin:) name:YMYammerSDKLoginDidFailNotification object:nil];
    [self updateUI];
}

- (void)updateUI
{
    NSString *authToken = [[YMLoginController sharedInstance] storedAuthToken];
    [self.tokenExists setText:(authToken ? @"Yes" : @"No")];
    [self.tokenExists setTextColor:(authToken ? [UIColor greenColor] : [UIColor redColor])];
}

// This is to test missing token functionality.  If there is no authToken, the app will have to login again before
// making a Yammer API call.  Important Note:  The Safari browser in iOS will hold on to the authToken in a cookie in the
// browser.  So if you have already logged in during testing, and you're trying to test the full login workflow again
// with the login dialog, you will need to delete cookies from Safari first.  You can do this by going to the iOS
// settings app, selecting Safari and then Clear Cookies and Data.
- (IBAction)deleteToken:(id)sender
{
    [[YMLoginController sharedInstance] clearAuthToken];
    [self updateUI];
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
    
    __weak STAPIController* weakSelf = self;
    
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

- (void)postToYammerWithTokenAndUser:(NSString *)authToken user:(NSDictionary *)user
{
    NSLog(@"Making sample API call");
    
    // The YMHTTPClient uses a "baseUrl" with paths appended.  The baseUrl looks like "https://www.yammer.com"
    NSURL *baseURL = [NSURL URLWithString: YAMMER_BASE_URL];
    
    NSString *actor_name = [user objectForKey:@"full_name"];
    NSString *actor_email = [[[[user objectForKey:@"contact"] objectForKey:@"email_addresses"] objectAtIndex:0] objectForKey:@"address"];
    NSLog(@"Name %@", actor_name);
    NSLog(@"Email %@", actor_email);
    
    NSDictionary *actor = @{@"name":actor_name,@"email":actor_email};
    NSDictionary *object = @{@"url":@"http://stacktimer.com/timer/blah",@"title":@"See Timer", @"type":@"page"};
    
    
    // Query params (in this case there are no params, but if there were, this is how you'd add them)
    NSDictionary *activity = @{@"actor": actor, @"object": object, @"message":@"Hey check out!", @"action":@"stacktimer:share"};
    
    NSDictionary *params = @{@"activity":activity};
    
    YMHTTPClient *client = [[YMHTTPClient alloc] initWithBaseURL:baseURL authToken:authToken];
    
    __weak STAPIController* weakSelf = self;
    
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
    [self updateUI];
    
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

@end