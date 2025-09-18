import requests

# Replace with your actual token
TOKEN = "your_token"
DOMAIN = "add_some_url"

# Headers from your curl request
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:142.0) Gecko/20100101 Firefox/142.0",
    "Accept": "application/json, text/javascript, */*; q=0.01",
    "Accept-Language": "en-US,en;q=0.5",
    "Accept-Encoding": "gzip, deflate, br, zstd",
    "Content-Type": "application/json; charset=utf-8",
    "X-Requested-With": "XMLHttpRequest",
    "Origin": f"https://{DOMAIN}",
    "Connection": "keep-alive",
    "Referer": f"https://{DOMAIN}/vm/",
    "Cookie": f"token={TOKEN}",
    "Sec-Fetch-Dest": "empty",
    "Sec-Fetch-Mode": "cors",
    "Sec-Fetch-Site": "same-origin",
    "Priority": "u=0",
    "TE": "trailers"
}

# JSON file with servers -> servers-list.json
with open("servers-list.json", "r") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue

        try:
            response = requests.post(
                f"https://{DOMAIN}/api/vm/",
                headers=headers,
                data=line,
                timeout=10
            )

            print(f"VM: {line} | Status: {response.status_code}")
            print(f"Response: {response.text[:100]}...")  # Show first 100 chars

        except Exception as e:
            print(f"Error processing line '{line}': {str(e)}")

print("Done!")