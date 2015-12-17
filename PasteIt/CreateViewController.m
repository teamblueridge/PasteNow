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
    
    // Get site URL and such if not present already
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"siteurl"])
    {
        // Write the defaults
        [userDefaults setObject:@"https://paste.teamblueridge.org" forKey:@"siteurl"];
        [userDefaults setObject:@"teamblueridgepaste" forKey:@"apikey"];
        [userDefaults synchronize];
    }
    
    siteURL = [userDefaults objectForKey:@"siteurl"];
    apikey = [userDefaults objectForKey:@"apikey"];
    
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
                     [_pickerView reloadAllComponents];
                     for (int i = 0; i < [uglyLanguages count]; i++)
                     {
                         if ([uglyLanguages[i] isEqualToString:@"text"])
                             [_pickerView selectRow:i inComponent:0 animated:NO];
                     }
                     lang = @"text";
                     [HUD hideUIBlockingIndicator];
                 });
             }
      ] resume];
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
    return [prettyLanguages count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [prettyLanguages objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    NSLog(@"Lang selected: %@", [uglyLanguages objectAtIndex:row]);
    lang = [uglyLanguages objectAtIndex:row];
}

- (IBAction)sendPaste:(id)sender {
    if (!_titleField || !_authorField || !lang || !_pasteContent)
    {
        NSLog(@"There is not a title, author, lang, or paste content");
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
    NSString * params = [NSString stringWithFormat:@"text=%@&title=%@&name=%@&lang=%@",_pasteContent.text, _titleField.text, _authorField.text, lang];
    
    // Add reply ID if it exists
    if (self.replyID){
         params = [NSString stringWithFormat:@"%@&reply=%@", params, self.replyID];
    }
   
    // Now set the body from the parameter string
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Run the task
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *webResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", webResponse);
        
        if ([webResponse containsString:@"paste contains blocked words"] || [webResponse isEqualToString:@""])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // toast with a specific duration and position
                [self.view makeToast:@"Your paste contains blocked words..." duration:2.5 position:CSToastPositionBottom];
                
            });
        } else {
            // Copy to clipboard
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // toast with a specific duration and position
                [self.view makeToast:@"Paste was successfully submitted..." duration:2.5 position:CSToastPositionBottom];
                
            });
        }
    }];
    [postDataTask resume];
}

@end