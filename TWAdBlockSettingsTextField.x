#import "TWAdBlockSettingsTextField.h"

@implementation TWAdBlockSettingsTextField

- (UITextField *)textField {
    Ivar ivar = class_getInstanceVariable(object_getClass(self), "textField");
    return ivar ? object_getIvar(self, ivar) : nil;
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
        // We are subclassing a Swift class, so we need to be careful
        self = [super initWithFrame:frame themeManager:themeManager];
        if (self) {
            self.applyShadowPathForElevation = YES;
            
            UITextField *tf = [[objc_getClass("_TtC12TwitchCoreUI13BaseTextField") alloc] init];
            if (tf) {
                Ivar ivar = class_getInstanceVariable(object_getClass(self), "textField");
                if (ivar) {
                    object_setIvar(self, ivar, tf);
                    tf.borderStyle = UITextBorderStyleNone;
                    tf.spellCheckingType = UITextSpellCheckingTypeNo;
                    tf.returnKeyType = UIReturnKeyGo;
                    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    tf.font = [objc_getClass("UIFont") twitchBody];
                    tf.enablesReturnKeyAutomatically = YES;
                    tf.translatesAutoresizingMaskIntoConstraints = NO;
                    tf.delegate = self;
                    [tf addTarget:self
                           action:@selector(textFieldEditingChanged)
                 forControlEvents:UIControlEventEditingChanged];
                    [self addSubview:tf];
                    
                    CGFloat inputPadding = tf.intrinsicContentSize.width * 2;
                    NSArray<NSLayoutConstraint *> *constraints = @[
                        [self.leftAnchor constraintEqualToAnchor:tf.leftAnchor constant:-inputPadding],
                        [self.rightAnchor constraintEqualToAnchor:tf.rightAnchor constant:inputPadding],
                        [self.topAnchor constraintEqualToAnchor:tf.topAnchor],
                        [self.bottomAnchor constraintEqualToAnchor:tf.bottomAnchor],
                    ];
                    [NSLayoutConstraint activateConstraints:constraints];
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"TwitchAdBlock: Error initializing TWAdBlockSettingsTextField: %@", exception);
    }
    return self;
}

@end
