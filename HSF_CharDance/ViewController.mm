//
//  ViewController.m
//  HSF_CharDance
//
//  Created by StarSky_MacBook Pro on 2019/4/24.
//  Copyright © 2019 StarSky_MacBook Pro. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/core/core.hpp>
#import <opencv2/highgui/highgui.hpp>

#import "ViewController.h"

// 先声明一个结构体用以标明长和宽
typedef struct{
    int width, height;
}SizeT;

@interface ViewController () <CvVideoCameraDelegate>
@property (weak, nonatomic) IBOutlet UILabel *myLabel;
@property (strong, nonatomic) CvVideoCamera *videoCamera;
@property (weak, nonatomic) IBOutlet UIView *cameraView;



@end

bool CameraFlag = false;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myLabel.font = [UIFont fontWithName:@"Courier" size:5];
    SizeT mySize = {60,60};
//    UIImage* myImage =[UIImage imageNamed:@"cake.jpg"];
//    myImage = [self resizeImage:myImage withSize:mySize];
//    myImage = [self grayImage:myImage];
//    _myLabel.text = [self convertImage:myImage];
    //_myLabel.text = [self convertImage:[self resizeImage:[UIImage imageNamed:@"cake.jpg"] withSize:mySize  ] ];
    
    CvVideoCamera *videoCamera = [[CvVideoCamera alloc] initWithParentView:self.cameraView];
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    videoCamera.defaultFPS = 30;
    videoCamera.grayscaleMode = NO;
    videoCamera.delegate = self;
    videoCamera.useAVCaptureVideoPreviewLayer = NO;
    
    _videoCamera = videoCamera;
    
    [videoCamera start];
}

/// 根据给定大小缩放图片
- (UIImage *)resizeImage:(UIImage *)image withSize:(SizeT)size {
    /// cv::Mat 对象为对应的图片的二维数组对象，我们可以很方便使用角标进行数组操作
    cv::Mat cvImage;
    /// 将UIImage对象转换为对应cv::Mat对象
    UIImageToMat(image, cvImage);
    cv::Mat reSizeImage;
    /// 重新赋值大小
    cv::resize(cvImage, reSizeImage, cv::Size(size.width, size.height));
    /// 释放
    cvImage.release();
    /// 生成新的UIImage
    UIImage *nImage = MatToUIImage(reSizeImage);
    /// 释放
    reSizeImage.release();
    return nImage;
}

- (UIImage *)grayImage:(UIImage *)image {
    cv::Mat cvImage;
    
    UIImageToMat(image, cvImage);
    
    cv::Mat gray;
    // 将图像转换为灰度显示
    cv::cvtColor(cvImage, gray, CV_RGB2GRAY);
    
    cvImage.release();
    // 将灰度图片转成UIImage
    UIImage *nImage = MatToUIImage(gray);
    
    gray.release();
    
    return nImage;
}

- (NSString *)convertImage:(UIImage *)image {
    cv::Mat gray;
    
    UIImageToMat(image, gray);
    // 获取一共多少列
    int row = gray.rows;
    // 获取一共多少行
    int col = gray.cols;
    // 初始化字符串数组 用来存储图片的每一行
    NSMutableArray <NSString *>* array = [NSMutableArray arrayWithCapacity:row];
    // 给定字符串灰度对应值
    NSArray *pixels = @[@"$", @"@", @"B", @"%", @"8", @"&", @"W", @"M", @"#", @"*", @"o", @"a", @"h", @"k", @"b", @"d", @"p", @"q", @"w", @"m", @"Z", @"0", @"o", @"Q", @"L", @"C", @"J", @"U", @"Y", @"X", @"z", @"c", @"v", @"u", @"n", @"x", @"r", @"j", @"f", @"t", @"/", @"\\", @"|", @"(", @")", @"1", @"{", @"}", @"[", @"]", @"?", @"-", @"_", @"+", @"~", @"<", @">", @"i", @"!", @"l", @"I", @";", @":", @",", @"\"", @"^", @"`", @"'", @".", @" "];;
    
    for (int i = 0 ; i < row; i ++) {
        NSMutableArray <NSString *>*item = [NSMutableArray arrayWithCapacity:col];
        
        for (int j = 0; j < col; j ++) {
            // 取出对应灰度值
            int temp = gray.at<uchar>(i, j);
            // 计算灰度百分比
            CGFloat percent = temp / 255.f;
            // 根据百分比取出对应的字符
            int totalCount = (pixels.count - 1) * percent;
            // 加入到字符串数组里
            [item addObject:pixels[totalCount]];
        }
        // 将数组转成字符串
        [array addObject:[item componentsJoinedByString:@" "]];
    }
    
    gray.release();
    // 返回分好行后的字符串
    return [array componentsJoinedByString:@"\n"];
}

- (void)processImage:(cv::Mat &)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        SizeT size;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            size.width = 54;
            size.height = 96;
        }
        else{
            size.width = 108;
            size.height = 192;
        }

        
        UIImage *myImage = MatToUIImage(image);
        myImage = [self resizeImage:myImage withSize:size];
        myImage = [self grayImage:myImage];
        self->_myLabel.text = [self convertImage:myImage];
        
    });
}

- (IBAction)changeCamera:(id)sender {
    if(CameraFlag = !CameraFlag)
    {
        CvVideoCamera *videoCamera = [[CvVideoCamera alloc] initWithParentView:self.cameraView];
        videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
        videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        videoCamera.defaultFPS = 30;
        videoCamera.grayscaleMode = NO;
        videoCamera.delegate = self;
        videoCamera.useAVCaptureVideoPreviewLayer = NO;
        
        _videoCamera = videoCamera;
        
        [videoCamera start];
    }
    else{
        CvVideoCamera *videoCamera = [[CvVideoCamera alloc] initWithParentView:self.cameraView];
        videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
        videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        videoCamera.defaultFPS = 30;
        videoCamera.grayscaleMode = NO;
        videoCamera.delegate = self;
        videoCamera.useAVCaptureVideoPreviewLayer = NO;
        
        _videoCamera = videoCamera;
        
        [videoCamera start];
    }
    

}




@end
