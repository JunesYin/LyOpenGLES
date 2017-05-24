//
//  ViewController.m
//  LyOpenGLES_02
//
//  Created by wJunes on 2017/4/25.
//  Copyright © 2017年 wJunes. All rights reserved.
//

#import "ViewController.h"


// 这个数据类型用于存储每一个顶点数据
typedef struct {
    GLKVector3 positionCoords;  // 顶点数据
    GLKVector2 textureCoords;   // 纹理坐标
} SceneVertex;


// 创建本例中要用到的三角形顶点数据
// 这里的数据比上一个例子新增了纹理数据
static const SceneVertex vertices[] =
{
    {{-0.5, -0.5, 0.0}, {0.0, 0.0}},  // 左下
    {{ 0.5, -0.5, 0.0}, {1.0, 0.0}},  // 右下
    {{-0.5,  0.5, 0.0}, {0.0, 1.0}},  // 左上
    // 解决图片只有一半显示的问题 begin
    {{ 0.5, -0.5, 0.0}, {1.0, 0.0}},
    {{-0.5,  0.5, 0.0}, {0.0, 1.0}},
    {{ 0.5,  0.5, 0.0}, {1.0, 1.0}}
    // 解决图片只有一半显示的问题 end
};



@interface ViewController ()
{
    GLuint vertexBufferId;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"ViewController's view is not a GLKView");
    
    // 创建一个OpenGL ES 2.0 context(上下文)并将其提供给view
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // 将刚刚创建的context设置为当前context
    [EAGLContext setCurrentContext:view.context];
    
    // 创建一个提供标准OpenGL ES 2.0的GLKBaseEffect
    self.baseEffect = [[GLKBaseEffect alloc] init];
    // 启用Shading Language programs（着色语言程序）
    self.baseEffect.useConstantColor = GL_TRUE;
    // 设置渲染使用的颜色
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    
    // 设置当前context的背景色为白色
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    
    // 生成缓存，并保存在vertexBufferId中
    glGenBuffers(1, &vertexBufferId);
    
    // 绑定缓存
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId);
    
    // 缓存数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
    
    
    // ============================================
    // 绘制纹理新增 begin
    // ============================================
    // 读入需要绘制的图片的CGImageRef内容
    // 毕竟OpenGL是基于C++的嘛，你直接给一个UIImage人怎么识别
    CGImageRef imageRefTulip = [UIImage imageNamed:@"tulip"].CGImage;
    
    // 使用GLKTextureLoader（纹理读取）从上边得到的imageRefTulip读取纹理信息
    // 解决纹理倒置问题 begin
//    GLKTextureInfo *textureInfoTulip = [GLKTextureLoader textureWithCGImage:imageRefTulip
//                                                                    options:nil
//                                                                      error:nil];
    GLKTextureInfo *textureInfoTulip = [GLKTextureLoader textureWithCGImage:imageRefTulip
                                                                    options:@{GLKTextureLoaderOriginBottomLeft: @(YES)}
                                                                      error:nil];
    // 解决纹理倒置问题 end
    
    // 将读取到的纹理信息缓存到baseEffec的texture2d0中
    self.baseEffect.texture2d0.name = textureInfoTulip.name;
    self.baseEffect.texture2d0.target = textureInfoTulip.target;
    // ============================================
    // 绘制纹理新增 end
    // ============================================
    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//    
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // 通知baseEffect准备好
    [self.baseEffect prepareToDraw];
    
    // 清理当前帧缓存的每一个像素缓存
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 绘制顶点数据准备
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVertex),
                          NULL + offsetof(SceneVertex, positionCoords));
    
    
    // 绘制纹理数据准备
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(SceneVertex),
                          NULL + offsetof(SceneVertex, textureCoords));
    
    
    // 执行绘画操作
    glDrawArrays(GL_TRIANGLES,
                 0,
                 sizeof(vertices) / sizeof(SceneVertex));
    
}


@end
