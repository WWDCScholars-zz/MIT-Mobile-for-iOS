#import <UIKit/UIKit.h>
#import "MITMobiusResource.h"

@interface MITMobiusRootPhoneViewController : UIViewController

@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,weak) IBOutlet UIView *helpTextView;
@property(nonatomic,weak) IBOutlet UIView *contentContainerView;
@property(nonatomic,weak) IBOutlet UIView *mapViewContainer;
@property(nonatomic,weak) IBOutlet UIView *tableViewContainer;

@end

@protocol MITMobiusRoomDataSource <NSObject>

@required

- (NSArray *)allRooms;
- (NSArray *)resourcesForRoom:(NSString *)room;

@end