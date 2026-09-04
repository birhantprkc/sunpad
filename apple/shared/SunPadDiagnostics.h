#pragma once

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* Starts the persistent runtime log and rotates it when it grows beyond 1 MB.
 * The log lives under SunPad/Logs in Application Support on iOS and Caches on
 * tvOS, where filesystem-backed state must be treated as purgeable. */
FOUNDATION_EXPORT void SunPadDiagnosticsStart(void);

/* Writes one timestamped line to both the unified device log and SunPad's
 * persistent runtime log. Intended for low-frequency lifecycle breadcrumbs,
 * not per-frame tracing. */
FOUNDATION_EXPORT void SunPadLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

/* Records a warning/error emitted by the embedded runtime. Repeated identical
 * events are counted and rate-limited so a failure cannot flood the log. */
FOUNDATION_EXPORT void SunPadLogRuntimeEvent(
    NSString *severity, NSString *category, NSString *message);

FOUNDATION_EXPORT NSString *SunPadDiagnosticsLogPath(void);

/* Builds the single privacy-reviewed file used by the guided problem-report
 * flow. Reporter answers and current technical context lead the file, followed
 * by bounded runtime-event summaries and the current/previous app sessions. */
FOUNDATION_EXPORT NSURL *_Nullable SunPadDiagnosticsReportURL(
    NSString *reportID,
    NSDictionary<NSString *, NSString *> *reporterAnswers,
    NSString *technicalContext,
    NSError **error);

NS_ASSUME_NONNULL_END
