//+------------------------------------------------------------------+
//|                                                    CDKTSLATR.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Indicators\Oscilators.mqh>

#include "CDKTrade.mqh"
#include "CDKTSLBase.mqh"

class CDKTSLATR : public CDKTSLBase {
private:
  CiATR*                    IndATR;
  double                    ATRRatio;
public:
  ENUM_TSL_RESULT           CDKTSLATR::Update(CDKTrade& _trade, const int _idx, const bool _update_tp);
  void                      CDKTSLATR::Init(CiATR* _atr_ind, const double _atr_ratio);
};

ENUM_TSL_RESULT CDKTSLATR::Update(CDKTrade& _trade, const int _idx, const bool _update_tp) {
  IndATR.Refresh();

  SetDistance(IndATR.Main(_idx)*ATRRatio);
    
  double sl_new = AddToPrice(PriceToClose(), -1*GetDistance());
  return CDKTSLBase::UpdateSL(_trade, sl_new, _update_tp);
}

void CDKTSLATR::Init(CiATR* _atr_ind, const double _atr_ratio) {
  IndATR   = _atr_ind;
  ATRRatio = _atr_ratio;
}