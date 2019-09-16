/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTBaseTextInputView.h"

#import <React/RCTAccessibilityManager.h>
#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTUIManager.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>
#import <UIKit/UIKit.h>

#import "RCTInputAccessoryView.h"
#import "RCTInputAccessoryViewContent.h"
#import "RCTTextAttributes.h"
#import "RCTTextSelection.h"
#import "EmojiTextAttachment.h"

@implementation RCTBaseTextInputView {
  __weak RCTBridge *_bridge;
  __weak RCTEventDispatcher *_eventDispatcher;
  BOOL _hasInputAccesoryView;
  NSString *_Nullable _predictedText;
  NSInteger _nativeEventCount;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
  RCTAssertParam(bridge);

  if (self = [super initWithFrame:CGRectZero]) {
    _bridge = bridge;
    _eventDispatcher = bridge.eventDispatcher;
  }

  return self;
}

RCT_NOT_IMPLEMENTED(- (instancetype)init)
RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)decoder)
RCT_NOT_IMPLEMENTED(- (instancetype)initWithFrame:(CGRect)frame)

- (UIView<RCTBackedTextInputViewProtocol> *)backedTextInputView
{
  RCTAssert(NO, @"-[RCTBaseTextInputView backedTextInputView] must be implemented in subclass.");
  return nil;
}

#pragma mark - RCTComponent

- (void)didUpdateReactSubviews
{
  // Do nothing.
}

- (NSString *)getPlainString
{
  NSMutableString *str = [[NSMutableString alloc] init];
  __block NSDictionary *emojis = [NSDictionary dictionaryWithObjectsAndKeys:@"<분노>", @"e000_00001_emoji",
                          @"<웃음>", @"e000_00002_emoji",
                          @"<ㅠㅠ>", @"e000_00003_emoji",
                          @"<빠직>", @"e000_00004_emoji",
                          @"<화남>", @"e000_00005_emoji",
                          @"<안녕>", @"e000_00006_emoji",
                          @"<반함>", @"e000_00007_emoji",
                          @"<으으>", @"e000_00008_emoji",
                          @"<피곤>", @"e000_00009_emoji",
                          @"<흡족>", @"e000_00010_emoji",
                          @"<좋아>", @"e000_00011_emoji",
                          @"<눈물>", @"e000_00012_emoji",
                          @"<씨익>", @"e000_00013_emoji",
                          @"<멘붕>", @"e000_00014_emoji",
                          @"<놀람>", @"e000_00015_emoji",
                          @"<슬픔>", @"e000_00016_emoji",
                          @"<힘듦>", @"e000_00017_emoji",
                          @"<폭소>", @"e000_00018_emoji",
                          @"<못마땅>", @"e000_00019_emoji",
                          @"<부르르>", @"e000_00020_emoji",
                          @"<버럭>", @"e000_00021_emoji",
                          @"<훗>", @"e000_00022_emoji",
                          @"<제발>", @"e000_00023_emoji",
                          @"<행복>", @"e000_00024_emoji",
                          @"<ㅜㅜ>", @"e000_00025_emoji",
                          @"<울먹>", @"e000_00026_emoji",
                          @"<쓰읍>", @"e000_00027_emoji",
                          @"<수줍>", @"e000_00028_emoji",
                          @"<발그레>", @"e000_00029_emoji",
                          @"<메롱>", @"e000_00030_emoji",
                          @"<커피>", @"e000_00031_emoji",
                          @"<활력>", @"e000_00032_emoji",
                          @"<엄지척>", @"e000_00033_emoji",
                          @"<약>", @"e000_00034_emoji",
                          @"<소주>", @"e000_00035_emoji",
                          @"<촛불>", @"e000_00036_emoji",
                          @"<고기>", @"e000_00037_emoji",
                          @"<돈>", @"e000_00038_emoji",
                          @"<지갑>", @"e000_00039_emoji",
                          @"<음악>", @"e000_00040_emoji",
                          @"<선물>", @"e000_00041_emoji",
                          @"<밥>", @"e000_00042_emoji",
                          @"<태양>", @"e000_00043_emoji",
                          @"<구름>", @"e000_00044_emoji",
                          @"<달>", @"e000_00045_emoji",
                          @"<아이스음료>", @"e000_00046_emoji",
                          @"<사탕>", @"e000_00047_emoji",
                          @"<막대사탕>", @"e000_00048_emoji",
                          @"<풍선>", @"e000_00049_emoji",
                          @"<비타민씨>", @"e000_00050_emoji",
                          @"<우동>", @"e000_00051_emoji",
                          @"<사과>", @"e000_00052_emoji",
                          @"<비>", @"e000_00053_emoji",
                          @"<축하>", @"e000_00054_emoji",
                          @"<담배>", @"e000_00055_emoji",
                          @"<하트>", @"e000_00056_emoji",
                          @"<고양이>", @"e000_00057_emoji",
                          @"<강아지>", @"e000_00058_emoji",
                          @"<발자국>", @"e000_00059_emoji",
                          @"<꽃>", @"e000_00060_emoji",
                          @"<피자>", @"e000_00061_emoji",
                          @"<팝콘>", @"e000_00062_emoji",
                          @"<맥주>", @"e000_00063_emoji",
                          @"<와인>", @"e000_00064_emoji",
                          @"<편지>", @"e000_00065_emoji",
                          @"<주사>", @"e000_00066_emoji",
                          @"<햄버거>", @"e000_00067_emoji",
                          @"<케익>", @"e000_00068_emoji",
                          @"<번개>", @"e000_00069_emoji",
                                  @"<리본>", @"e000_00070_emoji", nil];
  

  [str setString:self.attributedText.string];
  __block int base = 0;
  [self.attributedText enumerateAttribute:NSAttachmentAttributeName
                             inRange:NSMakeRange(0, self.attributedText.length)
                             options:0
                          usingBlock:
   ^(EmojiTextAttachment *attachment, NSRange range, __unused BOOL *stop) {
     if (!attachment) {
       return;
     }
     NSString *emojiURL = attachment.emojiName;
     NSString *getName = [emojis objectForKey:emojiURL];
     [str replaceCharactersInRange:NSMakeRange(range.location+base,range.length) withString:getName];
     base = base + (int)getName.length - 1;
   }
   ];
  return str;
}

#pragma mark - Properties

- (void)setTextAttributes:(RCTTextAttributes *)textAttributes
{
  _textAttributes = textAttributes;
  [self enforceTextAttributesIfNeeded];
}

- (void)enforceTextAttributesIfNeeded
{
  id<RCTBackedTextInputViewProtocol> backedTextInputView = self.backedTextInputView;
  if (backedTextInputView.attributedText.string.length != 0) {
    return;
  }

  backedTextInputView.font = _textAttributes.effectiveFont;
  backedTextInputView.textColor = _textAttributes.effectiveForegroundColor;
  backedTextInputView.textAlignment = _textAttributes.alignment;
}

- (void)setReactPaddingInsets:(UIEdgeInsets)reactPaddingInsets
{
  _reactPaddingInsets = reactPaddingInsets;
  // We apply `paddingInsets` as `backedTextInputView`'s `textContainerInset`.
  self.backedTextInputView.textContainerInset = reactPaddingInsets;
  [self setNeedsLayout];
}

- (void)setReactBorderInsets:(UIEdgeInsets)reactBorderInsets
{
  _reactBorderInsets = reactBorderInsets;
  // We apply `borderInsets` as `backedTextInputView` layout offset.
  self.backedTextInputView.frame = UIEdgeInsetsInsetRect(self.bounds, reactBorderInsets);
  [self setNeedsLayout];
}

- (NSAttributedString *)attributedText
{
  return self.backedTextInputView.attributedText;
}

- (void)setAttributedTextWithImage:(NSAttributedString *)attributedText
                   descendantViews:(NSArray<UIView *> *)descendantViews
{
  NSInteger eventLag = _nativeEventCount - _mostRecentEventCount;
  BOOL textNeedsUpdate = NO;
  // Remove tag attribute to ensure correct attributed string comparison.
  NSMutableAttributedString *const backedTextInputViewTextCopy = [self.backedTextInputView.attributedText mutableCopy];
  NSMutableAttributedString *const attributedTextCopy = [attributedText mutableCopy];
  
  [backedTextInputViewTextCopy removeAttribute:RCTTextAttributesTagAttributeName
                                         range:NSMakeRange(0, backedTextInputViewTextCopy.length)];
  
  [attributedTextCopy removeAttribute:RCTTextAttributesTagAttributeName
                                range:NSMakeRange(0, attributedTextCopy.length)];
  
  textNeedsUpdate = ([self textOf:attributedTextCopy equals:backedTextInputViewTextCopy] == NO);
  
  if (eventLag == 0 && textNeedsUpdate) {
    UITextRange *selection = self.backedTextInputView.selectedTextRange;
    NSInteger oldTextLength = self.backedTextInputView.attributedText.string.length;
    
    [self.backedTextInputView setAttributedTextWithImage:attributedText
                                  descendantViews:descendantViews];
    
    if (selection.empty) {
      // Maintaining a cursor position relative to the end of the old text.
      NSInteger offsetStart =
      [self.backedTextInputView offsetFromPosition:self.backedTextInputView.beginningOfDocument
                                        toPosition:selection.start];
      NSInteger offsetFromEnd = oldTextLength - offsetStart;
      NSInteger newOffset = attributedText.string.length - offsetFromEnd;
      UITextPosition *position =
      [self.backedTextInputView positionFromPosition:self.backedTextInputView.beginningOfDocument
                                              offset:newOffset];
      [self.backedTextInputView setSelectedTextRange:[self.backedTextInputView textRangeFromPosition:position toPosition:position]
                                      notifyDelegate:YES];
    }
    
    [self updateLocalData];
  } else if (eventLag > RCTTextUpdateLagWarningThreshold) {
    RCTLogWarn(@"Native TextInput(%@) is %lld events ahead of JS - try to make your JS faster.", self.backedTextInputView.attributedText.string, (long long)eventLag);
  }
}

- (BOOL)textOf:(NSAttributedString*)newText equals:(NSAttributedString*)oldText{
  // When the dictation is running we can't update the attibuted text on the backed up text view
  // because setting the attributed string will kill the dictation. This means that we can't impose
  // the settings on a dictation.
  // Similarly, when the user is in the middle of inputting some text in Japanese/Chinese, there will be styling on the
  // text that we should disregard. See https://developer.apple.com/documentation/uikit/uitextinput/1614489-markedtextrange?language=objc
  // for more info.
  // If the user added an emoji, the sytem adds a font attribute for the emoji and stores the original font in NSOriginalFont.
  // Lastly, when entering a password, etc., there will be additional styling on the field as the native text view
  // handles showing the last character for a split second.
  __block BOOL fontHasBeenUpdatedBySystem = false;
  [oldText enumerateAttribute:@"NSOriginalFont" inRange:NSMakeRange(0, oldText.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
    if (value){
      fontHasBeenUpdatedBySystem = true;
    }
  }];

  BOOL shouldFallbackToBareTextComparison =
    [self.backedTextInputView.textInputMode.primaryLanguage isEqualToString:@"dictation"] ||
    self.backedTextInputView.markedTextRange ||
    self.backedTextInputView.isSecureTextEntry ||
    fontHasBeenUpdatedBySystem;

  if (shouldFallbackToBareTextComparison) {
    return ([newText.string isEqualToString:oldText.string]);
  } else {
    return ([newText isEqualToAttributedString:oldText]);
  }
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
  NSInteger eventLag = _nativeEventCount - _mostRecentEventCount;
  BOOL textNeedsUpdate = NO;
  // Remove tag attribute to ensure correct attributed string comparison.
  NSMutableAttributedString *const backedTextInputViewTextCopy = [self.backedTextInputView.attributedText mutableCopy];
  NSMutableAttributedString *const attributedTextCopy = [attributedText mutableCopy];
  
  [backedTextInputViewTextCopy removeAttribute:RCTTextAttributesTagAttributeName
                                         range:NSMakeRange(0, backedTextInputViewTextCopy.length)];

  [attributedTextCopy removeAttribute:RCTTextAttributesTagAttributeName
                                range:NSMakeRange(0, attributedTextCopy.length)];

  textNeedsUpdate = ([self textOf:attributedTextCopy equals:backedTextInputViewTextCopy] == NO);

  if (eventLag == 0 && textNeedsUpdate) {
    UITextRange *selection = self.backedTextInputView.selectedTextRange;
    NSInteger oldTextLength = self.backedTextInputView.attributedText.string.length;

    self.backedTextInputView.attributedText = attributedText;
    
    if (selection.empty) {
      // Maintaining a cursor position relative to the end of the old text.
      NSInteger offsetStart =
      [self.backedTextInputView offsetFromPosition:self.backedTextInputView.beginningOfDocument
                                        toPosition:selection.start];
      NSInteger offsetFromEnd = oldTextLength - offsetStart;
      NSInteger newOffset = attributedText.string.length - offsetFromEnd;
      UITextPosition *position =
      [self.backedTextInputView positionFromPosition:self.backedTextInputView.beginningOfDocument
                                              offset:newOffset];
      [self.backedTextInputView setSelectedTextRange:[self.backedTextInputView textRangeFromPosition:position toPosition:position]
                                      notifyDelegate:YES];
    }

    [self updateLocalData];
  } else if (eventLag > RCTTextUpdateLagWarningThreshold) {
    RCTLogWarn(@"Native TextInput(%@) is %lld events ahead of JS - try to make your JS faster.", self.backedTextInputView.attributedText.string, (long long)eventLag);
  }
}

- (RCTTextSelection *)selection
{
  id<RCTBackedTextInputViewProtocol> backedTextInputView = self.backedTextInputView;
  UITextRange *selectedTextRange = backedTextInputView.selectedTextRange;
  return [[RCTTextSelection new] initWithStart:[backedTextInputView offsetFromPosition:backedTextInputView.beginningOfDocument toPosition:selectedTextRange.start]
                                           end:[backedTextInputView offsetFromPosition:backedTextInputView.beginningOfDocument toPosition:selectedTextRange.end]];
}

- (void)setSelection:(RCTTextSelection *)selection
{
  if (!selection) {
    return;
  }

  id<RCTBackedTextInputViewProtocol> backedTextInputView = self.backedTextInputView;

  UITextRange *previousSelectedTextRange = backedTextInputView.selectedTextRange;
  UITextPosition *start = [backedTextInputView positionFromPosition:backedTextInputView.beginningOfDocument offset:selection.start];
  UITextPosition *end = [backedTextInputView positionFromPosition:backedTextInputView.beginningOfDocument offset:selection.end];
  UITextRange *selectedTextRange = [backedTextInputView textRangeFromPosition:start toPosition:end];

  NSInteger eventLag = _nativeEventCount - _mostRecentEventCount;
  if (eventLag == 0 && ![previousSelectedTextRange isEqual:selectedTextRange]) {
    [backedTextInputView setSelectedTextRange:selectedTextRange notifyDelegate:NO];
  } else if (eventLag > RCTTextUpdateLagWarningThreshold) {
    RCTLogWarn(@"Native TextInput(%@) is %lld events ahead of JS - try to make your JS faster.", backedTextInputView.attributedText.string, (long long)eventLag);
  }
}

- (void)setTextContentType:(NSString *)type
{
  #if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if (@available(iOS 10.0, *)) {

        static dispatch_once_t onceToken;
        static NSDictionary<NSString *, NSString *> *contentTypeMap;

        dispatch_once(&onceToken, ^{
          contentTypeMap = @{@"none": @"",
                             @"URL": UITextContentTypeURL,
                             @"addressCity": UITextContentTypeAddressCity,
                             @"addressCityAndState":UITextContentTypeAddressCityAndState,
                             @"addressState": UITextContentTypeAddressState,
                             @"countryName": UITextContentTypeCountryName,
                             @"creditCardNumber": UITextContentTypeCreditCardNumber,
                             @"emailAddress": UITextContentTypeEmailAddress,
                             @"familyName": UITextContentTypeFamilyName,
                             @"fullStreetAddress": UITextContentTypeFullStreetAddress,
                             @"givenName": UITextContentTypeGivenName,
                             @"jobTitle": UITextContentTypeJobTitle,
                             @"location": UITextContentTypeLocation,
                             @"middleName": UITextContentTypeMiddleName,
                             @"name": UITextContentTypeName,
                             @"namePrefix": UITextContentTypeNamePrefix,
                             @"nameSuffix": UITextContentTypeNameSuffix,
                             @"nickname": UITextContentTypeNickname,
                             @"organizationName": UITextContentTypeOrganizationName,
                             @"postalCode": UITextContentTypePostalCode,
                             @"streetAddressLine1": UITextContentTypeStreetAddressLine1,
                             @"streetAddressLine2": UITextContentTypeStreetAddressLine2,
                             @"sublocality": UITextContentTypeSublocality,
                             @"telephoneNumber": UITextContentTypeTelephoneNumber,
                             };

          #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000 /* __IPHONE_11_0 */
            if (@available(iOS 11.0, tvOS 11.0, *)) {
              NSDictionary<NSString *, NSString *> * iOS11extras = @{@"username": UITextContentTypeUsername,
                                                                     @"password": UITextContentTypePassword};

              NSMutableDictionary<NSString *, NSString *> * iOS11baseMap = [contentTypeMap mutableCopy];
              [iOS11baseMap addEntriesFromDictionary:iOS11extras];

              contentTypeMap = [iOS11baseMap copy];
            }
          #endif

          #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 120000 /* __IPHONE_12_0 */
            if (@available(iOS 12.0, tvOS 12.0, *)) {
              NSDictionary<NSString *, NSString *> * iOS12extras = @{@"newPassword": UITextContentTypeNewPassword,
                                                                     @"oneTimeCode": UITextContentTypeOneTimeCode};

              NSMutableDictionary<NSString *, NSString *> * iOS12baseMap = [contentTypeMap mutableCopy];
              [iOS12baseMap addEntriesFromDictionary:iOS12extras];

              contentTypeMap = [iOS12baseMap copy];
            }
          #endif
        });

        // Setting textContentType to an empty string will disable any
        // default behaviour, like the autofill bar for password inputs
        self.backedTextInputView.textContentType = contentTypeMap[type] ?: type;
    }
  #endif
}

- (UIKeyboardType)keyboardType
{
  return self.backedTextInputView.keyboardType;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
  UIView<RCTBackedTextInputViewProtocol> *textInputView = self.backedTextInputView;
  if (textInputView.keyboardType != keyboardType) {
    textInputView.keyboardType = keyboardType;
    // Without the call to reloadInputViews, the keyboard will not change until the textview field (the first responder) loses and regains focus.
    if (textInputView.isFirstResponder) {
      [textInputView reloadInputViews];
    }
  }
}

- (BOOL)secureTextEntry {
  return self.backedTextInputView.secureTextEntry;
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry {
  UIView<RCTBackedTextInputViewProtocol> *textInputView = self.backedTextInputView;
    
  if (textInputView.secureTextEntry != secureTextEntry) {
    textInputView.secureTextEntry = secureTextEntry;
      
    // Fix #5859, see https://stackoverflow.com/questions/14220187/uitextfield-has-trailing-whitespace-after-securetextentry-toggle/22537788#22537788
    NSAttributedString *originalText = [textInputView.attributedText copy];
    self.backedTextInputView.attributedText = [NSAttributedString new];
    self.backedTextInputView.attributedText = originalText;
  }
    
}

#pragma mark - RCTBackedTextInputDelegate

- (BOOL)textInputShouldBeginEditing
{
  return YES;
}

- (void)textInputDidBeginEditing
{
  if (_clearTextOnFocus) {
    self.backedTextInputView.attributedText = [NSAttributedString new];
  }

  if (_selectTextOnFocus) {
    [self.backedTextInputView selectAll:nil];
  }

  [_eventDispatcher sendTextEventWithType:RCTTextEventTypeFocus
                                 reactTag:self.reactTag
                                     text:self.backedTextInputView.attributedText.string
                                      key:nil
                               eventCount:_nativeEventCount];
}

- (BOOL)textInputShouldEndEditing
{
  return YES;
}

- (void)textInputDidEndEditing
{
  [_eventDispatcher sendTextEventWithType:RCTTextEventTypeEnd
                                 reactTag:self.reactTag
                                     text:self.backedTextInputView.attributedText.string
                                      key:nil
                               eventCount:_nativeEventCount];

  [_eventDispatcher sendTextEventWithType:RCTTextEventTypeBlur
                                 reactTag:self.reactTag
                                     text:self.backedTextInputView.attributedText.string
                                      key:nil
                               eventCount:_nativeEventCount];
}

- (BOOL)textInputShouldReturn
{
  // We send `submit` event here, in `textInputShouldReturn`
  // (not in `textInputDidReturn)`, because of semantic of the event:
  // `onSubmitEditing` is called when "Submit" button
  // (the blue key on onscreen keyboard) did pressed
  // (no connection to any specific "submitting" process).
  [_eventDispatcher sendTextEventWithType:RCTTextEventTypeSubmit
                                 reactTag:self.reactTag
                                     text:self.backedTextInputView.attributedText.string
                                      key:nil
                               eventCount:_nativeEventCount];

  return _blurOnSubmit;
}

- (void)textInputDidReturn
{
  // Does nothing.
}

- (BOOL)textInputShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  id<RCTBackedTextInputViewProtocol> backedTextInputView = self.backedTextInputView;

  if (!backedTextInputView.textWasPasted) {
    [_eventDispatcher sendTextEventWithType:RCTTextEventTypeKeyPress
                                   reactTag:self.reactTag
                                       text:nil
                                        key:text
                                 eventCount:_nativeEventCount];
  }
  
  if (_maxLength) {
    NSUInteger allowedLength = _maxLength.integerValue - backedTextInputView.attributedText.string.length + range.length;

    if (text.length > allowedLength) {
      // If we typed/pasted more than one character, limit the text inputted.
      if (text.length > 1) {
        // Truncate the input string so the result is exactly maxLength
        NSString *limitedString = [text substringToIndex:allowedLength];
        NSMutableAttributedString *newAttributedText = [backedTextInputView.attributedText mutableCopy];
        [newAttributedText replaceCharactersInRange:range withString:limitedString];
        backedTextInputView.attributedText = newAttributedText;
        _predictedText = newAttributedText.string;

        // Collapse selection at end of insert to match normal paste behavior.
        UITextPosition *insertEnd = [backedTextInputView positionFromPosition:backedTextInputView.beginningOfDocument
                                                                       offset:(range.location + allowedLength)];
        [backedTextInputView setSelectedTextRange:[backedTextInputView textRangeFromPosition:insertEnd toPosition:insertEnd]
                                   notifyDelegate:YES];

        [self textInputDidChange];
      }
      
      return NO;
    }
  }

  NSString *previousText = backedTextInputView.attributedText.string ?: @"";
  
  if (range.location + range.length > backedTextInputView.attributedText.string.length) {
    _predictedText = backedTextInputView.attributedText.string;
  } else {
    _predictedText = [backedTextInputView.attributedText.string stringByReplacingCharactersInRange:range withString:text];
  }

  if (_onTextInput) {
    _onTextInput(@{
      @"text": text,
      @"previousText": previousText,
      @"range": @{
        @"start": @(range.location),
        @"end": @(range.location + range.length)
      },
      @"eventCount": @(_nativeEventCount),
    });
  }

  return YES;
}

- (void)textInputDidChange
{
  [self updateLocalData];

  id<RCTBackedTextInputViewProtocol> backedTextInputView = self.backedTextInputView;

  // Detect when `backedTextInputView` updates happend that didn't invoke `shouldChangeTextInRange`
  // (e.g. typing simplified chinese in pinyin will insert and remove spaces without
  // calling shouldChangeTextInRange).  This will cause JS to get out of sync so we
  // update the mismatched range.
  NSRange currentRange;
  NSRange predictionRange;
  if (findMismatch(backedTextInputView.attributedText.string, _predictedText, &currentRange, &predictionRange)) {
    NSString *replacement = [backedTextInputView.attributedText.string substringWithRange:currentRange];
    [self textInputShouldChangeTextInRange:predictionRange replacementText:replacement];
    // JS will assume the selection changed based on the location of our shouldChangeTextInRange, so reset it.
    [self textInputDidChangeSelection];
  }

  _nativeEventCount++;
  
  if (_onChange) {
    _onChange(@{
       @"text": [self getPlainString],
       @"target": self.reactTag,
       @"eventCount": @(_nativeEventCount),
    });
  }
}


- (void)textInputDidChangeSelection
{
  if (!_onSelectionChange) {
    return;
  }

  RCTTextSelection *selection = self.selection;

  _onSelectionChange(@{
    @"selection": @{
      @"start": @(selection.start),
      @"end": @(selection.end),
    },
  });
}

- (void)updateLocalData
{
  [self enforceTextAttributesIfNeeded];

  [_bridge.uiManager setLocalData:[self.backedTextInputView.attributedText copy]
                          forView:self];
}

#pragma mark - Layout (in UIKit terms, with all insets)

- (CGSize)intrinsicContentSize
{
  CGSize size = self.backedTextInputView.intrinsicContentSize;
  size.width += _reactBorderInsets.left + _reactBorderInsets.right;
  size.height += _reactBorderInsets.top + _reactBorderInsets.bottom;
  // Returning value DOES include border and padding insets.
  return size;
}

- (CGSize)sizeThatFits:(CGSize)size
{
  CGFloat compoundHorizontalBorderInset = _reactBorderInsets.left + _reactBorderInsets.right;
  CGFloat compoundVerticalBorderInset = _reactBorderInsets.top + _reactBorderInsets.bottom;

  size.width -= compoundHorizontalBorderInset;
  size.height -= compoundVerticalBorderInset;

  // Note: `paddingInsets` was already included in `backedTextInputView` size
  // because it was applied as `textContainerInset`.
  CGSize fittingSize = [self.backedTextInputView sizeThatFits:size];

  fittingSize.width += compoundHorizontalBorderInset;
  fittingSize.height += compoundVerticalBorderInset;

  // Returning value DOES include border and padding insets.
  return fittingSize;
}

#pragma mark - Accessibility

- (UIView *)reactAccessibilityElement
{
  return self.backedTextInputView;
}

#pragma mark - Focus Control

- (void)reactFocus
{
  [self.backedTextInputView reactFocus];
}

- (void)reactBlur
{
  [self.backedTextInputView reactBlur];
}

- (void)didMoveToWindow
{
  [self.backedTextInputView reactFocusIfNeeded];
}

#pragma mark - Custom Input Accessory View

- (void)didSetProps:(NSArray<NSString *> *)changedProps
{
  if ([changedProps containsObject:@"inputAccessoryViewID"] && self.inputAccessoryViewID) {
    [self setCustomInputAccessoryViewWithNativeID:self.inputAccessoryViewID];
  } else if (!self.inputAccessoryViewID) {
    [self setDefaultInputAccessoryView];
  }
}

- (void)setCustomInputAccessoryViewWithNativeID:(NSString *)nativeID
{
  #if !TARGET_OS_TV
  __weak RCTBaseTextInputView *weakSelf = self;
  [_bridge.uiManager rootViewForReactTag:self.reactTag withCompletion:^(UIView *rootView) {
    RCTBaseTextInputView *strongSelf = weakSelf;
    if (rootView) {
      UIView *accessoryView = [strongSelf->_bridge.uiManager viewForNativeID:nativeID
                                                                 withRootTag:rootView.reactTag];
      if (accessoryView && [accessoryView isKindOfClass:[RCTInputAccessoryView class]]) {
        strongSelf.backedTextInputView.inputAccessoryView = ((RCTInputAccessoryView *)accessoryView).inputAccessoryView;
        [strongSelf reloadInputViewsIfNecessary];
      }
    }
  }];
  #endif /* !TARGET_OS_TV */
}

- (void)setDefaultInputAccessoryView
{
  #if !TARGET_OS_TV
  UIView<RCTBackedTextInputViewProtocol> *textInputView = self.backedTextInputView;
  UIKeyboardType keyboardType = textInputView.keyboardType;

  // These keyboard types (all are number pads) don't have a "Done" button by default,
  // so we create an `inputAccessoryView` with this button for them.
  BOOL shouldHaveInputAccesoryView =
    (
      keyboardType == UIKeyboardTypeNumberPad ||
      keyboardType == UIKeyboardTypePhonePad ||
      keyboardType == UIKeyboardTypeDecimalPad ||
      keyboardType == UIKeyboardTypeASCIICapableNumberPad
    ) &&
    textInputView.returnKeyType == UIReturnKeyDone;

  if (_hasInputAccesoryView == shouldHaveInputAccesoryView) {
    return;
  }

  _hasInputAccesoryView = shouldHaveInputAccesoryView;

  if (shouldHaveInputAccesoryView) {
    UIToolbar *toolbarView = [[UIToolbar alloc] init];
    [toolbarView sizeToFit];
    UIBarButtonItem *flexibleSpace =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                    target:nil
                                                    action:nil];
    UIBarButtonItem *doneButton =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                    target:self
                                                    action:@selector(handleInputAccessoryDoneButton)];
    toolbarView.items = @[flexibleSpace, doneButton];
    textInputView.inputAccessoryView = toolbarView;
  }
  else {
    textInputView.inputAccessoryView = nil;
  }
  [self reloadInputViewsIfNecessary];
  #endif /* !TARGET_OS_TV */
}

- (void)reloadInputViewsIfNecessary
{
  // We have to call `reloadInputViews` for focused text inputs to update an accessory view.
  if (self.backedTextInputView.isFirstResponder) {
    [self.backedTextInputView reloadInputViews];
  }
}

- (void)handleInputAccessoryDoneButton
{
  if ([self textInputShouldReturn]) {
    [self.backedTextInputView endEditing:YES];
  }
}

#pragma mark - Helpers

static BOOL findMismatch(NSString *first, NSString *second, NSRange *firstRange, NSRange *secondRange)
{
  NSInteger firstMismatch = -1;
  for (NSUInteger ii = 0; ii < MAX(first.length, second.length); ii++) {
    if (ii >= first.length || ii >= second.length || [first characterAtIndex:ii] != [second characterAtIndex:ii]) {
      firstMismatch = ii;
      break;
    }
  }

  if (firstMismatch == -1) {
    return NO;
  }

  NSUInteger ii = second.length;
  NSUInteger lastMismatch = first.length;
  while (ii > firstMismatch && lastMismatch > firstMismatch) {
    if ([first characterAtIndex:(lastMismatch - 1)] != [second characterAtIndex:(ii - 1)]) {
      break;
    }
    ii--;
    lastMismatch--;
  }

  *firstRange = NSMakeRange(firstMismatch, lastMismatch - firstMismatch);
  *secondRange = NSMakeRange(firstMismatch, ii - firstMismatch);
  return YES;
}

@end
