#import "MITAcademicHolidaysCalendarViewController.h"
#import "MITCalendarManager.h"
#import "MITCalendarWebservices.h"
#import "Foundation+MITAdditions.h"

static NSString *const kMITHolidayCellName = @"kHolidayCellName";

@interface MITAcademicHolidaysCalendarViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) MITCalendarsCalendar *holidaysCalendar;
@property (nonatomic, strong) NSArray *events;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation MITAcademicHolidaysCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDateFormatter];
    
    [[MITCalendarManager sharedManager] getCalendarsCompletion:^(MITMasterCalendar *masterCalendar, NSError *error) {
        if (masterCalendar) {
            self.holidaysCalendar = masterCalendar.academicHolidaysCalendar;
            self.title = self.holidaysCalendar.name;
            [self loadHolidays];
        }
        else {
            NSLog(@"Error loading calendars: %@", error);
        }
    }];
}

- (void)setupDateFormatter
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"MMMM dd"];
}

- (void)loadHolidays
{
    [MITCalendarWebservices getEventsForCalendar:self.holidaysCalendar
                                      completion:^(NSArray *events, NSError *error) {
        
      self.activityIndicator.hidden = YES;
        if (events) {
            self.events = events;
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error fetching holidays calendar: %@", error);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.events count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMITHolidayCellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kMITHolidayCellName];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    }
    
    MITCalendarsEvent *event = self.events[indexPath.row];
    
    cell.textLabel.text = event.title;
    cell.detailTextLabel.text = [self dateStringForHolidayEvent:event];
    
    return cell;
}

- (NSString *)dateStringForHolidayEvent:(MITCalendarsEvent *)event
{
    NSString *dateString = [self.dateFormatter stringFromDate:event.startAt];
    
    if (![event.endAt isEqualToDate:event.startAt]) {
        dateString = [NSString stringWithFormat:@"%@ - %@", dateString, [self.dateFormatter stringFromDate:event.endAt]];
    }
    
    return dateString;
}

@end
