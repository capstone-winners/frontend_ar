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

+ (UIImage *)toGray:(UIImage *)source;

@end

NS_ASSUME_NONNULL_END
