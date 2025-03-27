import yfinance as yf
import pandas as pd
import google.generativeai as genai

# Configure Gemini AI
genai.configure(api_key="YOUR_GEMINI_API_KEY")

CSV_FILE = "portfolio.csv"

def load_portfolio():
    try:
        return pd.read_csv(CSV_FILE)
    except FileNotFoundError:
        return pd.DataFrame(columns=["Ticker", "Type", "Quantity", "Price"])

def fetch_stock_prices(tickers):
    prices = {}
    for ticker in tickers:
        stock = yf.Ticker(ticker)
        try:
            prices[ticker] = stock.history(period="1d")['Close'].iloc[-1]
        except Exception:
            prices[ticker] = None
    return prices

def analyze_portfolio():
    portfolio = load_portfolio()
    if portfolio.empty:
        return {"error": "No portfolio data available."}

    tickers = portfolio["Ticker"].unique()
    latest_prices = fetch_stock_prices(tickers)

    analysis = []
    total_profit_loss = 0

    for ticker in tickers:
        stock_data = portfolio[portfolio["Ticker"] == ticker]
        total_quantity = stock_data[stock_data["Type"] == "BUY"]["Quantity"].sum()
        total_cost = (stock_data[stock_data["Type"] == "BUY"]["Quantity"] * stock_data[stock_data["Type"] == "BUY"]["Price"]).sum()
        
        current_price = latest_prices.get(ticker)
        if current_price is None:
            continue
        
        current_value = total_quantity * current_price
        profit_loss = current_value - total_cost
        total_profit_loss += profit_loss

        analysis.append({
            "Ticker": ticker,
            "Total Shares": total_quantity,
            "Avg Buy Price": total_cost / total_quantity if total_quantity > 0 else 0,
            "Current Price": current_price,
            "Current Value": current_value,
            "Profit/Loss": profit_loss
        })

    if not analysis:
        return {"error": "No valid stock data to analyze."}

    return {
        "portfolio_analysis": analysis,
        "total_profit_loss": total_profit_loss
    }

def gemini_analysis():
    portfolio_data = analyze_portfolio()
    if "error" in portfolio_data:
        return {"error": portfolio_data["error"]}

    prompt = f"""
    Analyze this stock portfolio:
    {pd.DataFrame(portfolio_data["portfolio_analysis"]).to_string()}
    Provide concise insights.
    """
    
    model = genai.GenerativeModel("gemini-1.5-pro")
    response = model.generate_content(prompt)
    return {"gemini_analysis": response.text.strip()}
