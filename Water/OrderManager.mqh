//+------------------------------------------------------------------+
//|                                                 OrderManager.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
//| 订单管理者：
//| 目前都是开关仓的常规操作，不需包装成类，
//| 以函数形式暴露出去更合适
//+------------------------------------------------------------------+
#property strict
#include "Const.mqh"
#include "Input.mqh"
#include "MoneyManager.mqh"
#include "utils\CommonUtil.mqh"

const string TAG_OrderManager = "OrderManager";
//+------------------------------------------------------------------+
//| 订单包装类                                                                 |
//+------------------------------------------------------------------+
struct COrder
  {
   int               ticket;
   string            symbol;
   string            type;
   double            lots;
   double            openPrice;
   double            closePrice;
   double            profit;
   //--- Constructor
                     COrder(void):ticket(0),symbol(""),type(""),lots(0),openPrice(0),closePrice(0),profit(0) {}
                     COrder(const int p_ticket);
   //--- Destructor
                    ~COrder(){}
   string            ToString(void);
   string            ToFormatMail(void);
   static COrder     GetInstance(const int p_ticket);
  };

//+------------------------------------------------------------------+
//| 通过 ticket 完成构造                                                                 |
//+------------------------------------------------------------------+
COrder::COrder(int p_ticket)
  {
   if(!OrderSelect(p_ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      Print("COrder object creating failed: cant find this ticket:",p_ticket);
      return;
     }
   ticket = p_ticket;
   symbol = OrderSymbol();
   type = OrderType2Str(OrderType());
   lots = OrderLots();
   openPrice = OrderOpenPrice();
   closePrice = OrderClosePrice();
   profit = OrderProfit();
//Print("COrder object is created");
  }

//+------------------------------------------------------------------+
//| 获取一个实例                                                                 |
//+------------------------------------------------------------------+
COrder COrder::GetInstance(int p_ticket)
  {
   COrder order(p_ticket);
   return order;
  }
//+------------------------------------------------------------------+
//| COrder 对象转为 string 描述                                                                  |
//+------------------------------------------------------------------+
string COrder::ToString()
  {
   return StringConcatenate("{ticket:",ticket,
                            ",symbol:",symbol,
                            ",type:",type,
                            ",lots:",lots,
                            ",openPrice:",openPrice,
                            ",closePrice:",closePrice,
                            ",profit:",profit,
                            "}");
  }

//+------------------------------------------------------------------+
//| COrder 对象转成格式化邮件                                                                 |
//+------------------------------------------------------------------+
string COrder::ToFormatMail()
  {
   return StringConcatenate(
             "<!DOCTYPE html>"+
             "<html>"+
             "<head>"+
             "<meta charset=\"utf-8\">"+
             "<title></title>"+
             "</head>"+
             "<body>"+
             "<table cellspacing=\"1\" cellpadding=\"3\" border=\"0\">"+
             "<tbody>"+
             "<tr>"+
             "<td colspan=\"13\">"+
             "<b>"+
             "New Opened Order:"+
             "</b>"+
             "</td>"+
             "</tr>"+
             "<tr align=\"center\" bgcolor=\"#C0C0C0\">"+
             "<td>"+
             "Ticket"+
             "</td>"+
             "<td>"+
             "Type"+
             "</td>"+
             "<td>"+
             "Lots"+
             "</td>"+
             "<td>"+
             "Symbol"+
             "</td>"+
             "<td nowrap=\"nowrap\">"+
             "Open Price"+
             "</td>"+
             "<td>"+
             "SL"+
             "</td>"+
             "<td>"+
             "TP"+
             "</td>"+
             "<td nowrap=\"nowrap\">"+
             "Close Price"+
             "</td>"+
             "<td>"+
             "Profit"+
             "</td>"+
             "</tr>"+
             "<tr align=\"right\">"+
             "<td>",
             ticket,
             "</td>",
             "<td>",
             type,
             "</td>",
             "<td>",
             lots,
             "</td>",
             "<td>",
             symbol,
             "</td>",
             "<td>",
             openPrice,
             "</td>",
             "<td>",
             "0.00",
             "</td>",
             "<td>",
             "0.00",
             "</td>",
             "<td>",
             closePrice,
             "</td>",
             "<td>",
             profit,
             "</td>"+
             "</tr>"+
             "</tbody>"+
             "</table>"+
             "</body>"+
             "</html>");
  }

//+------------------------------------------------------------------+
//| 订单类型转成字符串形式                                                                 |
//+------------------------------------------------------------------+
string OrderType2Str(int orderTypeInt)
  {
   switch(orderTypeInt)
     {
      case OP_BUY:
         return ORDER_BUY;
      case OP_SELL:
         return ORDER_SELL;
      case OP_BUYLIMIT:
         return ORDER_BUYLIMIT;
      case OP_BUYSTOP:
         return ORDER_BUYSTOP;
      case OP_SELLLIMIT:
         return ORDER_SELLLIMIT;
      case OP_SELLSTOP:
         return ORDER_SELLSTOP;
     }
   return ORDER_UNKNOWN;
  }
//+------------------------------------------------------------------+
//| 检查是否开启自动交易                                                                 |
//+------------------------------------------------------------------+
bool IsAutoTradeAllowed()
  {
   if(!AllowAutoTrade)
      Print("Error opening/closing order : PLS Set AllowAutoTrade true !");
   return AllowAutoTrade;
  }

//+------------------------------------------------------------------+
//| 当前币种是否空仓,挂单不算 (注意：内部OrderSelect操作，影响后续订单指向)                                                                 |
//+------------------------------------------------------------------+
bool IsEmptyPositionsCurSymbol()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=_Symbol)
         continue;
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| 开仓,返回 true: 开仓成功                                                                 |
//+------------------------------------------------------------------+
bool OpenOrder(const bool isBuy,double lots)
  {
   if(!IsAutoTradeAllowed())
      return false;
   int ticket=OrderSend(_Symbol,isBuy?OP_BUY:OP_SELL,lots,isBuy?Ask:Bid,Slippage,0,0,EA_NAME,0,0,isBuy?Green:Red);
   if(ticket<0)
     {
      Log(TAG_OrderManager,StringConcatenate("Failed to open order : {",Symbol(),isBuy?" BUY ":" SELL ",lots,"}, err : ",GetLastError()));
      return false;
     }
// send mail when opening successfully
   SendMail("开单啦！",StringConcatenate("Order opened : ",COrder::GetInstance(ticket).ToFormatMail()));
   return true;
  }

//+------------------------------------------------------------------+
//| 平仓 ,根据ticket                                                                |
//+------------------------------------------------------------------+
void CloseOrderByTicket(const int ticket)
  {
   Print("CloseOrderByTicket...ticket=",ticket);
   if(!IsAutoTradeAllowed())
      return;
   if(!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      return;
   COrder order(ticket);
   if(!OrderClose(ticket,OrderLots(),OrderType()==OP_BUY?Bid:Ask,Slippage,Violet))
     {
      Log(TAG_OrderManager,StringConcatenate("Failed to close order : ",order.ToString(),", err : ",GetLastError()));
      return;
     }
// send mail when closed order
   SendMail("平仓啦！",StringConcatenate("Order closed : ",order.ToFormatMail()));
  }

//+------------------------------------------------------------------+
//| 平仓                                                                   |
//+------------------------------------------------------------------+
void CloseOrder()
  {
   CloseAllOrders();
  }

//+------------------------------------------------------------------+
//| 一次关闭该币种所有订单
//|(注意：因为订单的关闭，会对OrdersTotal()函数结果，以及每个单的position有影响，
//| 因此，一次关闭所有订单时，必须只能调一次OrdersTotal()，然后从订单列表的末尾开始关闭起，
//| 这样，前面未关闭的订单的position就不变，就不会影响到循环
//+------------------------------------------------------------------+
void CloseAllOrders()
  {
   int total = OrdersTotal();
   Print("CloseAllOrders...total=",total);
   for(int i= total-1; i>=0; i--)
     {
      Print("CloseAllOrders1...i=",i);
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      Print("CloseAllOrders2...i=",i);
      if(OrderSymbol()!=_Symbol)
         continue;
      Print("CloseAllOrders3...i=",i,",type=",OrderType());
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
         CloseOrderByTicket(OrderTicket());
     }
  }

//+------------------------------------------------------------------+
//| 开 多单                                                           |
//+------------------------------------------------------------------+
bool OpenBuy()
  {
   return OpenOrder(true, CMoneyManager::GetOpenLots());
  }

//+------------------------------------------------------------------+
//| 开 空单                                                            |
//+------------------------------------------------------------------+
bool OpenSell()
  {
   return OpenOrder(false,CMoneyManager::GetOpenLots());
  }


//+------------------------------------------------------------------+
//| 获取当前symbol的当前这组订单的综合信息
//| 主要包括总方向（type）（buy单多还是sell单多）
//| 和总利润                                                                     |
//+------------------------------------------------------------------+
COrder GetAllOrdersAsOne()
  {
   double buyLots = 0;
   double sellLots = 0;
   double buyProfit = 0;
   double sellProfit = 0;
   int total = OrdersTotal();
   for(int i=0; i<total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=_Symbol)
         continue;
      switch(OrderType())
        {
         case OP_BUY:
            buyLots+=OrderLots();
            buyProfit+=OrderProfit();
            break;
         case OP_SELL:
            sellLots+=OrderLots();
            sellProfit+=OrderProfit();
            break;
        }
     }
   COrder totalOrder;
   totalOrder.symbol = _Symbol;
   totalOrder.type = (buyLots==sellLots?ORDER_UNKNOWN:(buyLots>sellLots?ORDER_BUY:ORDER_SELL));
   totalOrder.profit = buyProfit+sellProfit;
   totalOrder.lots = MathAbs(buyLots-sellLots);
   return totalOrder;
  }

//+------------------------------------------------------------------+
//| 是否距离同类型其他订单太近                                                                 |
//+------------------------------------------------------------------+
bool IsCloseToSameTypeOrders(bool isBuy)
  {
   int total = OrdersTotal();
   for(int i=0; i<total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=_Symbol)
         continue;
      int type = OrderType();
      double openPrice = OrderOpenPrice();
      if((isBuy && type==OP_BUY && MathAbs(Ask-openPrice)<MinIntervalPoints*Point) ||
         (!isBuy && type==OP_SELL && MathAbs(Bid-openPrice)<MinIntervalPoints*Point))
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| 检查是否允许马丁加仓，不允许且同类型订单没有的时候才能开仓 ，其他情况都可以开仓                                                                |
//+------------------------------------------------------------------+
bool CheckMartinAllowed(bool isBuy)
  {
// 允许你马丁，随便开
   if(AllowMartin)
      return true;
// 不允许马丁，只能没有同类型订单的时候才能开
   int total = OrdersTotal();
   for(int i=0; i<total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=_Symbol)
         continue;
      int type = OrderType();
      if((isBuy && type==OP_BUY) || (!isBuy && type==OP_SELL))
         return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| 开启对冲头寸                                                                 |
//+------------------------------------------------------------------+
void OpenHedgePosition()
  {
   Print("OpenHedgePosition...");
   COrder totalOrder = GetAllOrdersAsOne();
   if(totalOrder.type==ORDER_BUY)
      OpenOrder(false,totalOrder.lots + CMoneyManager::GetOpenLots());
   else
      if(totalOrder.type==ORDER_SELL)
         OpenOrder(true,totalOrder.lots + CMoneyManager::GetOpenLots());
  }
//+------------------------------------------------------------------+
