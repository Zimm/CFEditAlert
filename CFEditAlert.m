//
//  CFEditAlert.m
//
//  Created by Dan Zimmerman on 6/20/12.
//

#import "CFEditAlert.h"
#include <stdarg.h>

@implementation CFEditAlert
@dynamic color;

- (id)initWithColor:(UIColor *)c delegate:(id)del recentColors:(id)col,... {
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:0];
    va_list vl;
    va_start(vl, col);
    if (col && [col isKindOfClass:[NSArray class]]) {
        [a addObjectsFromArray:[(NSArray*)col reversedArray]];
    } else {
        [a addObject:col];
        UIColor *rec;
        while ((rec = va_arg(vl, id)) != nil) {
            [a addObject:rec];
        }
    }
    if ((self = [super initWithTitle:@"" message:a.count ? @"\n\n\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n" delegate:del cancelButtonTitle:@"Okay" otherButtonTitles:nil]) != nil) {
        recentColors = [[NSMutableArray alloc] initWithArray:a];
        float red, green, blue, alpha;
        [c getRed:&red green:&green blue:&blue alpha:&alpha];
        r = [[UISlider alloc] initWithFrame:CGRectZero];
        [r sizeToFit];
        r.minimumValue = 0.0f;
        r.maximumValue = 1.0f;
        r.value = red;
        [r addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:r];
        g = [[UISlider alloc] initWithFrame:CGRectZero];
        [g sizeToFit];
        g.minimumValue = 0.0f;
        g.maximumValue = 1.0f;
        g.value = green;
        [g addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:g];
        b = [[UISlider alloc] initWithFrame:CGRectZero];
        [b sizeToFit];
        b.minimumValue = 0.0f;
        b.maximumValue = 1.0f;
        b.value = blue;
        [b addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:b];
        colorSlides = [[NSArray alloc] initWithObjects:r,g,b, nil];
        rl = [[UILabel alloc] initWithFrame:CGRectZero];
        rl.font = [UIFont boldSystemFontOfSize:12.0f];
        rl.textColor = [UIColor whiteColor];
        rl.text = @"Red";
        rl.backgroundColor = [UIColor clearColor];
        [self addSubview:rl];
        bl = [[UILabel alloc] initWithFrame:CGRectZero];
        bl.font = [UIFont boldSystemFontOfSize:12.0f];
        bl.textColor = [UIColor whiteColor];
        bl.text = @"Blue";
        bl.backgroundColor = [UIColor clearColor];
        [self addSubview:bl];
        gl = [[UILabel alloc] initWithFrame:CGRectZero];
        gl.font = [UIFont boldSystemFontOfSize:12.0f];
        gl.textColor = [UIColor whiteColor];
        gl.text = @"Green";
        gl.backgroundColor = [UIColor clearColor];
        [self addSubview:gl];
        currentColorView = [[UIView alloc] initWithFrame:CGRectZero];
        currentColorView.backgroundColor = c;
        currentColorView.layer.cornerRadius = 5.0f;
        [self addSubview:currentColorView];
        if (recentColors.count) {
            recentsScroll = [[UIScrollView alloc] initWithFrame:CGRectZero];
            recentsScroll.backgroundColor = [UIColor clearColor];
            recentsScroll.alwaysBounceVertical = NO;
            recentsScroll.alwaysBounceHorizontal = YES;
            recentsScroll.showsHorizontalScrollIndicator = YES;
            recentsScroll.showsVerticalScrollIndicator = NO;
            [self addSubview:recentsScroll];
        }
        [self changed:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [r sizeToFit];
    [g sizeToFit];
    [b sizeToFit];
    currentColorView.frame = CGRectMake(20.0f, 20.0f, self.frame.size.width-67.5f, 30.0f);
    r.frame = CGRectMake(60.0f, 60.0f, self.frame.size.width-100.0f, r.frame.size.height);
    g.frame = CGRectMake(60.0f, 20.0f + CGRectGetMaxY(r.frame), self.frame.size.width-100.0f, g.frame.size.height);
    b.frame = CGRectMake(60.0f, 20.0f + CGRectGetMaxY(g.frame), self.frame.size.width-100.0f, b.frame.size.height);
    rl.frame = CGRectMake(20.0f, r.frame.origin.y, 40.0f, r.frame.size.height);
    gl.frame = CGRectMake(15.0f, g.frame.origin.y, 35.0f, g.frame.size.height);
    bl.frame = CGRectMake(20.0f, b.frame.origin.y, 40.0f, b.frame.size.height);
    [self bringSubviewToFront:r];
    [self bringSubviewToFront:g];
    [self bringSubviewToFront:b];
    recentsScroll.frame = CGRectMake(currentColorView.frame.origin.x, CGRectGetMaxY(b.frame) + 20.0f, currentColorView.frame.size.width, 40.0f);
    float xoff = 5.0f;
    float yoff = 5.0f;
    float contwidth = 30.0f, contheight = 30.0f;
    [recentsScroll.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    for (UIColor *col in recentColors) {
        UIControl *control = [[UIControl alloc] initWithFrame:(CGRect){xoff,yoff,contwidth,contheight}];
        [control addTarget:self action:@selector(recented:) forControlEvents:UIControlEventTouchUpInside];
        xoff += contwidth + 10.0f;
        control.backgroundColor = col;
        control.layer.cornerRadius = 5.0f;
        [recentsScroll addSubview:control];
    }
    recentsScroll.contentSize = (CGSize){xoff+contwidth+5.0f,recentsScroll.frame.size.height};
    
}

- (void)recented:(UIControl *)cont {
    [self setColor:cont.backgroundColor];
}

- (void)changed:(UISlider *)s {
    currentColorView.backgroundColor = [self color];
//    CIFilter *filt = [CIFilter filterWithName:@"CIColorMonochrome"]; // CIImage
//    [filt setDefaults];
//    [filt setValue:[CIColor colorWithRed:((UISlider*)[colorSlides objectAtIndex:0]).value green:((UISlider*)[colorSlides objectAtIndex:1]).value blue:((UISlider*)[colorSlides objectAtIndex:2]).value alpha:1] forKey:@"inputColor"];
//    self.layer.filters = [NSArray arrayWithObject:filt];
}

- (void)setColor:(UIColor *)color {
    float red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    r.value = red;
    g.value = green;
    b.value = blue;
    [self changed:nil];
}

- (UIColor *)color {
    return [UIColor colorWithRed:((UISlider*)[colorSlides objectAtIndex:0]).value green:((UISlider*)[colorSlides objectAtIndex:1]).value blue:((UISlider*)[colorSlides objectAtIndex:2]).value alpha:1];
}

@end
