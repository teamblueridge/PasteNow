//
//  DetailViewController.m
//  PasteIt
//
//  Created by Simon Sickle on 11/27/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import "DetailViewController.h"
#import "HUD.h"

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    if (self.pasteID) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *url = [NSString stringWithFormat:@"https://paste.teamblueridge.org/api/paste/%@/?apikey=teamblueridgepaste", self.pasteID];
        NSURLSession *session2 = [NSURLSession sharedSession];
        [[session2 dataTaskWithURL:[NSURL URLWithString:url]
                 completionHandler:^(NSData *data, NSURLResponse *response,NSError *error) {
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                     
                     paste = [json objectForKey:@"raw"];
                     author = [json objectForKey:@"name"];
                     language = [json objectForKey:@"lang"];
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.detailTextView.text = paste;
                         self.detailAuthorLabel.text = [NSString stringWithFormat:@"Author: %@", author];
                         self.detailLanguageLabel.text = [NSString stringWithFormat:@"Language: %@", language];
                         [HUD hideUIBlockingIndicator];
                     });
                 }
          ] resume];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [HUD showUIBlockingIndicatorWithText:@"Downloading Paste Data"];
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
