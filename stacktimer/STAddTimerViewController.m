//
//  STAddTimerViewController.m
//  stacktimer
//
//  Created by Niket Shah on 18/10/2014.
//  Copyright (c) 2014 Niket Shah. All rights reserved.
//

#import "STAddTimerViewController.h"
#import "STRoutine.h"
#import "Timer.h"

@interface STAddTimerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end

@implementation STAddTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    STRoutine *routine = [[STRoutine alloc] init];
    Timer *timer = [Timer MR_createEntity];
    int countdownDuration = (int)self.timePicker.countDownDuration;
    int time = countdownDuration - (countdownDuration % 60);
    timer.time = [NSString stringWithFormat:@"%d", time * 1000];
    [routine addTimer:timer toRoutineWithName:self.nameForRoutine withCompletionBlock:^(BOOL success) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
