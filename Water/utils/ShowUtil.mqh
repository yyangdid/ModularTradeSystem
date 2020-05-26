//+------------------------------------------------------------------+
//|                                                     ShowUtil.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
#property strict
#include "..\Const.mqh"

//--- 最大净值
double MaxEquity = 0;
//+------------------------------------------------------------------+
//| 在屏幕上显示文字标签                                                                 |
//+------------------------------------------------------------------+
void ShowText(string LableName,string LableDoc,int Corner,int LableX,int LableY,int DocSize,string DocStyle,color DocColor)
  {
   if(Corner == -1)
      return;
//int myWindowsHandle = WindowFind(WindowExpertName()); //获取当前指标名称所在窗口序号
//LableName=LableName+DoubleToStr(myWindowsHandle,0);
   ObjectCreate(LableName, OBJ_LABEL, 0, 0, 0); //建立标签对象
   ObjectSetText(LableName, LableDoc, DocSize, DocStyle,DocColor); //定义对象属性
   ObjectSet(LableName, OBJPROP_CORNER, Corner); //确定坐标原点，0-左上角，1-右上角，2-左下角，3-右下角，-1-不显示
   ObjectSet(LableName, OBJPROP_XDISTANCE, LableX); //定义横坐标，单位像素
   ObjectSet(LableName, OBJPROP_YDISTANCE, LableY); //定义纵坐标，单位像素
  }

//+------------------------------------------------------------------+
//| 动态显示浮亏和最大回撤                                                                 |
//+------------------------------------------------------------------+
void ShowFlowProfit()
  {
// 更新最大净值
   MaxEquity = AccountEquity()>MaxEquity? AccountEquity():MaxEquity;
   double totalProfit = 0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=_Symbol)
         continue;
      totalProfit+=OrderProfit();
     }
   ObjectDelete("Profit");
   ObjectDelete("MaxDrawdown");
   ObjectCreate("Profit",OBJ_TEXT,0,Time[0],Close[0]);
   ObjectCreate("MaxDrawdown",OBJ_TEXT,0,Time[0],Close[0]-350*Point);
   ObjectSetText("Profit","               Profit:"+DoubleToStr(totalProfit,2)+"("+DoubleToStr(100*totalProfit/AccountBalance(),2)+"%)",15,"Arial",Red);
   ObjectSetText("MaxDrawdown","               MaxDrawdown:"+DoubleToStr(AccountEquity()-MaxEquity,2)+"("+DoubleToStr(100*(AccountEquity()-MaxEquity)/MaxEquity,2)+"%)",15,"Arial",Orange);
//Print("浮亏%="+100*totalProfit/AccountBalance());
//Print("最大回撤%="+100*(AccountEquity()-MaxEquity)/MaxEquity);
   //if(100*(AccountEquity()-MaxEquity)/MaxEquity<-10)
   //   Print("警告：最大回撤超过10%！");
  }

//+------------------------------------------------------------------+
//| 画趋势分割线                                                                 |
//+------------------------------------------------------------------+
void DrawTrendDivider(int trend)
  {
   string objName ="Divider"+TimeToString(Time[0]);
   ObjectCreate(objName,OBJ_VLINE,0,Time[0],0);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,trend == TREND_NO ? clrWhite: (trend==TREND_UP ? clrGreen:clrRed));
  }
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
