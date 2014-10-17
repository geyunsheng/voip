

#import "CustomizedAlertAnimation.h"

static CGFloat kTransitionDuration = 0.3;

@implementation CustomizedAlertAnimation

@synthesize view;

@synthesize delegate;

-(void)dealloc{
    if (delegate) {
        delegate = nil;
        
    }
    [view release];
    view = nil;
    [super dealloc];
}

-(id)customizedAlertAnimationWithUIview:(UIView *)v{
    if (self=[super init]) {
        view = v;
        
    }
    return self;
}

//get the transform of view based on the orientation of device.

-(CGAffineTransform)transformForOrientation{
    CGAffineTransform transform ;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication ]statusBarOrientation];
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            transform =  CGAffineTransformMakeRotation(M_PI*1.5);
            break;
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(M_PI/2);
            break;
        case UIInterfaceOrientationPortrait:
            transform = CGAffineTransformIdentity;
            break;
        default:
            transform = CGAffineTransformMakeRotation(-M_PI);
            break;
    }
    
    return transform;
}


//  begin the animation

-(void)showAlertAnimation{
    view.transform = CGAffineTransformScale([self transformForOrientation], 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/1.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(firstBouncesDidStop)];
    view.transform = CGAffineTransformScale([self transformForOrientation], 1.1, 1.1);
    [UIView commitAnimations];
}


-(void)dismissAlertAnimation{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    view.alpha = 0;
    [UIView setAnimationDidStopSelector:@selector(dismissAlertAnimationDidStoped)];
    [UIView commitAnimations];
}

#pragma  mark -- UIViewAnimation delegate

-(void)firstBouncesDidStop{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(secondBouncesDidStop)];
    view.transform = CGAffineTransformScale([self transformForOrientation], 0.9, 0.9);
    [UIView commitAnimations];
    
}


-(void)secondBouncesDidStop{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:kTransitionDuration/2];
    view.transform = [self transformForOrientation];
    [UIView commitAnimations];
    
    //You can do somethings at the end of animation
    
    [self.delegate showCustomizedAlertAnimationIsOverWithUIView:view];
}


-(void)dismissAlertAnimationDidStoped{
    [self.delegate dismissCustomizedAlertAnimationIsOverWithUIView:view];
}
@end