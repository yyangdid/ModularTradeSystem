//+------------------------------------------------------------------+
//|                                                 MoneyManager.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
#property strict
#include "Const.mqh"
#include "Input.mqh"

//+------------------------------------------------------------------+
//| 资金管理者                                                                 |
//+------------------------------------------------------------------+
class CMoneyManager
  {
private:
   static const string TAG;
public:
                     CMoneyManager(void);
                    ~CMoneyManager(void);
   static bool       HasEnoughMoney(void); //const; 只能用来限定成员函数，表示该函数不能修改成员变量，相当于“只读”，不能修饰static 函数
   static double     GetInitLots(void);
   static double     GetAddLots(void);
   static double     GetOpenLots(void);
  };

//--- Initialization of the static constant of the CStack class
const string CMoneyManager::TAG = "CMoneyManager";
//+------------------------------------------------------------------+
//| 是否有足够的钱                                                                 |
//+------------------------------------------------------------------+
bool CMoneyManager::HasEnoughMoney(void)
  {
   if(AccountFreeMargin()<(500))
     {
      Log(TAG,StringConcatenate("We have no enough money. Free Margin = ",AccountFreeMargin()));
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| 计算 开仓手数                                                                    |
//+------------------------------------------------------------------+
double CMoneyManager::GetOpenLots(void)
  {
   return GetAddLots(); //GetInitLots();
  }
//+------------------------------------------------------------------+
//| 计算 初始 手数                                                                 |
//+------------------------------------------------------------------+
double CMoneyManager::GetInitLots(void)
  {
   double lots=NormalizeDouble(AccountBalance()/MoneyEveryLot,1);
   if(lots < 0.01)
      lots = 0.01;
   else
      if(lots > 100)
         lots = 100;
   Log(TAG,StringConcatenate("AccountBalance() = ",AccountBalance(),",lots = ",lots));
   return lots;
  }

//+------------------------------------------------------------------+
//| 计算 加仓 手数(目前逻辑：当前订单中手数最大者的两倍)                                                                 |
//+------------------------------------------------------------------+
double CMoneyManager::GetAddLots(void)
  {
   double maxLots = 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=_Symbol)
         continue;
      double orderLots = OrderLots();
      if(orderLots>maxLots)
         maxLots = orderLots;
     }
   return maxLots == 0? GetInitLots():maxLots*1.2;
  }
//+------------------------------------------------------------------+
