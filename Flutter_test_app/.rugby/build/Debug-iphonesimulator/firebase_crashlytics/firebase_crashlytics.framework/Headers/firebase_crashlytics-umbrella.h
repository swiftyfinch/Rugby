#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Crashlytics_Platform.h"
#import "FLTFirebaseCrashlyticsPlugin.h"

FOUNDATION_EXPORT double firebase_crashlyticsVersionNumber;
FOUNDATION_EXPORT const unsigned char firebase_crashlyticsVersionString[];

