from openai import OpenAI
import base64, mimetypes, os
from .prompts import recipes_prompt
from dotenv import load_dotenv

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def file_to_data_url(source) -> str:
    if isinstance(source, str):
        if not os.path.exists(source):
            raise FileNotFoundError(f"File not found: {source}")
        mime = mimetypes.guess_type(source)[0] or "image/png"
        with open(source, "rb") as f:
            data = f.read()
    else:
        data = source.read()
        mime = getattr(source, "content_type", None) or "image/png"

    b64 = base64.b64encode(data).decode("utf-8")
    return f"data:{mime};base64,{b64}"

def get_recipes_by_image(path: str, preferences):
    data_url = file_to_data_url(path)
    resp = client.responses.create(
        model="gpt-4.1-mini",
        input=[{
            "role": "user",
            "content": [
                {"type": "input_text", "text": recipes_prompt(preferences)},
                {"type": "input_image", "image_url": data_url}
            ]
        }]
    )
    return resp.output_text

def get_photo(dish_name, products, recipe, download_path):
    prompt = (
        f"{dish_name} that was cooked with these products: {', '.join(products)}. "
        f"And cooked by this recipe:\n{recipe}\n\n"
    )

    response = client.images.generate(
        model="gpt-image-1",
        prompt=prompt,
        size="1024x1024",
        quality="low",
        n=1
    )

    image_b64 = response.data[0].b64_json
    image_bytes = base64.b64decode(image_b64)

    with open(download_path, "wb") as f:
        f.write(image_bytes)

    return download_path

if __name__ == "__main__":
    # print(get_recipes_by_image("test.jpg"))
    print(get_photo("Garlic Mashed Potatoes", ["Potatoes (500g)", "Garlic (3 cloves)", "Olive oil (3 tbsp)", "Salt (to taste)", "Black pepper (to taste)"], """
Step 1.
Peel and dice 500g of potatoes into even chunks.

Step 2.
Peel garlic cloves and crush them lightly with the flat side of a knife.

Step 3.
Place the potatoes and crushed garlic cloves in a pot and cover with cold water.

Step 4.
Bring to a boil over high heat and cook for 15-20 minutes until potatoes are fork-tender.

Step 5.
Drain the potatoes and garlic in a colander and return them to the pot.

Step 6.
Add 3 tablespoons of olive oil and mash the potatoes and garlic with a potato masher until smooth and creamy.

Step 7.
Season with salt and black pepper to taste and mix well.

Step 8.
Serve hot as a comforting side dish.""", "test.png"))
