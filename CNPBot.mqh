//+------------------------------------------------------------------+
//|                                                       CNPBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

// #todo 1. Clean imports
// #todo 2. Delete unused Includes

//#include <Generic\HashMap.mqh>
//#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayObj.mqh>
//#include <Arrays\ArrayDouble.mqh>
//#include <Arrays\ArrayLong.mqh>
//#include <Trade\TerminalInfo.mqh>
#include <Trade\DealInfo.mqh>
//#include <Trade\OrderInfo.mqh>
//#include <Charts\Chart.mqh>
//#include <Math\Stat\Math.mqh>


#include <ChartObjects\ChartObjectsShapes.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsArrows.mqh> 

//#include "Include\MarketBook\MarketBook.mqh"
//#include "Include\DBWrapper\Database.mqh"

//#include "Include\DKStdLib\Analysis\DKChartAnalysis.mqh"
//#include "Include\DKStdLib\Analysis\DKBarPatterns.mqh"
// #include "Include\DKStdLib\Common\DKNumPy.mqh"
#include "Include\DKStdLib\Common\CDKBarTag.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Logger\CDKLogger.mqh"
//#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStepSpread.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLFibo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLPriceChannel.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLEmpirix.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLBE.mqh"
//#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"
//#include "Include\DKStdLib\History\DKHistory.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Common\DKDatetime.mqh"
//#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CNPInputs.mqh"


// Enum for Bot's operation result
// Value is:
//   [-] negative if operation has sussesed
//   [+] negative if operation has failed
//
// Last digit of value determinates LogLevel for operation:
//  0: NO
//  1: DEBUG
//  2: INFO
//  3: WARN
//  4: ERROR
//  5: CRITICAL

enum ENUM_RETCODE {
  BRC_SIG_NO__EMPTY_UTBOT                         = +1011,
  BRC_SIG_NO__POS_IN_MARKET                       = +1021,
  BRC_SIG_OK__BUY                                 = -1002,
  BRC_SIG_OK__SELL                                = -1012,
  
  BRC_OPEN_ERROR__FAREST_SWING_NOT_FOUND          = +2004,
  BRC_OPEN_ERROR__TRADE                           = +2014,
  BRC_OPEN_OK__BUY                                = -2003,
  BRC_OPEN_OK__SELL                               = -2013,
  
  BRC_FIL_FAIL__STC_OUT_RANGE                     = +3002,  
  BRC_FIL_FAIL__DIR_NOT_ALLOWED                   = +3012, 
  BRC_FIL_PASS__STC_IN_RANGE                      = -3002,
};

class CNPBot : public CDKBaseBot<CNPBotInputs> {
public: // SETTINGS

protected:
public:
  // Constructor & init
  //void                       CNPBot::CNPBot(void);
  void                       CNPBot::~CNPBot(void);
  void                       CNPBot::InitChild();
  bool                       CNPBot::Check(void);

  // Event Handlers
  void                       CNPBot::OnDeinit(const int reason);
  void                       CNPBot::OnTick(void);
  void                       CNPBot::OnTrade(void);
  void                       CNPBot::OnBar(CArrayInt& _tf_list);
  void                       CNPBot::OnPositionOpened(ulong _position, ulong _deal);
  void                       CNPBot::OnPositionStopLoss(ulong _position, ulong _deal);
  
  // Bot's logic
  double                     CNPBot::GetPrevFractal(const int _dir, const double _ep);

  SBotRetCode<ENUM_RETCODE>  CNPBot::OpenPos(const int _dir);
  SBotRetCode<ENUM_RETCODE>  CNPBot::IsASFilterPassed(const int _dir);
  SBotRetCode<ENUM_RETCODE>  CNPBot::GetSignal();
  SBotRetCode<ENUM_RETCODE>  CNPBot::OpenOnSignal();
  
  void                       CNPBot::DrawSession();
  void                       CNPBot::UpdateComment(const bool _ignore_interval = false);
};

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CNPBot::~CNPBot(void){
}


//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CNPBot::InitChild() {
  // Put code here
  // vvvvvvvvvvvvv
  
  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CNPBot::Check(void) {
  if(!CDKBaseBot<CNPBotInputs>::Check())
    return false;
    
  if(!Inputs.InitAndCheck()) {
    Logger.Critical(Inputs.LastErrorMessage, true);
    return false;
  }
  
  // Put your additional checks here
  // vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
  
  return true;
}

//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CNPBot::OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CNPBot::OnTick(void) {
  CDKBaseBot<CNPBotInputs>::OnTick(); // Check new bar and show comment
  
  // 01. Channels update
  bool need_update = false;
  
  //// 02. TSL
  //if(Inputs.TRD_TSL_LEV > 0.0)
  //  SetTSL();
  
  // 04. Update comment
  if(need_update)
    UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CNPBot::OnBar(CArrayInt& _tf_list) {
  //// 01. TSL
  //if(Inputs.__TRD_TSL_MOD == BOT_TSL_MODE_ON_BAR)
  //  SetTSL();
    
  // 02. Signal check
  SBotRetCode<ENUM_RETCODE> sig = OpenOnSignal();
  
  if(Inputs.GUI_ENB) 
    DrawAllPos();
    
  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CNPBot::OnPositionOpened(ulong _position, ulong _deal) {
}

//+------------------------------------------------------------------+
//| OnPositionStopLoss Handler
//+------------------------------------------------------------------+
void CNPBot::OnPositionStopLoss(ulong _position, ulong _deal) {
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CNPBot::OnTrade(void) {
  CDKBaseBot<CNPBotInputs>::OnTrade();
}



//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CNPBot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();
  
  AddCommentLine(StringFormat("Current bar: %s", TimeToString(iTime(Sym.Name(), TF, 0))));

  ShowComment(_ignore_interval);     
}





////+------------------------------------------------------------------+
////| Check dir is allowed to trade
////+------------------------------------------------------------------+
//bool CNPBot::IsTradeDirAllowed(const int _dir){
//  if(Inputs.TRD_DIR_MOD == TRD_DIR_MODE_BOTH) return true;
//  return _dir*Inputs.TRD_DIR_MOD > 0;
//}


//+------------------------------------------------------------------+
//| Get prev fractal                                                                 
//+------------------------------------------------------------------+
double CNPBot::GetPrevFractal(const int _dir, const double _ep) {
  int idx = 0;
  Inputs.Fractals.Refresh();
  double frac_val = 0.0;
  ENUM_POSITION_TYPE dir = _dir > 0 ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
  do {
    idx++;
    frac_val = (_dir>0) ? Inputs.Fractals.Lower(idx) : Inputs.Fractals.Upper(idx);
    if(IsPosPriceGE(dir, frac_val, _ep))
      frac_val = 0.0;
  }
  while(!(frac_val > 0.0 && frac_val < DBL_MAX));
  
  return frac_val;
}

//+------------------------------------------------------------------+
//| Open pos
//+------------------------------------------------------------------+
SBotRetCode<ENUM_RETCODE> CNPBot::OpenPos(const int _dir) {
  // 01. Open new pos
  ENUM_POSITION_TYPE dir_open  = (_dir > 0) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
  double ep = Sym.GetPriceToOpen(dir_open);
  double sl = GetPrevFractal(_dir, ep);
  double sl_dist = MathAbs(ep-sl);
  double tp_dist = sl_dist * Inputs.TRD_TP_RR;
  double tp = (!CompareDouble(tp_dist, 0.0)) ? Sym.AddToPrice(dir_open, ep, tp_dist) : 0.0;
           
  double lot = CalculateLotSuper(Sym.Name(), Inputs.TRD_MM_MOD, Inputs.TRD_MM_VAL, ep, sl);
  string comment = Logger.Name;
    
  ulong ticket = 0;
  ticket = Trade.PositionOpenMarket(dir_open, lot, Sym.Name(), 0.0, sl, tp, comment);
  
  ENUM_RETCODE res = BRC_OPEN_ERROR__TRADE;
  if(ticket > 0) 
    res = _dir > 0 ? BRC_OPEN_OK__BUY : BRC_OPEN_OK__SELL; 
  
  SBOTRETCODE_RETURN_IAL(res, "", Logger); 
}

//+------------------------------------------------------------------+
//| Draw Session
//+------------------------------------------------------------------+
void CNPBot::DrawSession() {
//  CChartObjectRectangle rec;
//  string name = StringFormat("%s_SES_%s", Logger.Name, TimeToString(SessionSt.GetTime(), TIME_DATE));
//  rec.Create(0, name, 0, 
//             SessionSt.GetTime(), SessionSt.GetValue(),
//             SessionEn.GetTime(), SessionEn.GetValue());
//  rec.Color(Inputs.GUI_SES_CLR);
//  rec.Background(true);
//  rec.Description(StringFormat("%s %s", Inputs.SES_NAM, TimeToString(SessionSt.GetTime(), TIME_DATE)));
//  rec.Detach();
//  
//  ChartRedraw();
}

//+------------------------------------------------------------------+
//| Get Signal
//+------------------------------------------------------------------+
SBotRetCode<ENUM_RETCODE> CNPBot::IsASFilterPassed(const int _dir) {
  Inputs.STC.Refresh();
  int idx = 1;
  double stc = Inputs.STC.Main(idx);
  double clr = Inputs.STC.Color(idx); // red=0; green=1
  
  ENUM_RETCODE res = BRC_FIL_FAIL__STC_OUT_RANGE; 
  if(_dir > 0 && stc >= Inputs.F_STC_BUY_MIN && stc <= Inputs.F_STC_BUY_MAX && 
     (!Inputs.F_STC_CLR_ENB || CompareDouble(clr, 1.0)))  
    res = BRC_FIL_PASS__STC_IN_RANGE;
  if(_dir < 0 && stc >= Inputs.F_STC_SELL_MIN && stc <= Inputs.F_STC_SELL_MAX && 
     (!Inputs.F_STC_CLR_ENB || CompareDouble(clr, 0.0))) 
    res = BRC_FIL_PASS__STC_IN_RANGE;
    
  SBOTRETCODE_RETURN_IAL(res, "", Logger);  
}

//+------------------------------------------------------------------+
//| Get Signal
//+------------------------------------------------------------------+
SBotRetCode<ENUM_RETCODE> CNPBot::GetSignal() {
  ENUM_RETCODE sig = BRC_SIG_NO__EMPTY_UTBOT;
  int idx = 1;
  
  Inputs.UTBot.Refresh();
  double buf_b = Inputs.UTBot.Buy(idx);
  double buf_s = Inputs.UTBot.Sell(idx);
  if(buf_b > 0.0 && buf_b < DBL_MAX) sig = BRC_SIG_OK__BUY;
  if(buf_s > 0.0 && buf_s < DBL_MAX) sig = BRC_SIG_OK__SELL;
  
  SBOTRETCODE_RETURN_IAL(sig, "", Logger); 
}

//+------------------------------------------------------------------+
//| Open on Signal
//+------------------------------------------------------------------+
SBotRetCode<ENUM_RETCODE> CNPBot::OpenOnSignal() {
  SBotRetCode<ENUM_RETCODE> sig = GetSignal();
  if(sig.Code > 0) 
    SBOTRETCODE_RETURN_IAL(sig.Code, "", Logger);  

  int dir = (sig.Code == BRC_SIG_OK__BUY) ? +1 : -1;    
  
  // Close opposite pos
  if(Inputs.TRD_REV_ENB && Poses.Total() > 0) {  
    bool res = DeleteAllPosesByDir(dir > 0 ? POSITION_TYPE_SELL : POSITION_TYPE_BUY);
    LSF_ASSERT(res, "", WARN, ERROR);
    LoadMarket();
  }
  
  // Pos in market
  if(Poses.Total() > 0)
    SBOTRETCODE_RETURN_IAL(BRC_SIG_NO__POS_IN_MARKET, "", Logger);
    
  // Trade dir filter
  if((Inputs.TRD_DIR_MOD == TRD_DIR_MODE_BUY  && dir < 0) || 
     (Inputs.TRD_DIR_MOD == TRD_DIR_MODE_SELL && dir > 0))
    SBOTRETCODE_RETURN_IAL(BRC_FIL_FAIL__DIR_NOT_ALLOWED, "", Logger);  
    
  // Filter check
  SBotRetCode<ENUM_RETCODE> fil = IsASFilterPassed(dir);
  if(fil.Code > 0)
    SBOTRETCODE_RETURN_IAL(fil.Code, "", Logger);  
    
  // Open pos
  SBotRetCode<ENUM_RETCODE> res = OpenPos(dir);
  SBOTRETCODE_RETURN_IAL(res.Code, "", Logger);
}