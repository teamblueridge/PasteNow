//
//  CreateViewController.m
//  PasteIt
//
//  Created by Simon Sickle on 12/16/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//


#import "CreateViewController.h"

@interface CreateViewController ()

@end

@implementation CreateViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Set border on textView
    UIColor *borderColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    _pasteContent.layer.borderColor = borderColor.CGColor;
    _pasteContent.layer.borderWidth = 1.0;
    _pasteContent.layer.cornerRadius = 5.0;
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return;
    }

    // Get site URL and such if not present already
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"siteurl"]) {
        // Write the defaults
        [userDefaults setObject:@"https://paste.scratchbook.ch/" forKey:@"siteurl"];
        [userDefaults setObject:@"deinemudda" forKey:@"apikey"];
        [userDefaults synchronize];
    } else {
        // Get already set values
        siteURL= [userDefaults objectForKey:@"siteurl"];
        apikey = [userDefaults objectForKey:@"apikey"];
        
        if ([siteURL isEqual:@"https://paste.teamblueridge.org"]) {
            [userDefaults setObject:@"https://paste.scratchbook.ch/" forKey:@"siteurl"];
            [userDefaults setObject:@"deinemudda" forKey:@"apikey"];
            [userDefaults synchronize];
        }
    }
    
    siteURL= [userDefaults objectForKey:@"siteurl"];
    apikey = [userDefaults objectForKey:@"apikey"];
    
    expireArrayNames = [NSArray arrayWithObjects:@"Burn on Reading", @"Keep Forever",@"5 Minutes",
                        @"1 Hour", @"1 Day", @"1 Week", @"1 Month", @"1 Year" ,nil];
    expireArrayValues = [NSArray arrayWithObjects:@"burn", @"0", @"5", @"60", @"1440", @"10080",
                         @"40320", @"483840", nil];
    [_expirePicker setItemList:expireArrayNames];
    _expirePicker.selectedItem = @"Keep Forever";
    
    expireTime = @"0";
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *url = [NSString stringWithFormat:@"%@/api/langs/", siteURL];
    if (![apikey isEqualToString:@""])
        url = [NSString stringWithFormat:@"%@?apikey=%@", url, apikey];
    
    [HUD showUIBlockingIndicatorWithText:@"Downloading languages from the web"];
    
    NSURLSession *session2 = [NSURLSession sharedSession];
    [[session2 dataTaskWithURL:[NSURL URLWithString:url]
             completionHandler:^(NSData *data, NSURLResponse *response,NSError *error) {
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                 
                 // Set arrays for languages
                 prettyLanguages = [json allValues];
                 uglyLanguages = [json allKeys];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [_languagePicker setItemList:prettyLanguages];
                     for (int i = 0; i < [uglyLanguages count]; i++)
                     {
                         if ([uglyLanguages[i] isEqualToString:@"text"])
                             _languagePicker.selectedItem = @"Plain Text";
                     }
                     lang = @"text";
                     [HUD hideUIBlockingIndicator];
                 });
             }
    ] resume];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"Could not connect to the internet. App will not function" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:okButton];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
        
        return;
    }

}

// Touches mean hide keyboard
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
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
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
//{
//    if (pickerView == self.languagePicker) {
//        return [prettyLanguages count];
//    } else if (pickerView == self.expirePicker) {
//        return [expireArrayNames count];
//    }
//    return 0;
//}

//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
//{
//    if (pickerView == self.languagePicker) {
//        return [prettyLanguages objectAtIndex:row];
//    } else if (pickerView == self.expirePicker) {
//        return [expireArrayNames objectAtIndex:row];
//    }
//    
//    return @"";
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
//{
//    if (pickerView == self.languagePicker) {
//        lang = [uglyLanguages objectAtIndex:row];
//    } else if (pickerView == self.expirePicker) {
//        expireTime = [expireArrayValues objectAtIndex:row];
//    }
//}

- (IBAction)sendPaste:(id)sender {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    Reachability *hostReachability = [Reachability reachabilityWithHostName:siteURL];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable || hostReachability == NotReachable) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"Could not connect to the internet. App will not function" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:okButton];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
        
        return;
    }
    
    // Set the language
    for (int i = 0; i < [uglyLanguages count]; i++) {
        if ([[_languagePicker selectedItem] isEqualToString:prettyLanguages[i]])
            lang = uglyLanguages[i];
    }
    
    // Set the expire time
    for (int i = 0; i < [expireArrayValues count]; i++) {
        if ([[_expirePicker selectedItem] isEqualToString:expireArrayNames[i]])
            expireTime = expireArrayValues[i];
    }

    if ([_titleField.text isEqualToString:@""] || [_authorField.text isEqualToString:@""] || [_pasteContent.text isEqualToString:@""])
    {
        // Alert the user with async toast
        dispatch_async(dispatch_get_main_queue(), ^{
            // toast with a specific duration and position
            [self.view makeToast:@"Either the title, author, or paste content field was empty..." duration:2.5 position:CSToastPositionCenter];
            
        });
        
        // Dont go any further
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSString *formatURL = [NSString stringWithFormat:@"%@/api/create/", siteURL];
    
    // Add the api key to the request
    if (![apikey isEqualToString:@""])
        formatURL = [NSString stringWithFormat:@"%@?apikey=%@", formatURL, apikey];

    NSURL *url = [NSURL URLWithString:formatURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    // Set the data to be set to the api
    NSString * params = [NSString stringWithFormat:@"text=%@&title=%@&name=%@&lang=%@&expire=%@",_pasteContent.text, _titleField.text, _authorField.text,
                         lang, expireTime];
    
    // Add reply ID if it exists
    if (self.replyID) {
         params = [NSString stringWithFormat:@"%@&reply=%@", params, self.replyID];
    }
    
    // Check if it is a private paste
    if ([_privateSwitch isOn]) {
        params = [NSString stringWithFormat:@"%@&private=1", params];
    }
    
    // Now set the body from the parameter string
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Run the task
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *webResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([webResponse containsString:@"paste contains blocked words"] || [webResponse isEqualToString:@""])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // toast with a specific duration and position
                [self.view makeToast:@"Your paste contains blocked words..." duration:2.5 position:CSToastPositionCenter];
                
            });
        } else if ([webResponse containsString:@"copy this URL, it will become invalid on visit: "]) {
            // If burn was used as expire, remove the crap data in front of the url
            NSRange replaceRange = [webResponse rangeOfString:@"copy this URL, it will become invalid on visit: "];
            if (replaceRange.location != NSNotFound){
                webResponse = [webResponse stringByReplacingCharactersInRange:replaceRange withString:@""];
            }
            
            // Copy to the clipboard
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = webResponse;
            
            // Notify the user in the UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"Paste was successfully submitted... The link is in your clipbloard. It will be removed after it is loaded on the site." duration:2.5 position:CSToastPositionCenter];
                
            });

        } else {
            // Copy to the clipboard
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = webResponse;
            
            // Notify the user in the UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"Paste was successfully submitted... The link is in your clipbloard" duration:2.5 position:CSToastPositionCenter];
                
            });

        }
    }];
    [postDataTask resume];
}

@end
