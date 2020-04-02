//
//  NSObject+OpenCVWrapper.h
//  cap
//
//  Created by Andrew Tu on 3/17/20.
//  Copyright © 2020 Andrew Tu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
- (UIImage *)detect:(UIImage *)source;

typedef void (^frameCompleteCallbackType)(NSMutableArray*); //Declare the block type
@property frameCompleteCallbackType frameCompleteCallback; //Declare the block property using the block type

@end

NS_ASSUME_NONNULL_END
