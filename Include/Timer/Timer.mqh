//+------------------------------------------------------------------+
//|                                                        Timer.mqh |
//|                                    Copyright 2018, Nikolai Semko |
//|                         https://www.mql5.com/ru/users/nikolay7ko |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Nikolai Semko"
#property link      "https://www.mql5.com/ru/users/nikolay7ko"
#property link      "SemkoNV@bk.ru"
#property version   "1.05"

#ifndef  timer_define
#define timer_define 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTimer {
 protected:
   typedef void (*TFunc)();
   struct iTimer {
      TFunc f;
      uint t;
      uint n;
      uint lost;
      uint start;
   };
   uint N;
   iTimer mt[];
   bool loop;

 public:
   CTimer() {N=0; loop=false;};
   ~CTimer();
   void OnTimer();                              // эту функцию нужно поставить в штатный OnTimer
   void KillTimer(TFunc fun);                   // Удаляет все таймеры с функцией обработки fun
   void KillTimer(int milliseconds, TFunc fun); // Удаляет таймер с функцией обработки fun и периодичностью milliseconds
   void NewTimer(int milliseconds, TFunc fun);  // Создает таймер с периодичностью milliseconds и фукцией обработки fun
   void NewPeriod(int old_milliseconds, TFunc fun, int new_milliseconds); // Меняет периодичность данного таймера
   uint GetN() {return N;};                     // Получаем текущее количество работающих таймеров
   int GetLost(int milliseconds, TFunc fun);    // Получаем количество пропущенных событий таймера для контроля стабильности работы.
                                                // Если ноль, то пропусков нет. Если -1, то не найден такой таймер.
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTimer::~CTimer() {
   if (N>0) {
      ArrayFree(mt);
      EventKillTimer();
   }
}
//+------------------------------------------------------------------+
void CTimer::OnTimer() {
   if (loop) return;
   loop=true;
   uint t0=GetTickCount();
   uint n=N;
   for (uint i=0; i<N; i++) {
      if (mt[i].start>t0) continue;
      uint _n=(t0-mt[i].start)/mt[i].t;
      if (_n>=mt[i].n) {
         mt[i].lost+=_n-mt[i].n;
         mt[i].n=_n+1;
         mt[i].f();
         if (n>N) {
            i--;
            n=N;
         }
      }
   }
   loop=false;
}
//+------------------------------------------------------------------+
void CTimer::NewTimer(int milliseconds, TFunc fun) {
   if (N==0) EventSetMillisecondTimer(15);
   else for (uint i=0; i<N; i++) {   // проверяем нет ли уже таймера с такими параметрами, чтобы избежать дубликатов.
         if (mt[i].f== fun && mt[i].t==milliseconds) return;
      }
   ArrayResize(mt,N+1);
   mt[N].t=milliseconds;
   mt[N].f=fun;
   mt[N].start=GetTickCount();
   mt[N].n=0;
   mt[N].lost=0;
   N++;
}
//+------------------------------------------------------------------+
void CTimer::NewPeriod(int old_milliseconds, TFunc fun, int new_milliseconds) {
   bool dubl=false;
   for (uint i=0; i<N; i++) 
      if (mt[i].f== fun && mt[i].t==new_milliseconds) dubl=true;// проверяем нет ли уже таймера с такими параметрами, чтобы избежать дубликатов.
   for (uint i=0; i<N; i++) 
      if (mt[i].f== fun && mt[i].t==old_milliseconds) {
         if (dubl) {
           KillTimer(old_milliseconds, fun);
           break;
         }
         mt[i].t= new_milliseconds;
         mt[i].start=GetTickCount()+new_milliseconds;
         mt[i].n=0;
         break;
      }
}
//+------------------------------------------------------------------+
void CTimer::KillTimer(TFunc fun) {
   for (uint i=0; i<N; i++) {
      if (mt[i].f== fun) {
         if (ArrayRemove(mt,i,1)) N--;
      }
      if (N==0) EventKillTimer();
   }
}
//+------------------------------------------------------------------+
void CTimer::KillTimer(int milliseconds, TFunc fun) {
   for (uint i=0; i<N; i++) {
      if (mt[i].f== fun && mt[i].t==milliseconds) {
         if (ArrayRemove(mt,i,1)) N--;
      }
      if (N==0) EventKillTimer();
   }
}
//+------------------------------------------------------------------+
int CTimer::GetLost(int milliseconds, TFunc fun) {
   for (uint i=0; i<N; i++) {
      if (mt[i].f== fun && mt[i].t==milliseconds) return int(mt[i].lost);
   }
   return -1;
}
//+------------------------------------------------------------------+


#endif
