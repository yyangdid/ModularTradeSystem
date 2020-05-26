//+------------------------------------------------------------------+
//|                                             SignalEngineImpl.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
#property strict
#include "ISignalEngine.mqh"
#include "Const.mqh"
#include "Input.mqh"
#include "utils\CommonUtil.mqh"
#include "utils\ShowUtil.mqh"

//+------------------------------------------------------------------+
//| 信号引擎的具体实现类:
//| 独立封装信号计算逻辑，
//| 实现 ISignalEngine.mqh 中统一接口，供外界调用                                                               |
//+------------------------------------------------------------------+
class CSignalEngineImpl : public ISignalEngine
  {
private:
   static const string TAG;
   int               m_big_cross;
   int               m_small_cross;
   int               m_big_trend;
   int               m_small_trend;
   int               m_short_trend;
   int               GetBigTrend();
   int               GetSmallTrend();
   int               GetSmallCross();
   int               GetShortTrend();
   int               GetOrientation();
   int               GetOpenSignal();
   int               GetCloseSignal();
   CSignalData       CreateSignalData();
   void              ShowOriginSignalInfo();
public:
                     CSignalEngineImpl():m_big_cross(CROSS_NO),m_small_cross(CROSS_NO),m_big_trend(TREND_NO),m_small_trend(TREND_NO) { Print("CSignalEngineImpl was born"); }
                    ~CSignalEngineImpl() { Print("CSignalEngineImpl is dead");  }
   //--- Implementing the virtual methods of the ISignalEngine interface
   CSignalData       GetSignalData();
  };

//--- Initialization of the static constant of the CStack class
const string CSignalEngineImpl::TAG = "CSignalEngineImpl";
//+------------------------------------------------------------------+
//| 获取信号数据，暴露给外界调用                                                                 |
//+------------------------------------------------------------------+
CSignalData CSignalEngineImpl::GetSignalData()
  {
   m_big_trend = GetBigTrend();
   m_small_trend = GetSmallTrend();
   m_short_trend = GetShortTrend();
   GetShortTrend();
//Log(TAG,"GetSignalData..."+StringConcatenate("m_big_trend=",m_big_trend,",m_small_trend=",m_small_trend));
   ShowOriginSignalInfo();// 显示数据
   return CreateSignalData();
  }

//+------------------------------------------------------------------+
//| 创建 SignalData 实例                                                                 |
//+------------------------------------------------------------------+
CSignalData CSignalEngineImpl::CreateSignalData()
  {
   CSignalData data;
   data.orientation = GetOrientation();
   data.open_signal = GetOpenSignal();
   data.close_signal = GetCloseSignal();
   return data;
  }

//+------------------------------------------------------------------+
//| 获取交易方向                                                                 |
//+------------------------------------------------------------------+
int CSignalEngineImpl::GetOrientation()
  {
   switch(m_big_trend)
     {
      case TREND_UP:
         return ORIENTATION_UP;
      case TREND_DW:
         return ORIENTATION_DW;
     }
   return ORIENTATION_NO;
  }

//+------------------------------------------------------------------+
//| 获取 开仓 信号                                                                  |
//+------------------------------------------------------------------+
int CSignalEngineImpl::GetOpenSignal()
  {
   if(m_small_cross == CROSS_GLOD)
      return SIGNAL_OPEN_BUY;
   if(m_small_cross == CROSS_DEAD)
      return SIGNAL_OPEN_SELL;
   return SIGNAL_NO;
  }

//+------------------------------------------------------------------+
//| 获取 平仓 信号                                                                      |
//+------------------------------------------------------------------+
int CSignalEngineImpl::GetCloseSignal()
  {
   if(m_small_trend == TREND_DW && m_short_trend == TREND_DW)
      return SIGNAL_CLOSE_BUY;
   if(m_small_trend == TREND_UP && m_short_trend == TREND_UP)
      return SIGNAL_CLOSE_SELL;
   return SIGNAL_NO;
  }

//+------------------------------------------------------------------+
//| 获取大周期趋势方向（使用趋势强度指标）                                                                 |
//+------------------------------------------------------------------+
//int CSignalEngineImpl::GetBigTrend()
//  {
//   double intensityCurrent = iCustom(NULL,0,"TrendIntensity",IntensityFastEMA,IntensitySlowEMA,IntensitySignalSMA,3,1);
//   double intensityPrevious = iCustom(NULL,0,"TrendIntensity",IntensityFastEMA,IntensitySlowEMA,IntensitySignalSMA,3,2);
//// 获取最近的金叉死叉
//   if(intensityPrevious < -2 && intensityCurrent > -2)
//      m_big_cross = CROSS_GLOD;
//   if(intensityPrevious > 2 && intensityCurrent < 2)
//      m_big_cross = CROSS_DEAD;
//// 分界线之外判断
//   if(intensityCurrent > 2)
//      return TREND_UP;
//   if(intensityCurrent < -2)
//      return TREND_DW;
//// 中间区域判断，若最近的是金叉则做多，反之则空
//   return m_big_cross == CROSS_NO ? TREND_NO : (m_big_cross == CROSS_GLOD ? TREND_UP : TREND_DW);
//  }

//+------------------------------------------------------------------+
//| 获取小周期趋势及交叉信号
//+------------------------------------------------------------------+
int CSignalEngineImpl::GetBigTrend()
  {
   double macdCurrent=iMACD(NULL,0,IntensityFastEMA,IntensitySlowEMA,IntensitySignalSMA,PRICE_CLOSE,MODE_MAIN,1);
   double signalCurrent=iMACD(NULL,0,IntensityFastEMA,IntensitySlowEMA,IntensitySignalSMA,PRICE_CLOSE,MODE_SIGNAL,1);
// 获取趋势
   if(macdCurrent == signalCurrent)
      return TREND_NO;
   return macdCurrent > signalCurrent ? TREND_UP : TREND_DW;
  }

//+------------------------------------------------------------------+
//| 获取小周期趋势及交叉信号
//+------------------------------------------------------------------+
int CSignalEngineImpl::GetSmallTrend()
  {
   double macdCurrent=iMACD(NULL,0,SmallFastEMA,SmallSlowEMA,SmallSignalSMA,PRICE_CLOSE,MODE_MAIN,1);
   double signalCurrent=iMACD(NULL,0,SmallFastEMA,SmallSlowEMA,SmallSignalSMA,PRICE_CLOSE,MODE_SIGNAL,1);
   double macdPrevious=iMACD(NULL,0,SmallFastEMA,SmallSlowEMA,SmallSignalSMA,PRICE_CLOSE,MODE_MAIN,SmallCrossBars);
   double signalPrevious=iMACD(NULL,0,SmallFastEMA,SmallSlowEMA,SmallSignalSMA,PRICE_CLOSE,MODE_SIGNAL,SmallCrossBars);
// 获取交叉
   if(macdCurrent > signalCurrent && macdPrevious <= signalPrevious)
      m_small_cross = CROSS_GLOD;
   else
      if(macdCurrent < signalCurrent && macdPrevious >= signalPrevious)
         m_small_cross = CROSS_DEAD;
      else
         m_small_cross = CROSS_NO;
// 获取趋势
   if(macdCurrent == signalCurrent)
      return TREND_NO;
   return macdCurrent > signalCurrent ? TREND_UP : TREND_DW;
  }

//+------------------------------------------------------------------+
//| 获取短时价格趋势                                                                 |
//+------------------------------------------------------------------+
int CSignalEngineImpl::GetShortTrend()
  {
   if(Close[ShortTimeBars]==Close[1])
      return TREND_NO;
   return Close[ShortTimeBars]>Close[1] ? TREND_DW : TREND_UP;
  }

//+------------------------------------------------------------------+
//| 显示原始信号信息                                                                 |
//+------------------------------------------------------------------+
void CSignalEngineImpl::ShowOriginSignalInfo()
  {
   ShowText("SmallMACD",StringConcatenate("Small MACD:",SmallFastEMA," ",SmallSlowEMA," ",SmallSignalSMA),0,0,20,10,"",Red);
   ShowText("BigIndicator",StringConcatenate("Big Indicator:",IntensityFastEMA," ",IntensitySlowEMA," ",IntensitySignalSMA),0,0,40,10,"",Red);
   ShowText("SmallTrend",StringConcatenate("Small Trend:",m_small_trend),0,0,60,15,"",Red);
   ShowText("SmallCross",StringConcatenate("Small Cross:",m_small_cross),0,0,80,15,"",Red);
   ShowText("BigTrend",StringConcatenate("Big Trend:",m_big_trend),0,0,100,15,"",Red);
  }
//+------------------------------------------------------------------+
