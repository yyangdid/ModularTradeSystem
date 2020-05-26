//+------------------------------------------------------------------+
//|                                                ISignalEngine.mqh |
//|                                     Copyright 2020, Michael Wade |
//|                                             michaelwade@yeah.net |
//+------------------------------------------------------------------+
#property strict

// 必须定义在 ISignalEngine 前面，否则编译报错
struct CSignalData
  {
   int               orientation;
   int               open_signal;
   int               close_signal;
   bool              is_consumed;  // 信号是否已消费过
   bool              operator == (const CSignalData &rhs);
   bool              operator != (const CSignalData &rhs);
                     CSignalData(void);
                    ~CSignalData(void){};
   string            ToString(void);
  };

//+------------------------------------------------------------------+
//| 重写默认构造函数                                                                 |
//+------------------------------------------------------------------+
CSignalData::CSignalData()
  {
   orientation = 0;
   open_signal = 0;
   close_signal = 0;
   is_consumed = false;
  }
//+------------------------------------------------------------------+
//| 重载运算符==,判断内容是否相等,不包括 是否消费过                                                                 |
//+------------------------------------------------------------------+
bool CSignalData::operator == (const CSignalData &rhs)
  {
   return ((orientation == rhs.orientation) &&
           (open_signal == rhs.open_signal) &&
           (close_signal == rhs.close_signal));
  }

//+------------------------------------------------------------------+
//| 防止 != 错用，也重载一下                                                                 |
//+------------------------------------------------------------------+
bool CSignalData::operator != (const CSignalData &rhs)
  {
   return !operator==(rhs);
  }

//+------------------------------------------------------------------+
//|                                                              |
//+------------------------------------------------------------------+
string CSignalData::ToString()
  {
   return StringConcatenate("CSignalData={",
                            "orientation:",
                            orientation,
                            ",open_signal:",
                            open_signal,
                            ",close_signal:",
                            close_signal,
                            "}");
  }

//--- Basic interface for describing animals
interface ISignalEngine
  {
//--- The methods of the interface have public access by default
   CSignalData GetSignalData();
  };

//+------------------------------------------------------------------+
