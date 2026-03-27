#import "TWAdBlockSettingsTextField.h"

%subclass TWAdBlockSettingsTextField : _TtC12TwitchCoreUI17StandardTextField
%new
- (id<UITextFieldDelegate>)delegate {
  Ivar delegateIvar = class_getInstanceVariable(object_getClass(self), "delegate");
  if (!delegateIvar) {
    return nil;
  }
  return object_getIvar(self, delegateIvar);
}
%new
- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
  Ivar delegateIvar = class_getInstanceVariable(object_getClass(self), "delegate");
  if (delegateIvar) {
    object_setIvar(self, delegateIvar, delegate);
  }
}
%new
- (UITextField *)textField {
  Ivar textFieldIvar = class_getInstanceVariable(object_getClass(self), "textField");
  if (!textFieldIvar) {
    return nil;
  }
  return object_getIvar(self, textFieldIvar);
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if (![self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]) return YES;
  return [self.delegate textFieldShouldBeginEditing:textField];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
    [self.delegate textFieldDidBeginEditing:textField];
  
  @try {
    if (self.lastConfiguredTheme) {
      self.backgroundColor = self.lastConfiguredTheme.backgroundBodyColor;
      self.layer.borderColor = self.lastConfiguredTheme.backgroundAccentColor.CGColor;
      self.layer.borderWidth = 2;
    }
  } @catch (NSException *exception) {
    NSLog(@"TwitchAdBlock: Error in textFieldDidBeginEditing: %@", exception);
  }
}
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if (![self.delegate respondsToSelector:@selector(textField:
                                             shouldChangeCharactersInRange:replacementString:)])
    return YES;
  return [self.delegate textField:textField
      shouldChangeCharactersInRange:range
                  replacementString:string];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  if (![self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) return YES;
  return [self.delegate textFieldShouldEndEditing:textField];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
  if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
    [self.delegate textFieldDidEndEditing:textField];
  
  @try {
    if (self.lastConfiguredTheme) {
      self.backgroundColor = self.lastConfiguredTheme.backgroundInputColor;
      self.layer.borderWidth = 0;
    }
  } @catch (NSException *exception) {
    NSLog(@"TwitchAdBlock: Error in textFieldDidEndEditing: %@", exception);
  }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (![self.delegate respondsToSelector:@selector(textFieldShouldReturn:)])
    return [textField resignFirstResponder];
  return [self.delegate textFieldShouldReturn:textField];
}
- (void)textFieldEditingChanged {
}
- (instancetype)initWithFrame:(CGRect)frame
                 themeManager:(_TtC12TwitchCoreUI21TWDefaultThemeManager *)themeManager {
  @try {
    Class originalClass = object_setClass(self, UIView.class);
    if ((self = [self initWithFrame:frame])) {
      object_setClass(self, originalClass);
      self.themeManager = themeManager;
      self.applyShadowPathForElevation = YES;
      
      UITextField *textField = [[objc_getClass("_TtC12TwitchCoreUI13BaseTextField") alloc] init];
      if (textField) {
        Ivar textFieldIvar = class_getInstanceVariable(object_getClass(self), "textField");
        if (textFieldIvar) {
          object_setIvar(self, textFieldIvar, textField);
          textField.borderStyle = UITextBorderStyleNone;
          textField.spellCheckingType = UITextSpellCheckingTypeNo;
          textField.returnKeyType = UIReturnKeyGo;
          textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
          textField.font = UIFont.twitchBody;
          textField.enablesReturnKeyAutomatically = YES;
          textField.translatesAutoresizingMaskIntoConstraints = NO;
          textField.delegate = self;
          [textField addTarget:self
                        action:@selector(textFieldEditingChanged)
              forControlEvents:UIControlEventEditingChanged];
          [self addSubview:textField];
          CGFloat inputPadding = textField.intrinsicContentSize.width * 2;
          NSArray<NSLayoutConstraint *> *textFieldConstraints = @[
            [self.leftAnchor constraintEqualToAnchor:textField.leftAnchor constant:-inputPadding],
            [self.rightAnchor constraintEqualToAnchor:textField.rightAnchor constant:inputPadding],
            [self.topAnchor constraintEqualToAnchor:textField.topAnchor],
            [self.bottomAnchor constraintEqualToAnchor:textField.bottomAnchor],
          ];
          [NSLayoutConstraint activateConstraints:textFieldConstraints];
        }
      }
    }
  } @catch (NSException *exception) {
    NSLog(@"TwitchAdBlock: Error initializing TWAdBlockSettingsTextField: %@", exception);
  }
  return self;
}
- (void)dealloc {
  self.themeManager = nil;
  object_setClass(self, UIView.class);
  %orig;
}
%end
