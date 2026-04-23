import requests
res = requests.post("http://127.0.0.1:8000/api/v1/chat/prompt", json={
    "prompt": "Say hello to Discord",
    "model_name": "gpt-4.1-mini",
    "enabled_tool_ids": []
})
print(res.text)
