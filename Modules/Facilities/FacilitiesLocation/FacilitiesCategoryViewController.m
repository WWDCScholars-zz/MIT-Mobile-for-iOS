#import "FacilitiesCategoryViewController.h"

#import "FacilitiesCategory.h"
#import "FacilitiesConstants.h"
#import "FacilitiesLocation.h"
#import "FacilitiesLocationData.h"
#import "FacilitiesLocationViewController.h"
#import "FacilitiesRoomViewController.h"
#import "FacilitiesTypeViewController.h"
#import "FacilitiesUserLocationViewController.h"
#import "HighlightTableViewCell.h"
#import "MITLoadingActivityView.h"
#import "UIKit+MITAdditions.h"


@interface FacilitiesCategoryViewController ()
- (BOOL)shouldShowLocationSection;
- (NSArray*)dataForMainTableView;
- (void)configureMainTableCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)resultsForSearchString:(NSString*)searchText;
- (void)configureSearchCell:(HighlightTableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath;
@end

@implementation FacilitiesCategoryViewController
@synthesize tableView = _tableView;
@synthesize loadingView = _loadingView;
@synthesize locationData = _locationData;
@synthesize searchString = _searchString;

@dynamic cachedData;
@dynamic filteredData;
@dynamic filterPredicate;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Where is it?";
        self.locationData = [FacilitiesLocationData sharedData];
        self.filterPredicate = [NSPredicate predicateWithFormat:@"locations.@count > 0"];
    }
    return self;
}

- (void)dealloc
{
    self.tableView = nil;
    self.cachedData = nil;
	self.filteredData = nil;
	self.locationData = nil;
    self.loadingView = nil;
    self.searchString = nil;
    self.filterPredicate = nil;
    self.cachedData = nil;
    self.filteredData = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)loadView {
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    
    UIView *mainView = [[[UIView alloc] initWithFrame:screenFrame] autorelease];
    mainView.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                 UIViewAutoresizingFlexibleWidth);
    mainView.autoresizesSubviews = YES;
    mainView.backgroundColor = [UIColor clearColor];
    
    
    CGRect searchBarFrame = CGRectZero;
    
    {
        UISearchBar *searchBar = [[[UISearchBar alloc] init] autorelease];
        searchBar.delegate = self;
        searchBar.barStyle = UIBarStyleBlackOpaque;
        
        UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                                         contentsController:self];
        searchController.delegate = self;
        searchController.searchResultsDataSource = self;
        searchController.searchResultsDelegate = self;
        
        [searchBar sizeToFit];
        searchBarFrame = searchBar.frame;
        [mainView addSubview:searchBar];
    }
    
    {
        CGRect tableRect = screenFrame;
        tableRect.origin = CGPointMake(0, searchBarFrame.size.height);
        tableRect.size.height -= searchBarFrame.size.height;
        
        UITableView *tableView = [[[UITableView alloc] initWithFrame: tableRect
                                                               style: UITableViewStyleGrouped] autorelease];
        [tableView applyStandardColors];
        
        tableView.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                           UIViewAutoresizingFlexibleWidth);
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.hidden = YES;
        tableView.scrollEnabled = YES;
        tableView.autoresizesSubviews = YES;
        
        self.tableView = tableView;
        [mainView addSubview:tableView];
    }
    
    
    {
        CGRect loadingFrame = screenFrame;
        loadingFrame.origin = CGPointMake(0, searchBarFrame.size.height);
        loadingFrame.size.height -= searchBarFrame.size.height;
        
        MITLoadingActivityView *loadingView = [[[MITLoadingActivityView alloc] initWithFrame:loadingFrame] autorelease];
        loadingView.autoresizingMask = (UIViewAutoresizingFlexibleHeight |
                                             UIViewAutoresizingFlexibleWidth);
        loadingView.backgroundColor = [UIColor redColor];
        
        self.loadingView = loadingView;
        [mainView insertSubview:loadingView
                   aboveSubview:self.tableView];
    }
    
    self.view = mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = [backButton autorelease];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView = nil;
    self.cachedData = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.locationData addObserver:self
                         withBlock:^(NSString *notification, BOOL updated, id userData) {
                             if ((notification == nil) || [userData isEqualToString:FacilitiesCategoriesKey]) {
                                 [self.loadingView removeFromSuperview];
                                 self.loadingView = nil;
                                 self.tableView.hidden = NO;
                                 
                                 if ((self.cachedData == nil) || updated) {
                                     self.cachedData = nil;
                                     [self.tableView reloadData];
                                 }
                             }
                         }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.locationData removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Private Methods
- (BOOL)shouldShowLocationSection {
    if ((self.cachedData == nil) || ([self.cachedData count] == 0)) {
        return NO;
    } else {
        return [CLLocationManager locationServicesEnabled];
    }
}


#pragma mark - Public Methods
- (NSArray*)dataForMainTableView {
    NSPredicate *searchPred = [NSPredicate predicateWithValue:YES];
    NSArray *data = [self.locationData categoriesMatchingPredicate:searchPred];
    data = [data sortedArrayUsingComparator: ^(id obj1, id obj2) {
        FacilitiesCategory *c1 = (FacilitiesCategory*)obj1;
        FacilitiesCategory *c2 = (FacilitiesCategory*)obj2;
        
        return [c1.name compare:c2.name];
    }];
    
    return data;
}

- (NSArray*)resultsForSearchString:(NSString *)searchText {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS [c] %@",searchText];
    NSArray *results = [self.locationData locationsMatchingPredicate:searchPredicate];
    
    results = [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *key1 = [obj1 valueForKey:@"name"];
        NSString *key2 = [obj2 valueForKey:@"name"];

        NSRange matchRange1 = [key1 rangeOfString:searchText
                                          options:NSCaseInsensitiveSearch];
        NSRange matchRange2 = [key2 rangeOfString:searchText
                                          options:NSCaseInsensitiveSearch];
        
        if (matchRange1.location > matchRange2.location) {
            return NSOrderedDescending;
        } else if (matchRange1.location < matchRange2.location) {
            return NSOrderedAscending;
        }
        
        
        matchRange1 = [key1 rangeOfString:searchText
                                  options:NSCaseInsensitiveSearch];
        matchRange2 = [key2 rangeOfString:searchText
                                  options:NSCaseInsensitiveSearch];
        if (matchRange1.location > matchRange2.location) {
            return NSOrderedDescending;
        } else if (matchRange1.location < matchRange2.location) {
            return NSOrderedAscending;
        }
        
        return [key1 caseInsensitiveCompare:key2];
    }];
    
    return results;
}

- (void)configureMainTableCell:(UITableViewCell *)cell
                  forIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Use my location";
    } else {
        FacilitiesCategory *cat = (FacilitiesCategory*)[self.cachedData objectAtIndex:indexPath.row];
        cell.textLabel.text = cat.name;
    }
}

- (void)configureSearchCell:(HighlightTableViewCell *)cell
                forIndexPath:(NSIndexPath *)indexPath
{
    FacilitiesLocation *loc = (FacilitiesLocation*)[self.filteredData objectAtIndex:indexPath.row];
        
    cell.highlightLabel.searchString = self.searchString;
    cell.highlightLabel.text = loc.name;
}


#pragma mark - Dynamic Setters/Getters
- (void)setFilterPredicate:(NSPredicate *)filterPredicate {
    self.cachedData = nil;
    [_filterPredicate release];
    _filterPredicate = [filterPredicate retain];
}

- (NSPredicate*)filterPredicate {
    return _filterPredicate;
}

- (void)setCachedData:(NSArray *)cachedData {
    if (_cachedData != nil) {
        [_cachedData release];
    }
    
    _cachedData = [cachedData retain];
}

- (NSArray*)cachedData {
    if (_cachedData == nil) {
        [self setCachedData:[self dataForMainTableView]];
    }
    
    return _cachedData;
}

- (void)setFilteredData:(NSArray *)filteredData {
    [_filteredData release];
    _filteredData = [filteredData retain];
}

- (NSArray*)filteredData {
    if (_filteredData == nil) {
        [self setFilteredData:[self resultsForSearchString:self.searchString]];
    }
    
    return _filteredData;
}


#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *nextViewController = nil;
    
    if (tableView == self.tableView) {
        if ((indexPath.section == 0) && [self shouldShowLocationSection]) {
            nextViewController = [[[FacilitiesUserLocationViewController alloc] init] autorelease];
        } else {
            FacilitiesCategory *category = (FacilitiesCategory*)[self.cachedData objectAtIndex:indexPath.row];
            FacilitiesLocationViewController *controller = [[[FacilitiesLocationViewController alloc] init] autorelease];
            controller.category = category;
            nextViewController = controller;
        }
    } else {
        if (indexPath.row == 0) {
            FacilitiesTypeViewController *vc = [[[FacilitiesTypeViewController alloc] init] autorelease];
            vc.userData = [NSDictionary dictionaryWithObject: self.searchString
                                                      forKey: FacilitiesRequestLocationCustomKey];
            nextViewController = vc;
        } else {
            FacilitiesLocation *location = (FacilitiesLocation*)[self.filteredData objectAtIndex:(indexPath.row-1)];
            FacilitiesRoomViewController *controller = [[[FacilitiesRoomViewController alloc] init] autorelease];
            controller.location = location;
            nextViewController = controller;
        }
    }
    
    [self.navigationController pushViewController:nextViewController
                                         animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return ([self shouldShowLocationSection] ? 2 : 1);
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return ((section == 0) && [self shouldShowLocationSection]) ? 1 : [self.cachedData count];
    } else {
        return [self.filteredData count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *facilitiesIdentifier = @"facilitiesCell";
    static NSString *searchIdentifier = @"searchCell";
    
    if (tableView == self.tableView) {
        UITableViewCell *cell = nil;
        cell = [tableView dequeueReusableCellWithIdentifier:facilitiesIdentifier];
        
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:facilitiesIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        [self configureMainTableCell:cell 
                        forIndexPath:indexPath];
        return cell;
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        HighlightTableViewCell *hlCell = nil;
        hlCell = (HighlightTableViewCell*)[tableView dequeueReusableCellWithIdentifier:searchIdentifier];
        
        if (hlCell == nil) {
            hlCell = [[[HighlightTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                    reuseIdentifier:searchIdentifier] autorelease];
            
            hlCell.autoresizesSubviews = YES;
            hlCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if (indexPath.row == 0) {
            hlCell.highlightLabel.searchString = nil;
            hlCell.highlightLabel.text = [NSString stringWithFormat:@"Use: %@",self.searchString];
        } else {
            NSIndexPath *path = [NSIndexPath indexPathForRow:(indexPath.row-1)
                                                   inSection:indexPath.section];
            [self configureSearchCell:hlCell
                         forIndexPath:path];
        }
        
        
        return hlCell;
    } else {
        return nil;
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchString = searchText;
    self.filteredData = nil;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchDisplayController setActive:NO
                                   animated:YES];
}
@end