//
//  Maybe.h
//  RussianBlue
//
//  Created by cesare on 2013/11/23.
//  Copyright (c) 2013年 cesare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Maybe : NSObject
- (id)value;
- (BOOL)exists;
@end


@interface Just : Maybe {
    id value;
}

+ (Just*)value:(id)value;
@end


@interface Nothing : Maybe
+ (Nothing*)nothing;
@end
