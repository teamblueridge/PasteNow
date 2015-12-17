//
//  CreateViewController.h
//  PasteIt
//
//  Created by Simon Sickle on 12/16/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "HUD.h"

@interface CreateViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    NSArray *prettyLanguages;
    NSArray *uglyLanguages;
    NSMutableData *responseData;
    NSString *lang;
}

@property (strong, nonatomic) NSString *replyID;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *authorField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextView *pasteContent;

@end