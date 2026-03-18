#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.pitchos.PitchOS";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "SplashBackground" asset catalog color resource.
static NSString * const ACColorNameSplashBackground AC_SWIFT_PRIVATE = @"SplashBackground";

#undef AC_SWIFT_PRIVATE
