from openai import OpenAI
import base64, mimetypes, os
from prompts import recipes_prompt
from dotenv import load_dotenv

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def file_to_data_url(path: str) -> str:
    mime = mimetypes.guess_type(path)[0] or "image/png"
    with open(path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode("utf-8")
    return f"data:{mime};base64,{b64}"

def get_recipes_by_image(path: str):
    data_url = file_to_data_url(path)
    resp = client.responses.create(
        model="gpt-4.1-mini",
        input=[{
            "role": "user",
            "content": [
                {"type": "input_text", "text": recipes_prompt()},
                {"type": "input_image", "image_url": data_url}
            ]
        }]
    )
    return resp.output_text

if __name__ == "__main__":
    print(get_recipes_by_image("test.jpg"))
