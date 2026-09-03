#include "moderngekko/runtime.hpp"

#include <cassert>

int main()
{
  moderngekko::RuntimeConfig config;
  assert(!config.enable_gmse01_60fps);
  assert(!config.enable_gmse01_widescreen);

  config.enable_gmse01_60fps = true;
  config.enable_gmse01_widescreen = true;
  assert(config.enable_gmse01_60fps);
  assert(config.enable_gmse01_widescreen);
  return 0;
}
