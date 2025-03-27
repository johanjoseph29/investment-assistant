import yfinance as yf
import google.generativeai as genai

# Configure Gemini AI (Replace with your actual API key)
genai.configure(api_key="")

def get_stock_analysis(ticker, quantity, current_holdings, investor_type, action, buy_month=None, buy_year=None, stop_loss=None, target_price=None):
    """Fetch stock data, analyze trade decision, and return AI insights."""
    stock = yf.Ticker(ticker)

    # Get current price
    try:
        current_price = stock.history(period="1d")['Close'].iloc[-1]
    except IndexError:
        current_price = None  

    # Get historical buy price
    buy_price = None
    if buy_month and buy_year:
        try:
            history = stock.history(start=f"{buy_year}-{str(buy_month).zfill(2)}-01", period="1mo")
            buy_price = history['Close'].iloc[0] if not history.empty else None
        except:
            buy_price = None

    # Profit/Loss Calculation
    profit_or_loss = "N/A"
    if action == "SELL" and current_price and buy_price:
        profit_or_loss = (current_price - buy_price) * quantity

    # ✅ Optimized Gemini AI Prompt (Short & Effective)
    prompt = f"""
    Quick trade analysis for {ticker}:
    - **Action:** {action}
    - **Buy Price:** ₹{buy_price if buy_price else 'N/A'}
    - **Current Price:** ₹{current_price if current_price else 'N/A'}
    - **Profit/Loss:** {profit_or_loss}
    - **Investor Type:** {investor_type}
    - **Holdings:** {current_holdings} shares
    - **Stop-Loss:** {stop_loss if stop_loss else 'Not Set'}
    - **Target Price:** {target_price if target_price else 'Not Set'}

    Short & effective recommendation:
    1. **BUY / HOLD / SELL?**
    2. Justify using technicals (RSI, moving averages).
    3. Consider market trends & sector comparison.
    4. If HOLD, suggest an entry/exit strategy.

    Keep it concise but insightful.
    """

    model = genai.GenerativeModel("gemini-1.5-pro")
    response = model.generate_content(prompt)

    return {
        "ticker": ticker,
        "buy_price": buy_price,
        "current_price": current_price,
        "profit_or_loss": profit_or_loss,
        "gemini_analysis": response.text.strip()  # Removing extra whitespace
    }
