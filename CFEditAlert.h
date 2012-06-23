//
//  CFEditAlert.h
//
//  Created by Dan Zimmerman on 6/20/12.
//

#import <UIKit/UIKit.h>

@interface CFEditAlert : UIAlertView {
    NSArray *colorSlides;
    UISlider *r;
    UISlider *g;
    UISlider *b;
    UILabel *rl, *gl, *bl;
    UIView *currentColorView;
    NSMutableArray *recentColors;
    UIScrollView *recentsScroll;
}

@property (nonatomic, readwrite) UIColor *color;
- (id)initWithColor:(UIColor *)c delegate:(id)del recentColors:(id)col,...;
//either UIcolor variable args or a nsarray of uicolor

@end
