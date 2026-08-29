#import <UIKit/UIKit.h>

@interface _UIStatusBarRegion : NSObject
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic) UIOffset offset;
@property (nonatomic) NSDirectionalEdgeInsets edgeInsets;
@end

@interface _UIStatusBarVisualProvider_Split : NSObject
+ (double)height;
- (struct NSDirectionalEdgeInsets)edgeInsets;
- (double)leadingItemSpacing;
- (double)trailingItemSpacing;
@end

// Безопасные отступы для iPhone X под стиль iPhone 15/16 Pro Max
static const CGFloat kLeadingOffsetX  = 8.0;   // Сдвиг времени вправо от угла
static const CGFloat kTrailingOffsetX = 7.0;   // Сдвиг батарейного блока влево от угла
static const CGFloat kVerticalOffsetY = 1.5;   // Небольшое вертикальное центрирование в ушах

%hook _UIStatusBarRegion

- (struct UIOffset)offset {
    struct UIOffset origOffset = %orig;
    
    // Левая зона (Время)
    if ([self.identifier isEqualToString:@"leading"]) {
        origOffset.horizontal += kLeadingOffsetX;
        origOffset.vertical += kVerticalOffsetY;
    }
    // Правая зона (Батарея, Wi-Fi, Сигнал сотовой сети)
    else if ([self.identifier isEqualToString:@"trailing"]) {
        origOffset.horizontal -= kTrailingOffsetX;
        origOffset.vertical += kVerticalOffsetY;
    }
    
    return origOffset;
}

%end

%hook _UIStatusBarVisualProvider_Split

// Безопасное расширение внутренних отступов визуального провайдера
- (struct NSDirectionalEdgeInsets)edgeInsets {
    struct NSDirectionalEdgeInsets insets = %orig;
    insets.leading += kLeadingOffsetX;
    insets.trailing += kTrailingOffsetX;
    return insets;
}

%end
