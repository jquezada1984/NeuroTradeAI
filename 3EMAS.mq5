//+------------------------------------------------------------------+
//|                                                        3EMAS.mq5 |
//|                                    Copyright 2024, John Quezada. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, John Quezada."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input int Periodo=20;                            
input double Desviacion=2;                       // Desviacion

input int PeriodoRapido=20;
input int PeriodoMedio=20;
input int PeriodoLento=20;
int BB_Handle;

int PR_Handle;
int PM_Handle;
int PL_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;

// Variable global o estática para almacenar el índice de la última barra procesada
static int lastProcessedBar = -1;

int OnInit()
  {
//---
   min_rates_total=Periodo+1;
   BB_Handle=iBands(NULL,0,Periodo,0,Desviacion,PRICE_CLOSE);
   if(BB_Handle==INVALID_HANDLE) Print(" No se pudo controlar el indicador iBands");
   
   PR_Handle=iMA(NULL,0,PeriodoRapido,0,MODE_EMA,PRICE_CLOSE);
   PM_Handle=iMA(NULL,0,PeriodoMedio,0,MODE_EMA,PRICE_CLOSE);
   PL_Handle=iMA(NULL,0,PeriodoLento,0,MODE_EMA,PRICE_CLOSE);
   if(PR_Handle==INVALID_HANDLE || PM_Handle==INVALID_HANDLE || PL_Handle==INVALID_HANDLE) Print(" No se pudo controlar el indicador iMA");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    double EMA20[],EMA50[],EMA100[];
    int to_copy;
    CopyBuffer(PR_Handle,1,0,to_copy,EMA20);
    CopyBuffer(PM_Handle,1,0,to_copy,EMA50);
    CopyBuffer(PL_Handle,1,0,to_copy,EMA100);
  
            
    double VEMA20 = EMA20[0];
    double VEMA50 = EMA50[0];
    double VEMA100 = EMA100[0];
    double currentPrice = iClose(_Symbol, _Period, 0);


      
    // Verificar condiciones para compra
    if (currentPrice > VEMA20 && VEMA20 > VEMA50 && VEMA50 > VEMA100) {
        if (iClose(_Symbol, _Period, 1) < VEMA20 && EsVelaFuerte(1,10) && currentPrice > iHigh(_Symbol, _Period, 1)) {
            double stopLossPrice = MathMin(iLow(_Symbol, _Period, 1), iLow(_Symbol, _Period, 2));
           /* 
            double takeProfitPrice = currentPrice + TakeProfitFactor * (currentPrice - stopLossPrice);
            int ticket = OrderSend(_Symbol, OP_BUY, LotSize, currentPrice, 3, stopLossPrice, takeProfitPrice, "EMA Strategy Buy", 0, 0, clrGreen);
            if (ticket < 0) {
                Print("Error opening buy order: ", GetLastError());
            } else {
                Print("Buy order opened successfully");
            }
            */
        }
    }
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Función para determinar si una vela es fuerte                    |
//+------------------------------------------------------------------+
bool EsVelaFuerte(int index, int tamanio)
  {
   double promedioTamanio = 0;
   for (int i = 1; i <= tamanio; i++)
     {
      double openPrice = iOpen(_Symbol, _Period, i);
      double closePrice = iClose(_Symbol, _Period, i);
      promedioTamanio += MathAbs(openPrice - closePrice);
     }
   promedioTamanio /= tamanio;

   double openCurrent = iOpen(_Symbol, _Period, index);
   double closeCurrent = iClose(_Symbol, _Period, index);
   double highCurrent = iHigh(_Symbol, _Period, index);
   double lowCurrent = iLow(_Symbol, _Period, index);

   double cuerpoVela = MathAbs(openCurrent - closeCurrent);
   double tamanioVela = MathMax(highCurrent, closeCurrent) - MathMin(lowCurrent, openCurrent);
   double extremoCierre = (closeCurrent > openCurrent) ? (highCurrent - closeCurrent) : (closeCurrent - lowCurrent);

   // Verificar condiciones
   if (cuerpoVela >= promedioTamanio * 0.5 &&
       extremoCierre <= tamanioVela * 0.1 &&  // Cierre cerca del extremo (ajustar según necesidad)
       cuerpoVela >= tamanioVela * 0.5)
     {
      return true;
     }

   return false;
  }
  
   int Tendencia(){
      int limit,bar,trend,to_copy,maxbar;
      double smax0,smin0,bsmax0,bsmin0,close;
      double UpBB[],DnBB[],dsize;
   
      //---- declaraciones de variables de memoria
      static int trend_;    // Mantiene la tendencia calculada anterior.
      static double smax1,smin1,bsmax1,bsmin1;
      
      
      smax1=-999999999;
      smin1=+999999999;
      bsmax1=-999999999;
      bsmin1=+999999999;
      trend_=0;
         
          
      ArraySetAsSeries(UpBB,true);
      ArraySetAsSeries(DnBB,true);
      to_copy=limit+1;
      if(CopyBuffer(BB_Handle,1,0,to_copy,UpBB)<=0) return(0);
      if(CopyBuffer(BB_Handle,2,0,to_copy,DnBB)<=0) return(0);
      
      for(bar=limit; bar>=0 && !IsStopped(); bar--){
         close=iClose(_Symbol, _Period, bar);
         if(close>smax1) trend=1;
         if(close<smin1) trend=-1;
      }
      return 1;
   } 
   
   
