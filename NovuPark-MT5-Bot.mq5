//+------------------------------------------------------------------+
//|                                                   NP-MT5-Bot.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property strict
#property script_show_inputs

#property version "1.02"
#property copyright "Denis Kislitsyn"
#property link "https://kislitsyn.me/personal/algo"
#property icon "/Images/favicon_64.ico"

#property description "NovuPark-MT5-Bot"
#property description "The bot trades on the original closed strategy based on a combination of technical indicators"
#property description "1.02: [*] Fixed error setting no TP "
#property description "1.01: [+] STC color filter 'F_STC_CLR_ENB' (GREEN for BUY & RED for SELL)"
#property description "      [*] Fixed reversal open error"

#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "CNPBot.mqh"

CNPBot                          bot;
CDKTrade                        trade;
CDKLogger                       logger;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){  
  CNPBotInputs inputs;
  FillInputs(inputs);
  
  logger.Init(inputs._MS_EGP, inputs._MS_LOG_LL);
  logger.FilterInFromStringWithSep(inputs._MS_LOG_FI, ";");
  logger.FilterOutFromStringWithSep(inputs._MS_LOG_FO, ";");
  
  trade.Init(Symbol(), inputs._MS_MGC, 0, GetPointer(logger));

  bot.CommentEnable                = inputs._MS_COM_EN;
  bot.CommentIntervalMS            = inputs._MS_COM_IS;
  
  bot.Init(Symbol(), Period(), inputs._MS_MGC, trade, inputs._MS_COM_CW, inputs, GetPointer(logger));
  bot.SetFont("Courier New");
  bot.SetHighlightSelection(true);

  if (!bot.Check()) 
    return(INIT_PARAMETERS_INCORRECT);
  
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)  {
  bot.OnDeinit(reason);
  //EventKillTimer();
}
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {
  bot.OnTick();
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()  {
  bot.OnTrade();
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
  bot.OnTradeTransaction(trans, request, result);
}

double OnTester() {
  return bot.OnTester();
}

void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam) {
  bot.OnChartEvent(id, lparam, dparam, sparam);                                    
}

