//+------------------------------------------------------------------+
//|                                                CLevelPattern.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
// The code below makes my eyes bleed.
// It's copied from another project by client's request.
//+------------------------------------------------------------------+

#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

struct _Pause {
   int               start;
   int               end;
  };


void PeriodDaysToMinutes(_Pause &arr[],string to_split){
  string sep_1=",",sep_2="-",sep_3=":";                  // разделитель в виде символа
  ushort u_sep_1,u_sep_2,u_sep_3;                    // код символа разделителя
  string result_1[],result_2[],result_3[],result_4[];                 // массив для получения строк
  u_sep_1=StringGetCharacter(sep_1,0);
  u_sep_2=StringGetCharacter(sep_2,0);
  u_sep_3=StringGetCharacter(sep_3,0);
  int k_1=StringSplit(to_split,u_sep_1,result_1);
  ArrayResize(arr,k_1);
  for(int i=0; i<k_1; i++)  {
    arr[i].start=-1;
    arr[i].end=-1;
    int k_2=StringSplit(result_1[i],u_sep_2,result_2);
    if(k_2==2)    {
      int k_3=StringSplit(result_2[0],u_sep_3,result_3);
      int k_4=StringSplit(result_2[1],u_sep_3,result_4);
      if(k_3==2 && k_4==2)      {
        arr[i].start = ((int)StringToInteger(result_3[0]))*60+(int)StringToInteger(result_3[1]);
        arr[i].end = ((int)StringToInteger(result_4[0]))*60+(int)StringToInteger(result_4[1]);
      }
    }
  }
}

//+------------------------------------------------------------------+
void HourToMinutes(_Pause &arr[],string to_split){
  string sep_1=",",sep_2="-";                  // разделитель в виде символа
  ushort u_sep_1,u_sep_2;                    // код символа разделителя
  string result_1[],result_2[];                 // массив для получения строк
  u_sep_1=StringGetCharacter(sep_1,0);
  u_sep_2=StringGetCharacter(sep_2,0);
  int k_1=StringSplit(to_split,u_sep_1,result_1);
  ArrayResize(arr,k_1);

  for(int i=0; i<k_1; i++){
    arr[i].start=-1;
    arr[i].end=-1;
    int k_2=StringSplit(result_1[i],u_sep_2,result_2);
    if(k_2==2){
      arr[i].start = (int)StringToInteger(result_2[0]);
      arr[i].end = (int)StringToInteger(result_2[1]);
    }
  }
}


bool IsTimeAllowed(const datetime _dt, const int _add_hours) {
  MqlDateTime tim;
  TimeToStruct(_dt, tim);
  
  int h=tim.hour+_add_hours;
  int minutes;

  if(h>=0 && h<24)    {
     tim.hour = h;
    }
  else    {
     if(h>24)       {
        tim.hour = h-24;
        int d=tim.day_of_week;
        if(d>0)          {
           tim.day_of_week = d-1;
          }
        else          {
           tim.day_of_week = 6;
          }
       }
     else       {
        tim.hour = h+24;
        int d=tim.day_of_week;
        if(d<6)          {
           tim.day_of_week = d+1;
          }
        else          {
           tim.day_of_week = 0;
          }
       }
    }

  minutes = tim.hour*60 + tim.min;
  bool DrawArrow = true;

  //+------------------------------------------------------------------+
  //|        Отключение общей отрисовки дни                            |
  //+------------------------------------------------------------------+
  for(int i1=0; i1<ArraySize(Day_Pause); i1++)    {
     if(minutes>=Day_Pause[i1].start && minutes<=Day_Pause[i1].end)       {
        DrawArrow = false;
        break;
       }
    }

  //+------------------------------------------------------------------+
  //|        Отключение общей отрисовки часы                           |
  //+------------------------------------------------------------------+
  if(DrawArrow)    {
     for(int i1=0; i1<ArraySize(Hour_Pause); i1++)       {
        if(tim.min>=Hour_Pause[i1].start && tim.min<=Hour_Pause[i1].end)          {
           DrawArrow = false;
           break;
          }
       }
    }
  //+------------------------------------------------------------------+
  //|        Отключение отрисовки по дням                              |
  //+------------------------------------------------------------------+

  if(DrawArrow && tim.day_of_week == 1)    {
     for(int i1=0; i1<ArraySize(Monday_Pause); i1++)       {
        if(minutes>=Monday_Pause[i1].start && minutes<=Monday_Pause[i1].end)          {
           DrawArrow = false;
           break;
          }
       }
    }

  if(DrawArrow && tim.day_of_week == 2)    {
     for(int i1=0; i1<ArraySize(Tuesday_Pause); i1++)       {
        if(minutes>=Tuesday_Pause[i1].start && minutes<=Tuesday_Pause[i1].end)          {
           DrawArrow = false;
           break;
          }
       }
    }

  if(DrawArrow && tim.day_of_week == 3)    {
     for(int i1=0; i1<ArraySize(Wednesday_Pause); i1++)       {
        if(minutes>=Wednesday_Pause[i1].start && minutes<=Wednesday_Pause[i1].end)          {
           DrawArrow = false;
           break;
          }
       }
    }

  if(DrawArrow && tim.day_of_week == 4)    {
     for(int i1=0; i1<ArraySize(Thursday_Pause); i1++)       {
        if(minutes>=Thursday_Pause[i1].start && minutes<=Thursday_Pause[i1].end)          {
           DrawArrow = false;
           break;
          }
       }
    }

  if(DrawArrow && tim.day_of_week == 5)    {
     for(int i1=0; i1<ArraySize(Friday_Pause); i1++)       {
        if(minutes>=Friday_Pause[i1].start && minutes<=Friday_Pause[i1].end)          {
           DrawArrow = false;
           break;
          }
       }
    }

  return DrawArrow;
}