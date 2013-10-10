#import "MITMapCategoryBrowseController.h"
#import "MITMapModel.h"

typedef void (^MITMapCategorySelectionHandler)(NSOrderedSet *selectedPlaces);
static NSString* const MITMapCategoryViewAllText = @"View all on map";

@interface MITMapCategoryBrowseController ()
@property (nonatomic,copy) MITMapCategorySelectionHandler selectionBlock;
@property (nonatomic,strong) MITMapCategory *category;
@property (nonatomic,copy) NSOrderedSet *dataSource;

- (id)initWithCategory:(MITMapCategory*)category;
- (BOOL)isShowingCategories;
- (BOOL)isShowingPlaces;
@end

@implementation MITMapCategoryBrowseController
- (id)init
{
    self = [super init];
    if (self) {

    }

    return self;
}

- (id)init:(MITMapCategorySelectionHandler)placesSelected
{
    self = [self init];
    if (self) {
        _selectionBlock = [placesSelected copy];
    }

    return self;
}

- (id)initWithCategory:(MITMapCategory*)category
{
    self = [self init];
    if (self) {
        _category = category;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.category) {
        // We are about to appear and no parent category has been set.
        // Assume this mean we are the top-level object and show a list of
        // all categories.
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                    target:self
                                                                                    action:@selector(cancelItemTouched:)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        self.navigationItem.title = @"Browse";
        
        if (!self.dataSource) {
            [[MITMapModelController sharedController] categories:^(NSOrderedSet *objects, NSDate *lastUpdated, BOOL finished, NSError *error) {
                if (!error) {
                    if (![self.dataSource isEqualToOrderedSet:objects]) {
                        self.dataSource = objects;
                        [self.tableView reloadData];
                    }
                } else {
                    DDLogWarn(@"Failed to retreive category listing: %@",error);
                }
            }];
        }
    } else {
        // A category was set. If the category has subcategories, we should
        // show the subcategories, otherwise, grab the list of places which belong to the
        // assigned category and show them.
        self.navigationItem.title = self.category.name;
        
        if (!self.dataSource) {
            if ([self.category hasSubcategories]) {
                self.dataSource = self.category.subcategories;
            } else {
                [[MITMapModelController sharedController] placesInCategory:self.category
                                                                    loaded:^(NSOrderedSet *objects, NSDate *lastUpdated, BOOL finished, NSError *error) {
                                                                        if (!error) {
                                                                            if (![self.dataSource isEqualToOrderedSet:objects]) {
                                                                                self.dataSource = objects;
                                                                                [self.tableView reloadData];
                                                                            }
                                                                        } else {
                                                                            DDLogWarn(@"Failed to retreive category listing: %@",error);
                                                                        }
                                                                    }];
            }
        }
    }
}

- (IBAction)cancelItemTouched:(UIBarButtonItem*)doneItem
{
    if (self.selectionBlock) {
        self.selectionBlock(nil);
    }
}

- (BOOL)isShowingCategories
{
    return (!self.category || [self.category hasSubcategories]);
}

- (BOOL)isShowingPlaces
{
    return (self.category && ![self.category hasSubcategories]);
}

- (IBAction)showAllButtonTouched:(UIButton*)showAllButton
{
    if ([self isShowingPlaces] && self.selectionBlock) {
        self.selectionBlock(self.dataSource);
    }
}

#pragma mark - Table view data source
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self isShowingPlaces]) {
        UIButton *showAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        showAllButton.frame = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 0);
        showAllButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        showAllButton.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.95];
        showAllButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        showAllButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        showAllButton.contentEdgeInsets = UIEdgeInsetsMake(4, 8, 4, 8);

        [showAllButton setImage:[UIImage imageNamed:@"global/action-map"] forState:UIControlStateNormal];

        [showAllButton setTitle:MITMapCategoryViewAllText forState:UIControlStateNormal];
        [showAllButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        showAllButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8., 0, 0.);

        [showAllButton addTarget:self
                          action:@selector(showAllButtonTouched:)
                forControlEvents:UIControlEventTouchUpInside];

        return showAllButton;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.dataSource && [self isShowingPlaces]) {
        return [UIImage imageNamed:@"global/action-map"].size.height + 16.; // 8px inset on top and bottom of view
    } else {
        return 0.;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    // Use the older dequeue method here because we are using the UITableViewCellStyleSubtitle
    // style and not providing a subclass which overrides initWithStyle:reuseIdentifier:
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }


    if ([self isShowingCategories]) {
        MITMapCategory *category = self.dataSource[indexPath.row];
        cell.textLabel.text = category.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        NSInteger dataIndex = indexPath.row;
        // Otherwise, we are showing a category's places
        MITMapPlace *place = self.dataSource[dataIndex];
        cell.textLabel.text = place.name;
    }

    return cell;
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isShowingCategories]) {
        MITMapCategory *category = self.dataSource[indexPath.row];
        MITMapCategoryBrowseController *categoriesViewController = [[MITMapCategoryBrowseController alloc] initWithCategory:category];
        categoriesViewController.selectionBlock = self.selectionBlock;

        [self.navigationController pushViewController:categoriesViewController animated:YES];
    } else if (self.selectionBlock) {
        MITMapPlace *place = self.dataSource[indexPath.row];
        self.selectionBlock([NSOrderedSet orderedSetWithObject:place]);
    }
}

@end
