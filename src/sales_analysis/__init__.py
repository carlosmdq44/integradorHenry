from .strategies import (
    SalesAnalysisStrategy,  # interfaz abstracta (opcional exportarla)
    AnalysisFactory,  # factory para obtener estrategias por nombre
    profile_strategy  # helper para medir tiempos de ejecución
)

__all__ = [
    "SalesAnalysisStrategy",
    "AnalysisFactory",
    "profile_strategy",
]
