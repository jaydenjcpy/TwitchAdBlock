#import <dlfcn.h>
#import "TWAdBlockSettingsViewController.h"

extern NSBundle *tweakBundle;
extern NSUserDefaults *tweakDefaults;

#define LOC(x, d) [tweakBundle localizedStringForKey:x value:d table:nil]

// Hook the existing Twitch switch cell to add our delegate and helper methods
%hook _TtC6Twitch27SettingsSwitchTableViewCell
%new
- (id)delegate {
    Ivar ivar = class_getInstanceVariable(object_getClass(self), "delegate");
    return ivar ? object_getIvar(self, ivar) : nil;
}

%new
- (void)setDelegate:(id)delegate {
    Ivar ivar = class_getInstanceVariable(object_getClass(self), "delegate");
    if (ivar) object_setIvar(self, ivar, delegate);
}

%new
- (BOOL)isOn {
    Ivar ivar = class_getInstanceVariable(object_getClass(self), "$__lazy_storage_$_switchView");
    UISwitch *sw = ivar ? object_getIvar(self, ivar) : nil;
    if (!sw) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UISwitch class]]) {
                sw = (UISwitch *)subview;
                break;
            }
        }
    }
    return sw ? sw.isOn : NO;
}

%new
- (void)configureWithTitle:(NSString *)title
                   subtitle:(NSString *)subtitle
                  isEnabled:(BOOL)isEnabled
                       isOn:(BOOL)isOn
    accessibilityIdentifier:(NSString *)accessibilityIdentifier {
    if ([self respondsToSelector:@selector(textLabel)]) {
        self.textLabel.text = title;
    }
    if ([self respondsToSelector:@selector(detailTextLabel)]) {
        self.detailTextLabel.text = subtitle;
    }
    
    Ivar ivar = class_getInstanceVariable(object_getClass(self), "$__lazy_storage_$_switchView");
    UISwitch *sw = ivar ? object_getIvar(self, ivar) : nil;
    if (!sw) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UISwitch class]]) {
                sw = (UISwitch *)subview;
                break;
            }
        }
    }
    
    if (sw) {
        sw.enabled = isEnabled;
        sw.on = isOn;
    }
    self.accessibilityIdentifier = accessibilityIdentifier;
}

- (void)settingsSwitchToggled {
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(settingsCellSwitchToggled:)]) {
        [delegate settingsCellSwitchToggled:self];
    } else {
        %orig;
    }
}
%end

// Implementation of TWAdBlockSettingsViewController
@implementation TWAdBlockSettingsViewController

- (instancetype)initWithTableViewStyle:(NSInteger)tableViewStyle themeManager:(id)themeManager {
    // Manually call the super initializer since we are not using %subclass here
    // We assume TWBaseTableViewController's initializer works as expected
    self = [super initWithTableViewStyle:tableViewStyle themeManager:themeManager];
    if (self) {
        _adblockEnabled = [tweakDefaults boolForKey:@"TWAdBlockEnabled"];
        _proxyEnabled = [tweakDefaults boolForKey:@"TWAdBlockProxyEnabled"];
        _customProxyEnabled = [tweakDefaults boolForKey:@"TWAdBlockCustomProxyEnabled"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TwitchAdBlock";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.adblockEnabled ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    if (section == 1) {
        if (!self.adblockEnabled) return 0;
        if (!self.proxyEnabled) return 1;
        return self.customProxyEnabled ? 3 : 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        _TtC6Twitch27SettingsSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdBlockSwitchCell"];
        if (!cell) {
            cell = [[objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AdBlockSwitchCell"];
        }
        [cell configureWithTitle:LOC(@"settings.adblock.title", @"Ad Block")
                        subtitle:nil
                       isEnabled:YES
                            isOn:[tweakDefaults boolForKey:@"TWAdBlockEnabled"]
         accessibilityIdentifier:@"AdBlockSwitchCell"];
        [cell setDelegate:self];
        return cell;
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            _TtC6Twitch27SettingsSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdBlockProxySwitchCell"];
            if (!cell) {
                cell = [[objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AdBlockProxySwitchCell"];
            }
            [cell configureWithTitle:LOC(@"settings.proxy.title", @"Ad Block Proxy")
                            subtitle:nil
                           isEnabled:YES
                                isOn:[tweakDefaults boolForKey:@"TWAdBlockProxyEnabled"]
             accessibilityIdentifier:@"AdBlockProxySwitchCell"];
            [cell setDelegate:self];
            return cell;
        }
        if (indexPath.row == 1) {
            _TtC6Twitch27SettingsSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdBlockCustomProxySwitchCell"];
            if (!cell) {
                cell = [[objc_getClass("_TtC6Twitch27SettingsSwitchTableViewCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AdBlockCustomProxySwitchCell"];
            }
            [cell configureWithTitle:LOC(@"settings.custom_proxy.title", @"Custom Proxy")
                            subtitle:nil
                           isEnabled:YES
                                isOn:[tweakDefaults boolForKey:@"TWAdBlockCustomProxyEnabled"]
             accessibilityIdentifier:@"AdBlockCustomProxySwitchCell"];
            [cell setDelegate:self];
            return cell;
        }
        if (indexPath.row == 2) {
            TWAdBlockSettingsTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TWAdBlockProxy"];
            if (!cell) {
                cell = [[objc_getClass("TWAdBlockSettingsTextFieldTableViewCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TWAdBlockProxy"];
            }
            if (cell.textField && cell.textField.textField) {
                cell.textField.textField.placeholder = PROXY_ADDR;
                cell.textField.textField.text = [tweakDefaults stringForKey:@"TWAdBlockProxy"];
                cell.textField.delegate = self;
            }
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) return LOC(@"settings.adblock.footer", @"Choose whether or not you want to block ads");
    if (section == 1) return LOC(@"settings.proxy.footer", @"Proxy specific requests through a proxy server based in an ad-free country");
    return nil;
}

- (void)settingsCellSwitchToggled:(id)sender {
    _TtC6Twitch27SettingsSwitchTableViewCell *cell = (_TtC6Twitch27SettingsSwitchTableViewCell *)sender;
    BOOL isOn = [cell isOn];
    NSString *identifier = cell.accessibilityIdentifier;
    
    if ([identifier isEqualToString:@"AdBlockSwitchCell"]) {
        [tweakDefaults setBool:isOn forKey:@"TWAdBlockEnabled"];
        self.adblockEnabled = isOn;
        [self.tableView reloadData];
    } else if ([identifier isEqualToString:@"AdBlockProxySwitchCell"]) {
        [tweakDefaults setBool:isOn forKey:@"TWAdBlockProxyEnabled"];
        self.proxyEnabled = isOn;
        [self.tableView reloadData];
    } else if ([identifier isEqualToString:@"AdBlockCustomProxySwitchCell"]) {
        [tweakDefaults setBool:isOn forKey:@"TWAdBlockCustomProxyEnabled"];
        self.customProxyEnabled = isOn;
        [self.tableView reloadData];
    }
    [tweakDefaults synchronize];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [tweakDefaults setValue:textField.text forKey:@"TWAdBlockProxy"];
    [tweakDefaults synchronize];
}

@end
