//
//  CreateViewController.h
//  PasteIt
//
//  Created by Simon Sickle on 12/3/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CreateViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    NSArray *prettyLanguages;
    NSArray *uglyLanguages;
    NSString *lang;
    IBOutlet UITextField *pasteTitle;
    IBOutlet UITextField *pasteAuthor;
    IBOutlet UIPickerView *pickerView;
    IBOutlet UITextView *pasteContent;
    NSMutableData *responseData;
}

@end