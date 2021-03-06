//+------------------------------------------------------------------+
//|                                                        Water.mq4 |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
#property strict
#include "MoneyManager.mqh"
#include "OrderManager.mqh"
#include "EnvChecker.mqh"
#include "TradeSystemController.mqh"
#include "utils\CommonUtil.mqh"
#include "utils\ShowUtil.mqh"
#include "Const.mqh"

bool IsTestOrderOpened = false; // Mark the test order is open
CTradeSystemController *controller = NULL;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("OnInit...start");
   controller = new CTradeSystemController;
   EventSetTimer(60);   // Trigger timer every 60 seconds
   Print("OnInit...end");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete(controller);
   EventKillTimer();
   Print("OnDeinit...");
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   CheckSafe();
   Print("OnTimer...");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// Check the runtime environment
   if(!CheckEnv())
      return;
   CMoneyManager::UpdateMaxEquity();
// Compute the original signal data firstly
   controller.ComputeSignalData();
   CheckClose();
   CheckOpen();
//CheckSafe();
// CheckStopLoss(); // TODO
// CheckTakeProfit(); // TODO
   ShowInfo();
  }

//+------------------------------------------------------------------+
//| Check when to open orders
//+------------------------------------------------------------------+
void CheckOpen()
  {
// When to BUY
   if(controller.ShouldOpenBuy())
     {
      if(OpenBuy())
         controller.SetSingalConsumed(true);
      return;
     }
// When to SELL
   if(controller.ShouldOpenSell())
     {
      if(OpenSell())
         controller.SetSingalConsumed(true);
     }
  }

//+------------------------------------------------------------------+
//| Check when to close orders
//| Current strategy：Multiple orders are also treated as a single order                                                                  |
//+------------------------------------------------------------------+
void CheckClose()
  {
   COrder totalOrder = GetAllOrdersAsOne();
   if((totalOrder.type==ORDER_BUY && controller.ShouldCloseBuy(totalOrder)) ||
      (totalOrder.type==ORDER_SELL && controller.ShouldCloseSell(totalOrder)))
      CloseOrder();
  }

//+------------------------------------------------------------------+
//| Check the safety of the position regularly,
//| to see if there is no need for manual intervention                                                              |
//+------------------------------------------------------------------+
void CheckSafe()
  {
   int state = controller.GetSafeState();
   string msg = "";
   switch(state)
     {
      case POSITION_STATE_WARN:
         msg = "Your "+_Symbol+" position is NOT SAFE! Pls check.";
         Print(msg);
         if(AllowMail)
            SendMail("Attention!",msg);
         break;
      case POSITION_STATE_DANG:
         msg = "Your "+_Symbol+" position is DANGEROUS! Pls check.";
         Print(msg);
         if(AllowMail)
            SendMail("Dangerous!",msg);
         if(AllowHedge)
            OpenHedgePosition(true);
     }
  }
//+------------------------------------------------------------------+
//| Show some key information on screen immediately                                                                |
//+------------------------------------------------------------------+
void ShowInfo()
  {
// show profit
   double totalProfit = CMoneyManager::GetSymbolProfit();
   string profitContent = "               Profit:"+DoubleToStr(totalProfit,2)+"("+DoubleToStr(100*totalProfit/AccountBalance(),2)+"%)";
   ShowDynamicText("Profit",profitContent,0,0);
// show drawdown
   double drawdown  = CMoneyManager::GetDrawdownPercent();
   string drawdownContent = "               Drawdown:"+DoubleToStr(drawdown,2)+"%";
   ShowDynamicText("Drawdown",drawdownContent,0,-200);
  }

//+------------------------------------------------------------------+
//| TestSendMail                                                                 |
//+------------------------------------------------------------------+
void TestSendMail()
  {
   int ticket = 17528285;
   SendMail("New order！",GetOrderByTicket(ticket).ToFormatMail());
  }

//+------------------------------------------------------------------+
//| Test Open Order At Specified Time                                                                 |
//+------------------------------------------------------------------+
void TestOpenOrderAtSpecifiedTime()
  {
   if(!IsTestOrderOpened && TimeCurrent()> (D'2020.05.11 14:00') && TimeCurrent()< (D'2020.05.11 14:30'))
     {
      OpenOrder(false,CMoneyManager::GetOpenLots()*2);
      IsTestOrderOpened = true;
     }
  }
//+------------------------------------------------------------------+
