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

bool IsTestOrderOpened = false; // 标记测试订单是否开启
CTradeSystemController *controller = NULL;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   MessageBox("Loaded");
//MessageBox("sent="+ORDER_TYPE_BALANCE);
//SendMail("标题","test text");
//bool sent = SendNotification("ceshi");
   Print("test");
   controller = new CTradeSystemController;
   EventSetTimer(10);// 每1000秒触发一次定时器
   Print("OnInit...");
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
//TestSendMail();
// 定期检查仓位是否安全，需不需人工干预
//CheckSafe();
   Print("OnTimer...");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
// 检查运行环境
   if(!CheckEnv())
      return;
//计算信号数据
   controller.ComputeSignalData();
// 检查是否可以平仓
   CheckClose();
// 检查是否可以开仓
   CheckOpen();

   CheckSafe();// test,非测试要移到 OnTimer 中
// 检查止损
// checkSL();
// 检查止盈
// checkTP();
// 显示相关信息
   ShowInfo();
  }

//+------------------------------------------------------------------+
//| 检查开仓条件                                                                |
//+------------------------------------------------------------------+
void CheckOpen()
  {
//--- 测试开仓，正式版要注释掉
//TestOpenOrder();
//--- 开多
   if(controller.ShouldOpenBuy())
     {
      if(OpenBuy())
         controller.SetSingalConsumed(true);
      return;
     }
//--- 开空
   if(controller.ShouldOpenSell())
     {
      if(OpenSell())
         controller.SetSingalConsumed(true);
     }
  }

//+------------------------------------------------------------------+
//| 检查平仓条件 (目前逻辑：每个单单独判断是否平仓)                                                         |
//+------------------------------------------------------------------+
//void CheckCloseOneByOne()
//  {
//   for(int i=0; i<OrdersTotal(); i++)
//     {
//      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//         continue;
//      if(OrderSymbol()!=_Symbol)
//         continue;
//      if((OrderType()==OP_BUY && controller.ShouldCloseBuy()) ||
//         (OrderType()==OP_SELL && controller.ShouldCloseSell()))
//         CloseOrder(OrderTicket());
//     }
//  }

//+------------------------------------------------------------------+
//| 检查平仓条件 (目前逻辑：多个单也作为一个单来判断是否平仓)                                                                  |
//+------------------------------------------------------------------+
void CheckClose()
  {
   COrder totalOrder = GetAllOrdersAsOne();
   if((totalOrder.type==ORDER_BUY && controller.ShouldCloseBuy(totalOrder)) ||
      (totalOrder.type==ORDER_SELL && controller.ShouldCloseSell(totalOrder)))
      CloseOrder();
  }

//+------------------------------------------------------------------+
//| 检查仓位安全                                                                 |
//+------------------------------------------------------------------+
void CheckSafe()
  {
   int state = controller.GetSafeState();
   switch(state)
     {
      case POSITION_STATE_WARN:
         Print("Your "+_Symbol+" position is NOT SAFE! Pls check."); // test
         //SendMail("注意啦！","Your "+_Symbol+" position is NOT SAFE! Pls check.");
         break;
      case POSITION_STATE_DANG:
         Print("Your "+_Symbol+" position is DANGEROUS! Pls check."); // test
         if(AllowHedge)
            OpenHedgePosition();
     }
  }
//+------------------------------------------------------------------+
//| 显示相关信息                                                                 |
//+------------------------------------------------------------------+
void ShowInfo()
  {
   ShowFlowProfit();
  }

//+------------------------------------------------------------------+
//| 测试发邮件                                                                 |
//+------------------------------------------------------------------+
void TestSendMail()
  {
   int ticket = 17528285;
   SendMail("开单啦！",COrder::GetInstance(ticket).ToFormatMail());
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestOpenOrder()
  {
   if(!IsTestOrderOpened && TimeCurrent()> (D'2020.05.11 14:00') && TimeCurrent()< (D'2020.05.11 14:30'))
     {
      OpenOrder(false,CMoneyManager::GetOpenLots()*2);
      IsTestOrderOpened = true;
     }
  }
//+------------------------------------------------------------------+
