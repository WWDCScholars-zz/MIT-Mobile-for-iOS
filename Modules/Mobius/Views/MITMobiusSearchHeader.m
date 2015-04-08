#import "MITMobiusSearchHeader.h"
#import "UIKit+MITAdditions.h"

@interface MITMobiusSearchHeader ()
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopStatusLabel;
@end

@implementation MITMobiusSearchHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

+ (UINib *)searchHeaderNib
{
    return [UINib nibWithNibName:self.searchHeaderNibName bundle:nil];
}

+ (NSString *)searchHeaderNibName
{
    return @"MITMobiusSearchHeader";
}

- (void)updateConstraints
{
    self.shopNameLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.shopNameLabel.frame);
    self.shopHoursLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.shopHoursLabel.frame);
    self.shopStatusLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.shopStatusLabel.frame);
    [super updateConstraints];
}

- (void)setShopName:(NSString *)shopName
{
    if (![_shopName isEqualToString:shopName]) {
        _shopName = [shopName copy];
        _shopNameLabel.text = _shopName;
    }
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)setShopHours:(NSString *)shopHours
{
    if (![_shopHours isEqualToString:shopHours]) {
        _shopHours = [shopHours copy];
        _shopHoursLabel.text = _shopHours;
    }
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)setShopStatus:(NSString *)shopStatus
{
    if (![_shopStatus isEqualToString:shopStatus]) {
        _shopStatus = [shopStatus copy];
        
        if ([shopStatus caseInsensitiveCompare:@"open"] == NSOrderedSame) {
            _shopStatusLabel.textColor = [UIColor mit_openGreenColor];
        } else if ([shopStatus caseInsensitiveCompare:@"closed"] == NSOrderedSame) {
            _shopStatusLabel.textColor = [UIColor mit_closedRedColor];
        }
        _shopStatusLabel.text = _shopStatus;
    }
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}
@end
