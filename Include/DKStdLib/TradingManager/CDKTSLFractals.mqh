//+------------------------------------------------------------------+
//|                                           CDKTSLFractals.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Indicators\BillWilliams.mqh>

#include "CDKTrade.mqh"
#include "CDKTSLBase.mqh"

class CDKTSLFractals : public CDKTSLBase {
protected:
  ENUM_TIMEFRAMES           TF;
  uint                      Depth;
  int                       ExtraDistanceShift;
  
  CiFractals                IndFractal;  
public:
  void                      CDKTSLFractals::CDKTSLFractals(void);
  void                      CDKTSLFractals::Init(const int _activation_distance_from_open_point, 
                                                 const string _symbol,
                                                 const ENUM_TIMEFRAMES _period,
                                                 const uint _depth,
                                                 const int _extra_distance_shift);
  bool                      CDKTSLFractals::Update(CDKTrade& _trade, const bool _update_tp);
};

void CDKTSLFractals::CDKTSLFractals() {
  CDKTSLBase::Init(0, 0);
}

void CDKTSLFractals::Init(const int _activation_distance_from_open_point, 
                          const string _symbol,
                          const ENUM_TIMEFRAMES _period,
                          const uint _depth,
                          const int _extra_distance_shift) {
  CDKTSLBase::Init(_activation_distance_from_open_point, 0);
  TF = _period;
  Depth = _depth;
  ExtraDistanceShift = _extra_distance_shift;
  
  IndFractal.Create(_symbol, TF);
  IndFractal.Refresh();  
}

bool CDKTSLFractals::Update(CDKTrade& _trade, const bool _update_tp) {
  if(IndFractal.Handle() < 0) return false;

  IndFractal.Refresh();
  
  double sl_new = 0.0;
  for(uint i=0;i<Depth;i++) {
    double frac_val = (PositionType() == POSITION_TYPE_BUY) ? IndFractal.Lower(i) : IndFractal.Upper(i);
    if(frac_val > 0.0 && frac_val < DBL_MAX) {
      sl_new = frac_val;
      break;
    }
  }
  sl_new = AddToPrice(sl_new, -1*ExtraDistanceShift);
  
  return CDKTSLBase::UpdateSL(_trade, sl_new, _update_tp);
}

