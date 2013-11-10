//
//  Either.m
//  RussianBlue
//
//  Created by cesare on 2013/11/10.
//  Copyright (c) 2013年 cesare. All rights reserved.
//

#import "Either.h"

@implementation Either

- (BOOL)left {
    return NO;
}

- (BOOL)right {
    return NO;
}

- (id)value {
    return nil;
}

- (NSError*)error {
    return nil;
}

@end

@implementation Left

- (id)initWithError:(NSError*)anError {
    self = [super init];
    if (self != nil) {
        error = anError;
    }
    return self;
}

+ (Left*)left:(NSError *)error {
    return [[Left alloc] initWithError:error];
}

- (BOOL)left {
    return YES;
}

@end

@implementation Right

- (id)initWithValue:(id)aValue {
    self = [super init];
    if (self != nil) {
        value = aValue;
    }
    return self;
}

+ (Right*)right:(id)value {
    return [[Right alloc] initWithValue:value];
}

- (BOOL)right {
    return YES;
}

@end