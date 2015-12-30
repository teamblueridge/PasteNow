//
//  MasterViewController.m
//  PasteIt
//
//  Created by Simon Sickle on 12/16/15.
//  Copyright © 2015 Simon Sickle. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "HUD.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the detail view controller
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getPastes) forControlEvents:UIControlEventValueChanged];
    
    // Get site URL and such if not present already
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"siteurl"])
    {
        // Write the defaults
        [userDefaults setObject:@"https://paste.teamblueridge.org" forKey:@"siteurl"];
        [userDefaults setObject:@"teamblueridgepaste" forKey:@"apikey"];
        [userDefaults synchronize];
    }
    
    if (![userDefaults objectForKey:@"mainScreenPref"])
    {
        [userDefaults setObject:@"recent" forKey:@"mainScreenPref"];
        [userDefaults synchronize];
    }
    
    if ([[userDefaults objectForKey:@"mainScreenPref"] isEqualToString:@"trending"])
    {
        self.title = @"Trending Pastes";
    }
    
    // Set local variables for site and api from user defaults
    siteURL = [userDefaults objectForKey:@"siteurl"];
    apikey = [userDefaults objectForKey:@"apikey"];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    Reachability *hostReachability = [Reachability reachabilityWithHostName:siteURL];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable || hostReachability == NotReachable) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"Could not connect to the internet. App will not function" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:okButton];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
        
        return;
    }

    if (!recents)
    {
        [self getPastes];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"mainScreenPref"] isEqualToString:@"trending"])
    {
        self.title = @"Trending Pastes";
    } else {
        self.title = @"Recent Pastes";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPastes {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"Could not connect to the internet. App will not function" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:okButton];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            [self presentViewController:alert animated:YES completion:nil];
        });
        
        return;
    }

    // Alert user to network usage
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // If we arent refreshing, show a notification of loading
    if (![self.refreshControl isRefreshing])
        [HUD showUIBlockingIndicatorWithText:@"Downloading Pastes"];
    
    // Set up the URL
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"%@/api/%@/", siteURL, [userDefaults objectForKey:@"mainScreenPref" ]];
    
    // Check for API Key that isn't empty
    if (![apikey isEqualToString:@""])
        url = [NSString stringWithFormat:@"%@?apikey=%@", url, apikey];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:url]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        // Set the paste ID so the detail view knows what to open
        [controller setPasteID:[[recents objectAtIndex:indexPath.row] objectForKey:@"pid"]];
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = [[recents objectAtIndex:indexPath.row] objectForKey:@"title"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

@end
