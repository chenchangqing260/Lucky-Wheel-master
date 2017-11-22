//
//  ViewController.m
//  抽奖_Test
//
//  Created by aaron on 14-7-18.
//  Copyright (c) 2014年 The Technology Studio. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    float random;
    float startValue;
    float endValue;
    NSDictionary *awards;
    NSArray *miss;
    NSArray *data;
    NSString *result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    _plateImageView.image = [image rotate]
    
    UIImage *image = self.rotateStaticImageView.image;
    UIImage *newImg = [self image:image rotation:UIImageOrientationDown];
    self.rotateStaticImageView.image = newImg;
    
    data = @[@"500M",@"OFO月卡",@"50M",@"OFO3月卡",@"100M",@"谢谢参与",@"1G",@"谢谢参与"];
    
//中奖和没中奖之间的分隔线设有2个弧度的盲区，指针不会旋转到的，避免抽奖的时候起争议。
    miss = @[
             @{
                 @"min": @90,
                 @"max":@133
             },
             @{
                 @"min": @2,
                 @"max":@43
                 }
             ];
    
    
    awards = @{
               @"500M": @[
                           @{
                             @"min": @137,
                             @"max":@178
                            }
                          ],
               @"OFO月卡": @[
                       @{
                           @"min": @182,
                           @"max":@223
                           }
                       ],
               @"50M": @[
                       @{
                           @"min": @227,
                           @"max":@268
                           }
                       ],
               @"OFO3月卡": @[
                       @{
                           @"min": @272,
                           @"max":@314
                           }
                       ],
               @"100M": @[
                       @{
                           @"min": @315,
                           @"max":@358
                           }
                       ],
               @"1G": @[
                       @{
                           @"min": @47,
                           @"max":@89
                           }
                       ],
               @"谢谢参与": miss
               };
    
}

- (IBAction)start:(id)sender {
   
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    endValue = [self fetchResult];
    rotationAnimation.delegate = self;
    rotationAnimation.fromValue = @(startValue);
    rotationAnimation.toValue = @(endValue);
    rotationAnimation.duration = 2.0f;
    rotationAnimation.autoreverses = NO;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeBoth;
    [_plateImageView.layer addAnimation:rotationAnimation forKey:@"revItUpAnimation"];
    
 
}

-(float)fetchResult{
    
    //todo: fetch result from remote service
    srand((unsigned)time(0));
    random = rand() %6;
    int i = random;
    i = 2;
    result = data[i];  //TEST DATA ,shoud fetch result from remote service
    if (_labelTextField.text != nil && ![_labelTextField.text isEqualToString:@""]) {
        result = _labelTextField.text;
    }
    for (NSString *str in [awards allKeys]) {
        if ([str isEqualToString:result]) {
            NSDictionary *content = awards[str][0];
            int min = [content[@"min"] intValue];
            int max = [content[@"max"] intValue];
            
            
            srand((unsigned)time(0));
            random = rand() % (max - min) +min;
            
            return radians(random + 360*5);
        }
    }

    random = rand() %2;
    i = random;
    NSDictionary *content = miss[i];
    int min = [content[@"min"] intValue];
    int max = [content[@"max"] intValue];

    srand((unsigned)time(0));
    random = rand() % (max - min) +min;
    
    return radians(random + 360*5);
    
}

//角度转弧度
double radians(float degrees) {
    return degrees*M_PI/180;
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    startValue = endValue;
    if (startValue >= endValue) {
        startValue = startValue - radians(360*10);
    }
    
    NSLog(@"startValue = %f",startValue);
    NSLog(@"result = %@",result);
    _label1.text = result;
    NSLog(@"endValue = %f\n",endValue);
}

- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newPic;
}

@end
