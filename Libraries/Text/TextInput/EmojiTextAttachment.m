//
//  EmoticonTextAttachment.m
//  RCTText
//
//  Created by Sang Jun Lee on 16/09/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "EmojiTextAttachment.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>




@implementation EmojiTextAttachment

- (NSString *)property {
  return objc_getAssociatedObject(self, @selector(emojiName));
}

- (void)setProperty:(NSString *)value {
  objc_setAssociatedObject(self, @selector(emojiName), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
