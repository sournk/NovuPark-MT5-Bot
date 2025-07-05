//+------------------------------------------------------------------+
//|                                                      CiUTBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"


#define UTBot_INDICATOR_NAME "UTBot-MT5-Ind"
#define UTBot_INDICATOR_BUFFER_COUNT 3
#define UTBot_INITIAL_BUFFER_SIZE 2048

class CiUTBot : public CiCustom {
protected:
   virtual bool      Initialize(const string symbol, 
                                const ENUM_TIMEFRAMES period, 
                                const int num_params, 
                                const MqlParam &params[]
                     ) override;  
public:
   virtual bool      Create(string _symbol, 
                            ENUM_TIMEFRAMES _period, 
                            double _key_value,
                            uint _atr_period
                            ); 
                            
  virtual double     Main(int index) { return this.GetData(0, index); }
  virtual double     Buy(int index) { return this.GetData(1, index); }
  virtual double     Sell(int index) { return this.GetData(2, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiUTBot::Create(string _symbol, 
                         ENUM_TIMEFRAMES _period, 
                         double _key_value,
                         uint _atr_period) {  
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(UTBot_INDICATOR_NAME, TYPE_STRING)
         .Set(_key_value, TYPE_DOUBLE)
         .Set(_atr_period, TYPE_UINT);
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(UTBot_INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiUTBot::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(UTBot_INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}