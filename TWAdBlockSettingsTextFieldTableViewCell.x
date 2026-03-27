#import "TWAdBlockSettingsTextFieldTableViewCell.h"

%subclass TWAdBlockSettingsTextFieldTableViewCell : BaseTableViewCell
%property(nonatomic, strong) TWAdBlockSettingsTextField *textField;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = %orig)) {
    @try {
      id themeManager = [objc_getClass("_TtC12TwitchCoreUI21TWDefaultThemeManager") defaultThemeManager];
      if (!themeManager) {
        return self;
      }
      
      self.textField = [[objc_getClass("TWAdBlockSettingsTextField") alloc]
          initWithFrame:self.frame
           themeManager:themeManager];
      
      if (self.textField) {
        UITextField *textField = object_getIvar(
            self.textField, class_getInstanceVariable(object_getClass(self.textField), "textField"));
        if (textField) {
          textField.returnKeyType = UIReturnKeyDone;
          [self addSubview:self.textField];
        }
      }
    } @catch (NSException *exception) {
      // If anything goes wrong, just continue without the text field
      NSLog(@"TwitchAdBlock: Error initializing text field: %@", exception);
    }
  }
  return self;
}
- (void)layoutSubviews {
  %orig;
  if (self.textField) {
    self.textField.frame = self.bounds;
    self.textField.layer.cornerRadius = self.layer.cornerRadius;
  }
}
%end

%ctor {
  %init(BaseTableViewCell =
                       objc_getClass("TWBaseTableViewCell")
                           ?: objc_getClass("_TtC12TwitchCoreUI17BaseTableViewCell"));
}
