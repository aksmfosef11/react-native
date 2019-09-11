/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTBaseTextInputShadowView.h"
#import "RCTImageView.h"

#import <React/RCTBridge.h>
#import <React/RCTShadowView+Layout.h>
#import <React/RCTUIManager.h>
#import <yoga/Yoga.h>
#import "RCTTextView.h"

#import "NSTextStorage+FontScaling.h"
#import "RCTBaseTextInputView.h"

@implementation RCTBaseTextInputShadowView
{
  __weak RCTBridge *_bridge;
  NSAttributedString *_Nullable _previousAttributedText;
  BOOL _needsUpdateView;
  NSAttributedString *_Nullable _localAttributedText;
  CGSize _previousContentSize;

  NSString *_text;
  NSTextStorage *_textStorage;
  NSTextContainer *_textContainer;
  NSLayoutManager *_layoutManager;
  NSMapTable<id, NSTextStorage *> *_cachedTextStorages;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
  if (self = [super init]) {
    _bridge = bridge;
    _needsUpdateView = YES;
    _cachedTextStorages = [NSMapTable strongToStrongObjectsMapTable];

    YGNodeSetMeasureFunc(self.yogaNode, RCTBaseTextInputShadowViewMeasure);
    YGNodeSetBaselineFunc(self.yogaNode, RCTTextInputShadowViewBaseline);
  }

  return self;
}

- (BOOL)isYogaLeafNode
{
  return YES;
}

- (void)layoutSubviewsWithContext:(RCTLayoutContext)layoutContext
{
  // Do nothing.
}

- (void)setLocalData:(NSObject *)localData
{
  NSAttributedString *attributedText = (NSAttributedString *)localData;

  if ([attributedText isEqualToAttributedString:_localAttributedText]) {
    return;
  }

  _localAttributedText = attributedText;
  [self dirtyLayout];
}

- (void)dirtyLayout
{
  [super dirtyLayout];
  _needsUpdateView = YES;
  YGNodeMarkDirty(self.yogaNode);
  [self invalidateContentSize];
}

- (void)invalidateContentSize
{
  if (!_onContentSizeChange) {
    return;
  }

  CGSize maximumSize = self.layoutMetrics.frame.size;

  if (_maximumNumberOfLines == 1) {
    maximumSize.width = CGFLOAT_MAX;
  } else {
    maximumSize.height = CGFLOAT_MAX;
  }

  CGSize contentSize = [self sizeThatFitsMinimumSize:(CGSize)CGSizeZero maximumSize:maximumSize];

  if (CGSizeEqualToSize(_previousContentSize, contentSize)) {
    return;
  }
  _previousContentSize = contentSize;

  _onContentSizeChange(@{
    @"contentSize": @{
      @"height": @(contentSize.height),
      @"width": @(contentSize.width),
    },
    @"target": self.reactTag,
  });
}

- (NSString *)text
{
  return _text;
}

- (void)setText:(NSString *)text
{
  _text = text;
  // Clear `_previousAttributedText` to notify the view about the change
  // when `text` native prop is set.
  _previousAttributedText = nil;
  [self dirtyLayout];
}

#pragma mark - RCTUIManagerObserver

- (void)uiManagerWillPerformMounting
{
  if (YGNodeIsDirty(self.yogaNode)) {
    return;
  }

  if (!_needsUpdateView) {
    return;
  }
  _needsUpdateView = NO;

  UIEdgeInsets borderInsets = self.borderAsInsets;
  UIEdgeInsets paddingInsets = self.paddingAsInsets;

  RCTTextAttributes *textAttributes = [self.textAttributes copy];

  NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTextWithBaseTextAttributes:nil]];

  // Removing all references to Shadow Views and tags to avoid unnececery retainning
  // and problems with comparing the strings.
  // RCTBaseTextShadowViewEmbeddedShadowViewAttributeName 여기서 이미지를 지움
//  [attributedText removeAttribute:RCTBaseTextShadowViewEmbeddedShadowViewAttributeName
//                            range:NSMakeRange(0, attributedText.length)];

//  [attributedText removeAttribute:RCTTextAttributesTagAttributeName
//                            range:NSMakeRange(0, attributedText.length)];

  if (self.text.length) {
    NSAttributedString *propertyAttributedText =
      [[NSAttributedString alloc] initWithString:self.text
                                      attributes:self.textAttributes.effectiveTextAttributes];
    [attributedText insertAttributedString:propertyAttributedText atIndex:0];
  }

  BOOL isAttributedTextChanged = NO;
  if (![_previousAttributedText isEqualToAttributedString:attributedText]) {
    // We have to follow `set prop` pattern:
    // If the value has not changed, we must not notify the view about the change,
    // otherwise we may break local (temporary) state of the text input.
    isAttributedTextChanged = YES;
    _previousAttributedText = [attributedText copy];
  }

  NSNumber *tag = self.reactTag;

  [_bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    RCTBaseTextInputView *baseTextInputView = (RCTBaseTextInputView *)viewRegistry[tag];
    if (!baseTextInputView) {
      return;
    }

    baseTextInputView.textAttributes = textAttributes;
    baseTextInputView.reactBorderInsets = borderInsets;
    baseTextInputView.reactPaddingInsets = paddingInsets;

    if (isAttributedTextChanged) {
      NSMutableArray<NSNumber *> *descendantViewTags = [NSMutableArray new];
      [attributedText enumerateAttribute:RCTBaseTextShadowViewEmbeddedShadowViewAttributeName
                              inRange:NSMakeRange(0, attributedText.length)
                              options:0
                           usingBlock:
       ^(RCTShadowView *shadowView, NSRange range, __unused BOOL *stop) {
         if (!shadowView) {
           return;
         }
         
         [descendantViewTags addObject:shadowView.reactTag];
       }
       ];
        
        NSMutableArray<UIView *> *descendantViews =
        [NSMutableArray arrayWithCapacity:descendantViewTags.count];
        [descendantViewTags enumerateObjectsUsingBlock:^(NSNumber *_Nonnull descendantViewTag, NSUInteger index, BOOL *_Nonnull stop) {
          UIView *descendantView = viewRegistry[descendantViewTag];
          if (!descendantView) {
            return;
          }
          
          [descendantViews addObject:descendantView];
        }];
      RCTImageView *test = (RCTImageView *)descendantViews[0];
      NSLog(@"123%@",test);
      NSLog(@"123%@",test.imageSources);
      NSLog(@"123%@",test.image);

      
//        [textView setTextStorage:textStorage
//                    contentFrame:contentFrame
//                 descendantViews:descendantViews];
      // 실제 Attributed Text
      [baseTextInputView setAttributedTextWithImage:attributedText
                                  descendantViews:descendantViews];
//      baseTextInputView.attributedText = attributedText;
    }
  }];
}

#pragma mark -

- (NSAttributedString *)measurableAttributedText
{
  // Only for the very first render when we don't have `_localAttributedText`,
  // we use value directly from the property and/or nested content.
  NSAttributedString *attributedText =
    _localAttributedText ?: [self attributedTextWithBaseTextAttributes:nil];

  if (attributedText.length == 0) {
    // It's impossible to measure empty attributed string because all attributes are
    // assosiated with some characters, so no characters means no data.

    // Placeholder also can represent the intrinsic size when it is visible.
    NSString *text = self.placeholder;
    if (!text.length) {
      // Note: `zero-width space` is insufficient in some cases.
      text = @"I";
    }
    attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.textAttributes.effectiveTextAttributes];
  }

  return attributedText;
}

- (CGSize)sizeThatFitsMinimumSize:(CGSize)minimumSize maximumSize:(CGSize)maximumSize
{
  NSAttributedString *attributedText = [self measurableAttributedText];

  if (!_textStorage) {
    _textContainer = [NSTextContainer new];
    _textContainer.lineFragmentPadding = 0.0; // Note, the default value is 5.
    _layoutManager = [NSLayoutManager new];
    [_layoutManager addTextContainer:_textContainer];
    _textStorage = [NSTextStorage new];
    [_textStorage addLayoutManager:_layoutManager];
  }

  _textContainer.size = maximumSize;
  _textContainer.maximumNumberOfLines = _maximumNumberOfLines;
  [_textStorage replaceCharactersInRange:(NSRange){0, _textStorage.length}
                    withAttributedString:attributedText];
  [_layoutManager ensureLayoutForTextContainer:_textContainer];
  CGSize size = [_layoutManager usedRectForTextContainer:_textContainer].size;

  return (CGSize){
    MAX(minimumSize.width, MIN(RCTCeilPixelValue(size.width), maximumSize.width)),
    MAX(minimumSize.height, MIN(RCTCeilPixelValue(size.height), maximumSize.height))
  };
}

- (CGFloat)lastBaselineForSize:(CGSize)size
{
  NSAttributedString *attributedText = [self measurableAttributedText];

  __block CGFloat maximumDescender = 0.0;

  [attributedText enumerateAttribute:NSFontAttributeName
                             inRange:NSMakeRange(0, attributedText.length)
                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                          usingBlock:
    ^(UIFont *font, NSRange range, __unused BOOL *stop) {
      if (maximumDescender > font.descender) {
        maximumDescender = font.descender;
      }
    }
  ];

  return size.height + maximumDescender;
}

- (NSTextStorage *)textStorageAndLayoutManagerThatFitsSize:(CGSize)size
                                        exclusiveOwnership:(BOOL)exclusiveOwnership
{
  NSValue *key = [NSValue valueWithCGSize:size];
  NSTextStorage *cachedTextStorage = [_cachedTextStorages objectForKey:key];
  
  if (cachedTextStorage) {
    if (exclusiveOwnership) {
      [_cachedTextStorages removeObjectForKey:key];
    }
    
    return cachedTextStorage;
  }
  
  NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
  
  textContainer.lineFragmentPadding = 0.0; // Note, the default value is 5.
  textContainer.maximumNumberOfLines = _maximumNumberOfLines;
  
  NSLayoutManager *layoutManager = [NSLayoutManager new];
  [layoutManager addTextContainer:textContainer];
  
  NSTextStorage *textStorage =
  [[NSTextStorage alloc] initWithAttributedString:[self attributedTextWithMeasuredAttachmentsThatFitSize:size]];
  
  [self postprocessAttributedText:textStorage];
  
  [textStorage addLayoutManager:layoutManager];
  
  if (!exclusiveOwnership) {
    [_cachedTextStorages setObject:textStorage forKey:key];
  }
  
  return textStorage;
}


- (NSAttributedString *)attributedTextWithMeasuredAttachmentsThatFitSize:(CGSize)size
{
  NSMutableAttributedString *attributedText =
  [[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTextWithBaseTextAttributes:nil]];
  
  [attributedText beginEditing];
  
  [attributedText enumerateAttribute:RCTBaseTextShadowViewEmbeddedShadowViewAttributeName
                             inRange:NSMakeRange(0, attributedText.length)
                             options:0
                          usingBlock:
   ^(RCTShadowView *shadowView, NSRange range, __unused BOOL *stop) {
     if (!shadowView) {
       return;
     }
     
     CGSize fittingSize = [shadowView sizeThatFitsMinimumSize:CGSizeZero
                                                  maximumSize:size];
     NSTextAttachment *attachment = [NSTextAttachment new];
     attachment.bounds = (CGRect){CGPointZero, fittingSize};
     [attributedText addAttribute:NSAttachmentAttributeName value:attachment range:range];
   }
   ];
  
  [attributedText endEditing];
  
  return [attributedText copy];
}


- (void)postprocessAttributedText:(NSMutableAttributedString *)attributedText
{
  __block CGFloat maximumLineHeight = 0;
  
  [attributedText enumerateAttribute:NSParagraphStyleAttributeName
                             inRange:NSMakeRange(0, attributedText.length)
                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                          usingBlock:
   ^(NSParagraphStyle *paragraphStyle, __unused NSRange range, __unused BOOL *stop) {
     if (!paragraphStyle) {
       return;
     }
     
     maximumLineHeight = MAX(paragraphStyle.maximumLineHeight, maximumLineHeight);
   }
   ];
  
  if (maximumLineHeight == 0) {
    // `lineHeight` was not specified, nothing to do.
    return;
  }
  
  __block CGFloat maximumFontLineHeight = 0;
  
  [attributedText enumerateAttribute:NSFontAttributeName
                             inRange:NSMakeRange(0, attributedText.length)
                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                          usingBlock:
   ^(UIFont *font, NSRange range, __unused BOOL *stop) {
     if (!font) {
       return;
     }
     
     if (maximumFontLineHeight <= font.lineHeight) {
       maximumFontLineHeight = font.lineHeight;
     }
   }
   ];
  
  if (maximumLineHeight < maximumFontLineHeight) {
    return;
  }
  
  CGFloat baseLineOffset = maximumLineHeight / 2.0 - maximumFontLineHeight / 2.0;
  
  [attributedText addAttribute:NSBaselineOffsetAttributeName
                         value:@(baseLineOffset)
                         range:NSMakeRange(0, attributedText.length)];
}

static YGSize RCTBaseTextInputShadowViewMeasure(YGNodeRef node, float width, YGMeasureMode widthMode, float height, YGMeasureMode heightMode)
{
  RCTShadowView *shadowView = (__bridge RCTShadowView *)YGNodeGetContext(node);

  CGSize minimumSize = CGSizeMake(0, 0);
  CGSize maximumSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);

  CGSize size = {
    RCTCoreGraphicsFloatFromYogaFloat(width),
    RCTCoreGraphicsFloatFromYogaFloat(height)
  };

  switch (widthMode) {
    case YGMeasureModeUndefined:
      break;
    case YGMeasureModeExactly:
      minimumSize.width = size.width;
      maximumSize.width = size.width;
      break;
    case YGMeasureModeAtMost:
      maximumSize.width = size.width;
      break;
  }

  switch (heightMode) {
    case YGMeasureModeUndefined:
      break;
    case YGMeasureModeExactly:
      minimumSize.height = size.height;
      maximumSize.height = size.height;
      break;
    case YGMeasureModeAtMost:
      maximumSize.height = size.height;
      break;
  }

  CGSize measuredSize = [shadowView sizeThatFitsMinimumSize:minimumSize maximumSize:maximumSize];

  return (YGSize){
    RCTYogaFloatFromCoreGraphicsFloat(measuredSize.width),
    RCTYogaFloatFromCoreGraphicsFloat(measuredSize.height)
  };
}

static float RCTTextInputShadowViewBaseline(YGNodeRef node, const float width, const float height)
{
  RCTBaseTextInputShadowView *shadowTextView = (__bridge RCTBaseTextInputShadowView *)YGNodeGetContext(node);

  CGSize size = (CGSize){
    RCTCoreGraphicsFloatFromYogaFloat(width),
    RCTCoreGraphicsFloatFromYogaFloat(height)
  };

  CGFloat lastBaseline = [shadowTextView lastBaselineForSize:size];

  return RCTYogaFloatFromCoreGraphicsFloat(lastBaseline);
}

@end
