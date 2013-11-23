//
//  Maybe.m
//  RussianBlue
//
//  Created by cesare on 2013/11/23.
//  Copyright (c) 2013年 cesare. All rights reserved.
//

#import "Maybe.h"

@implementation Maybe

- (id)value {
    return nil;
}

- (BOOL)exists {
    return NO;
}

@end


@implementation Just

- (id)initWithValue:(id)aValue {
    self = [super init];
    if (self != nil) {
        value = aValue;
    }
    return self;
}

+ (Just*)value:(id)value {
    return [[Just alloc] initWithValue:value];
}

- (id)value {
    return value;
}

- (BOOL)exists {
    return YES;
}

@end


@implementation Nothing

+ (Nothing*)nothing {
    return [[Nothing alloc] init];
}

@end
