//
//  CreateViewController.h
//  PasteIt
//
//  Created by Simon Sickle on 12/3/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CreateViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UIPickerView *pickerView;
}

@property (strong, nonatomic) NSArray *languages;
@end