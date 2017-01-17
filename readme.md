# 1.设计方案
+ MainViewController: 交互行为的Controller；
+ G8Tesseract：OCR识别的基础类；
+ AVCaptureVideoPreviewLayer: 用于生成摄像头预览的图层；
+ AVCaptureSession：摄像头控制会话；
+ CALayer：用于在预览图层上绘制扫描边框及半透明蒙板；
+ UIButton：用户点击行为控制启动识别操作。

# 2.程序依赖项
Podfile
```
platform :ios, '8.0'
target :Recognize do
pod 'TesseractOCRiOS', '4.0.0'
end
```

# 3.图片识别函数实现
```
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
        NSString *telNumber = [trimmedString substringWithRange:range];
        NSURL *aURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", telNumber]];
        [[UIApplication sharedApplication] openURL:aURL];
    }

}
```

# 4.扫描窗口绘制部分代码实现
```
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
    CGContextAddRect(ctx, CGRectMake(scanRect.origin.x + scanRect.size.width - 2, scanRect.origin.y, 2 , 8))；
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
```

