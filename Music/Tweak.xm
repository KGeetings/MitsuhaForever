#import "Tweak.h"

%group MitsuhaVisuals

MSHConfig *mshConfig = NULL;

%hook MusicArtworkComponentImageView

-(void)layoutSubviews{
    %orig;
    if ([mshConfig view] == NULL) return;

    UIView *me = (UIView *)self;

    if(@available(iOS 13.0, *)) {
		if ([NSStringFromClass([me.superview class]) isEqualToString:@"MusicApplication.NowPlayingContentView"]) {
            if (mshConfig.colorMode != 2) {
                [self readjustWaveColor];
            }

            [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
        }
	} else {
		if ([NSStringFromClass([me.superview class]) isEqualToString:@"Music.NowPlayingContentView"]) {
            if (mshConfig.colorMode != 2) {
                [self readjustWaveColor];
            }

            [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
        }
    }
}

%new;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"] && mshConfig.colorMode != 2) {
        [self readjustWaveColor];
    }
}

%new;
-(void)readjustWaveColor{
    [mshConfig colorizeView:((MusicArtworkComponentImageView*)self).image];
}

%end

%hook MusicNowPlayingControlsViewController

%property (retain,nonatomic) MSHView *mshView;

-(void)viewDidLoad{
    %orig;
    
    CGFloat height = CGRectGetHeight(self.view.bounds);
    self.view.clipsToBounds = 1;
    
    [mshConfig initializeViewWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    
    self.mshView = [mshConfig view];
    [self.view addSubview:[mshConfig view]];
    [self.view sendSubviewToBack:[mshConfig view]];

    for (UIView *subview in self.view.subviews) {
        subview.backgroundColor = [UIColor clearColor];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    %orig;
    [[mshConfig view] start];
    [mshConfig view].center = CGPointMake([mshConfig view].center.x, [mshConfig view].frame.size.height);
}

-(void)viewWillDisappear:(BOOL)animated{
    %orig;
    [[mshConfig view] stop];
}

%end

%end

%ctor{
    mshConfig = [MSHConfig loadConfigForApplication:@"Music"];
    mshConfig.waveOffsetOffset = 70;
    if(mshConfig.enabled){
        NSString *classString = nil;
        if(@available(iOS 13.0, *)) {
            classString = @"MusicApplication.ArtworkComponentImageView";
	    } else {
		    classString = @"Music.ArtworkComponentImageView";
        }
        
        %init(MitsuhaVisuals, MusicArtworkComponentImageView = NSClassFromString(classString));
    }
}
