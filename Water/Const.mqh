//+------------------------------------------------------------------+
//|                                                        Const.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
#property strict

//--- EA 名字
#define EA_NAME  "Water 1.0"

//--- 趋势常量, 0:横盘，1:上升趋势，-1:下降趋势
#define TREND_NO  0
#define TREND_UP  1
#define TREND_DW  -1

//--- 交叉常量, 0:无交叉，1:金叉，-1:死叉
#define CROSS_NO    0
#define CROSS_GLOD  1
#define CROSS_DEAD  -1

//--- 方向常量, 0:不确定方向，1:上升趋势，-1:下降趋势，2:横盘震荡
#define ORIENTATION_NO  0
#define ORIENTATION_UP  1
#define ORIENTATION_DW  -1
#define ORIENTATION_HOR 2

//--- 信号常量, 0:无信号，1:，-1:下降趋势
#define SIGNAL_NO  0
#define SIGNAL_OPEN_BUY  1
#define SIGNAL_CLOSE_BUY  -1
#define SIGNAL_OPEN_SELL  2
#define SIGNAL_CLOSE_SELL  -2

//--- 订单类型常量
#define ORDER_BUY        "BUY"
#define ORDER_SELL       "SELL"
#define ORDER_BUYLIMIT   "BUYLIMIT"
#define ORDER_BUYSTOP    "BUYSTOP"
#define ORDER_SELLLIMIT  "SELLLIMIT"
#define ORDER_SELLSTOP   "SELLSTOP"
#define ORDER_UNKNOWN    "UNKNOWN"

//--- 仓位安全状态:安全，警告，危险
#define POSITION_STATE_SAFE    0 
#define POSITION_STATE_WARN    1
#define POSITION_STATE_DANG    2

//+------------------------------------------------------------------+
