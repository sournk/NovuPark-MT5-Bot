//+------------------------------------------------------------------+
//|                                                   UT Bot Alerts |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3

//--- Plot properties
#property indicator_label1  "UTBot Main"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "UTBot Buy"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  CHART_COLOR_CANDLE_BULL
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "UTBot Sell"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  CHART_COLOR_CANDLE_BEAR
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- Input parameters
input double   KeyValue    = 1.0;      // Key Value (sensitivity)
input int      ATRPeriod   = 10;       // ATR Period
      bool     ShowAlerts  = false;    // Show Buy/Sell alerts
      bool     ColorBars   = true;     // Color bars

//--- Indicator buffers
double ATRTrailingStopBuffer[];
double BuySignalBuffer[];
double SellSignalBuffer[];
double PositionBuffer[];

//--- Global variables
int atr_handle;
double atr_values[];
bool signals_checked[];  // Массив для отслеживания обработанных баров

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- Set buffers
    SetIndexBuffer(0, ATRTrailingStopBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, BuySignalBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, SellSignalBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, PositionBuffer, INDICATOR_CALCULATIONS);
    
    //--- Set buffer properties
    PlotIndexSetString(0, PLOT_LABEL, "ATR Trailing Stop");
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrBlue);
    PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
    
    PlotIndexSetString(1, PLOT_LABEL, "Buy Signal");
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrLime);
    PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
    PlotIndexSetInteger(1, PLOT_ARROW, 233); // Стрелка вверх
    
    PlotIndexSetString(2, PLOT_LABEL, "Sell Signal");
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_ARROW);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, clrRed);
    PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);
    PlotIndexSetInteger(2, PLOT_ARROW, 234); // Стрелка вниз
    
    //--- Initialize ATR handle
    atr_handle = iATR(_Symbol, _Period, ATRPeriod);
    if(atr_handle == INVALID_HANDLE)
    {
        Print("Error creating ATR indicator handle");
        return INIT_FAILED;
    }
    
    //--- Set indicator short name
    IndicatorSetString(INDICATOR_SHORTNAME, "UT Bot Alerts(" + 
                      DoubleToString(KeyValue, 1) + "," + 
                      IntegerToString(ATRPeriod) + ")");
    
    //--- Set accuracy
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    //--- Release indicator handle
    if(atr_handle != INVALID_HANDLE)
        IndicatorRelease(atr_handle);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    //--- Check for minimum bars
    if(rates_total < ATRPeriod + 1)
        return 0;
    
    //--- Get ATR values
    if(CopyBuffer(atr_handle, 0, 0, rates_total, atr_values) <= 0)
    {
        Print("Error copying ATR buffer");
        return 0;
    }
    
    //--- Determine starting position for calculation
    int start = MathMax(prev_calculated - 1, ATRPeriod);
    if(start < 1) start = 1;
    
    //--- Resize signals array if needed
    if(ArraySize(signals_checked) < rates_total)
    {
        ArrayResize(signals_checked, rates_total);
        for(int j = ArraySize(signals_checked); j < rates_total; j++)
            signals_checked[j] = false;
    }
    
    //--- Main calculation loop
    for(int i = start; i < rates_total; i++)
    {
        if(i >= ArraySize(atr_values)) break;
        
        // Инициализация буферов стрелок
        BuySignalBuffer[i] = EMPTY_VALUE;
        SellSignalBuffer[i] = EMPTY_VALUE;
        
        double src = close[i];
        double nLoss = KeyValue * atr_values[i];
        double prev_atr_stop = (i > 0) ? ATRTrailingStopBuffer[i-1] : 0.0;
        double prev_src = (i > 0) ? close[i-1] : 0.0;
        
        //--- Calculate ATR Trailing Stop
        double atr_trailing_stop;
        
        if(src > prev_atr_stop && prev_src > prev_atr_stop)
        {
            atr_trailing_stop = MathMax(prev_atr_stop, src - nLoss);
        }
        else if(src < prev_atr_stop && prev_src < prev_atr_stop)
        {
            atr_trailing_stop = MathMin(prev_atr_stop, src + nLoss);
        }
        else if(src > prev_atr_stop)
        {
            atr_trailing_stop = src - nLoss;
        }
        else
        {
            atr_trailing_stop = src + nLoss;
        }
        
        ATRTrailingStopBuffer[i] = atr_trailing_stop;
        
        //--- Calculate position
        int position = 0;
        if(i > 0)
        {
            double prev_pos = PositionBuffer[i-1];
            
            if(prev_src < prev_atr_stop && src > prev_atr_stop)
                position = 1;  // Long
            else if(prev_src > prev_atr_stop && src < prev_atr_stop)
                position = -1; // Short
            else
                position = (int)prev_pos;
        }
        
        PositionBuffer[i] = position;
        
        //--- Check for signals on completed bars only
        if(i < rates_total - 1) // Проверяем только завершенные бары
        {
            CheckSignals(i, src, atr_trailing_stop, position, time[i], high[i], low[i]);
        }
        
        //--- Color bars
        if(ColorBars && i == rates_total - 1)
        {
            if(src > atr_trailing_stop)
                ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrGreen);
            else if(src < atr_trailing_stop)
                ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrRed);
        }
    }
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Check for buy/sell signals on completed bars                    |
//+------------------------------------------------------------------+
void CheckSignals(int index, double src, double atr_stop, int position, datetime bar_time, double bar_high, double bar_low)
{
    if(index < 1) return;
    
    // Проверяем, был ли уже обработан этот бар
    if(index < ArraySize(signals_checked) && signals_checked[index]) 
        return;
    
    // Получаем текущую и предыдущую позицию
    int current_pos = (int)PositionBuffer[index];
    int prev_pos = (int)PositionBuffer[index-1];
    
    //--- Определяем изменение позиции для генерации сигнала
    bool buy_signal = (prev_pos <= 0 && current_pos == 1);   // Переход в лонг
    bool sell_signal = (prev_pos >= 0 && current_pos == -1); // Переход в шорт
    
    //--- Устанавливаем буферные сигналы
    if(buy_signal)
    {
        BuySignalBuffer[index] = bar_low;  // Стрелка на минимуме бара
        
        if(ShowAlerts)
            Alert("UT Bot: BUY signal on ", _Symbol, " ", EnumToString(_Period), " at ", TimeToString(bar_time));
    }
    
    if(sell_signal)
    {
        SellSignalBuffer[index] = bar_high; // Стрелка на максимуме бара
        
        if(ShowAlerts)
            Alert("UT Bot: SELL signal on ", _Symbol, " ", EnumToString(_Period), " at ", TimeToString(bar_time));
    }
    
    // Отмечаем бар как обработанный
    if(index < ArraySize(signals_checked))
        signals_checked[index] = true;
}