//
//  STAPIController.h
//  stacktimer
//
//  Created by George Nishimura on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#ifndef stacktimer_STAPIController_h
#define stacktimer_STAPIController_h

#import <UIKit/UIKit.h>
#import "YMLoginController.h"

@interface STAPIController : UIViewController <YMLoginControllerDelegate>

@property (nonatomic) BOOL attemptingSampleAPICall;
@property (weak, nonatomic) IBOutlet UILabel *tokenExists;

// Yammer Sample App

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Yammer Sample Code:
// Here's an example of attempting an API call.  First check to see if the authToken is available.
// If it's not available, then the user must login as the first step in acquiring the authToken.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)attemptShareToYammer:(id)sender;

// This is the direct call to start the login flow (for testing purposes)
- (IBAction)login:(id)sender;

// This deletes the authToken from the keychain (for testing purposes)
- (IBAction)deleteToken:(id)sender;

// This clears the sample API call JSON results from the text field on the iPad. (for testing API calls)
- (IBAction)clearResults:(id)sender;

@end

#endif
