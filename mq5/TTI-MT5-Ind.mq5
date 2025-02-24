//+------------------------------------------------------------------+
//|                                                  TTI-MT5-Ind.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "TTI"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_width1  1

#include <Arrays/ArrayObj.mqh>

#include "Include\DKStdLib\Logger\CDKLogger.mqh"
#include "Include\DKStdLib\Common\DKStdLib.mqh"

#include "TimeFilter.mqh"

input  group              "FORBIDDEN TIME (FT)"
input int                 InpTimeAddHours                   = 0;                                // FT.ETS: Extra Time Shift, hours
input string              InpTimeEveryDay_Not_Arrow         = "15:07-16:00";                    // FT.FD: Every DAY Forbidden Intervals (max 20 intervals)
input string              InpTimeEveryHour_Not_Arrow        = "00-10";                          // FT.FH: Every HOUR Forbidden Intervals (max 20 intervals)

input  group              "WEEKDAY SPECIAL (WS)"
input string              InpTimeMonday_Not_Arrow           = "08:30-08:55,10:30-12:15";        // WS.MON: MONDAY Forbidden Intervals (max 20 intervals)
input string              InpTimeTuesday_Not_Arrow          = "08:30-08:55,10:30-12:15";        // WS.TUE: TUESDAY Forbidden Intervals (max 20 intervals)
input string              InpTimeWednesday_Not_Arrow        = "08:30-08:55,10:30-12:15";        // WS.WED: WEDNESDAY Forbidden Intervals (max 20 intervals)
input string              InpTimeThursday_Not_Arrow         = "08:30-08:55,10:30-12:15";        // WS.THU: THURSDAY Forbidden Intervals (max 20 intervals)
input string              InpTimeFriday_Not_Arrow           = "08:30-08:55,10:30-12:15";        // WS.FRI: FRIDAY Forbidden Intervals (max 20 intervals)

input  group              "GRAPHICS (GR)"
sinput bool               InpShowMarker                     = false;                            // GR.ME: Show Marker On the Chart
sinput int                InpArrowCode                      = 167;                              // GR.MCC: Marker Char Code
sinput color              InpArrowColor                     = clrRed;                           // GR.MCL: Market Color

double                    buf[];
_Pause                    Monday_Pause[],Tuesday_Pause[],Wednesday_Pause[],Thursday_Pause[],Friday_Pause[],Day_Pause[],Hour_Pause[];

void InitBuffer(const int _buffer_num, double& _buffer[],
                const int _plot_arrow_code, const int _plot_arrow_shift, const color _color,
                const double _plot_empty_value) {
                
  SetIndexBuffer(_buffer_num, _buffer, INDICATOR_DATA); //--- indicator buffers mapping
  PlotIndexSetInteger(_buffer_num, PLOT_ARROW, _plot_arrow_code); //--- зададим код символа для отрисовки в PLOT_ARROW
  PlotIndexSetInteger(_buffer_num, PLOT_ARROW_SHIFT, _plot_arrow_shift); //--- зададим cмещение стрелок по вертикали в пикселях 
  PlotIndexSetDouble(_buffer_num, PLOT_EMPTY_VALUE, _plot_empty_value); //--- установим в качестве пустого значения 0
  PlotIndexSetInteger(_buffer_num, PLOT_LINE_COLOR, _color); //--- зададим цвет
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
  PeriodDaysToMinutes(Monday_Pause, InpTimeMonday_Not_Arrow);
  PeriodDaysToMinutes(Tuesday_Pause, InpTimeTuesday_Not_Arrow);
  PeriodDaysToMinutes(Wednesday_Pause, InpTimeWednesday_Not_Arrow);
  PeriodDaysToMinutes(Thursday_Pause, InpTimeThursday_Not_Arrow);
  PeriodDaysToMinutes(Friday_Pause, InpTimeFriday_Not_Arrow);
  PeriodDaysToMinutes(Day_Pause, InpTimeEveryDay_Not_Arrow);
  HourToMinutes(Hour_Pause, InpTimeEveryHour_Not_Arrow);  
  
  int market_code = (InpShowMarker) ? InpArrowCode : 32;
  InitBuffer(0, buf, market_code, 0, InpArrowColor, 0);
  return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &t[],
                const double &o[],
                const double &h[],
                const double &l[],
                const double &c[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

  // Fill 0.0 for buffers
  for(int i=rates_total-1; i>MathMax(prev_calculated-1, 0); i--) 
    buf[i] = 0.0;
  
  int start_idx = MathMax(prev_calculated-1, 0);
  for(int i=start_idx;i<rates_total;i++)
    if(!IsTimeAllowed(t[i], InpTimeAddHours))
      buf[i]=c[i];

  return(rates_total);                         
}
