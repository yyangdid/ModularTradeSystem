//+------------------------------------------------------------------+
//|                                                        Input.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
//| All input variables should be defined here.
//+------------------------------------------------------------------+
#property strict
#include "Const.mqh"
#define SmallTimes  12

// Whether to allow automated trading
input bool AllowAutoTrade = false;
// How much money must be in the account
input double MoneyAtLeast = 500.0;
// How much money is needed for opening one lot position
input double MoneyEveryLot = 35000.0;
// Default initial lot
input double DefaultLots   = 0.01;
// Minimum profit for every closing position.
input double MinProfit = 1;
// Whether to allow email
input bool AllowMail = false;
// Whether to allow hedge
input bool AllowHedge = false;
// Whether to allow using Martingale strategy
input bool AllowMartin = false;
// The lot multiple to add positions
input double AddLotsMultiple = 1.2;
// Minimum points between 2 same type orders
input int MinIntervalPoints = 500;
// Maximum acceptable slippage
input int Slippage = 100;
// Parameters for small period indicator
input int SmallFastEMA= 12*SmallTimes;
input int SmallSlowEMA= 26*SmallTimes;
input int SmallSignalSMA= 9*SmallTimes;
// Number of continuous bars of cross signal (at least 2 hours)
input int SmallCrossBars=2*SmallTimes;
// Parameters for big period indicator
input int BigFastEMA= 12*SmallTimes*4;
input int BigSlowEMA= 26*SmallTimes*4;
input int BigSignalSMA= 9*SmallTimes*4;
// Number of continuous bars of short time trend
input int ShortTimeBars=3*SmallTimes;

enum Orientation
  {
   ORI_NO = ORIENTATION_NO,
   ORI_UP = ORIENTATION_UP,
   ORI_DW = ORIENTATION_DW,
   ORI_HOR = ORIENTATION_HOR
  };
// The orientation which is confirmed manually.
// Default option ORI_NO: let machine determine the orientation.
input Orientation ArtificialOrientation = ORI_NO;
//+------------------------------------------------------------------+
