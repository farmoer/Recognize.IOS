//
//  ViewController.m
//  Recognize
//
//  Created by bijinlong on 26/12/2016.
//  Copyright © 2016 bijinlong. All rights reserved.
//

#import "MainViewController.h"
#import <TesseractOCR/TesseractOCR.h>

@interface MainViewController ()<CALayerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate ,G8TesseractDelegate>
@end

@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCapture];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (void)initCapture {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.alwaysDiscardsLateVideoFrames = YES;
    
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [output setVideoSettings:videoSettings];
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session addInput:input];
    [self.session addOutput:output];
    [self.session startRunning];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.session];
    
    scanRect = CGRectMake(self.view.bounds.size.width/4, (self.view.bounds.size.height - 100)/2 - 20, self.view.bounds.size.width * 2/4, 40);
    
    self.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.previewLayer];
    
    self.viewfinderLayer = [CALayer layer];
    self.viewfinderLayer.frame = self.view.bounds;
    self.viewfinderLayer.delegate = self;
    
    [self.view.layer addSublayer:self.viewfinderLayer];
    [self.viewfinderLayer setNeedsDisplay];
    
    NSLog(@"bounds:%@", NSStringFromCGRect(self.view.bounds));

    self.recognizeButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    self.recognizeButton.frame = CGRectMake(self.view.bounds.size.width/2 - 24, self.view.bounds.size.height - 74, 48, 48);
    [self.recognizeButton setBackgroundImage:[UIImage imageNamed:@"camera_white"]  forState:UIControlStateNormal];
    [self.recognizeButton addTarget:self action:@selector(buttonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recognizeButton];
    
}

- (void)buttonTouchUpInside
{
    NSLog(@"start recognition");
    [self tesseractRecognizeImage:self.image];
}

- (void)tesseractRecognizeImage:(UIImage *)image   {
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;
    [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"];
    //[tesseract setRect:rect];
    tesseract.image = [image g8_blackAndWhite];
    tesseract.image = image;
    [tesseract recognize];
    
    NSString *trimmedString = [[tesseract.recognizedText stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSLog(@"trimmedString ：%@", trimmedString);
    
    
    NSRange range = [trimmedString rangeOfString:@"1[3|4|5|7|8][0-9]\\d{8}" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        
        NSString *telNumber = [NSString stringWithFormat:@"telprompt:%@@139.com", [trimmedString substringWithRange:range]];
        NSURL *aURL = [NSURL URLWithString:telNumber];
        //if ([[UIApplication sharedApplication] canOpenURL:aURL]) {
        [[UIApplication sharedApplication] openURL:aURL];
        //}
    }

}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{

    CGContextAddRect(ctx, CGRectMake(0, 0, self.view.bounds.size.width , scanRect.origin.y));
    CGContextAddRect(ctx, CGRectMake(0, scanRect.origin.y, scanRect.origin.x, self.view.bounds.size.height - scanRect.origin.y - 100));
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x + scanRect.size.width, scanRect.origin.y, self.view.bounds.size.width - scanRect.origin.x - scanRect.size.width , self.view.bounds.size.height - scanRect.origin.y - 100));
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x, scanRect.origin.y + scanRect.size.height, scanRect.size.width , self.view.bounds.size.height - scanRect.origin.y - scanRect.size.height - 100));
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.23529412);
    CGContextFillPath(ctx);
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x, scanRect.origin.y, 2 , 8));
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x, scanRect.origin.y, 8 , 2));
    
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x + scanRect.size.width - 8, scanRect.origin.y, 8 , 2));
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x + scanRect.size.width - 2, scanRect.origin.y, 2 , 8));
    
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x, scanRect.origin.y + scanRect.size.height - 8, 2 , 8));
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x, scanRect.origin.y + scanRect.size.height - 2, 8 , 2));
    
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x + scanRect.size.width - 8, scanRect.origin.y + scanRect.size.height - 2, 8 , 2));
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x + scanRect.size.width - 2, scanRect.origin.y + scanRect.size.height - 8, 2 , 8));
    CGContextSetRGBFillColor(ctx, 0, 1, 0, 1);
    CGContextFillPath(ctx);
    
    
    CGContextAddRect(ctx, CGRectMake(0, self.view.bounds.size.height - 100 , self.view.bounds.size.width , 100));
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.9);
    CGContextFillPath(ctx);

    
}
-(void)back:(id)sender{
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)viewDidUnload {
    [self.session stopRunning];
    self.previewLayer = nil;
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,                                                  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(newContext);
    
    float rate =  width / self.view.bounds.size.height;
    CGRect newRect = CGRectMake( scanRect.origin.y * rate ,scanRect.origin.x * rate , scanRect.size.height * rate, scanRect.size.width * rate);
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, newRect);
    
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    //id object = (__bridge id)imagePartRef;
    //[self.customLayer performSelectorOnMainThread:@selector(setContents:) withObject: object waitUntilDone:YES];
    self.image = [UIImage imageWithCGImage:imagePartRef scale:1.0 orientation:UIImageOrientationRight];
    
    CGImageRelease(imageRef);
    CGImageRelease(imagePartRef);
    //[self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}
@end
