//
//  MasterViewController.h
//  PasteIt
//
//  Created by Simon Sickle on 11/27/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController {
    NSArray *recents;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) UIProgressView *progressBar;
@property (nonatomic, retain) NSMutableData *resourceData;
@property (nonatomic, retain) NSNumber *filesize;

@end