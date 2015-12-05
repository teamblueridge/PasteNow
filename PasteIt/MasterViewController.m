//
//  MasterViewController.m
//  PasteIt
//
//  Created by Simon Sickle on 11/27/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "HistoryViewController.h"
#import "CreateViewController.h"

#import "HUD.h"

@implementation MasterViewController

- (void)viewDidAppear:(BOOL)animated {
    if (!recents)
    {
        [self getPastes];
    }
}

- (void)getPastes {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if (![self.refreshControl isRefreshing])
        [HUD showUIBlockingIndicatorWithText:@"Downloading Pastes"];

    // Set up the detail view controller
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // Download JSON
    NSString *url = @"https://paste.teamblueridge.org/api/recent/?apikey=teamblueridgepaste";
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // Turn network indicator off
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                // Set recents from json object
                recents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                // Update UI in another thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    // If the app is refreshing, there is no blocking indicator
                    if (![self.refreshControl isRefreshing])
                        [HUD hideUIBlockingIndicator];
                    
                    // Reload the table
                    [self.tableView reloadData];
                    
                    // If app is refreshing, stop the refresh
                    if ([self.refreshControl isRefreshing]) {
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"MMM d, h:mm a"];
                        
                        // Add title with time of last refresh
                        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
                        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:nil];
                        self.refreshControl.attributedTitle = attributedTitle;
                        
                        // End the refreshing
                        [self.refreshControl endRefreshing];
                    }
                });
            }] resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add pull down to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                         action:@selector(getPastes)
                         forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        // Set the pasteID for the detail view to grab data
        controller.pasteID =  [[recents objectAtIndex:indexPath.row] objectForKey:@"pid"];
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    } else if ([[segue identifier] isEqualToString:@"showHistory"]) {
        // Show history
        NSLog(@"Showing history");
        HistoryViewController *controller = (HistoryViewController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    } else if ([[segue identifier] isEqualToString:@"showCreate"]) {
        // Show add new
        CreateViewController *controller = (CreateViewController *)[[segue destinationViewController] topViewController];
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
    
    // Set the title of the cell
    cell.textLabel.text = [[recents objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
