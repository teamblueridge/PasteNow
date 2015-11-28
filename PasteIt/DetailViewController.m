//
//  DetailViewController.m
//  PasteIt
//
//  Created by Simon Sickle on 11/27/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import "DetailViewController.h"

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
    NSLog(@"At config view");
    // Update the user interface for the detail item.
    
    if (self.pasteID) {
        NSLog(@"Set paste id");
//        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"https://paste.teamblueridge.org/api/paste/%@/?apikey=teamblueridgepaste", self.pasteID]];
        NSString *url = [NSString stringWithFormat:@"https://paste.teamblueridge.org/api/paste/%@/?apikey=teamblueridgepaste", self.pasteID];
//        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession]
//                                                  downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//                                                      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location] options:nil error:nil];
//                                                      
//                                                      paste = [json objectForKey:@"paste"];
//                                                      //self.detailDescriptionLabel.text = paste;
//                                                      self.detailTextView.text = paste;
//                                                  }];
//        [downloadTask resume];
        
        NSURLSession *session2 = [NSURLSession sharedSession];
        [[session2 dataTaskWithURL:[NSURL URLWithString:url]
                completionHandler:^(NSData *data, NSURLResponse *response,NSError *error) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    // Handle the response here
                    //paste = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        
        paste = [json objectForKey:@"paste"];
        //self.detailDescriptionLabel.text = paste;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.detailTextView.text = paste;
                    });

                }] resume];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
