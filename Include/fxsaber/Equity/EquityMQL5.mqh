// Based on https://www.mql5.com/ru/forum/218096

#include <Trade\AccountInfo.mqh>
#include <Math\Alglib\alglib.mqh>
#include <Math\Alglib\matrix.mqh>
#include <Math\Alglib\dataanalysis.mqh>


// Расчет эквити без ММ (вариант для односимвольных ТС)
class EQUITYMQL5
{
protected:
  double PrevEquity;
  
  // Добавление элемента в конец произвольного массива
  template <typename T>
  static void AddArrayElement( T &Array[], const T Value, const int Reserve = 0 )
  {
    const int Size = ::ArraySize(Array);
  
    ::ArrayResize(Array, Size + 1, Reserve);
  
    Array[Size] = Value;
  }

  
public:
  double Data[];

  EQUITYMQL5( void ) : PrevEquity(0)
  {
  }
  
  virtual void OnTimer( void )
  {
    CAccountInfo acc;
    const double NewEquity = acc.Equity();
    
    if (NewEquity != this.PrevEquity)    
    {
      EQUITYMQL5::AddArrayElement(this.Data, NewEquity, 1e4);
      
      this.PrevEquity = NewEquity;
    }
  }
};


enum ENUM_CORR_TYPE
  {
   CORR_PEARSON,     // Pearson's correlation
   CORR_SPEARMAN     // Spearman's Rank-Order correlation
  };
  
//+------------------------------------------------------------------+
//| Возвращает оценку R^2, рассчитанную на основе equity стратегии   |
//| Значения equity передается в качестве массива equity             |
//+------------------------------------------------------------------+
double CustomR2Equity(double& equity[], ENUM_CORR_TYPE corr_type = CORR_PEARSON)
{
   int total = ArraySize(equity);
   if(total == 0)
      return 0.0;
   //-- Заполняем матрицу Y - значение equity, X - порядковый номер значения
   CMatrixDouble xy(total, 2);
   for(int i = 0; i < total; i++)
   {
      xy.Set(i, 0, (double)i);
      xy.Set(i, 1, equity[i]);
   }
   //-- Находим коэффициенты a и b линейной модели y = a*x + b;
   int retcode = 0;
   double a, b;
   CLinReg::LRLine(xy, total, retcode, a, b);
   //-- Генерируем значения линейной регрессии для каждого X;
   double estimate[];
   ArrayResize(estimate, total);
   for(int x = 0; x < total; x++)
      estimate[x] = x*a+b;
   //-- Находим коэффициент корреляции значений с их же линейной регрессией
   double corr = 0.0;
   if(corr_type == CORR_PEARSON)
      corr = CAlglib::PearsonCorr2(equity, estimate);
   else
      corr = CAlglib::SpearmanCorr2(equity, estimate);
   //-- Находим R^2 и его знак
   double r2 = MathPow(corr, 2.0);
   int sign = 1;
   if(equity[0] > equity[total-1])
      sign = -1;
   r2 *= sign;
   //-- Возвращаем нормализованную оценку R^2, с точностью до сотых
   return NormalizeDouble(r2,2);
}