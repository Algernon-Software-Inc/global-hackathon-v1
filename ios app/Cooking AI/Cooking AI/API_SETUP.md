# API Setup Guide

## Quick Start

1. Open `Services/APIService.swift`
2. Replace `YOUR_API_BASE_URL` with your actual API endpoint
3. Ensure your API matches the expected format below

## API Endpoints

### 1. Get Dishes (POST)

**Endpoint:** `/api/get-dishes`

**Request Format:**
- Content-Type: `multipart/form-data`
- Fields:
  - `image`: JPEG/PNG image file
  - `preferences`: JSON string

**Preferences JSON Structure:**
```json
{
  "diets": ["Vegetarian", "Vegan", "Gluten-free", "Dairy-free", "Lactose-free", "Keto", "Low-carb", "None"],
  "experience": "Beginner | Intermediate | Advanced | Professional",
  "favourite": ["Italian", "Chinese", "Japanese", "Mexican", "Indian", "French", "Mediterranean", "American", "Thai"],
  "time": ["15-30 minutes", "30-60 minutes", "1-2 hours", "2+ hours"]
}
```

**Response Format:**
```json
[
  {
    "name": "Pasta Primavera",
    "products": ["pasta", "vegetables", "olive oil", "garlic"],
    "recipe": "1. Boil water...\n2. Cook pasta...\n3. Sauté vegetables...",
    "time_min": 30,
    "difficulty": 2,
    "energy_kcal": 450.5,
    "proteins_g": 12.5,
    "fats_g": 15.0,
    "carbs_g": 60.0,
    "image_id": "dish_image_123"
  },
  {
    "name": "Another Dish",
    "products": ["ingredient1", "ingredient2"],
    "recipe": "Step by step...",
    "time_min": 45,
    "difficulty": 3,
    "energy_kcal": 550.0,
    "proteins_g": 20.0,
    "fats_g": 25.0,
    "carbs_g": 50.0,
    "image_id": "dish_image_456"
  }
]
```

### 2. Get Dish Image (GET)

**Endpoint:** `/api/images/{image_id}`

**Response:**
- Content-Type: `image/jpeg` or `image/png`
- Binary image data

## Example cURL Commands

### Get Dishes
```bash
curl -X POST "https://your-api.com/api/get-dishes" \
  -H "Content-Type: multipart/form-data" \
  -F "image=@/path/to/ingredients.jpg" \
  -F 'preferences={"diets":["Vegetarian"],"experience":"Intermediate","favourite":["Italian"],"time":["30-60 minutes"]}'
```

### Get Image
```bash
curl -X GET "https://your-api.com/api/images/dish_image_123" \
  --output dish.jpg
```

## Testing the API

Before integrating with the app, test your API endpoints:

1. **Test POST endpoint:**
   - Upload a test image
   - Include valid preferences JSON
   - Verify response matches expected format

2. **Test GET image endpoint:**
   - Use an `image_id` from the POST response
   - Verify image is returned successfully

## Error Handling

The app handles the following error cases:
- Invalid URL configuration
- Network errors
- Invalid API responses
- Image decoding errors

Make sure your API returns:
- **200 OK** for successful requests
- **400 Bad Request** for invalid input
- **404 Not Found** for missing resources
- **500 Internal Server Error** for server issues

## Security Considerations

1. **HTTPS**: Use HTTPS for all API communications
2. **API Keys**: If your API requires authentication, add it in `APIService.swift`:
   ```swift
   request.setValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
   ```
3. **Rate Limiting**: Consider implementing rate limiting on the server
4. **Image Validation**: Validate uploaded images on the server

## Development vs Production

For development, you might want to add environment-based configuration:

```swift
#if DEBUG
private let baseURL = "http://localhost:3000"
#else
private let baseURL = "https://api.yourproduction.com"
#endif
```

## Troubleshooting

### Common Issues

1. **"Invalid URL" error**
   - Check that `baseURL` is set correctly
   - Ensure URL doesn't have trailing slash

2. **"Invalid Response" error**
   - Verify API returns 200 status code
   - Check JSON response matches expected format
   - Use network debugging tools (Charles, Proxyman)

3. **Image not loading**
   - Verify `image_id` is correct
   - Check image endpoint returns proper content-type
   - Ensure image data is not corrupted

### Network Debugging

Add this to `APIService.swift` for debugging:
```swift
if let responseString = String(data: data, encoding: .utf8) {
    print("API Response: \(responseString)")
}
```
