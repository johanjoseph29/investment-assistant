import google.generativeai as genai

# Configure Gemini API (Directly set API key)
GEMINI_API_KEY = ""
genai.configure(api_key=GEMINI_API_KEY)

def get_finance_response(user_message):
    """Generates a finance-related response using Gemini AI."""
    prompt = f"""
    You are a finance chatbot. Answer questions related to:
    - Investments
    - Stocks
    - Mutual funds
    - Gold
    - Real estate
    - Budgeting

    Only answer finance-related questions. Ignore any unrelated topics.

    User: {user_message}
    """

    try:
        model = genai.GenerativeModel("gemini-1.5-pro")
        response = model.generate_content(prompt)
        return response.text
    except Exception as e:
        return f"Error: {str(e)}"
