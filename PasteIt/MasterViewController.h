//
//  MasterViewController.h
//  PasteIt
//
//  Created by Simon Sickle on 12/16/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController {
    NSArray *recents;
    NSString *siteURL;
    NSString *apikey;
}

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

