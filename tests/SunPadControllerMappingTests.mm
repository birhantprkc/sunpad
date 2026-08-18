#import <Foundation/Foundation.h>

#include <cassert>
#include <iostream>

#import "SunPadControllerMapping.h"

static bool MappingsEqual(SunPadControllerButtonMapping lhs,
                          SunPadControllerButtonMapping rhs) {
    return lhs.gameA == rhs.gameA && lhs.gameB == rhs.gameB &&
           lhs.gameX == rhs.gameX && lhs.gameY == rhs.gameY &&
           lhs.gameZ == rhs.gameZ;
}

int main(void) {
    @autoreleasepool {
        const SunPadControllerButtonMapping defaults =
            SunPadDefaultControllerButtonMapping();
        SunPadControllerButtonMapping mapping = defaults;
        assert(SunPadControllerButtonMappingIsValid(mapping));
        assert(SunPadApplyControllerButtonMapping(mapping,
            SunPadPhysicalControllerButtonA | SunPadPhysicalControllerButtonLeftShoulder) ==
            (SunPadButtonA | SunPadButtonZ));
        assert(SunPadControllerRightTriggerPressure(0, NO) == 0);
        assert(SunPadControllerRightTriggerPressure(0, YES) == 128);
        assert(SunPadControllerRightTriggerPressure(64, YES) == 128);
        assert(SunPadControllerRightTriggerPressure(192, YES) == 192);
        assert(SunPadControllerRightTriggerPressure(255, NO) == 255);

        mapping = SunPadControllerButtonMappingByAssigning(
            mapping, SunPadPhysicalControllerButtonB, SunPadButtonA);
        assert(mapping.gameA == SunPadPhysicalControllerButtonB);
        assert(mapping.gameB == SunPadPhysicalControllerButtonA);
        assert(SunPadApplyControllerButtonMapping(mapping,
            SunPadPhysicalControllerButtonA | SunPadPhysicalControllerButtonB) ==
            (SunPadButtonA | SunPadButtonB));

        SunPadControllerButtonMapping corrupt = mapping;
        corrupt.gameZ = SunPadPhysicalControllerButtonB;
        assert(!SunPadControllerButtonMappingIsValid(corrupt));
        assert(SunPadApplyControllerButtonMapping(corrupt,
            SunPadPhysicalControllerButtonLeftShoulder) == SunPadButtonZ);

        [SunPadControllerMappingStore reset];
        assert(MappingsEqual([SunPadControllerMappingStore mapping], defaults));

        [SunPadControllerMappingStore setMapping:mapping];
        assert(MappingsEqual([SunPadControllerMappingStore mapping], mapping));

        [SunPadControllerMappingStore reset];
        assert(MappingsEqual([SunPadControllerMappingStore mapping], defaults));

        NSDictionary *corruptSavedMapping = @{
            @"A": @(SunPadPhysicalControllerButtonA),
            @"B": @(SunPadPhysicalControllerButtonA),
            @"X": @(SunPadPhysicalControllerButtonX),
            @"Y": @(SunPadPhysicalControllerButtonY),
            @"Z": @(SunPadPhysicalControllerButtonLeftShoulder),
        };
        [[NSUserDefaults standardUserDefaults]
            setObject:corruptSavedMapping
               forKey:@"SunPadControllerButtonMappingV1"];
        assert(MappingsEqual([SunPadControllerMappingStore mapping], defaults));

        [SunPadControllerMappingStore setMapping:corrupt];
        assert(MappingsEqual([SunPadControllerMappingStore mapping], defaults));
        [SunPadControllerMappingStore reset];

        std::cout << "SunPad controller mapping regression test passed\n";
    }
    return 0;
}
