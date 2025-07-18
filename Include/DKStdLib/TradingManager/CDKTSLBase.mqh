//+------------------------------------------------------------------+
//|                                                   CDKTSLBase.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//|
//| 2025-06-20: [*] .Update() now returns ENUM_TSL_RESULT instead bool
//| 2025-06-19: [*] Update now returns true if SL has not updated,
//|                 because of a) price's not reached activation
//|                 and b) new SL is not better than previous    
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include "CDKSymbolInfo.mqh"
#include "CDKPositionInfo.mqh"
#include "CDKTrade.mqh"

enum ENUM_TSL_RESULT {
  TSL_RESULT_NO__SL_UPDATE_NOT_REQUIRED = +0,
  TSL_RESULT_OK                         = -1,
  TSL_RESULT_ERROR                      = +1,
};

enum ENUM_TSL_CUSTOM_RET_CODE {
  TSL_CUSTOM_RET_CODE_PRICE_ACTIVATION_NOT_REACHED     = ERR_USER_ERROR_FIRST+1,  // Activations price has not reached yet. SL or TP didn't change
  TSL_CUSTOM_RET_CODE_PRICE_NOT_BETTER                 = ERR_USER_ERROR_FIRST+2   // Price didn't get better. Leave current SL and TP with no changes
};

class CDKTSLBase : public CDKPositionInfo {
protected:
  uint                      ResRetcode;
  string                    ResRetcodeDescription;
  
  double                    SLNew;
  double                    TPNew;

  double                    PriceActivation;
  double                    Distance;
  int                       DistancePoint;
public:
  uint                      CDKTSLBase::ResultRetcode() { return ResRetcode; }                          
  string                    CDKTSLBase::ResultRetcodeDescription() { return ResRetcodeDescription; }
  
  double                    CDKTSLBase::LastStopLoss() { return SLNew; }
  double                    CDKTSLBase::LastTakeProfit() { return TPNew; }

  void                      CDKTSLBase::SetActivation(const double _price);                             // Set Activation price. Default is 0 - means no activation price control
  void                      CDKTSLBase::SetActivation(const int _activation_distance_from_open_point);  // Set Activation price as PriceOpen()+_activation_distance_from_open_point 
  double                    CDKTSLBase::GetActivation();                                                // Return Activation Price
  
  void                      CDKTSLBase::SetDistance(const double _distance);             
  void                      CDKTSLBase::SetDistance(const int _distace_point);
  double                    CDKTSLBase::GetDistance();                                                  // Return current Distance
  int                       CDKTSLBase::GetDistancePoint();                                             // Return current Distance in points

  virtual void              CDKTSLBase::Init(const int _activation_distance_from_open_point, 
                                             const int _sl_distance,
                                             const string _name = "");

  ENUM_TSL_RESULT           CDKTSLBase::UpdateSL(CDKTrade& _trade, 
                                                 const double _new_sl,                                        // Moves SL to spesific _new_sl
                                                 const bool _update_tp);                                // You can also move TP with _update_tp=true

  virtual ENUM_TSL_RESULT   CDKTSLBase::Update(CDKTrade& _trade, const bool _update_tp);                // Moves SL with current ActivationPrice and Distance
  
  void                      CDKTSLBase::CDKTSLBase();
};

void CDKTSLBase::Init(const int _activation_distance_from_open_point, const int _sl_distance, const string _name = "") {
  if(_name != "")
    m_symbol.Name(_name);
    
  SetActivation(_activation_distance_from_open_point);
  SetDistance(_sl_distance);
  SLNew = 0.0;
  TPNew = 0.0;
}

//+------------------------------------------------------------------+
//| Setters and getters for Activation
//+------------------------------------------------------------------+
void CDKTSLBase::SetActivation(const double _price) {
  PriceActivation = _price;
}

void CDKTSLBase::SetActivation(const int _distance_from_open_point) {
  PriceActivation = AddToPrice(PriceOpen(), _distance_from_open_point);
}

double CDKTSLBase::GetActivation() {
  return PriceActivation;
}

void CDKTSLBase::SetDistance(const double _distance) {
  Distance = _distance;
  DistancePoint = m_symbol.PriceToPoints(Distance);
}

//+------------------------------------------------------------------+
//| Setters and getters for Distance
//+------------------------------------------------------------------+
void CDKTSLBase::SetDistance(const int _distace_point) {
  Distance = m_symbol.PointsToPrice(_distace_point);
  DistancePoint = _distace_point;
}

double CDKTSLBase::GetDistance() {
  return Distance;
}

int CDKTSLBase::GetDistancePoint() {
  return DistancePoint;
}

//+------------------------------------------------------------------+
//| Update public methods
//+------------------------------------------------------------------+
ENUM_TSL_RESULT CDKTSLBase::UpdateSL(CDKTrade& _trade, const double _new_sl, const bool _update_tp) {
  ResRetcode = 0;
  ResRetcodeDescription = "";
  // Activation price is disabled (=0) or AskBid is better
  if (!(PriceActivation <= 0 || IsPriceGT(PriceToClose(), PriceActivation))) {
    ResRetcode = TSL_CUSTOM_RET_CODE_PRICE_ACTIVATION_NOT_REACHED;
    ResRetcodeDescription = "activation price has not reached yet";    
    return TSL_RESULT_NO__SL_UPDATE_NOT_REQUIRED;
  }
  
  double curr_sl = StopLoss();
  SLNew = NormalizeDouble(_new_sl, m_symbol.Digits());
  
  double currTP = TakeProfit();
  TPNew = AddToPrice(PriceToClose(), Distance);
  TPNew = NormalizeDouble(TPNew, m_symbol.Digits());
  
  if (!IsPriceGT(SLNew, curr_sl)) SLNew = curr_sl;
  if (!(_update_tp && IsPriceGT(TPNew, currTP))) TPNew = currTP;
  
  if (CompareDouble(SLNew, curr_sl) && CompareDouble(TPNew, currTP)) {
    ResRetcode = TSL_CUSTOM_RET_CODE_PRICE_NOT_BETTER;
    ResRetcodeDescription = "new SL is not better than current";        
    return TSL_RESULT_NO__SL_UPDATE_NOT_REQUIRED;
  }
  
  bool res = false;
  // Current price is better than newTP or current price is worst new_sl ->
  // -> close pos immediatly, because it's impossible to set TP or SL
  if ((_update_tp && IsPriceGE(PriceToClose(), TPNew)) || IsPriceLE(PriceToClose(), SLNew))
    res = _trade.PositionClose(Ticket());
  else
    res = _trade.PositionModify(Ticket(), SLNew, TPNew);
    
  ResRetcode = _trade.ResultRetcode();
  ResRetcodeDescription = _trade.ResultRetcodeDescription();

  return res ? TSL_RESULT_OK : TSL_RESULT_ERROR;
}

ENUM_TSL_RESULT CDKTSLBase::Update(CDKTrade& _trade, const bool _update_tp) {
  double new_sl = AddToPrice(PriceToClose(), -1*GetDistancePoint());
  return UpdateSL(_trade, new_sl, _update_tp);
}

void CDKTSLBase::CDKTSLBase() {
  Init(0, 100);
}