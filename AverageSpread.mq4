//+------------------------------------------------------------------+
//|                                                AverageSpread.mq4 |
//|                                                             birt |
//|                                              http://eareview.net |
//+------------------------------------------------------------------+
#property copyright "birt"
#property link      "http://eareview.net"

extern int StartHour = 0;
extern int StartMinute = 0;
extern int EndHour = 0;
extern int EndMinute = 0;

int lastBarTime = 0;
int lastMinuteTime = 0;
double average = 0;
double minAverage = 0;
double maxAverage = 0;
double min = -1;
double max = 0;
int minutes = 0;
int ticks = 0;
double myPoint;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   myPoint = Point;
   if (Digits % 2 == 1) myPoint *= 10;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if (isTime()) {
      ticks++;
      double spread = (Ask - Bid) / myPoint;
      average += (spread - average) / ticks;
      if (spread < min || min < 0) {
         min = spread;
      }
      if (spread > max) {
         max = spread;
      }
      if (lastMinuteTime == 0) {
         lastMinuteTime = iTime(Symbol(), PERIOD_M1, 0);
      }
      if (lastMinuteTime != iTime(Symbol(), PERIOD_M1, 0)) {
         lastMinuteTime = iTime(Symbol(), PERIOD_M1, 0);
         minutes++;
         minAverage += (min - minAverage) / minutes;
         maxAverage += (max - maxAverage) / minutes;
         min = -1;
         max = 0;
      }
      if (lastBarTime != Time[0]) {
         lastBarTime = Time[0];
         Print("Average spread: " + DoubleToStr(average, 2) + "; ticks: " + ticks);
         Print("Smoothed min spread: " + DoubleToStr(minAverage, 2));
         Print("Smoothed max spread: " + DoubleToStr(maxAverage, 2));
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+

bool isTime() {
   bool result = false;
   if (StartHour == EndHour) {
      if (StartMinute >= EndMinute) { // 23+ hour interval
         if (Hour() != StartHour) {
            result = true;
         }
         else {
            if (Minute() >= StartMinute || Minute() < EndMinute) {
               result = true;
            }
         }
      }
   }
   else if (StartHour < EndHour) {
      if (Hour() == StartHour) {
         if (Minute() >= StartMinute) {
            result = true;
         }
      }
      else if (Hour() == EndHour) {
         if (Minute() < EndMinute) {
            result = true;
         }
      }
      else if (Hour() > StartHour && Hour() < EndHour) {
         result = true;
      }
   }
   else { // StartHour > EndHour
      if (Hour() == StartHour) {
         if (Minute() >= StartMinute) {
            result = true;
         }
      }
      else if (Hour() == EndHour) {
         if (Minute() < EndMinute) {
            result = true;
         }
      }
      else if (Hour() > StartHour || Hour() < EndHour) {
         result = true;
      }
   }
   return (result);
}