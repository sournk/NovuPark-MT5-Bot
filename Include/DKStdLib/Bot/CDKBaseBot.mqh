//+------------------------------------------------------------------+
//|                                                   CDKBaseBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//| ver. 2025-05-14
//|   [+] PosByDirCount(const ENUM_POSITION_TYPE _dir)
//|   [+] DeleteAllPosesByDir(const ENUM_POSITION_TYPE _dir)
//| ver. 2025-05-13 
//|   [+] SBOTRETCODE_RETURN_IAL_COND: create and log but return only if _cond
//| ver. 2025-04-11
//|   [+] AddBarHintFixedPrice() && AddBarHintAnchorPrice()
//|   [+] PosPriceAverage()
//| ver. 2025-03-11
//|   [+] OnBar(CArrayInt& _tf_list)
//| ver. 2025-02-28
//|   [+] SBotRetCode
//| ver. 2025-01-24
//|   [+] Lincese check from Inputs.__MS_LIC_DUR_SEC
//| ver. 2024-12-06
//|   [*] OnBar executed when ANY TF bar appears
//| ver. 2024-11-11
//|   [+] OnStopLoss, OnTakeProfit,
//| ver. 2024-11-03
//|   [+] Bot can show comment in the window above the chart
//+------------------------------------------------------------------+

#define IS_TRANSACTION_ORDER_PLACED            (trans.type == TRADE_TRANSACTION_REQUEST && request.action == TRADE_ACTION_PENDING && OrderSelect(result.order) && (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE) == ORDER_STATE_PLACED)
//#define IS_TRANSACTION_ORDER_MODIFIED          (trans.type == TRADE_TRANSACTION_REQUEST && request.action == TRADE_ACTION_MODIFY && OrderSelect(result.order) && (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE) == ORDER_STATE_PLACED)
#define IS_TRANSACTION_ORDER_MODIFIED          (trans.type == TRADE_TRANSACTION_REQUEST && request.action == TRADE_ACTION_MODIFY && OrderSelect(request.order) && (ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE) == ORDER_STATE_PLACED)
#define IS_TRANSACTION_ORDER_DELETED           (trans.type == TRADE_TRANSACTION_HISTORY_ADD && (trans.order_type >= 2 && trans.order_type < 6) && trans.order_state == ORDER_STATE_CANCELED)
#define IS_TRANSACTION_ORDER_EXPIRED           (trans.type == TRADE_TRANSACTION_HISTORY_ADD && (trans.order_type >= 2 && trans.order_type < 6) && trans.order_state == ORDER_STATE_EXPIRED)
#define IS_TRANSACTION_ORDER_TRIGGERED         (trans.type == TRADE_TRANSACTION_HISTORY_ADD && (trans.order_type >= 2 && trans.order_type < 6) && trans.order_state == ORDER_STATE_FILLED)

#define IS_TRANSACTION_POSITION_OPENED         (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_IN)
#define IS_TRANSACTION_POSITION_STOP_TAKE      (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_OUT && (ENUM_DEAL_REASON)HistoryDealGetInteger(trans.deal, DEAL_REASON) == DEAL_REASON_SL)
#define IS_TRANSACTION_POSITION_TAKE_TAKE      (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_OUT && (ENUM_DEAL_REASON)HistoryDealGetInteger(trans.deal, DEAL_REASON) == DEAL_REASON_TP)
#define IS_TRANSACTION_POSITION_CLOSED         (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_OUT && ((ENUM_DEAL_REASON)HistoryDealGetInteger(trans.deal, DEAL_REASON) != DEAL_REASON_SL && (ENUM_DEAL_REASON)HistoryDealGetInteger(trans.deal, DEAL_REASON) != DEAL_REASON_TP))
#define IS_TRANSACTION_POSITION_CLOSEBY        (trans.type == TRADE_TRANSACTION_DEAL_ADD && HistoryDealSelect(trans.deal) && (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) == DEAL_ENTRY_OUT_BY)
#define IS_TRANSACTION_POSITION_MODIFIED       (trans.type == TRADE_TRANSACTION_REQUEST && request.action == TRADE_ACTION_SLTP)


#include <Object.mqh>
#include <Arrays\ArrayLong.mqh>

#include "..\..\fxsaber\Equity\EquityMQL5.mqh"
#include "..\..\Timer\CDKTimer.mqh"

#include "..\Analysis\DKBarPatterns.mqh"
#include "..\ChartObjects\CDKChartObjectPosition.mqh"
#include "..\License\DKLicense.mqh"
#include "..\Logger\CDKLogger.mqh"
#include "..\TradingManager\CDKTrade.mqh"
#include "..\TradingManager\CDKPositionInfo.mqh"
#include "..\NewBarDetector\DKNewBarDetector.mqh"
#include "..\Filter\CDKAllowedTime.mqh"

#include "CDKBarHint.mqh"
#include "CDKCommentWnd.mqh"

#define FLP __FUNCTION__ + "/" + (string)__LINE__
#define SBOTRETCODE_IAL(_ret_code, _code, _msg, _logger) _ret_code.InitAndLog(_code, \
                                                         (SBotRetCode<ENUM_RETCODE>::LogLevelByBotRetCode(_code) >= _logger.Level) ? _msg : "", \
                                                         FLP, _logger)
#define SBOTRETCODE_RETURN_IAL(_code, _msg, _logger) {SBotRetCode<ENUM_RETCODE> ret_code; \
                                                      return ret_code.InitAndLog(_code, \
                                                                                (SBotRetCode<ENUM_RETCODE>::LogLevelByBotRetCode(_code) >= _logger.Level) ? _msg : "", \
                                                                                FLP, _logger);}
                                                                                
#define SBOTRETCODE_RETURN_IAL_COND(_code, _msg, _logger, _return_cond, _false_cond_loglevel, _accum_msg) { \
  SBotRetCode<ENUM_RETCODE> ret_code; \
  LogLevel loglev = (_return_cond) ? SBotRetCode<ENUM_RETCODE>::LogLevelByBotRetCode(_code): _false_cond_loglevel; \
  string txt = _msg; \
  _accum_msg += ((_accum_msg != "") ? "\n" : "") + txt; \
  ret_code.InitAndLog(_code, txt, FLP, _logger, loglev); \
  if(_return_cond) return ret_code; }
                                                                                
//#define SBOTRETCODE_RETURN_BAL(_ret_code, _logger) {if(SBotRetCode<ENUM_RETCODE>::LogLevelByBotRetCode(_ret_code.Code) >= _logger.Level)) { \
//                                                     _ret_code.BuildMsgFromData(); \
//                                                     _ret_code.Log(_logger, FLP); \
//                                                   } \
//                                                   return ret_code; }

#define SBOTRETCODE_RETURN_L(_ret_code, _msg, _logger) {return _ret_code.InitAndLog(_ret_code.Code, \
                                                                                    (SBotRetCode<ENUM_RETCODE>::LogLevelByBotRetCode(_ret_code.Code) >= _logger.Level) ? _msg : "", \
                                                                                     FLP, _logger);}


template<typename T_ENUM>
struct SBotRetCode {
private:
  CArrayString               Key;
  CArrayDouble               Val;
  
public:
  
  T_ENUM                     Code;
  string                     Msg;
  
  static string EnumBotRetCodeToString(T_ENUM _ret_code) {
    string str = EnumToString(_ret_code);
    StringReplace(str, "BRC_", "");
   
    return str;
  }  
  
  static LogLevel LogLevelByBotRetCode(T_ENUM _code) {
    int log_level_code = MathAbs(_code % 10);
    if(log_level_code == 1) return DEBUG;
    if(log_level_code == 2) return INFO;
    if(log_level_code == 3) return WARN;
    if(log_level_code == 4) return ERROR;
    if(log_level_code == 5) return CRITICAL;  
    
    return NO;
  }
  
  SBotRetCode Log(CDKLogger& _logger, string _prefix, LogLevel _forced_loglevel=WRONG_VALUE) {
    LogLevel level = (_forced_loglevel == WRONG_VALUE) ? LogLevelByBotRetCode(Code) : _forced_loglevel;
    
    if(level >= _logger.Level) {
      string msg = StringFormat("%sRES=%s%s", 
                               _prefix != "" ? _prefix + ": " : "",
                               EnumBotRetCodeToString(Code),
                               (Msg != "") ? "; " + Msg : "");
      _logger.Log(msg, level);          
    }
    return this;
  }  
  
  SBotRetCode InitAndLog(T_ENUM _code, string _msg, string _prefix, CDKLogger& _logger, LogLevel _forced_loglevel=WRONG_VALUE) {
    Code = _code;
    Msg = _msg;
    Log(_logger, _prefix, _forced_loglevel);
    return this;
  }  
  
  void SetData(const string _key, const double _val) {
    int idx = Key.SearchLinear(_key);
    if(idx < 0) {
      Key.Add(_key);
      Val.Add(_val);
    }
    else
      Val.Update(idx, _val);
  }
  
  double GetData(const string _key, const double _val = DBL_MAX) {
    int idx = Key.SearchLinear(_key);
    if(idx < 0) 
      return _val;
      
    return Val.At(idx);
  }

  string BuildMsgFromData() {
    Msg = "";
    for(int i=0;i<Key.Total();i++) 
      Msg += StringFormat("%s=%0.10g; ", Key.At(i), Val.At(i));

    Msg = StringSubstr(Msg, 0, StringLen(Msg)-2); // remove "; " from string tail
    
    return Msg;
  }
    
};

template<typename T>
class CDKBaseBot : public CObject {
 private:
  string                   CommentText;
  string                   CommentTextLastShown;
  string                   CommentFont;
  CArrayLong               Color;
  CArrayLong               BgrColor; 
  
 protected:
  CDKSymbolInfo            Sym;
  ENUM_TIMEFRAMES          TF;
  ulong                    Magic;
  CDKLogger                Logger;
  CDKTrade                 Trade;
  
  T                        Inputs;
  
  CDKAllowedTime           TimeAllowed;

  CDKNewBarDetector        NewBarDetector;
  CArrayInt                NewBarList;

  CArrayLong               Poses;
  CArrayLong               Orders;
  
  bool                     UseCustomComment;
  CDKCommentWnd*           CommentWnd;
  
  CArrayObj                BarHintArr; // List of drawn bar hints
  CDKNewBarDetector        BarHintNewBarDetector;
  
  EQUITYMQL5               OnTesterEquityCollector; // Equity Collector
  CDKNewBarDetector        OnTesterBarDetector; // Bar detector for OnTester values collector

 public:
  bool                     TrackPosByMagic;
  bool                     TrackOrdByMagic;
  bool                     TrackPosBySymbol;
  bool                     TrackOrdBySymbol; 
    
  bool                     CommentEnable;
  uint                     CommentIntervalMS;
  datetime                 CommentLastUpdate;
  
  void                     CDKBaseBot::SetFont(const string _font_name);
  void                     CDKBaseBot::SetHighlightSelection(const bool _highlight_selection_flag);

  void                     CDKBaseBot::Init(const string _sym,
                                            const ENUM_TIMEFRAMES _tf,
                                            const ulong _magic,
                                            CDKTrade& _trade,
                                            const bool _use_custom_comment_window,
                                            const T& _inputs,
                                            CDKLogger* _logger = NULL);
  virtual void             CDKBaseBot::InitChild()=NULL;
                                        
  bool                     CDKBaseBot::Check(void);



  // Get all market poses and orders
  void                     CDKBaseBot::LoadMarketPos();
  void                     CDKBaseBot::LoadMarketOrd();
  void                     CDKBaseBot::LoadMarket();
  
  // Group pos data
  double                   CDKBaseBot::PosPriceAverage(const ENUM_POSITION_TYPE _dir);
  
  // Pos and orders operation
  int                      CDKBaseBot::PosByDirCount(const ENUM_POSITION_TYPE _dir);
  bool                     CDKBaseBot::DeleteAllPoses();
  bool                     CDKBaseBot::DeleteAllPosesByDir(const ENUM_POSITION_TYPE _dir);
  
  bool                     CDKBaseBot::DeleteAllOrders();  
  
  // Comment
  void                     CDKBaseBot::SetComment(const string _comment);
  void                     CDKBaseBot::ClearComment();
  void                     CDKBaseBot::AddCommentLine(const string _str, const color _clr = 0, const color _bgr_clr = 0);
  void                     CDKBaseBot::ShowComment(const bool _ignore_interval = false);
  
  // Bar hints
  void                     CDKBaseBot::UpdateBarHints();
  void                     CDKBaseBot::AddBarHintFixedPrice(const string _msg, const string _hint, 
                                                            const double _price,
                                                            const int _idx=0,
                                                            const int _char=158, 
                                                            const color _clr=clrLightBlue,
                                                            const double _extra_price_shift_next = 0.0,
                                                            const double _extra_price_shift_first = 0.0);
  void                     CDKBaseBot::AddBarHintAnchorPrice(const string _msg, const string _hint, 
                                                             const int _idx=0,
                                                             const int _char=158, 
                                                             const color _clr=clrLightBlue, 
                                                             ENUM_BAR_HINT_ANCHOR _anchor=BAR_HIGH,
                                                             const double _extra_price_shift_next = 0.0,
                                                             double _extra_price_shift_first = 0.0);  

  // Draw Position
  void                     CDKBaseBot::DrawAllPos();

  // Event Handlers
  void                     CDKBaseBot::OnTick(void);
  void                     CDKBaseBot::OnTrade(void);
  void                     CDKBaseBot::OnChartEvent(const int id,
                                                    const long& lparam,
                                                    const double& dparam,
                                                    const string& sparam);
  void                     CDKBaseBot::OnTradeTransaction(const MqlTradeTransaction &trans, 
                                                          const MqlTradeRequest &request, 
                                                          const MqlTradeResult &result);
  double                   CDKBaseBot::OnTester(void);

  virtual void             CDKBaseBot::OnBar(CArrayInt& _tf_list)=NULL;                                                          
  virtual void             CDKBaseBot::OnOrderPlaced(ulong _order) {}
  virtual void             CDKBaseBot::OnOrderModified(ulong _order) {}
  virtual void             CDKBaseBot::OnOrderDeleted(ulong _order) {}
  virtual void             CDKBaseBot::OnOrderExpired(ulong _order) {}
  virtual void             CDKBaseBot::OnOrderTriggered(ulong _order) {}

  virtual void             CDKBaseBot::OnPositionOpened(ulong _position, ulong _deal) {}
  virtual void             CDKBaseBot::OnPositionStopLoss(ulong _position, ulong _deal) {}
  virtual void             CDKBaseBot::OnPositionTakeProfit(ulong _position, ulong _deal) {}
  virtual void             CDKBaseBot::OnPositionClosed(ulong _position, ulong _deal) {}
  virtual void             CDKBaseBot::OnPositionCloseBy(ulong _position, ulong _deal){}
  virtual void             CDKBaseBot::OnPositionModified(ulong _position) {}

  void                     CDKBaseBot::CDKBaseBot(void);
  void                     CDKBaseBot::~CDKBaseBot(void);
};


//+------------------------------------------------------------------+
//| Set comment text
//| To show comment is using ShowComment func
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::SetComment(const string _comment){
  ClearComment();
  CommentText = _comment;
} 

//+------------------------------------------------------------------+
//| Clear comment text
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::ClearComment() {
  CommentText = "";
  Color.Clear();
  BgrColor.Clear();
}

//+------------------------------------------------------------------+
//| Clear comment text
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::AddCommentLine(const string _str, const color _clr = 0, const color _bgr_clr = 0) {
  string sep = (CommentText != "") ? "\n" : "";
  CommentText += sep +_str;
  
  if(UseCustomComment) {
    Color.Add(_clr);
    BgrColor.Add(_bgr_clr);
  }
}

//+------------------------------------------------------------------+
//| Update current grid status
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::ShowComment(const bool _ignore_interval = false) {
  if(!CommentEnable) return;

  string text = CommentText;
  if(Inputs.__MS_LIC_DUR_SEC > 0)
    text += "\n\nBOT IS RUNNING IN FULLY FUNACTIOAL DEMO MODE";
    
  if(CommentText == "") return;
  if(CommentText == CommentTextLastShown) return; // Text didn't change ==> skip update

  if (UseCustomComment)
    CommentWnd.ShowText(text, Color, BgrColor);
  else  
    Comment(text);
    
  CommentLastUpdate = TimeCurrent();
  CommentTextLastShown = CommentText;
}

//+------------------------------------------------------------------+
//| Constructor   
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::CDKBaseBot(void) {
  Logger.Init("CDKBaseBot", NO);
  CommentIntervalMS = 60000; 
  UseCustomComment = false;
}

//+------------------------------------------------------------------+
//| Destructor    
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::~CDKBaseBot(void) {
  if(CommentWnd != NULL) {
    CommentWnd.Destroy(0);
    delete CommentWnd;
  }
  BarHintArr.Clear();
}

//+------------------------------------------------------------------+
//| Set Comment Font Name
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::SetFont(const string _font_name) {
  if(UseCustomComment)
    CommentWnd.SetFont(_font_name);
}

//+------------------------------------------------------------------+
//| Set Comment HighlightSelection
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::SetHighlightSelection(const bool _highlight_selection_flag) {
  if(UseCustomComment)
    CommentWnd.SetHighlightSelection(_highlight_selection_flag);  
}

//+------------------------------------------------------------------+
//| Init Bot
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::Init(const string _sym,
                      const ENUM_TIMEFRAMES _tf,
                      const ulong _magic,
                      CDKTrade& _trade,
                      const bool _use_custom_comment_window,
                      const T& _inputs,
                      CDKLogger* _logger = NULL) {
  MathSrand(GetTickCount());

  if (_logger != NULL) Logger = _logger; // Set custom logger

  Sym.Name(_sym);
  TF = _tf;
  Magic = _magic;
  
  TrackPosByMagic = true;
  TrackOrdByMagic = true;
  
  TrackPosBySymbol = true;
  TrackOrdBySymbol = true;
  
  Trade = _trade;
  Trade.SetExpertMagicNumber(Magic);
  
  Inputs = _inputs;
  
  TimeAllowed.ClearIntervalsAll();
  
  CommentText = "";
  CommentLastUpdate = 0;
  
  timers.KillAllTimers();
  CommentEnable = true;
  if((MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) || MQLInfoInteger(MQL_OPTIMIZATION)) CommentEnable = false;
  else
    timers.NewTimerSetMaxPossibleEventTimer(Inputs._MS_COM_IS, OnTimer_ShowComment);
  
  // Create custom comment dialog
  UseCustomComment = (CommentEnable) ? _use_custom_comment_window : false;
  if(UseCustomComment && CommentWnd == NULL) {
    CommentWnd = new CDKCommentWnd();
    if(!CommentWnd.Create(0, 
                          StringFormat("%s %I64u", Logger.Name, Inputs._MS_MGC),
                          0, 80, 80, 600, 530))
      return;
    CommentWnd.Run();   
  }
  
  // BarHint New bar detector
  BarHintArr.Clear();
  BarHintNewBarDetector.ClearTimeFrames();
  if(Inputs._MS_HIN_EN) {
    BarHintNewBarDetector.AddTimeFrame(Period());
    BarHintNewBarDetector.ResetAllLastBarTime();
  }
  
  // New bar detector init
  NewBarDetector.AddTimeFrame(TF);
  NewBarDetector.ResetAllLastBarTime();
  
  // OnTester new bar detecto
  OnTesterBarDetector.ClearTimeFrames();
  if(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION)) // Count OnTester Value runs only in Tester mode
    if(Inputs._MS_OTR_MOD != OTR_MODE_OFF) { 
      OnTesterBarDetector.AddTimeFrame(Inputs._MS_OTR_TF);
      OnTesterBarDetector.ResetAllLastBarTime();
    }    
  
  LoadMarket();
  
  InitChild();
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
template<typename T>
bool CDKBaseBot::Check(void) {
  bool res = true;
  //// Проверим режим счета. Нужeн ОБЯЗАТЕЛЬНО ХЕДЖИНГОВЫЙ счет
  //CAccountInfo acc;
  //if(acc.MarginMode() != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
  //  Logger.Error("Only hedging mode allowed", true);
  //  res = false;
  //}

  if(CheckExpiredAndShowMessage(Inputs.__MS_LIC_DUR_SEC)) 
    res = false;

  if(!Sym.Name(Symbol())) {
    Logger.Error(StringFormat("Symbol %s is not available", Symbol()), true);
    res = false;
  }
  
  return res;
}

//+------------------------------------------------------------------+
//| Loads pos from market
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::LoadMarketPos() {
  Poses.Clear();

  CDKPositionInfo pos;
  for (int i=0; i<PositionsTotal(); i++) {
    if (!pos.SelectByIndex(i)) continue;
    if (TrackPosByMagic && pos.Magic() != Magic) continue;
    if (TrackPosBySymbol && pos.Symbol() != Sym.Name()) continue;

    Poses.Add(pos.Ticket());
  }
}

//+------------------------------------------------------------------+
//| Loads orders from market
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::LoadMarketOrd() {
  Orders.Clear();

  COrderInfo order;
  for (int i=0; i<OrdersTotal(); i++) {
    if (!order.SelectByIndex(i)) continue;
    if (TrackOrdByMagic && order.Magic() != Magic) continue;
    if (TrackOrdBySymbol && order.Symbol() != Sym.Name()) continue;

    Orders.Add(order.Ticket());
  }
}

//+------------------------------------------------------------------+
//| Loads market poses and orders
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::LoadMarket() {
  LoadMarketPos();
  LoadMarketOrd();
}

//+------------------------------------------------------------------+
//| Return average price of all poses with _dir
//| All dir avg price use _dir==WRONG_VALUE
//+------------------------------------------------------------------+
template<typename T>
double CDKBaseBot::PosPriceAverage(const ENUM_POSITION_TYPE _dir) {
  if(Poses.Total() <= 0) return 0.0;
  
  CDKPositionInfo pos;
  
  if(Poses.Total() == 1)  {
    if(pos.SelectByTicket(Poses.At(0)) && pos.PositionType() == _dir)
      return pos.PriceOpen();
    return 0.0;
  }
  
  double s = 0.0;
  double v = 0.0;
  for(int i=0;i<Poses.Total();i++){
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    if(pos.PositionType() != _dir) continue;
    
    v += pos.Volume();
    s += pos.PriceOpen() * pos.Volume();
  }
  
  return (v > 0.0) ? s/v : 0.0;
}

//+------------------------------------------------------------------+
//| Count pos by _dir
//+------------------------------------------------------------------+
template<typename T>
int CDKBaseBot::PosByDirCount(const ENUM_POSITION_TYPE _dir) {
  if(Poses.Total() <= 0)
    return 0;
    
  int cnt = 0;
  CDKPositionInfo pos;
  for(int i=0;i<Poses.Total();i++) {
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    if(pos.PositionType() == _dir) cnt++;
  }

  return cnt;
}

//+------------------------------------------------------------------+
//| Delete all poses
//+------------------------------------------------------------------+
template<typename T>
bool CDKBaseBot::DeleteAllPoses() {
  int del_cnt = 0;
  for(int i=0;i<Poses.Total();i++) {
    bool del_res = Trade.PositionClose(Poses.At(i));
    LSF_ASSERT(del_res, 
               StringFormat("POS=%d/%d; TICKET=%I64u; RET_CODE=%d; RET_MSG='%s'",
                            i+1, Poses.Total(), Poses.At(i), 
                            Trade.ResultRetcode(), Trade.ResultRetcodeDescription()),
               WARN,
               ERROR);
    if(del_res) del_cnt++;
  }
  
  return del_cnt == Poses.Total();
}

//+------------------------------------------------------------------+
//| Delete all poses
//+------------------------------------------------------------------+
template<typename T>
bool CDKBaseBot::DeleteAllPosesByDir(const ENUM_POSITION_TYPE _dir) {
  CDKPositionInfo pos;
  int pos_to_del_cnt = 0;
  int del_cnt = 0;
  for(int i=0;i<Poses.Total();i++) {
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    if(pos.PositionType() != _dir) continue;
    
    pos_to_del_cnt++;    
    bool del_res = Trade.PositionClose(Poses.At(i));
    LSF_ASSERT(del_res, 
               StringFormat("POS=%d/%d; TICKET=%I64u; DIR=%s; RET_CODE=%d; RET_MSG='%s'",
                            i+1, Poses.Total(), 
                            Poses.At(i), PositionTypeToString(pos.PositionType()),                            
                            Trade.ResultRetcode(), Trade.ResultRetcodeDescription()),
               WARN, ERROR);
    if(del_res) del_cnt++;
  }
  
  return del_cnt == pos_to_del_cnt;
}

//+------------------------------------------------------------------+
//| Delete all orders
//+------------------------------------------------------------------+
template<typename T>
bool CDKBaseBot::DeleteAllOrders() {
  int del_cnt = 0;
  for(int i=0;i<Orders.Total();i++) {
    bool del_res = Trade.OrderDelete(Orders.At(i));
    LSF_ASSERT(del_res, 
               StringFormat("ORDER=%d/%d; TICKET=%I64u; RET_CODE=%d; RET_MSG='%s'",
                            i+1, Orders.Total(), Orders.At(i), 
                            Trade.ResultRetcode(), Trade.ResultRetcodeDescription()),
               WARN,
               ERROR);
    if(del_res) del_cnt++;
  }
  
  return del_cnt == Orders.Total();
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::OnTick(void) {
  CArrayInt BarList;
  if(NewBarDetector.CheckNewBarAvaliable(BarList)) {
    NewBarList = BarList;
    if(DEBUG >= Logger.Level) 
      for(int i=0;i<NewBarList.Total();i++) 
        Logger.Debug(StringFormat("%s/%d: New bar detected: TF=%s",
                                  __FUNCTION__, __LINE__,
                                  TimeframeToString((ENUM_TIMEFRAMES)NewBarList.At(i))));
    OnBar(BarList);
  }

  if(UseCustomComment)
    CommentWnd.OnTick(); 
    
  // Bar hints
  if(Inputs._MS_HIN_EN && BarHintNewBarDetector.CheckNewBarAvaliable(Period()))
    UpdateBarHints();
    
  // OnTester value
  if((Inputs._MS_OTR_MOD != OTR_MODE_OFF) && OnTesterBarDetector.CheckNewBarAvaliable(Inputs._MS_OTR_TF))
    OnTesterEquityCollector.OnTimer();

  ShowComment();
}


//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::OnTrade(void) {
  LoadMarket();
  ShowComment();
}

//+------------------------------------------------------------------+
//| OnChartEvent Handler
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::OnChartEvent(const int id,         // event ID  
                              const long& lparam,   // event parameter of the long type
                              const double& dparam, // event parameter of the double type
                              const string& sparam) { // event parameter of the string type
  if(!UseCustomComment) return;
  
  CommentWnd.ChartEvent(id,lparam,dparam,sparam);
}

//+------------------------------------------------------------------+
//| OnTradeTransaction Handler
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::OnTradeTransaction(const MqlTradeTransaction &trans, 
                                    const MqlTradeRequest &request,
                                    const MqlTradeResult &result) {
  if(IS_TRANSACTION_ORDER_PLACED)
    OnOrderPlaced(result.order);
  
  else if(IS_TRANSACTION_ORDER_MODIFIED) {
    OnOrderModified(request.order);
  }
  
  else if(IS_TRANSACTION_ORDER_DELETED) {
    OnOrderDeleted(trans.order);
  }
  
  else if(IS_TRANSACTION_ORDER_EXPIRED) {
    OnOrderExpired(trans.order);
  }
  
  else if(IS_TRANSACTION_ORDER_TRIGGERED) {
    OnOrderTriggered(trans.order);
  }
  
  else if(IS_TRANSACTION_POSITION_OPENED) {
    OnPositionOpened(trans.position,trans.deal);
  }
  
  else if(IS_TRANSACTION_POSITION_STOP_TAKE) {
    OnPositionStopLoss(trans.position,trans.deal);
  }
    
  else if(IS_TRANSACTION_POSITION_TAKE_TAKE) {
    OnPositionTakeProfit(trans.position,trans.deal);
  }    
  
  else if(IS_TRANSACTION_POSITION_CLOSED) {
    OnPositionClosed(trans.position,trans.deal);
  }
  
  else if(IS_TRANSACTION_POSITION_CLOSEBY) {
    OnPositionCloseBy(trans.position,trans.deal);
  }    
  
  else if(IS_TRANSACTION_POSITION_MODIFIED) {
    OnPositionModified(request.position);    
  }                                
}

//+------------------------------------------------------------------+
//| OnTester
//+------------------------------------------------------------------+
template<typename T>
double CDKBaseBot::OnTester(void) {
  if(Inputs._MS_OTR_MOD == OTR_MODE_OFF) return 0.0;
  
  ENUM_CORR_TYPE corr_type = CORR_PEARSON;
  if(Inputs._MS_OTR_MOD == OTR_MODE_PURE_R2_SPEARMAN) corr_type = CORR_SPEARMAN;
  return(CustomR2Equity(OnTesterEquityCollector.Data, corr_type));
}

//+------------------------------------------------------------------+
//| Update BarHints on the chart
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::UpdateBarHints() {
  if(!Inputs._MS_HIN_EN) return;
  
  int i = 0;
  while(i<BarHintArr.Total()){
    CDKBarHint* hint = BarHintArr.At(i);
    if(!hint.IsBarFinal()) 
      hint.Draw();
    if(hint.IsBarFinal()) {
      BarHintArr.Delete(i);
      continue;
    }
    
    i++;
  }
}

//+------------------------------------------------------------------+
//| Add hint to the bar on chart with ENUM_BAR_HINT_ANCHOR positioning
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::AddBarHintAnchorPrice(const string _msg, const string _hint, 
                                    const int _idx=0,
                                    const int _char=158, 
                                    const color _clr=clrLightBlue, 
                                    ENUM_BAR_HINT_ANCHOR _anchor=BAR_HIGH, 
                                    double _extra_price_shift_next = 0.0,
                                    double _extra_price_shift_first = 0.0
                                    ) {
  if(!Inputs._MS_HIN_EN) return;
  
  CDKBarHint* hint = new CDKBarHint;
  
  hint.ObjectPrefix = Logger.Name;
  hint.Message = _msg;
  hint.Hint = _hint;
  hint.Anchor = _anchor;
  hint.PriceBase = 0.0;
  hint.PriceShiftBase = _extra_price_shift_first;
  hint.PriceShiftNext = _extra_price_shift_next;
  hint.Time = iTime(Symbol(), Period(), _idx);
  hint.Char = char(_char);
  hint.Color = _clr;
  hint.Draw();
  
  BarHintArr.Add(hint);
}

//+------------------------------------------------------------------+
//| Add hint to the bar on chart by fixed price pos
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::AddBarHintFixedPrice(const string _msg, const string _hint, 
                                   const double _price,
                                   const int _idx=0,
                                   const int _char=158, 
                                   const color _clr=clrLightBlue,
                                   const double _extra_price_shift_next = 0.0,
                                   const double _extra_price_shift_first = 0.0
                                   ) {
  if(!Inputs._MS_HIN_EN) return;
  
  CDKBarHint* hint = new CDKBarHint;
  
  hint.ObjectPrefix = Logger.Name;
  hint.Message = _msg;
  hint.Hint = _hint;
  hint.Anchor = BAR_FIXED_PRICE;
  hint.PriceBase = _price;
  hint.PriceShiftBase = _extra_price_shift_first;
  hint.PriceShiftNext = _extra_price_shift_next;
  hint.Time = iTime(Symbol(), Period(), _idx);
  hint.Char = char(_char);
  hint.Color = _clr;
  hint.Draw();
  
  BarHintArr.Add(hint);
}


//+------------------------------------------------------------------+
//| Draw Position
//+------------------------------------------------------------------+
template<typename T>
void CDKBaseBot::DrawAllPos() {
  LoadMarketPos();

  CDKChartObjectPosition chart_pos;
  for(int i=0;i<Poses.Total();i++) {
    chart_pos.Create(Poses.At(i), 0, Logger.Name);   
    chart_pos.Detach();
  }
}

//+------------------------------------------------------------------+
//| Timer function for CDKBaseBot::ShowComment()                                                   |
//+------------------------------------------------------------------+
void OnTimer_ShowComment()  {
  bot.ShowComment();
}


