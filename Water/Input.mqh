//+------------------------------------------------------------------+
//|                                                        Input.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
//| 管理所有 input 变量
//+------------------------------------------------------------------+
#property strict
#include "Const.mqh"
#define SmallTimes  12

//是否允许自动交易
input bool AllowAutoTrade = true;
//多少美金开一手
input double MoneyEveryLot = 35000.0;
//默认起始手数
input double DefaultLots   = 0.01;
//平出点数
input int BalancePoints = 50;
// 最低获利
input double MinProfit = 5;
// Whether to allow email
input bool AllowMail = false;
//亏损时是否允许对冲
input bool AllowHedge = false;
//是否允许逆向加仓(马丁)
input bool AllowMartin = false;
//同类型订单最少间隔点数 MinPointsBetween2SameTypeOrders
input int MinIntervalPoints = 500;

//最大滑点
input int Slippage = 100;
//--- 小周期 macd 参数
input int SmallFastEMA= 100*SmallTimes;;
input int SmallSlowEMA= 216*SmallTimes;;
input int SmallSignalSMA= 9*SmallTimes;;
//交叉信号持续柱数（至少2个小时）
input int SmallCrossBars=2*SmallTimes;
//--- 趋势强度指标 参数(H4线)
input int IntensityFastEMA= 100*SmallTimes*4;
input int IntensitySlowEMA= 216*SmallTimes*4;
input int IntensitySignalSMA= 9*SmallTimes*4;
//--- 短时价格趋势判断柱数
input int ShortTimeBars=3*SmallTimes;

enum Orientation
  {
   ORI_NO = ORIENTATION_NO,
   ORI_UP = ORIENTATION_UP,
   ORI_DW = ORIENTATION_DW,
   ORI_HOR = ORIENTATION_HOR
  };
//---  人工判断方向(默认ORI_NO:人不参与)
input Orientation ArtificialOrientation = ORI_NO;
//+------------------------------------------------------------------+
