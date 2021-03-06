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
//| The controller is the main logical part of the trading system.
//| It processes the original signal data and combines it with other data
//| for comprehensive analysis, and finally outputs the execution signal.                                                             |
//+------------------------------------------------------------------+
class CTradeSystemController
  {
private:
   static const string  TAG;
   ISignalEngine     *m_signal_engine;
   CSignalData       m_signal_data;
public:
                     CTradeSystemController(void);
                    ~CTradeSystemController(void);
   void              ComputeSignalData(void);
   bool              ShouldOpenBuy(void);
   bool              ShouldOpenSell(void);
   bool              ShouldCloseBuy(COrder &order);
   bool              ShouldCloseSell(COrder &order);
   int               GetSafeState(void);
   void              SetSingalConsumed(const bool isConsumed);
  };

const string CTradeSystemController::TAG = "CTradeSystemController";
//+------------------------------------------------------------------+
//| Constructor with initialization list                                                           |
//+------------------------------------------------------------------+
CTradeSystemController::CTradeSystemController():m_signal_engine(NULL)
  {
   m_signal_engine = new CSignalEngineImpl;
   Log(TAG,"Controller Object is created");
  }
//+------------------------------------------------------------------+
//| Destructor                                                                 |
//+------------------------------------------------------------------+
CTradeSystemController::~CTradeSystemController()
  {
   delete(m_signal_engine);
   Log(TAG,"Controller Object is deleted");
  }

//+------------------------------------------------------------------+
//| Compute Signal Data，called in onTick() function.
//| ATTENTION: It must be called before calling controller's other member functions
//+------------------------------------------------------------------+
void CTradeSystemController::ComputeSignalData()
  {
   CSignalData new_signal_data = m_signal_engine.GetSignalData();
// if the ArtificialOrientation input variable is set, then choose the manual signal,
// Otherwise choose the machine signal.
   if(ArtificialOrientation != ORI_NO)
      new_signal_data.orientation = ArtificialOrientation;
// The new signal is taken only if the signal content changes,
// otherwise keep holding the old signal.
   if(m_signal_data != new_signal_data)
     {
      m_signal_data = new_signal_data;
     }
//Log(TAG,"ComputeSignalData..."+ToString());
  }
  
//+------------------------------------------------------------------+
//| When to open BUY order                                                                |
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
//| When to open SELL order                                                                   |
//+------------------------------------------------------------------+
bool CTradeSystemController::ShouldOpenSell()
  {
   return   CheckMartinAllowed(false) &&
            !m_signal_data.is_consumed &&
            (m_signal_data.orientation == ORIENTATION_DW || m_signal_data.orientation == ORIENTATION_HOR) &&
            m_signal_data.open_signal == SIGNAL_OPEN_SELL &&
            !IsCloseToSameTypeOrders(false);
  }

//+------------------------------------------------------------------+
//| When to close BUY order
//+------------------------------------------------------------------+
bool CTradeSystemController::ShouldCloseBuy(COrder &order)
  {
   return  order.profit > MinProfit &&
           m_signal_data.close_signal == SIGNAL_CLOSE_BUY;
  }

//+------------------------------------------------------------------+
//| When to close SELL order
//+------------------------------------------------------------------+
bool CTradeSystemController::ShouldCloseSell(COrder &order)
  {
   return  order.profit > MinProfit &&
           m_signal_data.close_signal == SIGNAL_CLOSE_SELL;
  }

//+------------------------------------------------------------------+
//| You must set a signal consumed after doing some actions according to it,
//| otherwise the signal will continuously trigger your actions.                                                             |
//+------------------------------------------------------------------+
void CTradeSystemController::SetSingalConsumed(const bool isConsumed)
  {
   m_signal_data.is_consumed = isConsumed;
  }

//+------------------------------------------------------------------+
//| Get the position safe state                                                             |
//+------------------------------------------------------------------+
int  CTradeSystemController::GetSafeState()
  {
   COrder totalOrder = GetAllOrdersAsOne();
//Log(TAG,"IsPositionDangerous..."+totalOrder.ToString());
   int state = POSITION_STATE_SAFE;
// if total profit is positive, never mind.
   if(totalOrder.profit>=0)
      return state;
// when totalorder's type is BUY
   if(totalOrder.type==ORDER_BUY && m_signal_data.close_signal == SIGNAL_CLOSE_BUY)
     {
      state = POSITION_STATE_WARN;  // level warn
      if(m_signal_data.orientation==ORIENTATION_DW)
         state = POSITION_STATE_DANG;
     }
// when totalorder's type is SELL
   if(totalOrder.type==ORDER_SELL && m_signal_data.close_signal == SIGNAL_CLOSE_SELL)
     {
      state = POSITION_STATE_WARN;
      if(m_signal_data.orientation==ORIENTATION_UP)
         state = POSITION_STATE_DANG; // level dangerous
     }
   return state;
  }

//+------------------------------------------------------------------+
