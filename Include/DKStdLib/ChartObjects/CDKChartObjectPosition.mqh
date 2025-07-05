//+------------------------------------------------------------------+
//|                                       CDKChartObjectPosition.mqh |
//|                                                  Denis Kislitsyn |
//|                                               http:/kislitsyn.me |
//+------------------------------------------------------------------+

#include <ChartObjects\ChartObjectsShapes.mqh>

#include "..\TradingManager\CDKPositionInfo.mqh"

class CDKChartObjectPosition  {
private:
  ulong                        Ticket;
public:
  CChartObjectRectangle        RecTP;
  CChartObjectRectangle        RecSL;
  
  bool CDKChartObjectPosition::Create(ulong ticket, 
                                      long chart_id, const string _name_prefix,
                                      const datetime time1, const datetime time2,
                                      const double price_open, 
                                      const double sl,
                                      const double tp) {
    CDKPositionInfo pos;
    if(!pos.SelectByTicket(ticket)) {
      Ticket = 0;
      return false;
    }
    
    Ticket = ticket;
    bool rec_sl = RecSL.Create(chart_id, StringFormat("%s_POS_%I64u_SL", _name_prefix, Ticket), 0,
                               time1, price_open, 
                               time2, sl);
                 
    bool rec_tp = RecTP.Create(chart_id, StringFormat("%s_POS_%I64u_TP", _name_prefix, Ticket), 0,
                               time1, price_open, 
                               time2, tp);
                               
    return rec_sl && rec_tp;
  }   
  
  bool CDKChartObjectPosition::Create(ulong ticket, 
                                      long chart_id, const string _name_prefix) {
    CDKPositionInfo pos;
    if(!pos.SelectByTicket(ticket)) {
      Ticket = 0;
      return false;
    }
    
    datetime dt_from = pos.Time();
    datetime dt_to = (dt_from != TimeCurrent()) ? TimeCurrent() : dt_from + PeriodSeconds(Period());
    Ticket = ticket;
    bool rec_sl = RecSL.Create(chart_id, StringFormat("%s_POS_%I64u_SL", _name_prefix, Ticket), 0,
                               dt_from, pos.PriceOpen(), 
                               dt_to, pos.StopLoss());
    RecSL.Color(clrLightPink);
    RecSL.Fill(true);
    RecSL.Background(true);
                 
    bool rec_tp = RecTP.Create(chart_id, StringFormat("%s_POS_%I64u_TP", _name_prefix, Ticket), 0,
                               dt_from, pos.PriceOpen(), 
                               dt_to, pos.TakeProfit());
    RecTP.Color(clrLightGreen);
    RecTP.Fill(true);
    RecTP.Background(true);    
                               
    return rec_sl && rec_tp;
  }  
  
  void CDKChartObjectPosition::Detach() {
    RecSL.Detach();
    RecTP.Detach();
  }
};