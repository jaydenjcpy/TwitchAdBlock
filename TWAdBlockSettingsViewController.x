#import <dlfcn.h>
#import "TWAdBlockSettingsViewController.h"

extern NSBundle *tweakBundle;
extern NSUserDefaults *tweakDefaults;

#define LOC(x, d) [tweakBundle localizedStringForKey:x value:d table:nil]

%hook _TtC6Twitch27SettingsSwitchTableViewCell
%new
- (id)delegate {
  return object_getIvar(self, class_getInstanceVariable(object_getClass(self), "delegate"));
}
%new
- (void)setDelegate:(id)delegate {
  object_setIvar(self, class_getInstanceVariable(object_getClass(self), "delegate"), delegate);
}
%new
- (BOOL)isOn {
  Ivar switchViewIvar = class_getInstanceVariable(object_getClass(self), "$__lazy_storage_$_switchView");
  if (!switchViewIvar) {
    // Fallback: try to find the switch view in the cell's subviews
    for (UIView *subview in self.subviews) {
      if ([subview isKindOfClass:[UISwitch class]]) {
        return [(UISwitch *)subview isOn];
      }
    }
    return NO;
  }
  UISwitch *switchView = object_getIvar(self, switchViewIvar);
  return switchView ? [switchView isOn] : NO;
}
%new
- (void)configureWithTitle:(NSString *)title
                   subtitle:(NSString *)subtitle
                  isEnabled:(BOOL)isEnabled
                       isOn:(BOOL)isOn
    accessibilityIdentifier:(NSString *)accessibilityIdentifier {
  self.textLabel.text = title;
  self.detailTextLabel.text = subtitle;
  
  Ivar switchViewIvar = class_getInstanceVariable(object_getClass(self), "$__lazy_storage_$_switchView");
  UISwitch *switchView = nil;
  
  if (switchViewIvar) {
    switchView = object_getIvar(self, switchViewIvar);
  } else {
    // Fallback: find the switch view in subviews
    for (UIView *subview in self.subviews) {
      if ([subview isKindOfClass:[UISwitch class]]) {
        switchView = (UISwitch *)subview;
        break;
      }
    }
  }
  
  if (switchView) {
    switchView.enabled = isEnabled;
    switchView.on = isOn;
  }
  
  self.accessibilityIdentifier = accessibilityIdentifier;
}
- (void)settingsSwitchToggled {
  if (![self.delegate respondsToSelector:@selector(settingsCellSwitchToggled:)])
    return %orig;
  [self.delegate settingsCellSwitchToggled:self];
}
%end

%subclass TWAdBlockSettingsViewController : TWBaseTableViewController
%property(nonatomic, assign) BOOL adblockEnabled;
%property(nonatomic, assign) BOOL proxyEnabled;
%property(nonatomic, assign) BOOL customProxyEnabled;
- (instancetype)initWithTableViewStyle:(NSInteger)tableViewStyle themeManager:(id)themeManager {
  if ((self = %orig)) {
    self.adblockEnabled = [tweakDefaults boolForKey:@"TWAdBlockEnabled"];
    self.proxyEnabled = [tweakDefaults boolForKey:@"TWAdBlockProxyEnabled"];
    self.customProxyEnabled = [tweakDefaults boolForKey:@"TWAdBlockCustomProxyEnabled"];
  }
  return self;
}
- (void)viewDidLoad {
  %orig;
  self.title = @"TwitchAdBlock";
}
%new
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.adblockEnabled ? 3 : 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return 1;
    case 1:
      return self.adblockEnabled ? self.proxyEnabled ? self.customProxyEnabled ? 3 : 2 : 1 : 0;
    default:
      return 0;
  }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  switch (indexPath.section) {
    case 0:
      cell = [[objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell") alloc]
            initWithStyle:UITableViewCellStyleDefault
          reuseIdentifier:@"AdBlockSwitchCell"];
      [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell
               configureWithTitle:LOC(@"settings.adblock.title", @"Ad Block")
                         subtitle:nil
                        isEnabled:YES
                             isOn:[tweakDefaults boolForKey:@"TWAdBlockEnabled"]
          accessibilityIdentifier:@"AdBlockSwitchCell"];
      [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell setDelegate:self];
      return cell;
    case 1:
      switch (indexPath.row) {
        case 0:
          cell = [[objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell") alloc]
                initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:@"AdBlockProxySwitchCell"];
          [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell
                   configureWithTitle:LOC(@"settings.proxy.title", @"Ad Block Proxy")
                             subtitle:nil
                            isEnabled:YES
                                 isOn:[tweakDefaults boolForKey:@"TWAdBlockProxyEnabled"]
              accessibilityIdentifier:@"AdBlockProxySwitchCell"];
          [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell setDelegate:self];
          return cell;
        case 1:
          cell = [[objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell") alloc]
                initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:@"AdBlockCustomProxySwitchCell"];
          [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell
                   configureWithTitle:LOC(@"settings.custom_proxy.title", @"Custom Proxy")
                             subtitle:nil
                            isEnabled:YES
                                 isOn:[tweakDefaults boolForKey:@"TWAdBlockCustomProxyEnabled"]
              accessibilityIdentifier:@"AdBlockCustomProxySwitchCell"];
          [(_TtC6Twitch27SettingsSwitchTableViewCell *)cell setDelegate:self];
          return cell;
        case 2:
          cell = [[objc_getClass("TWAdBlockSettingsTextFieldTableViewCell") alloc]
                initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:@"TWAdBlockProxy"];
          if (cell) {
            TWAdBlockSettingsTextField *textField =
                ((TWAdBlockSettingsTextFieldTableViewCell *)cell).textField;
            if (textField && textField.textField) {
              textField.textField.placeholder = PROXY_ADDR;
              textField.textField.text = [tweakDefaults stringForKey:@"TWAdBlockProxy"];
              textField.delegate = self;
            }
          }
          return cell;
      }
    default:
      return nil;
  }
}
%new
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  NSString *title;
  switch (section) {
    case 0:
      title = LOC(@"settings.adblock.footer", @"Choose whether or not you want to block ads");
      break;
    case 1:
      title = LOC(@"settings.proxy.footer",
                  @"Proxy specific requests through a proxy server based in an ad-free country");
      if (self.adblockEnabled) break;
    case 2: {
      _TtC6Twitch12VersionLabel *versionLabel =
          [[objc_getClass("_TtC6Twitch12VersionLabel") alloc] initWithFrame:CGRectZero];
      if (versionLabel) {
        versionLabel.text = @"TwitchAdBlock v" PACKAGE_VERSION;
        UIStackView *footerStackView =
            [[UIStackView alloc] initWithArrangedSubviews:@[ versionLabel ]];
        return footerStackView;
      }
      return nil;
    }
    default:
      return nil;
  }
  UITableViewHeaderFooterView *footerView =
      [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:nil];
  footerView.textLabel.text = title;
  footerView.textLabel.numberOfLines = 0;
  return footerView;
}
%new
- (void)settingsCellSwitchToggled:(id)sender {
  if (![sender isKindOfClass:objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell")]) {
    return;
  }
  
  _TtC6Twitch27SettingsSwitchTableViewCell *cell = (_TtC6Twitch27SettingsSwitchTableViewCell *)sender;
  NSString *accessibilityIdentifier = cell.accessibilityIdentifier;
  BOOL isOn = cell.isOn;
  
  if ([accessibilityIdentifier isEqualToString:@"AdBlockSwitchCell"]) {
    [tweakDefaults setBool:isOn forKey:@"TWAdBlockEnabled"];
    self.adblockEnabled = isOn;

    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:1];
    if (isOn)
      [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
    else
      [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
  } else if ([accessibilityIdentifier isEqualToString:@"AdBlockProxySwitchCell"]) {
    [tweakDefaults setBool:isOn forKey:@"TWAdBlockProxyEnabled"];
    self.proxyEnabled = isOn;

    NSMutableArray *indexPaths = [NSMutableArray array];
    [indexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:1]];
    if (self.customProxyEnabled) [indexPaths addObject:[NSIndexPath indexPathForRow:2 inSection:1]];
    if (isOn)
      [self.tableView insertRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationFade];
    else
      [self.tableView deleteRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationFade];
  } else if ([accessibilityIdentifier isEqualToString:@"AdBlockCustomProxySwitchCell"]) {
    [tweakDefaults setBool:isOn forKey:@"TWAdBlockCustomProxyEnabled"];
    self.customProxyEnabled = isOn;

    NSArray *indexPaths = @[ [NSIndexPath indexPathForRow:2 inSection:1] ];
    if (isOn)
      [self.tableView insertRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationFade];
    else
      [self.tableView deleteRowsAtIndexPaths:indexPaths
                            withRowAnimation:UITableViewRowAnimationFade];
  }

  [tweakDefaults synchronize];
}
%new
- (void)textFieldDidEndEditing:(UITextField *)textField {
  [tweakDefaults setValue:textField.text forKey:@"TWAdBlockProxy"];
}
%end
