//
//  DetailViewController.h
//  PasteIt
//
//  Created by Simon Sickle on 12/16/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController {
    NSString *siteURL;
    NSString *apikey;
}

@property (strong, nonatomic) NSObject *detailItem;
@property (strong, nonatomic) NSString *pasteID;

@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UITextView *pasteContents;

@end

