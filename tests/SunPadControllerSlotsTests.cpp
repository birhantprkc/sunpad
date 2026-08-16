#include "../apple/ios/SunPadControllerSlots.h"

#include <cassert>
#include <iostream>

int main() {
  constexpr uintptr_t first = 0x1001;
  constexpr uintptr_t first_returned = 0x1002;
  constexpr uintptr_t second = 0x2001;

  // A sole controller owns player 1 and retains it across ordinary reconcile.
  SunPadControllerSlots single;
  auto result = single.Reconcile({first});
  assert(result.assigned.size() == 1 && result.assigned[0].slot == 0);
  result = single.Reconcile({first});
  assert(result.assigned.empty() && result.removed.empty());
  assert(single.SlotFor(first) == 0);

  // A missed removal is repaired from the current-controller enumeration.
  result = single.Reconcile({});
  assert(result.removed.size() == 1 && result.removed[0].instance == first);
  assert(single.SlotFor(first) == -1);
  result = single.Reconcile({first_returned});
  assert(single.SlotFor(first_returned) == 0);

  // A genuine second controller takes player 2 without displacing player 1.
  SunPadControllerSlots multiple;
  multiple.Reconcile({first});
  result = multiple.Reconcile({first, second});
  assert(result.assigned.size() == 1 && result.assigned[0].slot == 1);
  assert(multiple.SlotFor(first) == 0);
  assert(multiple.SlotFor(second) == 1);

  // Enumeration order changes do not disturb valid connected assignments.
  result = multiple.Reconcile({second, first});
  assert(result.assigned.empty() && result.removed.empty());
  assert(multiple.SlotFor(first) == 0);
  assert(multiple.SlotFor(second) == 1);

  // If player 1 disappears without a notification, player 2 stays in its
  // existing slot. A returning controller then reclaims the free player 1.
  result = multiple.Reconcile({second});
  assert(result.removed.size() == 1 && result.removed[0].slot == 0);
  assert(multiple.SlotFor(second) == 1);
  result = multiple.Reconcile({second, first_returned});
  assert(multiple.SlotFor(first_returned) == 0);
  assert(multiple.SlotFor(second) == 1);

  // Foreground reconciliation is idempotent and preserves both slots.
  result = multiple.Reconcile({first_returned, second});
  assert(result.assigned.empty() && result.removed.empty());

  std::cout << "SunPad controller-slot reconciliation tests passed\n";
  return 0;
}
