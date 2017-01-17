//
//  ViewController.h
//  Recognize
//
//  Created by bijinlong on 26/12/2016.
//  Copyright © 2016 bijinlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MainViewController : UIViewController
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) CALayer *viewfinderLayer;
@property (nonatomic, strong) UIButton *recognizeButton;
@property (nonatomic, strong) UIImage *image;
@end
CGRect scanRect;
