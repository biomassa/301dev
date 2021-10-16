#pragma once

#include <od/objects/Object.h>

namespace od
{

  class Msproc : public Object
  {
  public:
    Msproc();
    virtual ~Msproc();

#ifndef SWIGLUA
    virtual void process();
    Inlet mLeftInput{"Left In"};
    Inlet mRightInput{"Right In"};
    Outlet mLeftOutput{"Left Out"};
    Outlet mRightOutput{"Right Out"};
    Inlet mWidth{"Width"};
#endif
  };

} /* namespace ars */
