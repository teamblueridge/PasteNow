//
//  DetailViewController.m
//  PasteIt
//
//  Created by Simon Sickle on 12/16/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import "DetailViewController.h"
#import "CreateViewController.h"
#import "HUD.h"

@interface DetailViewController ()

@end

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
    // Update the user interface for the detail item.
    if (self.pasteID) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [HUD showUIBlockingIndicatorWithText:@"Downloading Paste Data"];
        NSLog(@"%@", self.pasteID);
        
        // Set up the URL
        NSString *url = [NSString stringWithFormat:@"%@/api/paste/%@/", siteURL, self.pasteID];
        
        // Check for API Key that isn't empty
        if (![apikey isEqualToString:@""])
            url = [NSString stringWithFormat:@"%@?apikey=%@", url, apikey];

        NSURLSession *session2 = [NSURLSession sharedSession];
        [[session2 dataTaskWithURL:[NSURL URLWithString:url]
                 completionHandler:^(NSData *data, NSURLResponse *response,NSError *error) {
                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         self.pasteContents.text = [json objectForKey:@"raw"];
                         self.authorLabel.text = [NSString stringWithFormat:@"Author: %@", [json objectForKey:@"name"]];
                         [self.titleLabel setText:[json objectForKey:@"title"]];
                         self.languageLabel.text = [NSString stringWithFormat:@"Language: %@", [json objectForKey:@"lang"]];
                         [HUD hideUIBlockingIndicator];
                     });
                 }
          ] resume];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
    
    // Configure the detail view
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showCreate"]) {
        CreateViewController *controller = (CreateViewController *)[[segue destinationViewController] topViewController];
        [controller setReplyID:self.pasteID];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


@end
