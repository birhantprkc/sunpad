#import <Foundation/Foundation.h>
#include <cassert>
static dispatch_queue_t worker;
#define dispatch_get_global_queue(priority, flags) worker
#include "../apple/ios/SunPadDiscExtractor.mm"
#undef dispatch_get_global_queue
int main() {
 @autoreleasepool {
  worker=dispatch_queue_create("sunpad.extraction.regression", DISPATCH_QUEUE_SERIAL);
  NSString* root=[NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
  __block bool done=false;
  __block unsigned callbacks=0;
  [SunPadDiscExtractor extractImageAtPath:@"synthetic" toDirectory:root
    progress:^(NSString* message, double fraction) {
      assert(message.length>0 && fraction>=0 && fraction<=1); ++callbacks;
    } completion:^(BOOL success, NSString* error) { assert(success && !error); done=true; }];
  // Drain the worker before allowing any queued main callback to execute.
  dispatch_sync(worker, ^{});
  NSDate* deadline=[NSDate dateWithTimeIntervalSinceNow:5];
  while (!done && deadline.timeIntervalSinceNow>0)
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
  assert(done && callbacks==4);
  [NSFileManager.defaultManager removeItemAtPath:root error:nil];
 }
 puts("Extraction delayed-callback check passed");
}
