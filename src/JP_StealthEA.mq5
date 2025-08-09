//+------------------------------------------------------------------+
//| JP Stealth EA - Phase 1 (hidden SL/TP with local management)     |
//+------------------------------------------------------------------+
#property strict
#include <Trade/Trade.mqh>
CTrade trade;

//--- Inputs
input double LotSize        = 0.10;   // Trade lot size
input int    VirtualSL_pts  = 300;    // Stealth Stop Loss (points)
input int    VirtualTP_pts  = 600;    // Stealth Take Profit (points)
input int    SlippagePoints = 20;     // Max slippage in points

//--- Variables
ulong  g_ticket = 0;
double g_vSL = 0.0;
double g_vTP = 0.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // No open position? Check for entry signal
   if(!PositionSelect(_Symbol))
   {
      // Simple bullish M15 candle entry (just for testing)
      double c1 = iClose(_Symbol, PERIOD_M15, 1);
      double o1 = iOpen(_Symbol, PERIOD_M15, 1);

      if(c1 > o1)
      {
         trade.SetDeviationInPoints(SlippagePoints);
         if(trade.Buy(LotSize))
         {
            g_ticket = trade.ResultOrder();
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

            // Set virtual SL/TP levels
            g_vSL = NormalizeDouble(ask - VirtualSL_pts * _Point, _Digits);
            g_vTP = NormalizeDouble(ask + VirtualTP_pts * _Point, _Digits);
         }
      }
      return;
   }

   // Position open? Check for stealth SL/TP hit
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(bid <= g_vSL || bid >= g_vTP)
   {
      trade.PositionClose(_Symbol);
   }
}
