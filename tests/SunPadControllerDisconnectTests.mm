#import <Foundation/Foundation.h>

#include <cassert>
#include <iostream>

#include "SunPadInputMixer.h"

int main() {
  @autoreleasepool {
    SunPadInputMixer *mixer = [[SunPadInputMixer alloc] init];

    SunPadInputState held = {};
    held.connected = 1;
    held.buttons = SunPadButtonA | SunPadButtonR;
    held.stickX = 127;
    held.stickY = -64;
    held.cStickX = -127;
    held.cStickY = 64;
    held.triggerL = 96;
    held.triggerR = 255;
    [mixer setInputState:held fromTouch:NO];

    SunPadInputState active = [mixer consumeMergedState];
    assert(active.connected == 1);
    assert(active.buttons == held.buttons);
    assert(active.stickX == held.stickX && active.stickY == held.stickY);
    assert(active.cStickX == held.cStickX && active.cStickY == held.cStickY);
    assert(active.triggerL == held.triggerL && active.triggerR == held.triggerR);

    [mixer clearInputFromTouch:NO];
    SunPadInputState released = [mixer consumeMergedState];
    assert(released.connected == 0);
    assert(released.buttons == 0);
    assert(released.stickX == 0 && released.stickY == 0);
    assert(released.cStickX == 0 && released.cStickY == 0);
    assert(released.triggerL == 0 && released.triggerR == 0);

    std::cout << "SunPad controller disconnect release test passed\n";
  }
  return 0;
}
