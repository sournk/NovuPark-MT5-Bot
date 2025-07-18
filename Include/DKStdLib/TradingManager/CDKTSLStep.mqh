//+------------------------------------------------------------------+
//|                                                   CDKTSLStep.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include "CDKTrade.mqh"
#include "CDKTSLBase.mqh"

class CDKTSLStep : public CDKTSLBase {
  int                       ActivationStep;
public:
  void                      CDKTSLStep::CDKTSLBase();
  void                      CDKTSLStep::Init(const int _activation_step_point, const int _sl_distance, const string _name = "");
  ENUM_TSL_RESULT           CDKTSLStep::Update(CDKTrade& _trade, const bool _update_tp);
};

void CDKTSLStep::CDKTSLBase() {
  Init(500, 0);
}

void CDKTSLStep::Init(const int _activation_step_point, const int _sl_distance, const string _name = "") {
  ActivationStep = _activation_step_point;
  CDKTSLBase::Init(0, _sl_distance, _name);
}

ENUM_TSL_RESULT CDKTSLStep::Update(CDKTrade& _trade, const bool _update_tp) {
  double sl_old = StopLoss();
  double price_activation = (IsPriceGEOpen(sl_old)) ? sl_old : PriceOpen();
  price_activation = AddToPrice(price_activation, ActivationStep);
  CDKTSLBase::SetActivation(price_activation);
  
  double sl_new = AddToPrice(PriceToClose(), -1*GetDistance());
  
  return CDKTSLBase::UpdateSL(_trade, sl_new, _update_tp);
}