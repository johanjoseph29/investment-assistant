import yfinance as yf
import google.generativeai as genai

# Configure Gemini API
genai.configure(api_key="")

def get_stock_data(ticker, period="6mo"):
    stock = yf.Ticker(ticker)
    hist = stock.history(period=period)
    if hist.empty or 'Close' not in hist:
        return None, None, None, None, None, None
    
    start_price = hist.iloc[0]['Close']
    end_price = hist.iloc[-1]['Close']
    growth = ((end_price - start_price) / start_price) * 100
    
    avg_volume = hist['Volume'].mean()
    volatility = hist['Close'].pct_change().std()
    
    return start_price, end_price, growth, avg_volume, volatility, hist

def get_gemini_suggestions(target_ticker):
    prompt = f"Suggest twenty-five valid NSE stock tickers that are either similar to {target_ticker} or better within the same sector in terms of growth and performance. Only provide tickers separated by commas, without any additional text."
    model = genai.GenerativeModel("gemini-1.5-pro")
    response = model.generate_content(prompt)
    tickers = response.text.strip().split(",")
    return [ticker.strip().upper() for ticker in tickers if ticker.strip()]

def verify_suggestions(suggested_stocks, target_ticker, period="6mo", growth_threshold=5):
    target_start, target_end, target_growth, target_volume, target_volatility, target_hist = get_stock_data(target_ticker, period)
    if target_growth is None:
        print(f"Error: No data found for {target_ticker}. It may be delisted or invalid.")
        return []

    print(f"\n{target_ticker} Analysis:")
    print(f"Start Price: {target_start:.2f}")
    print(f"End Price: {target_end:.2f}")
    print(f"Growth: {target_growth:.2f}%")
    print(f"Average Volume: {target_volume:.2f}")
    print(f"Volatility: {target_volatility:.4f}\n")
    
    valid_stocks = []

    for stock in suggested_stocks:
        start, end, growth, volume, volatility, hist = get_stock_data(stock, period)
        if growth is None:
            continue
        
        print(f"{stock} Growth: {growth:.2f}%")
        
        if abs(growth - target_growth) <= growth_threshold:
            valid_stocks.append(stock)
    
    return valid_stocks

if __name__ == "__main__":
    stock_ticker = input("Enter stock ticker: ").upper()
    gemini_suggestions = get_gemini_suggestions(stock_ticker)
    valid_stocks = verify_suggestions(gemini_suggestions, stock_ticker)
    
    print("Suggested stocks to buy:")
    print(valid_stocks if valid_stocks else "No similar growth stocks found in the same sector.")
