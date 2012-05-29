//
//  ConstantsAndMacros.h
//  Particles
//

// How many times a second to refresh the screen
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#define kRenderingFrequency             15.0
#define kInactiveRenderingFrequency     5.0
#else
#define kRenderingFrequency             30.0
#define kInactiveRenderingFrequency     3.0
#endif
// For setting up perspective, define near, far, and angle of view
#define kZNear                          0.01
#define kZFar                           10.0
#define kFieldOfView                    45.0
// Defines whether to setup and use a depth buffer
#define USE_DEPTH_BUFFER                0
// Set to 1 if you want it to attempt to create a 2.0 context
#define kAttemptToUseOpenGLES2          0
// Macros
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)