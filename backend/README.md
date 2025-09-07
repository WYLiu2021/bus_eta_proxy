Setup and run the HK Bus ETA proxy backend

1. Create and activate a virtual environment (example using PowerShell):

   python -m venv .venv; .\.venv\Scripts\Activate.ps1

2. Install dependencies:

   pip install -r requirements.txt

3. Run the server:

   python app.py

The API endpoints:
- GET /routes -> list of route_id strings
- GET /etas?route_id=<route_id>&seq=0&language=en -> returns ETA JSON from hk-bus-eta

Note: hk-bus-eta scrapes/uses transport data sources; respect its license (GPL-2.0) and rate limits.
