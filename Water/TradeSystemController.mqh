//+------------------------------------------------------------------+
//|                                        TradeSystemController.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
#property strict
#include "Const.mqh"
#include "ISignalEngine.mqh"
#include "OrderManager.mqh"
#include "utils\CommonUtil.mqh"
#include "SignalEngineImpl.mqh"

//+------------------------------------------------------------------+
//| 交易系统控制器：
//| 交易系统的主要逻辑部分,
//| 获取原始信号数据,
//| 结合各种其他数据，综合判断，输出最终执行信号                                                                |
//+------------------------------------------------------------------+
class CTradeSystemController
  {
private:
   static const string  TAG;
   ISignalEngine       *m_signal_engine;
   CSignalData       m_signal_data;

public:
                     CTradeSystemController();
                    ~CTradeSystemController();
   void              ComputeSignalData();
   bool              ShouldOpenBuy();
   bool              ShouldOpenSell();
   bool              ShouldCloseBuy(COrder &order);
   bool              ShouldCloseSell(COrder &order);
   int               GetSafeState();
   void              SetSingalConsumed(const bool isConsumed);
   string            ToString();
  };

//--- Initialization of the static constant of the CStack class
const string CTradeSystemController::TAG = "CTradeSystemController";
//+------------------------------------------------------------------+
//| 带初始化列表的 constructor                                                                 |
//+------------------------------------------------------------------+
CTradeSystemController::CTradeSystemController():m_signal_engine(NULL)
  {
   m_signal_engine = new CSignalEngineImpl;
   Log(TAG,"Object is created");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTradeSystemController::~CTradeSystemController()
  {
   delete(m_signal_engine);
   Log(TAG,"Object is deleted");
  }

//+------------------------------------------------------------------+
//| 字符串形式显示成员信息                                                                 |
//+------------------------------------------------------------------+
string CTradeSystemController::ToString()
  {
   return StringConcatenate("m_signal_data={",
                            "m_orientation:",
                            m_signal_data.orientation,
                            ",m_open_signal:",
                            m_signal_data.open_signal,
                            ",m_close_signal:",
                            m_signal_data.close_signal,
                            "}");
  }

//+------------------------------------------------------------------+
//| 计算信号数据，onTick()中调用，在调用本文件其他方法前调用                                                                  |
//+------------------------------------------------------------------+
void CTradeSystemController::ComputeSignalData()
  {
   CSignalData new_signal_data = m_signal_engine.GetSignalData();
// 对机器信号做人工检查,如果人工做了方向判断，那么以人工为主
   if(ArtificialOrientation != ORI_NO)
      new_signal_data.orientation = ArtificialOrientation;
// 如果信号内容改变才取新信号，否则本地持有的信号不动
   if(m_signal_data != new_signal_data)
     {
      m_signal_data = new_signal_data;
     }
//Log(TAG,"ComputeSignalData..."+ToString());
  }
//+------------------------------------------------------------------+
//| 开 多单 条件                                                                  |
//+------------------------------------------------------------------+
bool CTradeSystemController::ShouldOpenBuy()
  {
   return  CheckMartinAllowed(true) &&
           !m_signal_data.is_consumed &&
           (m_signal_data.orientation == ORIENTATION_UP || m_signal_data.orientation == ORIENTATION_HOR) &&
           m_signal_data.open_signal == SIGNAL_OPEN_BUY &&
           !IsCloseToSameTypeOrders(true);

  }

//+------------------------------------------------------------------+
//| 开 空单 条件                                                                  |
//+------------------------------------------------------------------+
bool CTradeSystemController::ShouldOpenSell()
  {
   return   CheckMartinAllowed(false) &&
            !m_signal_data.is_consumed &&
            (m_signal_data.orientation == ORIENTATION_DW || m_signal_data.orientation == ORIENTATION_HOR) &&
            m_signal_data.open_signal == SIGNAL_OPEN_SELL &&
            !IsCloseToSameTypeOrders(false);
//IsEmptyPositionsCurSymbol();
  }

//+------------------------------------------------------------------+
//| 多单 平仓条件（趋势下降且不亏就平）
//+------------------------------------------------------------------+
bool CTradeSystemController::ShouldCloseBuy(COrder &order)
  {
   return  order.profit > 5 && //Bid-OrderOpenPrice() > BalancePoints*Point &&
           m_signal_data.close_signal == SIGNAL_CLOSE_BUY;//  &&
//!IsEmptyPositionsCurSymbol();
  }

//+------------------------------------------------------------------+
//| 空单 平仓条件（趋势上升且不亏就平）
//+------------------------------------------------------------------+
bool CTradeSystemController::ShouldCloseSell(COrder &order)
  {
   return  order.profit > 5 && //OrderOpenPrice()-Ask > BalancePoints*Point &&
           m_signal_data.close_signal == SIGNAL_CLOSE_SELL;//  &&
//!IsEmptyPositionsCurSymbol();
  }

//+------------------------------------------------------------------+
//| 设置信号为已消费                                                                 |
//+------------------------------------------------------------------+
void CTradeSystemController::SetSingalConsumed(const bool isConsumed)
  {
   m_signal_data.is_consumed = isConsumed;
  }

//+------------------------------------------------------------------+
//| 获取仓位安全状态，
//| 仓位是否危险（已开仓位出现对应平仓信号，但是 profit<0 ）                                                                |
//+------------------------------------------------------------------+
int  CTradeSystemController::GetSafeState()
  {
// 测试
//return true;
   COrder totalOrder = GetAllOrdersAsOne();
//Log(TAG,"IsPositionDangerous..."+totalOrder.ToString());
   int state = POSITION_STATE_SAFE;
// 总利润为正，不用管
   if(totalOrder.profit>=0)
      return state;
// 利润为负，且总体相当于 多 仓，且平 空 仓信号已出现，即警告
   if(totalOrder.type==ORDER_BUY && m_signal_data.close_signal == SIGNAL_CLOSE_BUY)
     {
      state = POSITION_STATE_WARN;
      if(m_signal_data.orientation==ORIENTATION_DW)
         state = POSITION_STATE_DANG;
     }
// 利润为负，且总体相当于 空 仓，且平 空 仓信号已出现，即危险
   if(totalOrder.type==ORDER_SELL && m_signal_data.close_signal == SIGNAL_CLOSE_SELL)
     {
      state = POSITION_STATE_WARN;
      if(m_signal_data.orientation==ORIENTATION_UP)
         state = POSITION_STATE_DANG;
     }
   return state;
  }


//+------------------------------------------------------------------+
