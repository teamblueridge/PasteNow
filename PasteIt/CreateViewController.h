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
#import "UIView+Toast.h"
#import "HUD.h"
#import "IQKeyboardManager.h"
#import "IQKeyboardReturnKeyHandler.h"
#import "IQDropDownTextField.h"
#import "IQUIView+IQKeyboardToolbar.h"


@interface CreateViewController : UIViewController {
    NSArray *prettyLanguages;
    NSArray *uglyLanguages;
    NSArray *expireArrayNames;
    NSArray *expireArrayValues;
    NSMutableData *responseData;
    NSString *lang;
    NSString *expireTime;
    NSString *siteURL;
    NSString *apikey;
}

@property (strong, nonatomic) NSString *replyID;
@property (weak, nonatomic) IQKeyboardReturnKeyHandler *returnKeyHandler;

@property (weak,nonatomic) IBOutlet UITextField *titleField;
@property (weak,nonatomic) IBOutlet UITextField *authorField;
@property (weak,nonatomic) IBOutlet IQDropDownTextField *expirePicker;
@property (weak,nonatomic) IBOutlet IQDropDownTextField *languagePicker;
@property (weak,nonatomic) IBOutlet UISwitch *privateSwitch;
@property (weak,nonatomic) IBOutlet UITextView *pasteContent;

@end