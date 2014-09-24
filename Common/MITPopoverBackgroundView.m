#import "MITPopoverBackgroundView.h"

#define CONTENT_INSET 0.0
#define CORNER_INSET 28.0
#define ARROW_BASE 37.0
#define ARROW_HEIGHT 13.0
#define CORNER_ARROW_OFFSET 13.0
#define BUBBLE_ARROW_NUMBER 26.0

static CGFloat TOP_CONTENT_INSET = 0;
static CGFloat LEFT_CONTENT_INSET = 0;
static CGFloat BOTTOM_CONTENT_INSET = 0;
static CGFloat RIGHT_CONTENT_INSET = 0;

#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

@interface MITPopoverBackgroundView()

@property (nonatomic, strong) UIImage *popoverBubbleImage;
@property (nonatomic, strong) UIImage *popoverArrowImage;

@end

@implementation MITPopoverBackgroundView

- (CGFloat)arrowOffset
{
    return _arrowOffset;
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
}

- (UIPopoverArrowDirection)arrowDirection
{
    return _arrowDirection;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(TOP_CONTENT_INSET, LEFT_CONTENT_INSET, BOTTOM_CONTENT_INSET, RIGHT_CONTENT_INSET);
}

+ (CGFloat)arrowHeight
{
    return ARROW_HEIGHT;
}

+ (CGFloat)arrowBase
{
    return ARROW_BASE;
}

static UIColor *popoverTintColor = nil;
+ (void)setTintColor:(UIColor *)tintColor
{
    popoverTintColor = tintColor;
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        NSInteger multiplier = 1;
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            multiplier = 1;
        } else {
            multiplier = 2;
        }
        CGFloat scale = [UIScreen mainScreen].scale;
        
        CGFloat cornerInset = CORNER_INSET / multiplier;
        
        UIImage *popOverImage = [UIImage imageNamed:@"_UIPopoverViewBlurMaskBackgroundArrowDown@2x"];
        
        CGFloat popOverImageWidth = popOverImage.size.width;
        CGFloat popOverImageHeight = popOverImage.size.height;
        
        // arrow is multiplied by 2 because the original image is @2x
        CGRect bubbleImageRect = CGRectMake(0, 0, popOverImageWidth, popOverImageHeight - ARROW_HEIGHT * multiplier);
        
        UIGraphicsBeginImageContextWithOptions(bubbleImageRect.size, NO, 0);
        [popOverImage drawAtPoint:CGPointZero];
        
        UIImage *croppedBubble = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // arrow is multiplied by 2 because the original image is @2x
        CGRect arrowImageRect = CGRectMake(popOverImageWidth/2 - ARROW_BASE, popOverImageHeight - (ARROW_HEIGHT * multiplier), ARROW_BASE*2, ARROW_HEIGHT * multiplier);
        
        UIGraphicsBeginImageContextWithOptions(arrowImageRect.size, NO, 0);
        
        [popOverImage drawAtPoint:(CGPoint){-arrowImageRect.origin.x, -arrowImageRect.origin.y}];
        
        UIImage *croppedArrow = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            croppedArrow = [[UIImage alloc] initWithCGImage: croppedArrow.CGImage
                                                      scale: scale * .5
                                                orientation: UIImageOrientationUp];
        }
        
        croppedBubble = [[UIImage alloc] initWithCGImage: croppedBubble.CGImage
                                                   scale: scale * multiplier
                                             orientation: UIImageOrientationUp];
        
        
        
        self.popoverBubbleImage = [croppedBubble resizableImageWithCapInsets:UIEdgeInsetsMake(cornerInset, cornerInset, cornerInset, cornerInset)];
        _popoverArrowBubbleView = [[UIImageView alloc] init];
        
        self.popoverArrowImage = croppedArrow;
        
        [self addSubview:_popoverArrowBubbleView];
        self.layer.shadowColor = [[UIColor clearColor] CGColor];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat _height = self.frame.size.height;
    CGFloat _width = self.frame.size.width;
    CGFloat _left = 0.0;
    CGFloat _top = 0.0;
    CGFloat _coordinate = 0.0;
    NSInteger multiplier = 1;
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        multiplier = 2;
    }
    
    UIImage *popoverArrowBubbleImage = [UIImage imageNamed:@"_UIPopoverViewBlurMaskBackgroundArrowDownRight@2x.png"];
    popoverArrowBubbleImage = [[UIImage alloc] initWithCGImage: popoverArrowBubbleImage.CGImage
                                                         scale: 1
                                                   orientation: UIImageOrientationUp];
    
    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionAny:
            break;
        case UIPopoverArrowDirectionUnknown:
            break;
            
        case UIPopoverArrowDirectionUp:
            if (self.frame.size.width/2 + self.arrowOffset < BUBBLE_ARROW_NUMBER|| self.frame.size.width/2 + self.arrowOffset + BUBBLE_ARROW_NUMBER > self.frame.size.width) {
                
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                _popoverArrowBubbleView.image = [popoverArrowBubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 56, 62)];
                
                NSInteger sign = 1;
                if (self.frame.size.width/2 + self.arrowOffset + BUBBLE_ARROW_NUMBER > self.frame.size.width) {
                    sign = -1;
                }
                CGAffineTransform scale = CGAffineTransformMakeScale(sign * .5, .5);
                CGAffineTransform transform = CGAffineTransformRotate(scale, -M_PI);
                _popoverArrowBubbleView.transform = transform;
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                
            } else {
                
                _coordinate = ((self.frame.size.width / 2) + self.arrowOffset - floor(ARROW_BASE / multiplier));
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(_width, _height), NO, 0);
                CGContextRef bitmap = UIGraphicsGetCurrentContext();
                CGContextDrawImage(bitmap, CGRectMake(_coordinate, 0, self.popoverArrowImage.size.width/2, self.popoverArrowImage.size.height/2), self.popoverArrowImage.CGImage);
                
                [self.popoverBubbleImage drawInRect:CGRectMake(0, ARROW_HEIGHT, _width, _height - ARROW_HEIGHT)];
                _popoverArrowBubbleView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
            
        case UIPopoverArrowDirectionDown:
            
            if (self.frame.size.width/2 + self.arrowOffset < BUBBLE_ARROW_NUMBER|| self.frame.size.width/2 + self.arrowOffset + BUBBLE_ARROW_NUMBER > self.frame.size.width) {
                
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                _popoverArrowBubbleView.image = [popoverArrowBubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 56, 62)];
                
                NSInteger sign = -1;
                if (self.frame.size.width/2 + self.arrowOffset + BUBBLE_ARROW_NUMBER > self.frame.size.width) {
                    sign = 1;
                }
                CGAffineTransform scale = CGAffineTransformMakeScale(sign * .5, .5);
                CGAffineTransform transform = CGAffineTransformRotate(scale, 0);
                _popoverArrowBubbleView.transform = transform;
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                
            } else {
                
                _coordinate = ((self.frame.size.width / 2) + self.arrowOffset + ceil(ARROW_BASE / multiplier));
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(_width, _height), NO, 0);
                CGContextRef bitmap = UIGraphicsGetCurrentContext();
                CGContextTranslateCTM(bitmap, 0, _height);
                CGContextRotateCTM(bitmap, M_PI);
                CGContextDrawImage(bitmap, CGRectMake(-_coordinate, 0, self.popoverArrowImage.size.width/2, self.popoverArrowImage.size.height/2), self.popoverArrowImage.CGImage);
                
                [self.popoverBubbleImage drawInRect:CGRectMake(-_width, ARROW_HEIGHT, _width, _height - ARROW_HEIGHT)];
                _popoverArrowBubbleView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
            
        case UIPopoverArrowDirectionLeft:
            
            if (self.frame.size.height/2 + self.arrowOffset < BUBBLE_ARROW_NUMBER|| self.frame.size.height/2 + self.arrowOffset + BUBBLE_ARROW_NUMBER > self.frame.size.height) {
                
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                _popoverArrowBubbleView.image = [popoverArrowBubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 56, 62)];
                
                NSInteger sign = -1;
                if (self.frame.size.height/2 + self.arrowOffset + BUBBLE_ARROW_NUMBER > self.frame.size.height) {
                    sign = 1;
                }
                CGAffineTransform scale = CGAffineTransformMakeScale(sign * .5, .5);
                CGAffineTransform transform = CGAffineTransformRotate(scale, sign*M_PI_2);
                _popoverArrowBubbleView.transform = transform;
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                
            } else {
                
                _coordinate = ((self.frame.size.height / 2) + self.arrowOffset + floor(ARROW_BASE / multiplier));
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(_width, _height), NO, 0);
                CGContextRef bitmap = UIGraphicsGetCurrentContext();
                CGContextRotateCTM(bitmap, -M_PI_2);
                CGContextDrawImage(bitmap, CGRectMake(-_coordinate, 0, self.popoverArrowImage.size.width/2, self.popoverArrowImage.size.height/2), self.popoverArrowImage.CGImage);
                
                [self.popoverBubbleImage drawInRect:CGRectMake(-_height, ARROW_HEIGHT, _height, _width - ARROW_HEIGHT)];
                _popoverArrowBubbleView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
            
        case UIPopoverArrowDirectionRight:
            
            if (self.frame.size.height/2 + self.arrowOffset < BUBBLE_ARROW_NUMBER|| self.frame.size.height/2 + self.arrowOffset + BUBBLE_ARROW_NUMBER > self.frame.size.height) {
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                _popoverArrowBubbleView.image = [popoverArrowBubbleImage resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 56, 62)];
                
                NSInteger sign = 1;
                if (self.frame.size.height/2 + self.arrowOffset + BUBBLE_ARROW_NUMBER > self.frame.size.height) {
                    sign = -1;
                }
                CGAffineTransform scale = CGAffineTransformMakeScale(sign * .5, .5);
                CGAffineTransform transform = CGAffineTransformRotate(scale, -sign*M_PI_2);
                _popoverArrowBubbleView.transform = transform;
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                
            } else {
                
                _coordinate = ((self.frame.size.height / 2) + self.arrowOffset - floor(ARROW_BASE / multiplier));
                _popoverArrowBubbleView.frame =  CGRectMake(_left, _top, _width, _height);
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(_width, _height), NO, 0);
                CGContextRef bitmap = UIGraphicsGetCurrentContext();
                CGContextRotateCTM(bitmap, M_PI_2);
                CGContextDrawImage(bitmap, CGRectMake(_coordinate, -_width, self.popoverArrowImage.size.width/2, self.popoverArrowImage.size.height/2), self.popoverArrowImage.CGImage);
                
                [self.popoverBubbleImage drawInRect:CGRectMake(_left, -_width + ARROW_HEIGHT, _height, _width - ARROW_HEIGHT)];
                _popoverArrowBubbleView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            break;
            
    }
    if (popoverTintColor) {
        _popoverArrowBubbleView.image = [_popoverArrowBubbleView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _popoverArrowBubbleView.tintColor = popoverTintColor;
    } else {
        _popoverArrowBubbleView.image = [_popoverArrowBubbleView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _popoverArrowBubbleView.tintColor = [UIColor whiteColor];
    }
}

@end