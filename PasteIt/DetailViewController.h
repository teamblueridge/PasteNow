//
//  DetailViewController.h
//  PasteIt
//
//  Created by Simon Sickle on 11/27/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailViewController : UIViewController {
    NSString *paste;
    NSString *author;
    NSString *language;
}

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLanguageLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (strong, nonatomic) NSString *pasteID;

@end

