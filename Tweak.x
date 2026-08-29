#import <UIKit/UIKit.h>

@interface _UIStatusBarRegion : NSObject
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) UIView *contentView;
@end

@interface _UIStatusBar : UIView
@property (nonatomic, strong, readonly) NSDictionary *regions;
@end

@interface _UIStatusBarVisualProvider_Split : NSObject
+ (double)height;
- (struct NSDirectionalEdgeInsets)edgeInsets;
@end

// Смещение для iPhone X:
// +12.0pt вправо для времени (слева)
// -12.0pt влево для сети/Wi-Fi/батареи (справа)
// +1.5pt вниз для центрирования по вертикали
static const CGFloat kLeadingOffsetX  = 12.0;
static const CGFloat kTrailingOffsetX = 12.0;
static const CGFloat kVerticalOffsetY = 1.5;

%hook _UIStatusBar

- (void)layoutSubviews {
    %orig;

    NSDictionary *regions = nil;
    if ([self respondsToSelector:@selector(regions)]) {
        regions = [self regions];
    } else {
        @try {
            regions = [self valueForKey:@"_regions"];
        } @catch (id e) {}
    }

    if ([regions isKindOfClass:[NSDictionary class]]) {
        for (NSString *key in regions) {
            id region = regions[key];
            NSString *identifier = nil;
            if ([region respondsToSelector:@selector(identifier)]) {
                identifier = [region identifier];
            }
            if (!identifier || identifier.length == 0) {
                identifier = key;
            }

            UIView *contentView = nil;
            if ([region respondsToSelector:@selector(contentView)]) {
                contentView = [region contentView];
            }

            if (!contentView) continue;

            // Время слева
            if ([identifier isEqualToString:@"leading"] ||
                [identifier rangeOfString:@"leading" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                contentView.transform = CGAffineTransformMakeTranslation(kLeadingOffsetX, kVerticalOffsetY);
            }
            // Связь, Wi-Fi и батарея справа
            else if ([identifier isEqualToString:@"trailing"] ||
                       [identifier rangeOfString:@"trailing" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                contentView.transform = CGAffineTransformMakeTranslation(-kTrailingOffsetX, kVerticalOffsetY);
            }
        }
    }
}

%end

%hook _UIStatusBarVisualProvider_Split

- (struct NSDirectionalEdgeInsets)edgeInsets {
    struct NSDirectionalEdgeInsets insets = %orig;
    insets.leading += kLeadingOffsetX;
    insets.trailing += kTrailingOffsetX;
    return insets;
}

%end
