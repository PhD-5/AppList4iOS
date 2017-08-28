#import "AppListUtils.h"

%hook SpringBoard

%new
- (void)applicationDidBecomeActive:(id)application{
[AppListUtils updateAppList];
}



%end