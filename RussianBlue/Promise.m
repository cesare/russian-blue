#import "Promise.h"

@interface PromiseCallback : NSObject {
    Promise* promise;
    PromiseOnFulfilled onFullfilled;
    PromiseOnRejected onRejected;
}

@property (nonatomic, readonly) Promise* promise;
@property (nonatomic, readonly) PromiseOnFulfilled onFullfilled;
@property (nonatomic, readonly) PromiseOnRejected onRejected;

+ (PromiseCallback*)callbackWithPromise:(Promise*)promise onFullfilled:(PromiseOnFulfilled)onFullfilled onRejected:(PromiseOnRejected)onRejected;
@end


@implementation PromiseCallback
@synthesize promise, onFullfilled, onRejected;

+ (PromiseCallback*)callbackWithPromise:(Promise*)promise onFullfilled:(PromiseOnFulfilled)onFullfilled onRejected:(PromiseOnRejected)onRejected {
    return [[PromiseCallback alloc] initWithPromise:promise onFullfilled:onFullfilled onRejected:onRejected];
}

- (id)initWithPromise:(Promise*)thePromise onFullfilled:(PromiseOnFulfilled)fullfilled onRejected:(PromiseOnRejected)rejected {
    self = [super init];
    if (self != nil) {
        promise = thePromise;
        onFullfilled = fullfilled;
        onRejected = rejected;
    }
    return self;
}

@end


@interface PromiseQueue : NSObject {
    dispatch_queue_t dispatchQueue;
}

@property (nonatomic, readonly) dispatch_queue_t dispatchQueue;

+ (void)dispatchAsync:(void (^)())block;
@end

@implementation PromiseQueue

@synthesize dispatchQueue;

+ (PromiseQueue*)sharedQueue {
    static PromiseQueue* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            PromiseQueue* queue = [[PromiseQueue alloc] init];
            instance = queue;
        }
    });

    return instance;
}

+ (void)dispatchAsync:(void (^)())block {
    dispatch_queue_t queue = [[PromiseQueue sharedQueue] dispatchQueue];
    dispatch_async(queue, block);
}

- (id)init {
    self = [super init];
    if (self != nil) {
        dispatchQueue = dispatch_queue_create("jp.mayverse.russianblue.promise", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

@end


@implementation Promise

#pragma - Class Scope Factory Methods

+ (Promise*)promise {
    return [[Promise alloc] init];
}


#pragma - Initializers

- (id)init {
    self = [super init];
    if (self != nil) {
        callbacks = [NSMutableArray array];
    }
    return self;
}


#pragma - Then Methods

- (Promise*)then:(PromiseOnFulfilled)onFullfilled {
    return [self then:onFullfilled onRejected:nil];
}

- (Promise*)then:(PromiseOnFulfilled)onFullfilled onRejected:(PromiseOnRejected)onRejected {
    Promise* nextPromise = [Promise promise];
    PromiseCallback* callback = [PromiseCallback callbackWithPromise:nextPromise onFullfilled:onFullfilled onRejected:onRejected];

    [PromiseQueue dispatchAsync:^{
        [callbacks addObject:callback];
        [self executeCallbacks];
    }];

    return nextPromise;
}


#pragma mark - Resolution and Rejection

- (void)resolve:(id)value {
    [PromiseQueue dispatchAsync:^{
        if (![self isPending]) {
            return;
        }

        results = [Right right:value];
        [self executeCallbacks];
    }];
}

- (void)reject:(NSException*)exception {
    [PromiseQueue dispatchAsync:^{
        if (![self isPending]) {
            return;
        }

        results = [Left left:exception];
        [self executeCallbacks];
    }];
}


#pragma mark - Executing Callbacks (private methods)

- (void)executeCallbacks {
    if ([self isPending]) {
        return;
    }

    for (PromiseCallback* callback in callbacks) {
        if ([self isFullfilled]) {
            [self executeFullfilledCallback:callback];
        }
        else {
            [self executeRejectedCallback:callback];
        }
    }

    [callbacks removeAllObjects];
}

- (void)executeFullfilledCallback:(PromiseCallback*)callback {
    PromiseOnFulfilled f = [callback onFullfilled];
    if (f == nil) {
        return;
    }

    @try {
        id value = f([results value]);
        [self resolveNextPromise:[callback promise] withValue:value];
    }
    @catch (NSException *exception) {
        [[callback promise] reject:exception];
    }
}

- (void)executeRejectedCallback:(PromiseCallback*)callback {
    PromiseOnRejected f = [callback onRejected];
    if (f == nil) {
        return;
    }

    @try {
        id value = f([results value]);
        [self resolveNextPromise:[callback promise] withValue:value];
    }
    @catch (NSException *exception) {
        [[callback promise] reject:exception];
    }
}

- (void)resolveNextPromise:(Promise*)promise withValue:(id)value {
    if (value == nil) {
        return;
    }

    if (promise == value) {
        // TODO reject the promise with a kind of TypeError
        return;
    }

    if ([value isKindOfClass:[Promise class]]) {
        Promise* valuePromise = (Promise*)value;
        [valuePromise then:^(id v){
            [promise resolve:v];
            return v;
        } onRejected:^(NSException* e) {
            [valuePromise reject:e];
            return e;
        }];
    }
    else {
        [promise resolve:value];
    }
}

#pragma mark - Predicates

- (BOOL)isPending {
    return results == nil;
}

- (BOOL)isFullfilled {
    return results != nil && [results right];
}

- (BOOL)isRejected {
    return results != nil && [results left];
}

@end
