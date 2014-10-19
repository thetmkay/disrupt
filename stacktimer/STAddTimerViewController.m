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

@interface STAddTimerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic)  UIDatePicker *timePicker;
@property(retain, nonatomic) IBOutlet UIPickerView *pickerView;
@property(retain, nonatomic) NSMutableArray *hoursArray;
@property(retain, nonatomic) NSMutableArray *minsArray;
@property(retain, nonatomic) NSMutableArray *secsArray;

@end

@implementation STAddTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self setupArrays];
}

- (void)setupArrays {
    //initialize arrays
    self.hoursArray = [[NSMutableArray alloc] init];
    self.minsArray = [[NSMutableArray alloc] init];
    self.secsArray = [[NSMutableArray alloc] init];
    NSString *strVal = [[NSString alloc] init];
    
    for(int i=0; i<61; i++)
    {
        strVal = [NSString stringWithFormat:@"%d", i];
        
        //NSLog(@"strVal: %@", strVal);
        
        //Create array with 0-12 hours
        if (i < 13)
        {
            [self.hoursArray addObject:strVal];
        }
        
        //create arrays with 0-60 secs/mins
        [self.minsArray addObject:strVal];
        [self.secsArray addObject:strVal];
    }
    
    
    NSLog(@"[hoursArray count]: %ld", [self.hoursArray count]);
    NSLog(@"[minsArray count]: %ld", [self.minsArray count]);
    NSLog(@"[secsArray count]: %ld", [self.secsArray count]);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

// Method to define the numberOfRows in a component using the array.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent :(NSInteger)component
{
    if (component==0)
    {
        return [self.hoursArray count];
    }
    else if (component==1)
    {
        return [self.minsArray count];
    }
    else
    {
        return [self.secsArray count];
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [self.hoursArray objectAtIndex:row];
            break;
            
        case 1:
            return [self.minsArray objectAtIndex:row];
            
        case 2:
            return [self.secsArray objectAtIndex:row];
            
        default:
            return @"how did you call this?";
            break;
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
    STRoutine *routine = [[STRoutine alloc] init];
    Timer *timer = [Timer MR_createEntity];
    int time = [self getTimeInterval];
    timer.time = [NSString stringWithFormat:@"%d", time * 1000];
    [routine addTimer:timer toRoutineWithName:self.nameForRoutine withCompletionBlock:^(BOOL success) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (NSTimeInterval)getTimeInterval {
    NSInteger hours = [self.pickerView selectedRowInComponent:0];
    NSInteger mins = [self.pickerView selectedRowInComponent:1];
    NSInteger secs = [self.pickerView selectedRowInComponent:2];
    
    return (hours * 60 * 60) + (mins * 60) + secs;
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
