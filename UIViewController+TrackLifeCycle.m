//
//  UIViewController+TrackLifeCycle.m
//  NSIHackySack
//
//  Created by Michael Yau on 12/7/15.
//  Copyright © 2015 Michael Yau. All rights reserved.
//

#import "UIViewController+TrackLifeCycle.h"

#if DEBUG

#import <objc/runtime.h>
#import "NSILog.h"

const char kViewControllerWatcherKey;

@interface ViewControllerWatcher : NSObject
@property (nonatomic, copy, readonly) NSString *classString;
+ (instancetype)viewControllerWatcherWithClassString:(NSString *)classString;
@end

@implementation ViewControllerWatcher

#pragma mark - Dealloc watcher

+ (instancetype)viewControllerWatcherWithClassString:(NSString *)classString {
    return [[ViewControllerWatcher alloc] initWithClassString:classString];
}

- (id)initWithClassString:(NSString *)classString {
    self = [super init];
    if (!self) {
        return nil;
    }
    _classString = classString;
    return self;
}

- (void)dealloc {
    SLog(@"%@ dealloc", self.classString);
}

@end

@implementation UIViewController (TrackLifeCycle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        NSValue *loadViewSelector = [NSValue valueWithPointer:@selector(loadView)];
        NSValue *viewDidLoadSelector = [NSValue valueWithPointer:@selector(viewDidLoad)];
        NSValue *viewWillAppearSelector = [NSValue valueWithPointer:@selector(viewWillAppear:)];
        NSValue *viewDidAppearSelector = [NSValue valueWithPointer:@selector(viewDidAppear:)];
        NSValue *viewWillDisappearSelector = [NSValue valueWithPointer:@selector(viewWillDisappear:)];
        NSValue *viewDidDisappearSelector = [NSValue valueWithPointer:@selector(viewDidDisappear:)];
        
        NSArray *originalSelectors = @[loadViewSelector,
                                       viewDidLoadSelector,
                                       viewWillAppearSelector,
                                       viewDidAppearSelector,
                                       viewWillDisappearSelector,
                                       viewDidDisappearSelector];
        
        NSValue *nsi_loadViewSelector = [NSValue valueWithPointer:@selector(nsi_loadView)];
        NSValue *nsi_viewDidLoadSelector = [NSValue valueWithPointer:@selector(nsi_viewDidLoad)];
        NSValue *nsi_viewWillAppearSelector = [NSValue valueWithPointer:@selector(nsi_viewWillAppear:)];
        NSValue *nsi_viewDidAppearSelector = [NSValue valueWithPointer:@selector(nsi_viewDidAppear:)];
        NSValue *nsi_viewWillDisappearSelector = [NSValue valueWithPointer:@selector(nsi_viewWillDisappear:)];
        NSValue *nsi_viewDidDisappearSelector = [NSValue valueWithPointer:@selector(nsi_viewDidDisappear:)];
        
        NSArray *swizzledSelectors = @[nsi_loadViewSelector,
                                       nsi_viewDidLoadSelector,
                                       nsi_viewWillAppearSelector,
                                       nsi_viewDidAppearSelector,
                                       nsi_viewWillDisappearSelector,
                                       nsi_viewDidDisappearSelector];
        
        for (int i = 0; i < [originalSelectors count]; i++) {
            SEL originalSelector = [originalSelectors[i] pointerValue];
            SEL swizzledSelector = [swizzledSelectors[i] pointerValue];
            swizzleMethod(class, originalSelector, swizzledSelector);
        }
    });
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Method Swizzling Life Cycle

- (void)nsi_loadView {
    SLog(@"%@ loadView", NSStringFromClass([self class]));
    ViewControllerWatcher *watcher = [ViewControllerWatcher viewControllerWatcherWithClassString:NSStringFromClass([self class])];
    objc_setAssociatedObject(self, &kViewControllerWatcherKey, watcher, OBJC_ASSOCIATION_RETAIN);
    [self nsi_loadView];
}

- (void)nsi_viewDidLoad {
    SLog(@"%@ viewDidLoad", NSStringFromClass([self class]));
    [self nsi_viewDidLoad];
}

- (void)nsi_viewWillAppear:(BOOL)animated {
    SLog(@"%@ viewWillAppear:%@", NSStringFromClass([self class]), animated ? @"YES":@"NO");
    [self nsi_viewWillAppear:animated];
}

- (void)nsi_viewDidAppear:(BOOL)animated {
    SLog(@"%@ viewDidAppear:%@", NSStringFromClass([self class]), animated ? @"YES":@"NO");
    [self nsi_viewDidAppear:animated];
    [self logHierarchy];
}

- (void)nsi_viewWillDisappear:(BOOL)animated {
    SLog(@"%@ viewWillDisappear:%@", NSStringFromClass([self class]), animated ? @"YES":@"NO");
    [self nsi_viewWillDisappear:animated];
}

- (void)nsi_viewDidDisappear:(BOOL)animated {
    SLog(@"%@ viewDidDisappear:%@", NSStringFromClass([self class]), animated ? @"YES":@"NO");
    [self nsi_viewDidDisappear:animated];
}

#pragma mark - Hierarchy

- (void)logHierarchy {
    NSString *viewControllerPath;
    if ([self parentViewController] == nil) {
        viewControllerPath = NSStringFromClass([self class]);
    }
    else if ([[self parentViewController] isKindOfClass:[UINavigationController class]]) {
        UINavigationController *parentViewController = (UINavigationController *)[self parentViewController];
        viewControllerPath = NSStringFromClass([parentViewController class]);
        for (NSUInteger i = 0; i < parentViewController.viewControllers.count; i++) {
            viewControllerPath = [viewControllerPath stringByAppendingString:@"~>"];
            viewControllerPath = [viewControllerPath stringByAppendingString:NSStringFromClass([parentViewController.viewControllers[i] class])];
        }
    }
    else if ([[self parentViewController] isKindOfClass:[UITabBarController class]]) {
        viewControllerPath = NSStringFromClass([[self parentViewController] class]);
        viewControllerPath = [viewControllerPath stringByAppendingString:@"~>"];
        viewControllerPath = [viewControllerPath stringByAppendingString:NSStringFromClass([self class])];
    }
    SLog(@"%@", viewControllerPath);
}

@end

#endif
