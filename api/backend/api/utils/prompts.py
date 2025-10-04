def recipes_prompt():
    return f"""Give me recipes of 4 pretty popular dishes i can make with these products (AND salt, oil, water, butter). Use only products I have, no other products. 
Every recipe should be in this format:
Dish name
List of products used and measurements in brackets (separated by coma, if measurements are not exact like 50g of tomatoes use the amount of the product, for example: Tomatoes (1 piece))
Dish recipe
Time to make the dish (in minutes)
How hard is it to make the dish (out of 5, 5 is the hardest)
Dish energy value (in kcal)
Dish proteins (in g)
Dish fats (in g)
Dish carbs (in g)

Example:
Burger
Bread (2 slices), Tomatoes (1 piece), Cucumbers (several slices), Meat (100g)
Step 1.
Preheat an outdoor grill for high heat and lightly oil grate.

Step 2.
Whisk egg, salt, and pepper together in a medium bowl.

Step 3.
Add ground beef and bread crumbs; mix with your hands or a fork until well blended.

Step 4.
Form into four 3/4-inch-thick patties.

Step 5.
Place patties on the preheated grill. Cover and cook 6 to 8 minutes per side, or to desired doneness. An instant-read thermometer inserted into the center should read at least 160 degrees F (70 degrees C).

Step 6.
Serve hot and enjoy!
10
2
422
15
32
18.5

Each new recipe should be separated with "\n----------\n" (new line, 10 dashes and new line)
In the dish name and products there should not be new lines.
Dont use any text before and after all recipes. Dont write titles like "Dish name", "Dish recipe", only type the name itself without anything.
The recipe should be detailed (everything should be by steps like in example). Try to make steps as detailed as possible. If it written about something that takes time write how much time it takes. If there are some concrete measurements in the step include them into the text. Every step should come with a new line (new line for a word step and number, then a new line with exact step and then a new line after all), exactly like its given in the example.
For energy value provide only number (without any text like "kcal" or "g")
As an answer provide all recipes in the given format, without any symbols before first dish's name and without any symbols after last dish recipe."""