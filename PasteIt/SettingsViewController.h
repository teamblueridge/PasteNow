//
//  SettingsViewController.h
//  PasteIt
//
//  Created by Simon Sickle on 12/17/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HUD.h"

@interface SettingsViewController : UIViewController

@property (weak,nonatomic) IBOutlet UITextField *siteURL;
@property (weak,nonatomic) IBOutlet UITextField *apiKey;
@property (weak,nonatomic) IBOutlet UITextField *mainViewSelection;

@end