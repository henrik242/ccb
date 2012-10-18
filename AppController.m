#import "AppController.h"
#define IS_CAPS_LOCK(x)		(x & alphaLock)

@implementation AppController

+ (void)initialize {
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:[NSNumber numberWithBool:NO]] forKeys:[NSArray arrayWithObject:CLStateOfAlarm]]];
}

- (void)awakeFromNib {
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	menuItem = [bar statusItemWithLength:NSVariableStatusItemLength];
	[menuItem retain]; // keep it!
	[menuItem setTitle:NSLocalizedString(@"📢",@"")]; // title
	[menuItem setHighlightMode:YES]; // behave like main menu
	[menuItem setMenu:menuItemMenu];	
	
	isAlarming = NO;
	alarmIsEnabled = [[[NSUserDefaults standardUserDefaults] objectForKey:CLStateOfAlarm] boolValue];
	
	sound = [[NSSound soundNamed:@"Alarm"] retain];
	
	// Set menu state
	if (alarmIsEnabled) {
		[enabledMenuItem setTitle:NSLocalizedString(@"Deactivate Warning",@"")];
		[enabledMenuItem setTag:1];
	} else {
		[enabledMenuItem setTitle:NSLocalizedString(@"Activate Warning",@"")];
		[enabledMenuItem setTag:0];
	}
	[quitMenuItem setTitle:[NSLocalizedString(@"Quit",@"") stringByAppendingString:@" Carbon CapsBeeper"]];
}

- (IBAction)menuChanged:(id)sender {
	if ([enabledMenuItem tag] == 0) { // Activate Alarm
		[enabledMenuItem setTitle:NSLocalizedString(@"Deactivate Warning",@"")];
		[self setAlarmIsEnabled:YES];
		[enabledMenuItem setTag:1];
	} else { // Deactivate Alarm
		[enabledMenuItem setTitle:NSLocalizedString(@"Activate Warning",@"")];
		[self setAlarmIsEnabled:NO];
		[enabledMenuItem setTag:0];
	}
}

- (void)setAlarmIsEnabled:(BOOL)aBool {
	if (aBool != alarmIsEnabled) {
		if (aBool == YES) {
			timer = [[NSTimer scheduledTimerWithTimeInterval:0.1
													  target:self 
													selector:@selector(checkCapsLock:) 
													userInfo:nil 
													 repeats:YES] retain];
		} else {
			if ([sound isPlaying])
				[sound stop];
			isAlarming = NO;
			[timer invalidate];
			[timer release];
			timer = nil;
		}
		alarmIsEnabled = aBool;
	}
}

- (BOOL)alarmIsEnabled {
	return alarmIsEnabled;
}

- (void)checkCapsLock:(NSTimer *)aTimer {
	int keyModifier = GetCurrentKeyModifiers();  // the only real Carbon function
	if ( IS_CAPS_LOCK(keyModifier) && !isAlarming) {
		isAlarming = YES;
		[sound play];
	}
	else if ( !IS_CAPS_LOCK(keyModifier) && isAlarming) {
		isAlarming = NO;
		[sound stop];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	alarmIsEnabled = !alarmIsEnabled;
	[self setAlarmIsEnabled:!alarmIsEnabled];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[[NSStatusBar systemStatusBar] removeStatusItem:menuItem];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[self alarmIsEnabled]] forKey:CLStateOfAlarm];
}

- (void)dealloc {
	[self setAlarmIsEnabled:NO];
	[menuItem release];
	[sound release];
	
	[super dealloc];
}

- (IBAction)openWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/henrik242/ccb"]];
}

@end
