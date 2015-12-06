//
//  CreateViewController.m
//  PasteIt
//
//  Created by Simon Sickle on 12/3/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import "MasterViewController.h"
#import "CreateViewController.h"
#import "HUD.h"


@implementation CreateViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    _languages = @[@"CPP", @"Plain Text"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return _languages.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return _languages[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    NSLog(@"Lang selected");
}
@end