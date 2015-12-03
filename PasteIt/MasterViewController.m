//
//  MasterViewController.m
//  PasteIt
//
//  Created by Simon Sickle on 11/27/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#include "HUD.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!recents)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [HUD showUIBlockingIndicatorWithText:@"Downloading Pastes"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    
    NSString *url = @"https://paste.teamblueridge.org/api/recent/?apikey=teamblueridgepaste";
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                recents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [HUD hideUIBlockingIndicator];
                    [self.tableView reloadData];
                });
      }] resume];

    
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.pasteID =  [[recents objectAtIndex:indexPath.row] objectForKey:@"pid"];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [[recents objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
