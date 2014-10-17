//自定义的  alert view 类

#import <Foundation/Foundation.h>

#import "CustomizedAlertAnimation.h"

@protocol CustomeAlertViewDelegate ;



@interface CustomeAlertView : UIWindow  <CustomizedAlertAnimationDelegate>

@property(strong,nonatomic)UIView *myView;
@property(strong,nonatomic)CustomizedAlertAnimation *animation;
@property(assign,nonatomic)id<CustomeAlertViewDelegate> delegate;
@property(assign,nonatomic)NSInteger flag;
-(void)show;
- (void)setViewFrame:(CGRect)frame;
-(void)dismiss;
-(id)initWithBtnTitle1:(NSString*)btnTitle1 andBtnTitle2:(NSString*)btnTitle2;
@end


@protocol CustomeAlertViewDelegate

-(void)CustomeAlertViewDismiss:(CustomeAlertView *) alertView;
@end
