//+------------------------------------------------------------------+
//|                                                        Timer.mqh |
//|                                    Copyright 2018, Nikolai Semko |
//|                         https://www.mql5.com/ru/users/nikolay7ko |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link "https://kislitsyn.me/personal/algo"
#property version   "1.00"

#include  "Timer.mqh";

class CDKTimer : public CTimer {
 public:
   void NewTimerSetMaxPossibleEventTimer(int milliseconds, TFunc fun);
   void KillAllTimers();                        // Удаляет все таймеры
};


//+------------------------------------------------------------------+
void CDKTimer::NewTimerSetMaxPossibleEventTimer(int milliseconds, TFunc fun) {
   uint min_timer = milliseconds;
   if (N==0) EventSetMillisecondTimer(milliseconds);
   else 
    for (uint i=0; i<N; i++) {   // проверяем нет ли уже таймера с такими параметрами, чтобы избежать дубликатов.
        if (mt[i].t < min_timer) min_timer = mt[i].t;
        if (mt[i].f== fun && mt[i].t==milliseconds) return;
    }
    
   // New timer has minimal delay from existing in a list ==> Update system timer
   if((uint)milliseconds < min_timer) {
        EventKillTimer();
        EventSetMillisecondTimer(milliseconds);
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
void CDKTimer::KillAllTimers(){
   for (uint i=0; i<N; i++) {
     if (ArrayRemove(mt,i,1)) N--;
     if (N==0) EventKillTimer();
   }
}

CDKTimer timers; // создаём единственный объект

//+------------------------------------------------------------------+
void OnTimer() {
   timers.OnTimer();
}
//+------------------------------------------------------------------+
