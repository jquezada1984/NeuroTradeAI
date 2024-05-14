import MetaTrader5 as mt5
import pytz
from datetime import datetime
import pandas as pd

class MT5Conexion:
    def __init__(self, broker):
        """Inicializa la conexión con los detalles del broker."""
        self.broker = broker
    
    def conectar(self):
        """Conecta con la cuenta de trading en MetaTrader 5."""
        if not mt5.initialize(path=self.broker["path"], 
                              login=self.broker["login"], 
                              password=self.broker["password"], 
                              server=self.broker["server"]):
            print("Error en la conexión con el broker", mt5.last_error())
            return False
        print("Conexión exitosa con el broker.")
        return True
    
    def estaConectado(self):
        return mt5.terminal_info() is not None

    def copiarInformacion(self,fechai,fechaf,simbolo="EURUSD", timeframe=mt5.TIMEFRAME_M5):
        timezone = pytz.utc        
        utc_from = datetime.strptime(fechai, "%Y-%m-%d").replace(tzinfo=timezone)
        utc_to  = datetime.strptime(fechaf, "%Y-%m-%d").replace(tzinfo=timezone)
        rates = mt5.copy_rates_range(simbolo, timeframe, utc_from, utc_to)
        rates_frame = pd.DataFrame(rates)
        rates_frame['time']=pd.to_datetime(rates_frame['time'], unit='s')
        return rates_frame
    
    def desconectar(self):
        """Desconecta de MetaTrader 5."""
        mt5.shutdown()
        print("Desconexión exitosa de MetaTrader 5.")
