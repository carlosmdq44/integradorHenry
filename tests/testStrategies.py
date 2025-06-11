import pandas as pd
from sales_analysis import AnalysisFactory

def demo_df():
    fechas = pd.date_range("2022-01-01", periods=20, freq="D").repeat(5)
    return pd.DataFrame({
        "SalesDate": fechas,
        "TotalPriceCalculated": 100
    })

def test_top5_equivalentes():
    df = demo_df()
    strat1 = AnalysisFactory.get_strategy("top5_brute")
    strat2 = AnalysisFactory.get_strategy("top5_vectorized")
    result1 = strat1.analyze(df)
    result2 = strat2.analyze(df)
    assert result1["TotalSales"].iloc[0] == result2["TotalSales"].iloc[0]

def test_max_single_day():
    df = demo_df()
    strat = AnalysisFactory.get_strategy("max_single_day")
    result = strat.analyze(df)
    assert "TotalSales" in result.columns
    assert result.shape[0] == 1