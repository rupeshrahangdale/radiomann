# Radio Bharti API Documentation

## Authentication

All API requests require authentication using an API token. The token should be included in the request headers.

```
Authorization: RABTK875673
```
flutter pub add change_app_package_name
flutter pub run change_app_package_name:main com.nxtinlbs.radiobharatbharti 

## API Endpoints

### Streaming URLs

**Endpoint:** `GET /api/streaming-urls`

**Description:** Get all active streaming URLs

**Response:**
```json
{
    "status": true,
    "message": "Streaming URLs retrieved successfully",
    "data": [
        {
            "id": 1,
            "streaming_url": "https://example.com/stream1",
            "status": 1,
            "created_at": "2023-08-10T12:00:00.000000Z",
            "updated_at": "2023-08-10T12:00:00.000000Z"
        }
    ]
}
```

### Contact Information

**Endpoint:** `GET /api/contact-info`

**Description:** Get contact information

**Response:**
```json
{
    "status": true,
    "message": "Contact information retrieved successfully",
    "data": {
        "id": 1,
        "mobile": "+91 1234567890",
        "email": "contact@radiobharti.com",
        "address": "123 Radio Street, Delhi, India",
        "whatsapp": "+91 9876543210",
        "instagram_url": "https://instagram.com/radiobharti",
        "facebook_url": "https://facebook.com/radiobharti",
        "twitter_url": "https://twitter.com/radiobharti",
        "youtube_url": "https://youtube.com/radiobharti",
        "status": 1,
        "created_at": "2023-08-10T12:00:00.000000Z",
        "updated_at": "2023-08-10T12:00:00.000000Z"
    }
}
```

### Privacy Policy

**Endpoint:** `GET /api/privacy-policy`

**Description:** Get privacy policy

**Response:**
```json
{
    "status": true,
    "message": "Privacy policy retrieved successfully",
    "data": {
        "id": 1,
        "title": "Privacy Policy",
        "content": "Long text content of privacy policy...",
        "status": 1,
        "created_at": "2023-08-10T12:00:00.000000Z",
        "updated_at": "2023-08-10T12:00:00.000000Z"
    }
}
```

### Birthday Stickers

**Endpoint:** `GET /api/birthday-stickers`

**Description:** Get all active birthday stickers

**Response:**
```json
{
    "status": true,
    "message": "Birthday stickers retrieved successfully",
    "data": [
        {
            "id": 1,
            "sticker_url": "https://example.com/stickers/birthday1.png",
            "status": 1,
            "created_at": "2023-08-10T12:00:00.000000Z",
            "updated_at": "2023-08-10T12:00:00.000000Z"
        }
    ]
}
```

### Submit Birthday Wish Request

**Endpoint:** `POST /api/birthday-wish-request`

**Description:** Submit a birthday wish request

**Request Body:**
```json
{
    "name": "John Doe",
    "dob": "1990-01-15",
    "message": "Happy Birthday to my friend!"
}
```

**Response:**
```json
{
    "status": true,
    "message": "Birthday wish request submitted successfully",
    "data": {
        "id": 1,
        "name": "John Doe",
        "dob": "1990-01-15",
        "message": "Happy Birthday to my friend!",
        "status": 1,
        "created_at": "2023-08-10T12:00:00.000000Z",
        "updated_at": "2023-08-10T12:00:00.000000Z"
    }
}
```

### Photo Gallery

**Endpoint:** `GET /api/photos`

**Description:** Get all active photos from gallery

**Response:**
```json
{
    "status": true,
    "message": "Photos retrieved successfully",
    "data": [
        {
            "id": 1,
            "photo_url": "https://example.com/gallery/photo1.jpg",
            "caption": "Radio Bharti Event 2023",
            "status": 1,
            "created_at": "2023-08-10T12:00:00.000000Z",
            "updated_at": "2023-08-10T12:00:00.000000Z"
        }
    ]
}
```

### Upcoming Events

**Endpoint:** `GET /api/upcoming-events`

**Description:** Get all active upcoming events

**Response:**
```json
{
    "status": true,
    "message": "Upcoming events retrieved successfully",
    "data": [
        {
            "id": 1,
            "event_name": "Radio Bharti Annual Festival",
            "event_date_time": "2023-12-15 18:00:00",
            "event_place": "Delhi Convention Center",
            "event_poster_url": "https://example.com/events/annual-festival.jpg",
            "event_details": "Join us for our annual festival with music and performances.",
            "status": 1,
            "created_at": "2023-08-10T12:00:00.000000Z",
            "updated_at": "2023-08-10T12:00:00.000000Z"
        }
    ]
}
```

### Programs

**Endpoint:** `GET /api/programs`

**Description:** Get all active programs

**Response:**
```json
{
    "status": true,
    "message": "Programs retrieved successfully",
    "data": [
        {
            "id": 1,
            "program_name": "Morning Show",
            "program_date": "2023-08-15",
            "program_time": "08:00:00",
            "program_place": "Studio A",
            "program_poster_url": "https://example.com/programs/morning-show.jpg",
            "program_type": "Live",
            "program_link": "https://example.com/live/morning-show",
            "status": 1,
            "created_at": "2023-08-10T12:00:00.000000Z",
            "updated_at": "2023-08-10T12:00:00.000000Z"
        }
    ]
}
```

### Programs by Type

**Endpoint:** `GET /api/programs/{type}`

**Description:** Get programs by type (Live or Recorded)

**Parameters:**
- `type`: Must be either "Live" or "Recorded"

**Response:**
```json
{
    "status": true,
    "message": "Live programs retrieved successfully",
    "data": [
        {
            "id": 1,
            "program_name": "Morning Show",
            "program_date": "2023-08-15",
            "program_time": "08:00:00",
            "program_place": "Studio A",
            "program_poster_url": "https://example.com/programs/morning-show.jpg",
            "program_type": "Live",
            "program_link": "https://example.com/live/morning-show",
            "status": 1,
            "created_at": "2023-08-10T12:00:00.000000Z",
            "updated_at": "2023-08-10T12:00:00.000000Z"
        }
    ]
}
```

### Podcasts

**Endpoint:** `GET /api/podcasts`

**Description:** Get all active podcasts

**Response:**
```json
{
    "status": true,
    "message": "Podcasts retrieved successfully",
    "data": [
        {
            "id": 1,
            "podcast_name": "Tech Talk",
            "podcast_poster": "https://example.com/podcasts/tech-talk.jpg",
            "podcast_date": "2023-08-10",
            "podcast_time": "14:00:00",
            "podcast_place": "Studio B",
            "details": "A podcast about the latest technology trends.",
            "podcast_url": "https://example.com/podcasts/tech-talk-ep1.mp3",
            "status": 1,
            "created_at": "2023-08-10T12:00:00.000000Z",
            "updated_at": "2023-08-10T12:00:00.000000Z"
        }
    ]
}
```

### Submit Enquiry

**Endpoint:** `POST /api/enquiry`

**Description:** Submit a new enquiry

**Request Body:**
```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "+91 9876543210",
    "message": "I would like to know more about your radio programs."
}
```

**Response:**
```json
{
    "status": true,
    "message": "Enquiry submitted successfully",
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "mobile": "+91 9876543210",
        "message": "I would like to know more about your radio programs.",
        "status": 1,
        "created_at": "2023-08-10T12:00:00.000000Z",
        "updated_at": "2023-08-10T12:00:00.000000Z"
    }
}
```

## Error Responses

### Unauthorized Access

**Status Code:** 401

**Response:**
```json
{
    "status": false,
    "message": "Unauthorized access",
    "data": null
}
```

### Resource Not Found

**Status Code:** 404

**Response:**
```json
{
    "status": false,
    "message": "[Resource] not found",
    "data": null
}
```

### Validation Error

**Status Code:** 422

**Response:**
```json
{
    "status": false,
    "message": "Validation failed",
    "data": {
        "field_name": [
            "Error message for field"
        ]
    }
}
```

### Server Error

**Status Code:** 500

**Response:**
```json
{
    "status": false,
    "message": "Failed to [operation]",
    "data": null
}
```