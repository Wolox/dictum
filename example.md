# Index
- MyResource

# MyResource
This is MyResource description.

## POST /api/v1/my_resource

### Description:
This optional property exists to add a description to the endpoint.

### Request headers:
```json
{
  "AUTHORIZATION" : "user_token",
  "Content-Type" : "application/json",
  "Accept" : "application/json"
}
```

### Path parameters:
```json
{ "id": 1, "page": 1 }
```

### Body parameters:
```json
{ "some": "parameter" }
```

### Response headers:
```json
{ "some_header": "some_header_value" }
```

### Response status:
200

### Response body:
```json
"no_content"
```
