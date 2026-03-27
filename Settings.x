#import "Settings.h"

extern NSBundle *tweakBundle;
extern NSUserDefaults *tweakDefaults;

%hook _TtC6Twitch25AccountMenuViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1 &&
      indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
    @try {
      UITableViewStyle tableViewStyle = UITableViewStyleGrouped;
      if (@available(iOS 13, *)) tableViewStyle = UITableViewStyleInsetGrouped;
      
      id themeManager = [objc_getClass("_TtC12TwitchCoreUI21TWDefaultThemeManager") defaultThemeManager];
      if (!themeManager) {
        NSLog(@"TwitchAdBlock: Failed to get theme manager");
        return %orig;
      }
      
      Class settingsViewControllerClass = objc_getClass("TWAdBlockSettingsViewController");
      if (!settingsViewControllerClass) {
        NSLog(@"TwitchAdBlock: Failed to get settings view controller class");
        return %orig;
      }
      
      TWAdBlockSettingsViewController *adblockSettingsViewController =
          [[settingsViewControllerClass alloc]
              initWithTableViewStyle:tableViewStyle
                        themeManager:themeManager];
      
      if (!adblockSettingsViewController) {
        NSLog(@"TwitchAdBlock: Failed to create settings view controller");
        return %orig;
      }
      
      adblockSettingsViewController.tableView.separatorStyle =
          UITableViewCellSeparatorStyleSingleLine;
      return [self.navigationController pushViewController:adblockSettingsViewController
                                                  animated:YES];
    } @catch (NSException *exception) {
      NSLog(@"TwitchAdBlock: Exception when opening settings: %@", exception);
      return %orig;
    }
  }
  %orig;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger numberOfRows = %orig;
  if (section == [self numberOfSectionsInTableView:tableView] - 1) numberOfRows++;
  return numberOfRows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == [self numberOfSectionsInTableView:tableView] - 1 &&
      indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
    @try {
      _TtC6Twitch34ConfigurableAccessoryTableViewCell *cell =
          [[objc_getClass("_TtC6Twitch34ConfigurableAccessoryTableViewCell") alloc]
                initWithStyle:UITableViewCellStyleSubtitle
              reuseIdentifier:@"Twitch.ConfigurableAccessoryTableViewCell"];
      
      if (!cell) {
        return %orig;
      }
      
      [cell configureWithTitle:@"TwitchAdBlock"];
      
      UIImage *arrowImage = [UIImage imageNamed:@"arrow-forward"
                                        inBundle:tweakBundle
                   compatibleWithTraitCollection:nil];
      if (arrowImage) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[arrowImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
      }
      
      Ivar customImageViewIvar = class_getInstanceVariable(object_getClass(cell), "customImageView");
      if (customImageViewIvar) {
        UIImageView *customImageView = object_getIvar(cell, customImageViewIvar);
        if (customImageView) {
          UIImage *iconImage = [UIImage imageNamed:@"twab-icon"
                                       inBundle:tweakBundle
                  compatibleWithTraitCollection:nil];
          if (iconImage) {
            customImageView.image = [iconImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            customImageView.hidden = NO;
          }
        }
      }

      if ([cell respondsToSelector:@selector(useDefaultBackgroundColor)]) {
        cell.useDefaultBackgroundColor = YES;
      } else {
        Ivar ivar = class_getInstanceVariable(object_getClass(cell), "useDefaultBackgroundColor");
        if (ivar) {
          ptrdiff_t offset = ivar_getOffset(ivar);
          uint8_t *bytes = (uint8_t *)(__bridge void *)cell;
          *((BOOL *)(bytes + offset)) = YES;
        }
      }
      return cell;
    } @catch (NSException *exception) {
      NSLog(@"TwitchAdBlock: Exception when creating settings cell: %@", exception);
      return %orig;
    }
  }
  return %orig;
}
%end
