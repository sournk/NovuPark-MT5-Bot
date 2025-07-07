//+------------------------------------------------------------------+
//|                                                      CiSTC.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Indicators/Custom.mqh>
#include "../../MqlParams/MqlParams.mqh"


#define STC_INDICATOR_NAME "Schaff Trend Cycle"
#define STC_INDICATOR_BUFFER_COUNT 2
#define STC_INITIAL_BUFFER_SIZE 2048

enum enPrices
  {
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken Ashi close
   pr_haopen ,    // Heiken Ashi open
   pr_hahigh,     // Heiken Ashi high
   pr_halow,      // Heiken Ashi low
   pr_hamedian,   // Heiken Ashi median
   pr_hatypical,  // Heiken Ashi typical
   pr_haweighted, // Heiken Ashi weighted
   pr_haaverage,  // Heiken Ashi average
   pr_hamedianb,  // Heiken Ashi median body
   pr_hatbiased,  // Heiken Ashi trend biased price
   pr_hatbiased2  // Heiken Ashi trend biased (extreme) price
  };

class CiSTC : public CiCustom {
protected:
   virtual bool      Initialize(const string symbol, 
                                const ENUM_TIMEFRAMES period, 
                                const int num_params, 
                                const MqlParam &params[]
                     ) override;  
public:
   virtual bool      Create(string _symbol, 
                            ENUM_TIMEFRAMES _period,
                             
                            int             _SchaffPeriod,       // Schaff period
                            int             _FastEma,       // Fast EMA period
                            int             _SlowEma,       // Slow EMA period
                            double          _SmoothPeriod,        // Smoothing period
                            enPrices        _Price // Price
                            ); 
                            
  virtual double     Main(int index)  { return this.GetData(0, index); }
  virtual double     Color(int index) { return this.GetData(1, index); }
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiSTC::Create(string _symbol, 
                         ENUM_TIMEFRAMES _period, 

                         int             _SchaffPeriod,       // Schaff period
                         int             _FastEma,       // Fast EMA period
                         int             _SlowEma,       // Slow EMA period
                         double          _SmoothPeriod,        // Smoothing period
                         enPrices        _Price // Price
                         ) {  
   // #1 Setup the MQL params array for the custom indicator.
   CMqlParams params;
   params.Set(STC_INDICATOR_NAME, TYPE_STRING)
         .Set(_SchaffPeriod, TYPE_INT)
         .Set(_FastEma, TYPE_INT)
         .Set(_SlowEma, TYPE_INT)
         .Set(_SmoothPeriod, TYPE_DOUBLE)
         .Set(_Price, TYPE_INT);
         
   // #2 Call the parent Create method with the params
   if (!CiCustom::Create(_symbol, _period, IND_CUSTOM, params.Total(), params.params))
      return false;
   // #3 Resize the buffer to the desired initial size
   if (!this.BufferResize(STC_INITIAL_BUFFER_SIZE))
      return false;
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiSTC::Initialize(const string symbol, 
                             const ENUM_TIMEFRAMES period, 
                             const int num_params, 
                             const MqlParam &params[]) {
   // #1 Specify if this indicator redraws
   this.Redrawer(true);
   // #2 Specify the number of indicator buffers to be used. 
   if (!this.NumBuffers(STC_INDICATOR_BUFFER_COUNT))
      return false; 
   // #3 Call super.Initialize 
   if (!CiCustom::Initialize(symbol, period, num_params, params))
      return false;
   return true;
}