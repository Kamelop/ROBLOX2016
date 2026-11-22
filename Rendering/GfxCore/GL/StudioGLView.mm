#import "StudioGLView.h"
#import <QuartzCore/CAEAGLLayer.h>

@implementation RBXStudioGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

@end
