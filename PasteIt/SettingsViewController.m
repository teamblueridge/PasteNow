//
//  SettingsViewController.m
//  PasteIt
//
//  Created by Simon Sickle on 12/17/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIView+Toast.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"siteurl"])
    {
        // Write the defaults
        [userDefaults setObject:@"https://paste.teamblueridge.org" forKey:@"siteurl"];
        [userDefaults setObject:@"teamblueridgepaste" forKey:@"apikey"];
        [userDefaults synchronize];
    } else {
        // Get already set values
        [_siteURL setText: [userDefaults objectForKey:@"siteurl"]];
        [_apiKey setText: [userDefaults objectForKey:@"apikey"]];
    }
    
    if (![userDefaults objectForKey:@"mainScreenPref"])
    {
        [userDefaults setObject:@"recent" forKey:@"mainScreenPref"];
        [userDefaults synchronize];
    } else {
        [_mainViewSelection setText: [userDefaults objectForKey:@"mainScreenPref"]];
    }
}

- (IBAction)savePreferences:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject: [_siteURL text] forKey:@"siteurl"];
    [userDefaults setObject: [_apiKey text] forKey:@"apikey"];
    
    if ([_mainViewSelection.text containsString:@"trending"])
    {
        [userDefaults setObject:@"trending" forKey:@"mainScreenPref"];
    } else {
        [userDefaults setObject:@"recent" forKey:@"mainScreenPref"];
    }
    
    [userDefaults synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"Settings were saved sucessfully" duration:2.5 position:CSToastPositionBottom];
        
    });
}

@end