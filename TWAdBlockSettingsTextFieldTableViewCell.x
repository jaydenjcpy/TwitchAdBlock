#import "TWAdBlockSettingsTextFieldTableViewCell.h"

@implementation TWAdBlockSettingsTextFieldTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        @try {
            id themeManager = [objc_getClass("_TtC12TwitchCoreUI21TWDefaultThemeManager") defaultThemeManager];
            if (themeManager) {
                self.textField = [[objc_getClass("TWAdBlockSettingsTextField") alloc]
                    initWithFrame:self.frame
                     themeManager:themeManager];
                
                if (self.textField) {
                    UITextField *tf = self.textField.textField;
                    if (tf) {
                        tf.returnKeyType = UIReturnKeyDone;
                        [self addSubview:self.textField];
                    }
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"TwitchAdBlock: Error initializing text field: %@", exception);
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.textField) {
        self.textField.frame = self.bounds;
        self.textField.layer.cornerRadius = self.layer.cornerRadius;
    }
}

@end
