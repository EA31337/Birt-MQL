//+------------------------------------------------------------------+
//|                                                PositionAlert.mq5 |
//|                                                             birt |
//|                                             http://eareview.net/ |
//+------------------------------------------------------------------+
#property copyright "birt"
#property link      "http://eareview.net/"
#property version   "1.00"

//--- input parameters
input bool      AlertOnTpSlChange = true;

ulong symbolChecksum[];
ulong symbolTpSl[];
int symbolCount = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   symbolCount = SymbolsTotal(false);
   ArrayResize(symbolChecksum, symbolCount);
   ArrayInitialize(symbolChecksum, 0);
   ArrayResize(symbolTpSl, symbolCount);
   ArrayInitialize(symbolTpSl, 0);
   CheckPositions(false);
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade() {
   CheckPositions(true);
}

void CheckPositions(bool alert) {
   ulong newSymbolChecksum[];
   ulong newSymbolTpSl[];
   ArrayResize(newSymbolChecksum, symbolCount);
   ArrayInitialize(newSymbolChecksum, 0);
   ArrayResize(newSymbolTpSl, symbolCount);
   ArrayInitialize(newSymbolTpSl, 0);
   int totalPositions = PositionsTotal();
   uint positionStamp = 0;
   for(int i = 0; i < totalPositions; i++) {
      string symbol = PositionGetSymbol(i);
      if (PositionSelect(symbol)) {
         long type = PositionGetInteger(POSITION_TYPE);
         long id = PositionGetInteger(POSITION_IDENTIFIER);
         int symbolLotDigits = SymbolLotDigits(symbol);
         long volume = (long)(PositionGetDouble(POSITION_VOLUME) * MathPow(10, symbolLotDigits));
         double symbolPoint = SymbolInfoDouble(symbol, SYMBOL_POINT);
         long open = (long)(PositionGetDouble(POSITION_PRICE_OPEN) / symbolPoint);
         long sl = (long)(PositionGetDouble(POSITION_SL) / symbolPoint);
         long tp = (long)(PositionGetDouble(POSITION_TP) / symbolPoint);
         int symbolId = SymbolId(symbol);
         newSymbolChecksum[symbolId] = type ^ id ^ volume ^ open;
         newSymbolTpSl[symbolId] = sl ^ tp;
      }
   }
   for (int i = 0; i < symbolCount; i++) {
      bool newPosition = false;
      if (newSymbolChecksum[i] != symbolChecksum[i]) {
         if (symbolChecksum[i] == 0) {
            newPosition = true;
         }
         if (alert) {
            if (symbolChecksum[i] == 0) {
               Alert("New position on " + SymbolName(i, false));
            }
            else if (newSymbolChecksum[i] == 0) {
               Alert("Position on " + SymbolName(i, false) + " was closed.");
            }
            else {
               Alert("Position on " + SymbolName(i, false) + " has changed. Inspect the deal tab for more info.");
            }
         }
         symbolChecksum[i] = newSymbolChecksum[i];
      }
      if (AlertOnTpSlChange && symbolChecksum[i] != 0 && !newPosition && newSymbolTpSl[i] != symbolTpSl[i]) {
         if (alert) {
            Alert("Stop loss or take profit changed for the position on " + SymbolName(i, false));
         }
      }
      symbolTpSl[i] = newSymbolTpSl[i];
   }
}

int SymbolLotDigits(string symbol) {
   double lotIncrement = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double min = MathMin(lotIncrement, minLot);
   double compare = 1;
   int digits = 0;
   while (min < compare) {
      compare /= 10;
      digits++;
   }
   return digits;
}

int SymbolId(string symbol) {
   int result = -1;
   for (int i = 0; i < SymbolsTotal(false); i++) {
      if (SymbolName(i, false) == symbol) {
         result = i;
         break;
      }
   }
   return result;
}