#import <UIKit/UIKit.h>
#import <QuartzCore/CAEAGLLayer.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#include "ContextGL.h"
#include "HeadersGL.h"
#include "rbx/Debug.h"

#include <dlfcn.h>
#include <stdexcept>

LOGGROUP(Graphics)

namespace
{
template <typename T>
T loadGLProc(const char* coreName, const char* extensionName)
{
    T result = reinterpret_cast<T>(dlsym(RTLD_DEFAULT, coreName));
    if (!result && extensionName)
        result = reinterpret_cast<T>(dlsym(RTLD_DEFAULT, extensionName));
    return result;
}

typedef void (*BindVertexArrayProc)(GLuint);
typedef void (*DeleteVertexArraysProc)(GLsizei, const GLuint*);
typedef void (*GenVertexArraysProc)(GLsizei, GLuint*);
typedef void* (*MapBufferProc)(GLenum, GLenum);
typedef GLboolean (*UnmapBufferProc)(GLenum);
typedef void* (*MapBufferRangeProc)(GLenum, GLintptr, GLsizeiptr, GLbitfield);
typedef void (*TexImage3DProc)(GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, const GLvoid*);
typedef void (*TexSubImage3DProc)(GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLenum, const GLvoid*);
typedef void (*TexStorage2DProc)(GLenum, GLsizei, GLenum, GLsizei, GLsizei);
typedef void (*TexStorage3DProc)(GLenum, GLsizei, GLenum, GLsizei, GLsizei, GLsizei);
typedef GLsync (*FenceSyncProc)(GLenum, GLbitfield);
typedef void (*DeleteSyncProc)(GLsync);
typedef GLenum (*ClientWaitSyncProc)(GLsync, GLbitfield, GLuint64);
typedef void (*WaitSyncProc)(GLsync, GLbitfield, GLuint64);
typedef void (*BlitFramebufferProc)(GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLbitfield, GLenum);
typedef void (*RenderbufferStorageMultisampleProc)(GLenum, GLsizei, GLenum, GLsizei, GLsizei);
typedef void (*InvalidateFramebufferProc)(GLenum, GLsizei, const GLenum*);

BindVertexArrayProc bindVertexArrayProc = 0;
DeleteVertexArraysProc deleteVertexArraysProc = 0;
GenVertexArraysProc genVertexArraysProc = 0;
MapBufferProc mapBufferProc = 0;
UnmapBufferProc unmapBufferProc = 0;
MapBufferRangeProc mapBufferRangeProc = 0;
TexImage3DProc texImage3DProc = 0;
TexSubImage3DProc texSubImage3DProc = 0;
TexStorage2DProc texStorage2DProc = 0;
TexStorage3DProc texStorage3DProc = 0;
FenceSyncProc fenceSyncProc = 0;
DeleteSyncProc deleteSyncProc = 0;
ClientWaitSyncProc clientWaitSyncProc = 0;
WaitSyncProc waitSyncProc = 0;
BlitFramebufferProc blitFramebufferProc = 0;
RenderbufferStorageMultisampleProc renderbufferStorageMultisampleProc = 0;
InvalidateFramebufferProc invalidateFramebufferProc = 0;

void loadGLExtensions()
{
    bindVertexArrayProc = loadGLProc<BindVertexArrayProc>("glBindVertexArray", "glBindVertexArrayOES");
    deleteVertexArraysProc = loadGLProc<DeleteVertexArraysProc>("glDeleteVertexArrays", "glDeleteVertexArraysOES");
    genVertexArraysProc = loadGLProc<GenVertexArraysProc>("glGenVertexArrays", "glGenVertexArraysOES");
    mapBufferProc = loadGLProc<MapBufferProc>("glMapBuffer", "glMapBufferOES");
    unmapBufferProc = loadGLProc<UnmapBufferProc>("glUnmapBuffer", "glUnmapBufferOES");
    mapBufferRangeProc = loadGLProc<MapBufferRangeProc>("glMapBufferRange", "glMapBufferRangeEXT");
    texImage3DProc = loadGLProc<TexImage3DProc>("glTexImage3D", "glTexImage3DOES");
    texSubImage3DProc = loadGLProc<TexSubImage3DProc>("glTexSubImage3D", "glTexSubImage3DOES");
    texStorage2DProc = loadGLProc<TexStorage2DProc>("glTexStorage2D", "glTexStorage2DEXT");
    texStorage3DProc = loadGLProc<TexStorage3DProc>("glTexStorage3D", "glTexStorage3DEXT");
    fenceSyncProc = loadGLProc<FenceSyncProc>("glFenceSync", "glFenceSyncAPPLE");
    deleteSyncProc = loadGLProc<DeleteSyncProc>("glDeleteSync", "glDeleteSyncAPPLE");
    clientWaitSyncProc = loadGLProc<ClientWaitSyncProc>("glClientWaitSync", "glClientWaitSyncAPPLE");
    waitSyncProc = loadGLProc<WaitSyncProc>("glWaitSync", "glWaitSyncAPPLE");
    blitFramebufferProc = loadGLProc<BlitFramebufferProc>("glBlitFramebuffer", "glBlitFramebufferANGLE");
    renderbufferStorageMultisampleProc = loadGLProc<RenderbufferStorageMultisampleProc>("glRenderbufferStorageMultisample", "glRenderbufferStorageMultisampleAPPLE");
    invalidateFramebufferProc = loadGLProc<InvalidateFramebufferProc>("glInvalidateFramebuffer", "glDiscardFramebufferEXT");
}
}

GLvoid glBindVertexArray(GLuint array)
{
    if (bindVertexArrayProc) bindVertexArrayProc(array);
}
GLvoid glDeleteVertexArrays(GLsizei n, const GLuint* arrays)
{
    if (deleteVertexArraysProc) deleteVertexArraysProc(n, arrays);
}
GLvoid glGenVertexArrays(GLsizei n, GLuint* arrays)
{
    if (genVertexArraysProc) genVertexArraysProc(n, arrays);
}
GLvoid* glMapBuffer(GLenum target, GLenum access)
{
    return mapBufferProc ? mapBufferProc(target, access) : 0;
}
GLboolean glUnmapBuffer(GLenum target)
{
    return unmapBufferProc ? unmapBufferProc(target) : GL_FALSE;
}
GLvoid* glMapBufferRange(GLenum target, GLintptr offset, GLsizeiptr length, GLbitfield access)
{
    return mapBufferRangeProc ? mapBufferRangeProc(target, offset, length, access) : 0;
}
GLvoid glTexImage3D(GLenum target, GLint level, GLenum internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const GLvoid* pixels)
{
    if (texImage3DProc) texImage3DProc(target, level, internalFormat, width, height, depth, border, format, type, pixels);
}
GLvoid glTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const GLvoid* pixels)
{
    if (texSubImage3DProc) texSubImage3DProc(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels);
}
GLvoid glTexStorage2D(GLenum target, GLsizei levels, GLenum internalFormat, GLsizei width, GLsizei height)
{
    if (texStorage2DProc) texStorage2DProc(target, levels, internalFormat, width, height);
}
GLvoid glTexStorage3D(GLenum target, GLsizei levels, GLenum internalFormat, GLsizei width, GLsizei height, GLsizei depth)
{
    if (texStorage3DProc) texStorage3DProc(target, levels, internalFormat, width, height, depth);
}
GLsync glFenceSync(GLenum condition, GLbitfield flags)
{
    return fenceSyncProc ? fenceSyncProc(condition, flags) : 0;
}
void glDeleteSync(GLsync sync)
{
    if (deleteSyncProc) deleteSyncProc(sync);
}
GLenum glClientWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout)
{
    return clientWaitSyncProc ? clientWaitSyncProc(sync, flags, timeout) : GL_WAIT_FAILED;
}
void glWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout)
{
    if (waitSyncProc) waitSyncProc(sync, flags, timeout);
}
GLvoid glBlitFramebuffer(GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter)
{
    if (blitFramebufferProc) blitFramebufferProc(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}
GLvoid glRenderbufferStorageMultisample(GLenum target, GLsizei samples, GLenum internalFormat, GLsizei width, GLsizei height)
{
    if (renderbufferStorageMultisampleProc) renderbufferStorageMultisampleProc(target, samples, internalFormat, width, height);
}
GLvoid glInvalidateFramebuffer(GLenum target, GLsizei numAttachments, const GLenum* attachments)
{
    if (invalidateFramebufferProc) invalidateFramebufferProc(target, numAttachments, attachments);
}

namespace RBX
{
namespace Graphics
{

class ContextGLEAGL : public ContextGL
{
public:
    explicit ContextGLEAGL(void* windowHandle)
        : view(static_cast<UIView*>(windowHandle))
        , layer(nil)
        , context(nil)
        , framebuffer(0)
        , colorRenderbuffer(0)
        , surfaceWidth(0)
        , surfaceHeight(0)
    {
        if (!view)
            throw std::runtime_error("iOS OpenGL ES context requires a UIView.");

        layer = (CAEAGLLayer*)[view layer];
        if (![layer isKindOfClass:[CAEAGLLayer class]])
            throw std::runtime_error("The host UIView must use CAEAGLLayer as its backing layer.");

        layer.opaque = YES;
        layer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
            kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!context)
            throw std::runtime_error("Unable to create an OpenGL ES 2 EAGLContext.");

        if (![EAGLContext setCurrentContext:context])
            throw std::runtime_error("Unable to make the EAGLContext current.");

        glGenFramebuffers(1, &framebuffer);
        glGenRenderbuffers(1, &colorRenderbuffer);
        if (!rebuildDrawable())
            throw std::runtime_error("Unable to create the iOS drawable framebuffer.");

        loadGLExtensions();
    }

    virtual ~ContextGLEAGL()
    {
        if (context)
            [EAGLContext setCurrentContext:context];

        if (colorRenderbuffer)
            glDeleteRenderbuffers(1, &colorRenderbuffer);
        if (framebuffer)
            glDeleteFramebuffers(1, &framebuffer);

        if ([EAGLContext currentContext] == context)
            [EAGLContext setCurrentContext:nil];

        [context release];
    }

    virtual void setCurrent()
    {
        RBXASSERT([EAGLContext setCurrentContext:context]);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    }

    virtual void swapBuffers()
    {
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        RBXASSERT([context presentRenderbuffer:GL_RENDERBUFFER]);
    }

    virtual unsigned int getMainFramebufferId()
    {
        return framebuffer;
    }

    virtual bool isMainFramebufferRetina()
    {
        return view.contentScaleFactor > 1.0;
    }

    virtual std::pair<unsigned int, unsigned int> updateMainFramebuffer(unsigned int width, unsigned int height)
    {
        setCurrent();
        if (width != surfaceWidth || height != surfaceHeight || surfaceWidth == 0 || surfaceHeight == 0)
            rebuildDrawable();
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        return std::make_pair((unsigned int)surfaceWidth, (unsigned int)surfaceHeight);
    }

private:
    bool rebuildDrawable()
    {
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);

        if (![context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer])
            return false;

        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &surfaceWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &surfaceHeight);

        return surfaceWidth > 0 && surfaceHeight > 0 &&
            glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE;
    }

    UIView* view;
    CAEAGLLayer* layer;
    EAGLContext* context;
    GLuint framebuffer;
    GLuint colorRenderbuffer;
    GLint surfaceWidth;
    GLint surfaceHeight;
};

ContextGL* ContextGL::create(void* windowHandle)
{
    return new ContextGLEAGL(windowHandle);
}

}
}
