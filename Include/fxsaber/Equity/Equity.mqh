// Расчет эквити без ММ (вариант для односимвольных ТС)
class EQUITY
{
protected:
  int PrevHistoryTotal;
  double Balance;
  double PrevEquity;
  
  // Добавление элемента в конец произвольного массива
  template <typename T>
  static void AddArrayElement( T &Array[], const T Value, const int Reserve = 0 )
  {
    const int Size = ::ArraySize(Array);
  
    ::ArrayResize(Array, Size + 1, Reserve);
  
    Array[Size] = Value;
  }

  static double GetOrderProfit( void )
  {
    return((OrderProfit()/* + OrderCommission() + OrderSwap()*/) / OrderLots()); // комиссия и своп иногда полезно игнорировать
  }
  
  static double GetProfit( void )
  {
    double Res = 0;
    
    for (int i = OrdersTotal() - 1; i >= 0; i--)
      if (OrderSelect(i, SELECT_BY_POS) && (OrderType() <= OP_SELL))
        Res += EQUITY::GetOrderProfit();
    
    return(Res);
  }
  
  double GetBalance( void )
  {
    const int HistoryTotal = OrdersHistoryTotal();
    
    if (HistoryTotal != this.PrevHistoryTotal)
    {
      for (int i = HistoryTotal - 1; i >= PrevHistoryTotal; i--)
        if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && (OrderType() <= OP_SELL) && OrderLots()) // OrderLots - CloseBy
          this.Balance += EQUITY::GetOrderProfit();
      
      this.PrevHistoryTotal = HistoryTotal;
    }
    
    return(this.Balance);
  }
  
public:
  double Data[];

  EQUITY( void ) : PrevHistoryTotal(0), Balance(0), PrevEquity(0)
  {
  }
  
  virtual void OnTimer( void )
  {
    const double NewEquity = this.GetBalance() + EQUITY::GetProfit();
    
    if (NewEquity != this.PrevEquity)    
    {
      EQUITY::AddArrayElement(this.Data, NewEquity, 1e4);
      
      this.PrevEquity = NewEquity;
    }
  }
};