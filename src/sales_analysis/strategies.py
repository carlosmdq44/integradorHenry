from abc import ABC, abstractmethod
from typing import Dict, Type, Any

import pandas as pd
import numpy as np

# ---------------------------------------------------------------------------
# 1. Interfaz común (Strategy)
# ---------------------------------------------------------------------------

class SalesAnalysisStrategy(ABC):
    """Interfaz abstracta para estrategias de análisis de ventas."""

    @abstractmethod
    def analyze(self, df: pd.DataFrame) -> pd.DataFrame:
        """Ejecuta el análisis y devuelve un DataFrame con los resultados."""
        pass

# ---------------------------------------------------------------------------
# 2. Estrategias concretas
# ---------------------------------------------------------------------------

class Top5ConsecutiveDaysBrute(SalesAnalysisStrategy):
    """Encuentra los 5 días consecutivos con mayor venta total usando un bucle for (fuerza bruta)."""

    def analyze(self, df: pd.DataFrame) -> pd.DataFrame:
        daily = (
            df.groupby(df["SalesDate"].dt.date)["TotalPriceCalculated"]
            .sum()
            .sort_index()
        )

        best_total = -np.inf
        best_start = best_end = None

        dates = daily.index.to_list()
        values = daily.values

        for i in range(len(values) - 4):
            total = values[i : i + 5].sum()
            if total > best_total:
                best_total = total
                best_start = dates[i]
                best_end = dates[i + 4]

        return pd.DataFrame({
            "StartDate": [best_start],
            "EndDate": [best_end],
            "TotalSales": [best_total],
            "Method": ["brute"]
        })

class Top5ConsecutiveDaysVectorized(SalesAnalysisStrategy):
    """Encuentra los 5 días consecutivos con mayor venta usando rolling() de Pandas (optimizado)."""

    def analyze(self, df: pd.DataFrame) -> pd.DataFrame:
        daily = (
            df.groupby(df["SalesDate"].dt.date)["TotalPriceCalculated"]
            .sum()
            .sort_index()
        )

        rolling_sum = daily.rolling(window=5).sum().dropna()
        best_end = rolling_sum.idxmax()
        best_total = rolling_sum.max()
        best_start = pd.to_datetime(best_end) - pd.Timedelta(days=4)

        return pd.DataFrame({
            "StartDate": [best_start.date()],
            "EndDate": [best_end],
            "TotalSales": [best_total],
            "Method": ["vectorized"]
        })

class MaxSingleDayStrategy(SalesAnalysisStrategy):
    """Encuentra el día con mayor venta total."""

    def analyze(self, df: pd.DataFrame) -> pd.DataFrame:
        daily = df.groupby(df["SalesDate"].dt.date)["TotalPriceCalculated"].sum()
        best_day = daily.idxmax()
        best_val = daily.max()

        return pd.DataFrame({
            "Date": [best_day],
            "TotalSales": [best_val],
            "Method": ["max_single_day"]
        })

# ---------------------------------------------------------------------------
# 3. Factory Method
# ---------------------------------------------------------------------------

class AnalysisFactory:
    """Fábrica de estrategias. Devuelve la estrategia solicitada por nombre."""

    _strategies: Dict[str, Type[SalesAnalysisStrategy]] = {
        "top5_brute": Top5ConsecutiveDaysBrute,
        "top5_vectorized": Top5ConsecutiveDaysVectorized,
        "max_single_day": MaxSingleDayStrategy,
    }

    @staticmethod
    def get_strategy(name: str) -> SalesAnalysisStrategy:
        if name not in AnalysisFactory._strategies:
            raise ValueError(f"Estrategia desconocida: '{name}'")
        return AnalysisFactory._strategies[name]()

# ---------------------------------------------------------------------------
# 4. Perfilador de ejecución
# ---------------------------------------------------------------------------

def profile_strategy(strategy: SalesAnalysisStrategy, df: pd.DataFrame, repeat: int = 3) -> float:
    """Devuelve el tiempo promedio de ejecución usando timeit."""
    import timeit
    return timeit.timeit(lambda: strategy.analyze(df), number=repeat) / repeat