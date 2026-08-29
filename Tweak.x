#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <objc/runtime.h>

// Увеличенные отступы (16pt), чтобы разница была видна сразу и четко
static const CGFloat kLeadingOffsetX  = 16.0;
static const CGFloat kTrailingOffsetX = 16.0;
static const CGFloat kVerticalOffsetY = 2.0;

static void applyOffsetsToStatusBar(UIView *bar) {
    if (!bar) return;

    NSDictionary *regions = nil;
    if ([bar respondsToSelector:@selector(regions)]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        regions = [bar performSelector:@selector(regions)];
        #pragma clang diagnostic pop
    } else {
        @try {
            regions = [bar valueForKey:@"_regions"];
        } @catch (id e) {}
    }

    if (![regions isKindOfClass:[NSDictionary class]]) return;

    for (NSString *key in regions) {
        id region = regions[key];
        NSString *identifier = nil;
        if ([region respondsToSelector:@selector(identifier)]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            identifier = [region performSelector:@selector(identifier)];
            #pragma clang diagnostic pop
        }
        if (!identifier || identifier.length == 0) {
            identifier = key;
        }

        UIView *contentView = nil;
        if ([region respondsToSelector:@selector(contentView)]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            contentView = [region performSelector:@selector(contentView)];
            #pragma clang diagnostic pop
        }
        if (!contentView || ![contentView isKindOfClass:[UIView class]]) continue;

        // Время (левая сторона)
        if ([identifier isEqualToString:@"leading"] ||
            [identifier rangeOfString:@"leading" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            contentView.transform = CGAffineTransformMakeTranslation(kLeadingOffsetX, kVerticalOffsetY);
        }
        // Сеть, Wi-Fi, Батарея (правая сторона)
        else if ([identifier isEqualToString:@"trailing"] ||
                   [identifier rangeOfString:@"trailing" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            contentView.transform = CGAffineTransformMakeTranslation(-kTrailingOffsetX, kVerticalOffsetY);
        }
    }
}

%group SpringBoardHooks

%hook STUIStatusBar

- (void)layoutSubviews {
    %orig;
    applyOffsetsToStatusBar(self);
}

%end

%hook STUIStatusBarVisualProvider_Split

- (struct NSDirectionalEdgeInsets)edgeInsets {
    struct NSDirectionalEdgeInsets insets = %orig;
    insets.leading += kLeadingOffsetX;
    insets.trailing += kTrailingOffsetX;
    return insets;
}

%end

%end

%group UIKitHooks

%hook _UIStatusBar

- (void)layoutSubviews {
    %orig;
    applyOffsetsToStatusBar(self);
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

%end

%ctor {
    // В iOS 16 статус-бар SpringBoard вынесен в SystemStatusUI.framework
    dlopen("/System/Library/PrivateFrameworks/SystemStatusUI.framework/SystemStatusUI", RTLD_NOW);

    if (objc_getClass("STUIStatusBar")) {
        %init(SpringBoardHooks);
    }

    if (objc_getClass("_UIStatusBar")) {
        %init(UIKitHooks);
    }
}
