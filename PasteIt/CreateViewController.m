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
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     NSString *url = @"https://paste.teamblueridge.org/api/langs/?apikey=teamblueridgepaste";
     NSURLSession *session2 = [NSURLSession sharedSession];
     [[session2 dataTaskWithURL:[NSURL URLWithString:url]
              completionHandler:^(NSData *data, NSURLResponse *response,NSError *error) {
                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                  
                  // Set arrays for languages
                  prettyLanguages = [json allValues];
                  uglyLanguages = [json allKeys];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [pickerView reloadAllComponents];
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
    NSLog(@"Clicked submit");
    if (!pasteTitle || !pasteAuthor || !lang || !pasteContent)
    {
        NSLog(@"There is not a title, author, lang, or paste content");
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"https://paste.teamblueridge.org/api/create?apikey=teamblueridgepaste"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    
    NSString * params = [NSString stringWithFormat:@"text=%@&title=%@&name=%@&lang=%@",pasteContent.text, pasteTitle.text, pasteAuthor.text, lang];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }];
    
    [postDataTask resume];
}
@end