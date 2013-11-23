//
//  Either.h
//  RussianBlue
//
//  Created by cesare on 2013/11/10.
//  Copyright (c) 2013年 cesare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Either : NSObject
- (BOOL)left;
- (BOOL)right;
- (id)value;
- (NSException*)exception;
@end

@interface Left : Either {
    NSException* exception;
}

+ (Left*)left:(NSException*)exception;
@end

@interface Right : Either {
    id value;
}

+ (Right*)right:(id)value;
@end
