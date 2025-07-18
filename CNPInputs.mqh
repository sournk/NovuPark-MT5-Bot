//+------------------------------------------------------------------+
//|                                                    CNPInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

// Field naming convention:
//  1. With the prefix '__' the field will not be declared for user input
//  2. With the prefix '_' the field will be declared as 'sinput'
//  3. otherwise it will be declared as 'input'

//#include <Indicators\Oscilators.mqh>
//#include <Indicators\Trend.mqh>

#include <Indicators\BillWilliams.mqh>

#include "Include\DKStdLib\CiCustom\CiUTBot.mqh"
#include "Include\DKStdLib\CiCustom\CiSTC.mqh"
#include "Include\DKStdLib\Common\DKStdLib.mqh"


enum ENUM_OTR_MODE {
  OTR_MODE_OFF                 = 1, // Off
  OTR_MODE_PURE_R2_PEARSON     = 2, // Pure R^2 by Pearson's correlation
  OTR_MODE_PURE_R2_SPEARMAN    = 3, // Pure R^2 by Spearman's Rank-Order correlation
};

enum ENUM_TRD_DIR_MODE {
  TRD_DIR_MODE_BOTH = +0, // Оба: BUY+SELL
  TRD_DIR_MODE_BUY  = +1, // Только BUY
  TRD_DIR_MODE_SELL = -1, // Только SELL
};

// PARSING AREA OF INPUT STRUCTURE == START == DO NOT REMOVE THIS COMMENT
struct CNPBotInputs {
  // input  group                    "1. INDICATORS (I*)"
  double                      I_UT_KEY;                 // UT Bot: Key Value (sensitivity) // 1.0(x>0)
  uint                        I_UT_ATR;                 // UT Bot: ATR Period // 10(x>0)  
  int                         I_STC_SCH_PER;            // STC: Schaff period // 32(x>0)
  int                         I_STC_FEMA;               // STC: Fast EMA period // 23(x>0)
  int                         I_STC_SEMA;               // STC: Slow EMA period // 50(x>0)
  double                      I_STC_SMT_PER;            // STC: Smoothing period // 3(x>0)
  enPrices                    I_STC_PRC;                // STC: Price // pr_close 
  
  // input  group                    "2. FILTER (F)"
  double                      F_STC_BUY_MIN;            // BUY allowed Min STC value // 0(x>=0)
  double                      F_STC_BUY_MAX;            // BUY allowed Max STC value // 25(x>=0)
  double                      F_STC_SELL_MIN;           // SELL allowed Min STC value // 75(x>=0)
  double                      F_STC_SELL_MAX;           // SELL allowed Max STC value // 100(x>=0)
  bool                        F_STC_CLR_ENB;            // Color Filter Enabled (BUY=GREEN; SELL=RED) // true
  
  // input  group                    "3. TRADE (TRD)"
  ENUM_TRD_DIR_MODE           TRD_DIR_MOD;              // Режим торговли // TRD_DIR_MODE_BOTH
  ENUM_MM_TYPE                TRD_MM_MOD;               // Money Management Type // ENUM_MM_TYPE_FIXED_LOT
  double                      TRD_MM_VAL;               // Money Management Value // 1.0(x>0.0)
  double                      TRD_TP_RR;                // TP RR // 1.0(x>=0)
  bool                        TRD_REV_ENB;              // Close pos on opposite signal // true
  
  // input  group                    "4. GRAPHIC (GUI)"
  bool                        GUI_ENB;                  // Draw pos // true

  // input  group                    "9. MISC (MS)"
  ulong                       _MS_MGC;                  // _Expert Adviser ID - Magic // 20250705
  string                      _MS_EGP;                  // _Expert Adviser Global Prefix // "NP"
  
  LogLevel                    _MS_LOG_LL;               // _Log Level // INFO
  string                      _MS_LOG_FI;               // _Log Filter IN String (use `;` as sep) // ""
  string                      _MS_LOG_FO;               // _Log Filter OUT String (use `;` as sep) // ""
  
  bool                        _MS_COM_EN;               // _Comment Enable (turn off for fast testing) // true
  uint                        _MS_COM_IS;               // _Comment Interval, ms // 30000
  bool                        _MS_COM_CW;               // _Comment Custom Window // false
  
  bool                        _MS_HIN_EN;               // _On Chart Hints Enabled // true
  int                         _MS_HIN_CH;               // _On Chart Default Char // 158
  color                       _MS_HIN_CL;               // _On Chart Default Color // clrCrimson
  
  ENUM_OTR_MODE               _MS_OTR_MOD;              // _On Tester Result calculation Mode // OTR_MODE_PURE_R2_SPEARMAN
  ENUM_TIMEFRAMES             _MS_OTR_TF;               // _On Tester Result calculation Timeframe // PERIOD_H1
  
  uint                        _MS_TIM_MS;               // _Timer Interval, ms // 60000
  uint                        __MS_LIC_DUR_SEC;         // __License Duration, Sec // 0*24*60*60
  
  
// PARSING AREA OF INPUT STRUCTURE == END == DO NOT REMOVE THIS COMMENT

  string LastErrorMessage;
  bool CNPBotInputs::InitAndCheck();
  bool CNPBotInputs::Init();
  bool CNPBotInputs::CheckBeforeInit();
  bool CNPBotInputs::CheckAfterInit();
  void CNPBotInputs::CNPBotInputs();
  
  // IND HNDLs
  // vvvvvvvvv
  CiUTBot                     UTBot;
  CiSTC                       STC;
  CiFractals                  Fractals;
};

//+------------------------------------------------------------------+
//| Init struc and Check values
//+------------------------------------------------------------------+
bool CNPBotInputs::InitAndCheck(){
  LastErrorMessage = "";

  if (!CheckBeforeInit())
    return false;

  if (!Init()) {
    LastErrorMessage = "Input.Init() failed";
    return false;
  }

  return CheckAfterInit();
}

//+------------------------------------------------------------------+
//| Init struc
//+------------------------------------------------------------------+
bool CNPBotInputs::Init(){
  UTBot.Create(Symbol(), Period(), I_UT_KEY, I_UT_ATR);
  STC.Create(Symbol(), Period(), I_STC_SCH_PER, I_STC_FEMA, I_STC_SEMA, I_STC_SMT_PER, I_STC_PRC);
  Fractals.Create(Symbol(), Period());

  return true;
}

//+------------------------------------------------------------------+
//| Check struc after Init
//+------------------------------------------------------------------+
bool CNPBotInputs::CheckAfterInit(){
  LastErrorMessage = "";
  
  if(UTBot.Handle() <= 0) LastErrorMessage = "Custom indicator 'UT Bot' load error";
  if(STC.Handle() <= 0) LastErrorMessage = "Custom indicator 'STC' load error";
  if(Fractals.Handle() <= 0) LastErrorMessage = "Custom indicator 'Fractals' load error";
  
  return LastErrorMessage == "";
}

// GENERATED CODE == START == DO NOT REMOVE THIS COMMENT

input  group                    "1. INDICATORS (I*)"
input  double                    Inp_I_UT_KEY                       = 1.0;                       // I_UT_KEY: UT Bot: Key Value (sensitivity)
input  uint                      Inp_I_UT_ATR                       = 10;                        // I_UT_ATR: UT Bot: ATR Period
input  int                       Inp_I_STC_SCH_PER                  = 32;                        // I_STC_SCH_PER: STC: Schaff period
input  int                       Inp_I_STC_FEMA                     = 23;                        // I_STC_FEMA: STC: Fast EMA period
input  int                       Inp_I_STC_SEMA                     = 50;                        // I_STC_SEMA: STC: Slow EMA period
input  double                    Inp_I_STC_SMT_PER                  = 3;                         // I_STC_SMT_PER: STC: Smoothing period
input  enPrices                  Inp_I_STC_PRC                      = pr_close;                  // I_STC_PRC: STC: Price

input  group                    "2. FILTER (F)"
input  double                    Inp_F_STC_BUY_MIN                  = 0;                         // F_STC_BUY_MIN: BUY allowed Min STC value
input  double                    Inp_F_STC_BUY_MAX                  = 25;                        // F_STC_BUY_MAX: BUY allowed Max STC value
input  double                    Inp_F_STC_SELL_MIN                 = 75;                        // F_STC_SELL_MIN: SELL allowed Min STC value
input  double                    Inp_F_STC_SELL_MAX                 = 100;                       // F_STC_SELL_MAX: SELL allowed Max STC value
input  bool                      Inp_F_STC_CLR_ENB                  = true;                      // F_STC_CLR_ENB: Color Filter Enabled (BUY=GREEN; SELL=RED)

input  group                    "3. TRADE (TRD)"
input  ENUM_TRD_DIR_MODE         Inp_TRD_DIR_MOD                    = TRD_DIR_MODE_BOTH;         // TRD_DIR_MOD: Режим торговли
input  ENUM_MM_TYPE              Inp_TRD_MM_MOD                     = ENUM_MM_TYPE_FIXED_LOT;    // TRD_MM_MOD: Money Management Type
input  double                    Inp_TRD_MM_VAL                     = 1.0;                       // TRD_MM_VAL: Money Management Value
input  double                    Inp_TRD_TP_RR                      = 1.0;                       // TRD_TP_RR: TP RR
input  bool                      Inp_TRD_REV_ENB                    = true;                      // TRD_REV_ENB: Close pos on opposite signal

input  group                    "4. GRAPHIC (GUI)"
input  bool                      Inp_GUI_ENB                        = true;                      // GUI_ENB: Draw pos

input  group                    "9. MISC (MS)"
sinput ulong                     Inp__MS_MGC                        = 20250705;                  // MS_MGC: Expert Adviser ID - Magic
sinput string                    Inp__MS_EGP                        = "NP";                      // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                  Inp__MS_LOG_LL                     = INFO;                      // MS_LOG_LL: Log Level
sinput string                    Inp__MS_LOG_FI                     = "";                        // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                    Inp__MS_LOG_FO                     = "";                        // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
sinput bool                      Inp__MS_COM_EN                     = true;                      // MS_COM_EN: Comment Enable (turn off for fast testing)
sinput uint                      Inp__MS_COM_IS                     = 30000;                     // MS_COM_IS: Comment Interval, ms
sinput bool                      Inp__MS_COM_CW                     = false;                     // MS_COM_CW: Comment Custom Window
sinput bool                      Inp__MS_HIN_EN                     = true;                      // MS_HIN_EN: On Chart Hints Enabled
sinput int                       Inp__MS_HIN_CH                     = 158;                       // MS_HIN_CH: On Chart Default Char
sinput color                     Inp__MS_HIN_CL                     = clrCrimson;                // MS_HIN_CL: On Chart Default Color
sinput ENUM_OTR_MODE             Inp__MS_OTR_MOD                    = OTR_MODE_PURE_R2_SPEARMAN; // MS_OTR_MOD: On Tester Result calculation Mode
sinput ENUM_TIMEFRAMES           Inp__MS_OTR_TF                     = PERIOD_H1;                 // MS_OTR_TF: On Tester Result calculation Timeframe
sinput uint                      Inp__MS_TIM_MS                     = 60000;                     // MS_TIM_MS: Timer Interval, ms

// INPUTS FOR USER MANUAL:

// ##### 1. INDICATORS (I*)
// - [x] `I_UT_KEY`: UT Bot: Key Value (sensitivity)
// - [x] `I_UT_ATR`: UT Bot: ATR Period
// - [x] `I_STC_SCH_PER`: STC: Schaff period
// - [x] `I_STC_FEMA`: STC: Fast EMA period
// - [x] `I_STC_SEMA`: STC: Slow EMA period
// - [x] `I_STC_SMT_PER`: STC: Smoothing period
// - [x] `I_STC_PRC`: STC: Price

// ##### 2. FILTER (F)
// - [x] `F_STC_BUY_MIN`: BUY allowed Min STC value
// - [x] `F_STC_BUY_MAX`: BUY allowed Max STC value
// - [x] `F_STC_SELL_MIN`: SELL allowed Min STC value
// - [x] `F_STC_SELL_MAX`: SELL allowed Max STC value
// - [x] `F_STC_CLR_ENB`: Color Filter Enabled (BUY=GREEN; SELL=RED)

// ##### 3. TRADE (TRD)
// - [x] `TRD_DIR_MOD`: Режим торговли
// - [x] `TRD_MM_MOD`: Money Management Type
// - [x] `TRD_MM_VAL`: Money Management Value
// - [x] `TRD_TP_RR`: TP RR
// - [x] `TRD_REV_ENB`: Close pos on opposite signal

// ##### 4. GRAPHIC (GUI)
// - [x] `GUI_ENB`: Draw pos

// ##### 9. MISC (MS)
// - [x] `MS_MGC`: Expert Adviser ID - Magic
// - [x] `MS_EGP`: Expert Adviser Global Prefix
// - [x] `MS_LOG_LL`: Log Level
// - [x] `MS_LOG_FI`: Log Filter IN String (use `;` as sep)
// - [x] `MS_LOG_FO`: Log Filter OUT String (use `;` as sep)
// - [x] `MS_COM_EN`: Comment Enable (turn off for fast testing)
// - [x] `MS_COM_IS`: Comment Interval, ms
// - [x] `MS_COM_CW`: Comment Custom Window
// - [x] `MS_HIN_EN`: On Chart Hints Enabled
// - [x] `MS_HIN_CH`: On Chart Default Char
// - [x] `MS_HIN_CL`: On Chart Default Color
// - [x] `MS_OTR_MOD`: On Tester Result calculation Mode
// - [x] `MS_OTR_TF`: On Tester Result calculation Timeframe
// - [x] `MS_TIM_MS`: Timer Interval, ms


//+------------------------------------------------------------------+
//| Fill Input struc with user inputs vars
//+------------------------------------------------------------------+    
void FillInputs(CNPBotInputs& _inputs) {
  _inputs.I_UT_KEY                  = Inp_I_UT_KEY;                                              // I_UT_KEY: UT Bot: Key Value (sensitivity)
  _inputs.I_UT_ATR                  = Inp_I_UT_ATR;                                              // I_UT_ATR: UT Bot: ATR Period
  _inputs.I_STC_SCH_PER             = Inp_I_STC_SCH_PER;                                         // I_STC_SCH_PER: STC: Schaff period
  _inputs.I_STC_FEMA                = Inp_I_STC_FEMA;                                            // I_STC_FEMA: STC: Fast EMA period
  _inputs.I_STC_SEMA                = Inp_I_STC_SEMA;                                            // I_STC_SEMA: STC: Slow EMA period
  _inputs.I_STC_SMT_PER             = Inp_I_STC_SMT_PER;                                         // I_STC_SMT_PER: STC: Smoothing period
  _inputs.I_STC_PRC                 = Inp_I_STC_PRC;                                             // I_STC_PRC: STC: Price
  _inputs.F_STC_BUY_MIN             = Inp_F_STC_BUY_MIN;                                         // F_STC_BUY_MIN: BUY allowed Min STC value
  _inputs.F_STC_BUY_MAX             = Inp_F_STC_BUY_MAX;                                         // F_STC_BUY_MAX: BUY allowed Max STC value
  _inputs.F_STC_SELL_MIN            = Inp_F_STC_SELL_MIN;                                        // F_STC_SELL_MIN: SELL allowed Min STC value
  _inputs.F_STC_SELL_MAX            = Inp_F_STC_SELL_MAX;                                        // F_STC_SELL_MAX: SELL allowed Max STC value
  _inputs.F_STC_CLR_ENB             = Inp_F_STC_CLR_ENB;                                         // F_STC_CLR_ENB: Color Filter Enabled (BUY=GREEN; SELL=RED)
  _inputs.TRD_DIR_MOD               = Inp_TRD_DIR_MOD;                                           // TRD_DIR_MOD: Режим торговли
  _inputs.TRD_MM_MOD                = Inp_TRD_MM_MOD;                                            // TRD_MM_MOD: Money Management Type
  _inputs.TRD_MM_VAL                = Inp_TRD_MM_VAL;                                            // TRD_MM_VAL: Money Management Value
  _inputs.TRD_TP_RR                 = Inp_TRD_TP_RR;                                             // TRD_TP_RR: TP RR
  _inputs.TRD_REV_ENB               = Inp_TRD_REV_ENB;                                           // TRD_REV_ENB: Close pos on opposite signal
  _inputs.GUI_ENB                   = Inp_GUI_ENB;                                               // GUI_ENB: Draw pos
  _inputs._MS_MGC                   = Inp__MS_MGC;                                               // MS_MGC: Expert Adviser ID - Magic
  _inputs._MS_EGP                   = Inp__MS_EGP;                                               // MS_EGP: Expert Adviser Global Prefix
  _inputs._MS_LOG_LL                = Inp__MS_LOG_LL;                                            // MS_LOG_LL: Log Level
  _inputs._MS_LOG_FI                = Inp__MS_LOG_FI;                                            // MS_LOG_FI: Log Filter IN String (use `;` as sep)
  _inputs._MS_LOG_FO                = Inp__MS_LOG_FO;                                            // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
  _inputs._MS_COM_EN                = Inp__MS_COM_EN;                                            // MS_COM_EN: Comment Enable (turn off for fast testing)
  _inputs._MS_COM_IS                = Inp__MS_COM_IS;                                            // MS_COM_IS: Comment Interval, ms
  _inputs._MS_COM_CW                = Inp__MS_COM_CW;                                            // MS_COM_CW: Comment Custom Window
  _inputs._MS_HIN_EN                = Inp__MS_HIN_EN;                                            // MS_HIN_EN: On Chart Hints Enabled
  _inputs._MS_HIN_CH                = Inp__MS_HIN_CH;                                            // MS_HIN_CH: On Chart Default Char
  _inputs._MS_HIN_CL                = Inp__MS_HIN_CL;                                            // MS_HIN_CL: On Chart Default Color
  _inputs._MS_OTR_MOD               = Inp__MS_OTR_MOD;                                           // MS_OTR_MOD: On Tester Result calculation Mode
  _inputs._MS_OTR_TF                = Inp__MS_OTR_TF;                                            // MS_OTR_TF: On Tester Result calculation Timeframe
  _inputs._MS_TIM_MS                = Inp__MS_TIM_MS;                                            // MS_TIM_MS: Timer Interval, ms
}


//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CNPBotInputs::CNPBotInputs():
       I_UT_KEY(1.0),
       I_UT_ATR(10),
       I_STC_SCH_PER(32),
       I_STC_FEMA(23),
       I_STC_SEMA(50),
       I_STC_SMT_PER(3),
       I_STC_PRC(pr_close),
       F_STC_BUY_MAX(25),
       F_STC_SELL_MIN(75),
       F_STC_SELL_MAX(100),
       F_STC_CLR_ENB(true),
       TRD_DIR_MOD(TRD_DIR_MODE_BOTH),
       TRD_MM_MOD(ENUM_MM_TYPE_FIXED_LOT),
       TRD_MM_VAL(1.0),
       TRD_TP_RR(1.0),
       TRD_REV_ENB(true),
       GUI_ENB(true),
       _MS_MGC(20250705),
       _MS_EGP("NP"),
       _MS_LOG_LL(INFO),
       _MS_LOG_FI(""),
       _MS_LOG_FO(""),
       _MS_COM_EN(true),
       _MS_COM_IS(30000),
       _MS_COM_CW(false),
       _MS_HIN_EN(true),
       _MS_HIN_CH(158),
       _MS_HIN_CL(clrCrimson),
       _MS_OTR_MOD(OTR_MODE_PURE_R2_SPEARMAN),
       _MS_OTR_TF(PERIOD_H1),
       _MS_TIM_MS(60000),
       __MS_LIC_DUR_SEC(0*24*60*60){

};


//+------------------------------------------------------------------+
//| Check struc before Init
//+------------------------------------------------------------------+
bool CNPBotInputs::CheckBeforeInit() {
  LastErrorMessage = "";
  if(!(I_UT_KEY>0)) LastErrorMessage = "'I_UT_KEY' must satisfy condition: I_UT_KEY>0";
  if(!(I_UT_ATR>0)) LastErrorMessage = "'I_UT_ATR' must satisfy condition: I_UT_ATR>0";
  if(!(I_STC_SCH_PER>0)) LastErrorMessage = "'I_STC_SCH_PER' must satisfy condition: I_STC_SCH_PER>0";
  if(!(I_STC_FEMA>0)) LastErrorMessage = "'I_STC_FEMA' must satisfy condition: I_STC_FEMA>0";
  if(!(I_STC_SEMA>0)) LastErrorMessage = "'I_STC_SEMA' must satisfy condition: I_STC_SEMA>0";
  if(!(I_STC_SMT_PER>0)) LastErrorMessage = "'I_STC_SMT_PER' must satisfy condition: I_STC_SMT_PER>0";
  if(!(F_STC_BUY_MIN>=0)) LastErrorMessage = "'F_STC_BUY_MIN' must satisfy condition: F_STC_BUY_MIN>=0";
  if(!(F_STC_BUY_MAX>=0)) LastErrorMessage = "'F_STC_BUY_MAX' must satisfy condition: F_STC_BUY_MAX>=0";
  if(!(F_STC_SELL_MIN>=0)) LastErrorMessage = "'F_STC_SELL_MIN' must satisfy condition: F_STC_SELL_MIN>=0";
  if(!(F_STC_SELL_MAX>=0)) LastErrorMessage = "'F_STC_SELL_MAX' must satisfy condition: F_STC_SELL_MAX>=0";
  if(!(TRD_MM_VAL>0.0)) LastErrorMessage = "'TRD_MM_VAL' must satisfy condition: TRD_MM_VAL>0.0";
  if(!(TRD_TP_RR>=0)) LastErrorMessage = "'TRD_TP_RR' must satisfy condition: TRD_TP_RR>=0";

  return LastErrorMessage == "";
}
// GENERATED CODE == END == DO NOT REMOVE THIS COMMENT



