#import <Foundation/Foundation.h>
#import "Either.h"

typedef id (^PromiseOnFulfilled)(id results);
typedef id (^PromiseOnRejected)(NSException* exception);

@interface Promise : NSObject {
    @private
    Either* results;
    NSMutableArray* callbacks;
}

+ (Promise*)promise;

- (Promise*)then:(PromiseOnFulfilled)onFullfilled;
- (Promise*)then:(PromiseOnFulfilled)onFullfilled onRejected:(PromiseOnRejected)onRejected;

- (void)resolve:(id)value;
- (void)reject:(NSException*)exception;

- (BOOL)isPending;
- (BOOL)isFullfilled;
- (BOOL)isRejected;

@end
