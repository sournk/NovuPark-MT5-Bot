//+------------------------------------------------------------------+
//|                                                     DKStdLib.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//| 2025-06-09:
//|   [+] PosReverse()
//|   [+] PosByDir()
//| 2025-04-03:
//|   [*] PositionTypeToString() return NONE for WRONG_VALUE
//| 2024-10-24:
//|   [+] Macro def for CArrayObj iteration
//| 2024-11-2:
//|   [+] ENUM_POS_TYPE
//+------------------------------------------------------------------+

#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#define CARRAYOBJ_ITER(_list, _el_type_name, _code_block) \
  for(int i=0;i<_list.Total();i++)    {                   \
    _el_type_name* el = _list.At(i);                      \
    _code_block                                           \
  }                                                       \
  
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include "..\TradingManager\CDKSymbolInfo.mqh";

enum ENUM_OBJECT_COMPARE_MODE {
  OBJECT_COMPARE_MODE_LT = 10,
  OBJECT_COMPARE_MODE_LE = 11,
  OBJECT_COMPARE_MODE_GT = 12,
  OBJECT_COMPARE_MODE_GE = 13,
  OBJECT_COMPARE_MODE_EQ = 14,
  OBJECT_COMPARE_MODE_NE = 15,
};

enum ENUM_MM_TYPE {
  ENUM_MM_TYPE_FIXED_LOT,                 // Fixed lot
  ENUM_MM_TYPE_FIXED_LOSS,                // Fixed max loss
  ENUM_MM_TYPE_BALANCE_PERCENT,           // % of Balance
  ENUM_MM_TYPE_EQUITY_PERCENT,            // % of Equity
  ENUM_MM_TYPE_FREE_MARGIN_PERCENT,       // % of Free Margin
  ENUM_MM_TYPE_AUTO_LIMIT_RISK            // Auto (limit % of risk)
};

enum ENUM_DK_POS_TYPE {
  BUY  = POSITION_TYPE_BUY, // Buy
  SELL = POSITION_TYPE_SELL // Sell
};

enum ENUM_DK_ORDER_TYPE {
  MARKET = 0,    // Market 
  STOP = 1,      // Stop
  LIMIT = 2,     // Limit
  STOP_LIMIT = 3 // Stop Limit
};

ENUM_ORDER_TYPE PosToOrderType(ENUM_DK_POS_TYPE _pos_type, ENUM_DK_ORDER_TYPE _order_type) {
  if(_pos_type == BUY ){
    if(_order_type == MARKET) return ORDER_TYPE_BUY;
    if(_order_type == STOP) return ORDER_TYPE_BUY_STOP;
    if(_order_type == LIMIT) return ORDER_TYPE_BUY_LIMIT;
    if(_order_type == STOP_LIMIT) return ORDER_TYPE_BUY_STOP_LIMIT;
  }
  
  
  if(_order_type == STOP) return ORDER_TYPE_SELL_STOP;
  if(_order_type == LIMIT) return ORDER_TYPE_SELL_LIMIT;
  if(_order_type == STOP_LIMIT) return ORDER_TYPE_SELL_STOP_LIMIT;  
  
  
  return ORDER_TYPE_SELL; //if(_order_type == MARKET) 
}

ENUM_DK_POS_TYPE PosReverse(ENUM_DK_POS_TYPE _pos_type) {
  if(_pos_type == BUY) return SELL;
  return BUY;
}

ENUM_POSITION_TYPE PosReverse(ENUM_POSITION_TYPE _pos_type) {
  if(_pos_type == POSITION_TYPE_BUY) return POSITION_TYPE_SELL;
  return POSITION_TYPE_BUY;
}

ENUM_POSITION_TYPE PosByDir(int _dir) {
  if(_dir > 0) return POSITION_TYPE_BUY;
  if(_dir < 0) return POSITION_TYPE_SELL;
  return WRONG_VALUE;
}

string TimeToStringISO(const datetime _dt) {
  string shor_dt = StringFormat("%sT%s", 
                                StringSubstr(TimeToString(_dt, TIME_DATE), 2), 
                                TimeToString(_dt, TIME_MINUTES));
  StringReplace(shor_dt, ".", "");
  StringReplace(shor_dt, ":", "");
  
  return shor_dt;
}

string TimeToStringNA(const datetime aDt, const int aFlags=TIME_DATE|TIME_MINUTES, const string aZeroText="NA") {
  if (aDt == 0) return aZeroText;
  return TimeToString(aDt, aFlags);
}

string IntegerTo36(ulong n) {   
  if (n == 0) return "0";
  
  const string digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const int radix = 36;

  string r = "";
  while (n>0) {
    ulong k = n % radix; //
    r = StringSubstr(digits, (int)k, 1) + r; // # приклеим к результату
    n = (int)MathFloor(n / radix);
  }
  return r;
}

string GetUniqueInstanceName(const string baseName) {
  ulong seed = GetTickCount64();
  return StringFormat("%s%s_%s", baseName, IntegerTo36(seed), IntegerTo36(MathRand()));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeLot(string aSymbol, double lot) {
  CSymbolInfo symbol;
  if (symbol.Name(aSymbol)) {
    lot =  NormalizeDouble(lot, symbol.Digits());
    double lotStep = symbol.LotsStep();
    return floor(lot / lotStep) * lotStep;
  }
  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeLotFilterMinMax(string aSymbol, double lot) {
  CSymbolInfo symbol;

  double useLot = 0;
  if (symbol.Name(aSymbol)) {
    double maxLot  = symbol.LotsMax();
    double minLot  = symbol.LotsMin();
    double lotStep = symbol.LotsStep();

    useLot  = minLot;
    if(lot > useLot) {
      if(lot > maxLot) useLot = maxLot;
      else useLot = floor(lot / lotStep) * lotStep;
    }

  }
  return useLot;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Money Managment and Lot size calculation
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Returns Point Value                                              |
//+------------------------------------------------------------------+
double GetPointValue(string _symbol) {
  double point = SymbolInfoDouble(_symbol, SYMBOL_POINT);
  double tickValue = SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE);
  double tickSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
  double pointValue = tickValue * (point / tickSize);
  
  return (pointValue);
}

//+------------------------------------------------------------------+
//| Calculates Lots by MM type                                       |
//+------------------------------------------------------------------+
double CalculateLots(const string aSymbol,
                     const ENUM_MM_TYPE aMMType,
                     const double aMMValue,
                     const double aStopLoss = 0,
                     const double aPrice = 0) {

  double result = 0.0;

  CDKSymbolInfo symbol;
  if (!symbol.Name(aSymbol)) return result;

  double lotStep = symbol.LotsStep();
  double minLot = symbol.LotsMin();
  double maxLot = symbol.LotsMax();
  double tickValue = symbol.TickValue();
  int calcMode = symbol.TradeCalcMode();
  string calcModeStr = symbol.TradeCalcModeDescription();
  
  CAccountInfo account;
  if(aMMType == ENUM_MM_TYPE_FIXED_LOT) result = NormalizeDouble(aMMValue, 2);
  if(aMMType == ENUM_MM_TYPE_BALANCE_PERCENT) result = MathFloor(account.Balance() * aMMValue / 100 / aPrice);
  if(aMMType == ENUM_MM_TYPE_FREE_MARGIN_PERCENT) result = MathFloor(account.FreeMargin() * aMMValue / 100 / aPrice);
  if(aMMType == ENUM_MM_TYPE_AUTO_LIMIT_RISK) { 
    double base = MathMin(account.Equity(), account.Balance());
    double currencyRisk = base * aMMValue / 100;
    result = currencyRisk / (aStopLoss * tickValue); 
  }  

  if (lotStep != 0) result = MathFloor(result / lotStep) * lotStep; 
  result = NormalizeDouble(MathMin(MathMax(result, minLot), maxLot), 2);
  return(result);
}  

//+------------------------------------------------------------------+
//| Calculates Lots for your aAssetsBase in account currency
//|   - If aStopLossPrice == 0 then returns lot for % (aBasePercent)  of aAssetsBase
//|   - If aStopLoss !=0 then returns lot for max loss equals % (aBasePercent)  of aAssetsBase
//+------------------------------------------------------------------+
double CalculateLotSuperForSum(const string aSymbol,                // Symbol
                               const double aSum,                   // Assets in account currency
                               const double aOpenPrice,             // Open price
                               const double aStopLossPrice = 0) {   // Stoploss price
  CAccountInfo account;
  CSymbolInfo symbol;
  if (!symbol.Name(aSymbol)) return 0;
  
  double result = 0.0;

  double lotStep   = symbol.LotsStep();
  double minLot    = symbol.LotsMin();
  double maxLot    = symbol.LotsMax();
  double contractSize = symbol.ContractSize();
  long lev = account.Leverage();
  
  double max_margin_or_loss_allowed = aSum;
  double max_margin_or_loss_for_max_lot = 0;
  if(aStopLossPrice != 0) 
    max_margin_or_loss_for_max_lot = MathAbs(account.OrderProfitCheck(aSymbol, ORDER_TYPE_BUY, maxLot, aOpenPrice, aStopLossPrice));
  else 
    max_margin_or_loss_for_max_lot = account.MarginCheck(aSymbol, ORDER_TYPE_BUY, maxLot, aOpenPrice);  
    
  result = (max_margin_or_loss_allowed / max_margin_or_loss_for_max_lot) * maxLot;
  
  if (lotStep != 0) result = MathFloor(result / lotStep) * lotStep; 
  result = NormalizeDouble(MathMin(MathMax(result, minLot), maxLot), 2);
  return result;
}  

//+------------------------------------------------------------------+
//| Calculates Lots for your aAssetsBase in account currency
//|   - If aStopLossPrice == 0 then returns lot for % (aBasePercent)  of aAssetsBase
//|   - If aStopLoss !=0 then returns lot for max loss equals % (aBasePercent)  of aAssetsBase
//+------------------------------------------------------------------+
double CalculateLotSuper(const string aSymbol,                // Symbol
                         const double aBasePercent,           // % of your base
                         const double aAssetsBase,            // Assets in account currency
                         const double aOpenPrice,             // Open price
                         const double aStopLossPrice = 0) {   // Stoploss price
  return CalculateLotSuperForSum(aSymbol, aAssetsBase * aBasePercent / 100, aOpenPrice, aStopLossPrice);
}  

//+------------------------------------------------------------------+
//| Calculates Lots using MM_Type based on your account currency
//+------------------------------------------------------------------+
double CalculateLotSuper(const string aSymbol,               // Symbol
                         const ENUM_MM_TYPE aMMType,         // MM type
                         const double aMMValue,              // MM value: for Fixed Lot = lot else % from Assests
                         const double aOpenPrice,            // Open price
                         const double aStopLossPrice) {      // Stop loss price
  if(aMMType == ENUM_MM_TYPE_FIXED_LOT) return NormalizeDouble(aMMValue, 2);
  if(aMMType == ENUM_MM_TYPE_FIXED_LOSS) return CalculateLotSuperForSum(aSymbol, aMMValue, aOpenPrice, aStopLossPrice);

  CAccountInfo account;
  double base = 0;
  if(aMMType == ENUM_MM_TYPE_BALANCE_PERCENT)                base = account.Balance();
  if(aMMType == ENUM_MM_TYPE_FREE_MARGIN_PERCENT)            base = account.FreeMargin();
  //if(aMMType == ENUM_MM_TYPE_EQUITY_PERCENT)                 base = account.Equity();  
  if(aMMType == ENUM_MM_TYPE_AUTO_LIMIT_RISK)                base = MathMin(account.Balance(), account.Equity());
  
  if(aMMType == ENUM_MM_TYPE_AUTO_LIMIT_RISK) return CalculateLotSuper(aSymbol, aMMValue, base, aOpenPrice, aStopLossPrice);
  
  return CalculateLotSuper(aSymbol, aMMValue, base, aOpenPrice, 0);
}   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceToPoints(string aSymbol, double aValue) {
  CSymbolInfo symbol;
  if(symbol.Name(aSymbol)) return((int)(aValue * MathPow(10, symbol.Digits())));
  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PointsToPrice(string aSymbol, int aValue) {
  CSymbolInfo symbol;
  if(symbol.Name(aSymbol)) return(NormalizeDouble(aValue * symbol.Point(), symbol.Digits()));
  return 0;
}

bool CompareDouble(double a, double b) {       
  return (fabs(a-b)<=DBL_MIN+8*DBL_EPSILON*fmax(fabs(a),fabs(b)));
}

//+------------------------------------------------------------------+
//| Returns dir sign +1 or -1                                                                  |
//+------------------------------------------------------------------+
int GetPosDirSign(const ENUM_POSITION_TYPE _dir) {
  if (_dir == POSITION_TYPE_BUY) return +1;
  return -1;
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is better (gt) _price_base 
//| given pos dir
//+------------------------------------------------------------------+
bool IsPosPriceGT(const ENUM_POSITION_TYPE _dir, const double _price_to_check, const double _price_base) {
  if (_dir == POSITION_TYPE_BUY) return _price_to_check>_price_base;
  return _price_to_check<_price_base;
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is better (ge) _price_base 
//| given pos dir
//+------------------------------------------------------------------+
bool IsPosPriceGE(const ENUM_POSITION_TYPE _dir, const double _price_to_check, const double _price_base) {
  if (_dir == POSITION_TYPE_BUY) return _price_to_check>=_price_base;
  return _price_to_check<=_price_base;
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is worst (lt) _price_base 
//| given pos dir
//+------------------------------------------------------------------+
bool IsPosPriceLT(const ENUM_POSITION_TYPE _dir, const double _price_to_check, const double _price_base) {
  if (_dir == POSITION_TYPE_BUY) return _price_to_check<_price_base;
  return _price_to_check>_price_base;
}

//+------------------------------------------------------------------+
//| Check if _price_to_check is worst (le) _price_base 
//| given pos dir
//+------------------------------------------------------------------+
bool IsPosPriceLE(const ENUM_POSITION_TYPE _dir, const double _price_to_check, const double _price_base) {
  if (_dir == POSITION_TYPE_BUY) return _price_to_check<=_price_base;
  return _price_to_check>=_price_base;
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| EA EVENTS
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Checks autotrading is avaliable                                  |
//+------------------------------------------------------------------+
bool IsAutoTradingEnabled() {
  // https://www.mql5.com/en/docs/runtime/tradepermission

  if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return(false);
  if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) return(false);
  if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) return(false);

  return(true);
}

//+------------------------------------------------------------------+
//| Refreshes rates                                                  |
//+------------------------------------------------------------------+
bool RefreshRates(string aName) {
  CSymbolInfo symbol;
  
  if(!symbol.Name(aName)) return false;
  if(!symbol.RefreshRates()) return false;
  if((0 == symbol.Ask()) || (0 == symbol.Bid())) return false;

  return true;
}

ENUM_TIMEFRAMES StringToTimeframe(const string aString) {    
  if (aString == "PERIOD_M1"  || aString =="M1")  return PERIOD_M1;
  if (aString == "PERIOD_M2"  || aString =="M2")  return PERIOD_M2;
  if (aString == "PERIOD_M3"  || aString =="M3")  return PERIOD_M3;
  if (aString == "PERIOD_M4"  || aString =="M4")  return PERIOD_M4;
  if (aString == "PERIOD_M5"  || aString =="M5")  return PERIOD_M5;
  if (aString == "PERIOD_M6"  || aString =="M6")  return PERIOD_M6;
  if (aString == "PERIOD_M10" || aString =="M10") return PERIOD_M10;
  if (aString == "PERIOD_M12" || aString =="M12") return PERIOD_M12;
  if (aString == "PERIOD_M15" || aString =="M15") return PERIOD_M15;
  if (aString == "PERIOD_M20" || aString =="M20") return PERIOD_M20;
  if (aString == "PERIOD_M30" || aString =="M30") return PERIOD_M30;
  if (aString == "PERIOD_H1"  || aString =="H1")  return PERIOD_H1;
  if (aString == "PERIOD_H2"  || aString =="H2")  return PERIOD_H2;
  if (aString == "PERIOD_H3"  || aString =="H3")  return PERIOD_H3;
  if (aString == "PERIOD_H4"  || aString =="H4")  return PERIOD_H4;
  if (aString == "PERIOD_H6"  || aString =="H6")  return PERIOD_H6;
  if (aString == "PERIOD_H8"  || aString =="H8")  return PERIOD_H8;
  if (aString == "PERIOD_H12" || aString =="H12") return PERIOD_H12;
  if (aString == "PERIOD_D1"  || aString =="D1")  return PERIOD_D1;
  if (aString == "PERIOD_W1"  || aString =="W1")  return PERIOD_W1;
  if (aString == "PERIOD_MN1" || aString =="MN1") return PERIOD_MN1;

  return Period();
}

string AppliedPriceToSrting(ENUM_APPLIED_PRICE _enum) {
  string enum_str = EnumToString(_enum);
  StringReplace(enum_str, "PRICE_", "");
  return enum_str;
}

string TimeframeToString(ENUM_TIMEFRAMES _period) {
  string enum_str = EnumToString(_period);
  StringReplace(enum_str, "PERIOD_", "");
  return enum_str;
}

string PositionTypeToString(const ENUM_POSITION_TYPE _type, const bool _short_format=false) {
  if(_type == WRONG_VALUE)
    return (_short_format) ? "0" : "NONE";
    
  string enum_str = EnumToString(_type);
  StringReplace(enum_str, "POSITION_TYPE_", "");
  if (_short_format) {
    StringReplace(enum_str, "BUY", "B");
    StringReplace(enum_str, "SELL", "S");
  }
  return enum_str;  
}

string PosTypeDKToString(const ENUM_DK_POS_TYPE _type, const bool _short_format=false) {
  return PositionTypeToString((ENUM_POSITION_TYPE)_type, _short_format);
}

// Returns a random number in the range [min..max) Max excluded.
// Random(10,  0)   returns 0   … 9      with equal probability.
// Random(10.0,0.0) returns 0.0 … 9.9999 with equal probability.
int RandomLinear(int max, int min=0){
   int range   = max - min;
   int randMax = 32768 - 32768 % range;
   int rand;  do{ rand = MathRand(); }while (rand >= randMax);
   return rand % range + min;
}