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
- (NSError*)error;
@end

@interface Left : Either {
    NSError* error;
}

+ (Left*)left:(NSError*)error;
@end

@interface Right : Either {
    id value;
}

+ (Right*)right:(id)value;
@end
