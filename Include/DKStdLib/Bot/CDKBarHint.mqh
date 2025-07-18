//+------------------------------------------------------------------+
//|                                                   CDKBarHint.mqh |
//|                                                  Denis Kislitsyn |
//|                                https://kislitsyn.me/peronal/algo |
//+------------------------------------------------------------------+

#include <ChartObjects\ChartObjectsArrows.mqh> 

enum ENUM_BAR_HINT_ANCHOR {
  BAR_FIXED_PRICE,
  BAR_HIGH,
  BAR_LOW,
};

class CDKBarHint : public CObject {
 protected:
  bool                            BarFinal;
  string                          ObjectName;
  double                          PriceShiftTotal;

 public:
  string                          ObjectPrefix;

  string                          Message;
  string                          Hint;

  ENUM_BAR_HINT_ANCHOR            Anchor; // OHLC or other types for fixed price
  double                          PriceBase;
  double                          PriceShiftBase;
  double                          PriceShiftNext;

  datetime                        Time;

  char                            Char;
  color                           Color;

  void                            CDKBarHint::CDKBarHint():
                                    BarFinal(false),
                                    ObjectPrefix(""),
                                    ObjectName(""),
                                    Message(""),
                                    Hint(""),
                                    Anchor(BAR_FIXED_PRICE),
                                    PriceBase(0.0),
                                    PriceShiftTotal(0.0),                                    
                                    PriceShiftBase(0.0),
                                    PriceShiftNext(0.0),
                                    Time(0),
                                    Char(char(158)),
                                    Color(clrLightBlue) {};

  void                            CDKBarHint::Draw();
  
  bool                            CDKBarHint::IsBarFinal() { return BarFinal; };
};



//+------------------------------------------------------------------+
//| Draw object
//+------------------------------------------------------------------+
void CDKBarHint::Draw() {
  // New object?
  if(ObjectName == "") {
    ObjectName = StringFormat("%s_HINT_%s", ObjectPrefix, TimeToString(Time));
    int i=0;
    while(ObjectFind(0, ObjectName) >=0 ) {
      i++;
      ObjectName = StringFormat("%s_HINT_%s_%d", ObjectPrefix, TimeToString(Time), i);
    }
    PriceShiftTotal = PriceShiftBase + i*PriceShiftNext;
    PriceShiftTotal = ((Anchor == BAR_HIGH) ? +1 : -1) * PriceShiftTotal;
    BarFinal = false;
  }

  if(IsBarFinal()) return;

  // Update Price
  int bar_idx = iBarShift(Symbol(), Period(), Time);
  BarFinal = bar_idx > 0;
  if(Anchor == BAR_HIGH) PriceBase = iHigh(Symbol(), Period(), bar_idx); 
  if(Anchor == BAR_LOW)  PriceBase = iLow(Symbol(), Period(), bar_idx);
  
  ENUM_ARROW_ANCHOR anchor = (Anchor == BAR_HIGH) ? ANCHOR_BOTTOM : ANCHOR_TOP;

  // Draw
  CChartObjectArrow hint;
  double draw_price = PriceBase+PriceShiftTotal;
  hint.Create(0, ObjectName, 0, Time, draw_price, Char);
  hint.Description(Message);
  hint.Tooltip(Hint);
  hint.Color(Color);
  hint.Anchor(anchor);
  hint.Detach();
  
  //CChartObjectText label;
  //double draw_price = PriceBase+PriceShiftTotal;
  //label.Create(0, ObjectName, 0, Time, draw_price);
  //label.Description("——");
  //label.Tooltip(Hint);
  //label.Anchor(ANCHOR_CENTER);
  //label.Color(clrRed);
  //label.Detach();      
}
