
#import "MITDateNavigationBarView.h"

@implementation MITDateNavigationBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setTintColor:(UIColor *)tintColor {
    self.previousDateButton.tintColor = tintColor;
    self.nextDateButton.tintColor = tintColor;
    self.showDateControlButton.tintColor = tintColor;
    [super setTintColor:tintColor];
}

@end