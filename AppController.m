#import "AppController.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation AppController {
    NSSound *_sound;
    NSTimer *_timer;
    NSStatusItem *_statusItem;
    BOOL _isAlarming;
    BOOL _alarmEnabled;
    BOOL _beepsDone;
    NSMenuItem *_loginMenuItem;
    NSMenuItem *_beepsMenuItem;
    NSInteger _blinkCounter;
    NSInteger _numberOfBeeps;
    NSInteger _beepCount;
}

+ (void)initialize {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{CLStateOfAlarm: @YES, CLNumberOfBeeps: @0}];
}

- (void)awakeFromNib {
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.button.title = NSLocalizedString(@"📢", @"");
    _statusItem.menu = self.menuItemMenu;

    _sound = [NSSound soundNamed:@"Alarm"];
    _sound.delegate = self;

    _alarmEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:CLStateOfAlarm];
    _numberOfBeeps = [[NSUserDefaults standardUserDefaults] integerForKey:CLNumberOfBeeps];

    if (_alarmEnabled) {
        self.enabledMenuItem.title = NSLocalizedString(@"Deactivate Warning", @"");
        self.enabledMenuItem.tag = 1;
    } else {
        self.enabledMenuItem.title = NSLocalizedString(@"Activate Warning", @"");
        self.enabledMenuItem.tag = 0;
    }
    self.quitMenuItem.title = [NSLocalizedString(@"Quit", @"") stringByAppendingString:@" Cocoa CapsBeeper"];

    _loginMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Start on Login", @"")
                                                action:@selector(toggleStartOnLogin:)
                                         keyEquivalent:@""];
    _loginMenuItem.target = self;
    NSInteger quitIndex = [self.menuItemMenu indexOfItem:self.quitMenuItem];
    [self.menuItemMenu insertItem:_loginMenuItem atIndex:quitIndex];
    [self.menuItemMenu insertItem:[NSMenuItem separatorItem] atIndex:quitIndex + 1];

    if (SMAppService.mainAppService.status == SMAppServiceStatusEnabled) {
        _loginMenuItem.state = NSControlStateValueOn;
    }

    NSMenu *beepsSubmenu = [[NSMenu alloc] init];
    NSArray *options = @[@1, @2, @3, @5, @0];
    for (NSNumber *count in options) {
        NSString *title = count.integerValue == 0
            ? NSLocalizedString(@"Continuous", @"")
            : count.stringValue;
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                      action:@selector(selectNumberOfBeeps:)
                                               keyEquivalent:@""];
        item.tag = count.integerValue;
        item.target = self;
        if (count.integerValue == _numberOfBeeps) {
            item.state = NSControlStateValueOn;
        }
        [beepsSubmenu addItem:item];
    }

    _beepsMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Number of Beeps", @"")
                                                action:nil
                                         keyEquivalent:@""];
    _beepsMenuItem.submenu = beepsSubmenu;
    NSInteger enabledIndex = [self.menuItemMenu indexOfItem:self.enabledMenuItem];
    [self.menuItemMenu insertItem:_beepsMenuItem atIndex:enabledIndex + 1];
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
        _statusItem.button.title = NSLocalizedString(@"📢", @"");
    }
}

- (void)checkCapsLock:(NSTimer *)aTimer {
    BOOL capsLockOn = ([NSEvent modifierFlags] & NSEventModifierFlagCapsLock) != 0;
    if (capsLockOn && !_isAlarming && !_beepsDone) {
        _isAlarming = YES;
        _beepCount = 0;
        _blinkCounter = 0;
        [_sound play];
    } else if (!capsLockOn && (_isAlarming || _beepsDone)) {
        _isAlarming = NO;
        _beepsDone = NO;
        [_sound stop];
        _statusItem.button.title = NSLocalizedString(@"📢", @"");
    }

    if (_isAlarming && ++_blinkCounter % 5 == 0) {
        _statusItem.button.title = _statusItem.button.title.length == 0
            ? NSLocalizedString(@"📢", @"")
            : @"";
    }
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying {
    if (!_isAlarming) return;
    _beepCount++;
    if (_numberOfBeeps == 0 || _beepCount < _numberOfBeeps) {
        [_sound play];
    } else {
        _isAlarming = NO;
        _beepsDone = YES;
        _statusItem.button.title = NSLocalizedString(@"📢", @"");
    }
}

- (void)selectNumberOfBeeps:(NSMenuItem *)sender {
    for (NSMenuItem *item in _beepsMenuItem.submenu.itemArray) {
        item.state = NSControlStateValueOff;
    }
    sender.state = NSControlStateValueOn;
    _numberOfBeeps = sender.tag;
    [[NSUserDefaults standardUserDefaults] setInteger:_numberOfBeeps forKey:CLNumberOfBeeps];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setAlarmEnabled:_alarmEnabled];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] setBool:_alarmEnabled forKey:CLStateOfAlarm];
}

- (void)toggleStartOnLogin:(id)sender {
    NSError *error = nil;
    if (SMAppService.mainAppService.status == SMAppServiceStatusEnabled) {
        [SMAppService.mainAppService unregisterAndReturnError:&error];
        if (!error) {
            _loginMenuItem.state = NSControlStateValueOff;
        }
    } else {
        [SMAppService.mainAppService registerAndReturnError:&error];
        if (!error) {
            _loginMenuItem.state = NSControlStateValueOn;
        }
    }
}

- (IBAction)openWebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/henrik242/ccb"]];
}

@end
