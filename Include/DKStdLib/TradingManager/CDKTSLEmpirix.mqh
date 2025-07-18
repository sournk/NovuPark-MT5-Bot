//+------------------------------------------------------------------+
//|                                                CDKTSLEmpirix.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include "CDKTrade.mqh"
#include "CDKTSLBase.mqh"

class CDKTSLEmpirix : public CDKTSLBase {
private:
  double                    FilterMinDistanceFromPrevBar;
public:
  bool                      CDKTSLEmpirix::Update(CDKTrade& _trade, const bool _update_tp);
  
  void                      CDKTSLEmpirix::Init(const int _activation_distance_from_open_point, 
                                                const int _sl_distance,
                                                const double _dist);
};

bool CDKTSLEmpirix::Update(CDKTrade& _trade, const bool _update_tp) {
  // Mock this condition
  // if (closebar >= NormalizeDouble(ep+ktsl*dATR, Digits()) && SymbolInfo.Ask() > CurentSL+dSL+ktsl*dATR) 
  if(FilterMinDistanceFromPrevBar > 0.0){
    int dir = PositionType() == POSITION_TYPE_BUY ? +1 : -1;
    double sl_curr = StopLoss();
    double filter_price = sl_curr + dir*FilterMinDistanceFromPrevBar + dir*Distance;

    double closebar = iClose(Symbol(), Period(), 1);
    if(IsPriceLT(closebar, filter_price)) {
      ResRetcode = ERR_USER_ERROR_FIRST+3;
      ResRetcodeDescription = StringFormat("Close[1]=%0.10g < PriceActivation=%0.10g", closebar, PriceActivation);
      return false;
    }
  }
    
  double sl_new = AddToPrice(PriceToClose(), -1*GetDistance());
  return CDKTSLBase::UpdateSL(_trade, sl_new, _update_tp);
}

void CDKTSLEmpirix::Init(const int _activation_distance_from_open_point, 
                         const int _sl_distance,
                         const double _dist) {
  
  FilterMinDistanceFromPrevBar = _dist;
  CDKTSLBase::Init(_activation_distance_from_open_point, _sl_distance);
}