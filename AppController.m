#import "AppController.h"

@implementation AppController {
    NSSound *_sound;
    NSTimer *_timer;
    NSStatusItem *_statusItem;
    BOOL _isAlarming;
    BOOL _alarmEnabled;
}

+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{CLStateOfAlarm: @YES}];
}

- (void)awakeFromNib {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.button.title = NSLocalizedString(@"📢", @"");
    _statusItem.menu = self.menuItemMenu;

    _sound = [NSSound soundNamed:@"Alarm"];

    _alarmEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:CLStateOfAlarm];

    if (_alarmEnabled) {
        self.enabledMenuItem.title = NSLocalizedString(@"Deactivate Warning", @"");
        self.enabledMenuItem.tag = 1;
    } else {
        self.enabledMenuItem.title = NSLocalizedString(@"Activate Warning", @"");
        self.enabledMenuItem.tag = 0;
    }
    self.quitMenuItem.title = [NSLocalizedString(@"Quit", @"") stringByAppendingString:@" Carbon CapsBeeper"];
}

- (IBAction)menuChanged:(id)sender {
    if (self.enabledMenuItem.tag == 0) {
        self.enabledMenuItem.title = NSLocalizedString(@"Deactivate Warning", @"");
        [self setAlarmEnabled:YES];
        self.enabledMenuItem.tag = 1;
    } else {
        self.enabledMenuItem.title = NSLocalizedString(@"Activate Warning", @"");
        [self setAlarmEnabled:NO];
        self.enabledMenuItem.tag = 0;
    }
}

- (void)setAlarmEnabled:(BOOL)enabled {
    _alarmEnabled = enabled;
    [_timer invalidate];
    _timer = nil;

    if (enabled) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(checkCapsLock:)
                                                userInfo:nil
                                                 repeats:YES];
    } else {
        [_sound stop];
        _isAlarming = NO;
    }
}

- (void)checkCapsLock:(NSTimer *)aTimer {
    BOOL capsLockOn = ([NSEvent modifierFlags] & NSEventModifierFlagCapsLock) != 0;
    if (capsLockOn && !_isAlarming) {
        _isAlarming = YES;
        [_sound play];
    } else if (!capsLockOn && _isAlarming) {
        _isAlarming = NO;
        [_sound stop];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setAlarmEnabled:_alarmEnabled];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] setBool:_alarmEnabled forKey:CLStateOfAlarm];
}

- (IBAction)openWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/henrik242/ccb"]];
}

@end
