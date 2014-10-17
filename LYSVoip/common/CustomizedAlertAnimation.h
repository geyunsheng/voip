

//这个类主要时用来对指定的view进行动画，，动画类似UIAlertView的出现和消失
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol CustomizedAlertAnimationDelegate;


@interface CustomizedAlertAnimation : NSObject

@property(strong,nonatomic)UIView *view;

@property(assign,nonatomic)id<CustomizedAlertAnimationDelegate> delegate;

-(id)customizedAlertAnimationWithUIview:(UIView *)v;

-(void)showAlertAnimation;

-(void)dismissAlertAnimation;
@end



@protocol CustomizedAlertAnimationDelegate

-(void)showCustomizedAlertAnimationIsOverWithUIView:(UIView *)v;

-(void)dismissCustomizedAlertAnimationIsOverWithUIView:(UIView *)v;
@end