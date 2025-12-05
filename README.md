# nvim-devutils

A collection of developer utilities for Neovim. Quick access to encoding, decoding, formatting, and code sharing tools without leaving your editor.

## Features

- **Base64**: Encode/decode selections using Neovim's built-in base64 functions
- **URL Encoding**: Percent-encode/decode URLs and query strings
- **JSON Formatting**: Pretty-print and format JSON with proper indentation
- **UUID Generation**: Generate and insert v4 UUIDs
- **Ray.so Integration**: Create styled code snippet URLs for sharing
- **JWT Decoder**: Decode and inspect JWT tokens with expiry info
- **Timestamp Converter**: Convert between Unix timestamps and human-readable dates
- **Case Conversion**: Convert between camelCase, snake_case, PascalCase, kebab-case, and more
- **Telescope Integration**: Unified picker interface for all utilities
- **Which-key Support**: Integration with which-key for keybinding help

## Installation

Using [packer.nvim](https://github.com/wbthomson/packer.nvim):

```lua
use 'stemitom/nvim-devutils'
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'stemitom/nvim-devutils',
  config = function()
    require('nvim-utils').setup()
  end
}
```

## Setup

### Basic Setup

```lua
require('nvim-utils').setup()
```

### Custom Configuration

```lua
require('nvim-utils').setup({
  mappings = {
    base64_encode = "<leader>ue",
    base64_decode = "<leader>ud",
    json_format = "<leader>uj",
    url_encode = "<leader>uU",
    url_decode = "<leader>uu",
    uuid_generate = "<leader>ug",
    rayso_generate = "<leader>ur",
    rayso_options = "<leader>uR",
    telescope_utils = "<leader>ut",
    jwt_decode = "<leader>uJ",
    timestamp_convert = "<leader>us",
    timestamp_insert = "<leader>uS",
    case_convert = "<leader>uc",
  },
  telescope = {
    enabled = true,
  }
})
```

Set any mapping to `false` to disable it:

```lua
require('nvim-utils').setup({
  mappings = {
    rayso_options = false,  -- Disable this keybinding
  }
})
```

## Usage

### Keybindings

All utilities work on visual selections unless otherwise noted.

| Keybinding | Command | Description |
|-----------|---------|-------------|
| `<leader>ue` | `Base64Encode` | Base64 encode selection |
| `<leader>ud` | `Base64Decode` | Base64 decode selection |
| `<leader>uj` | `JsonFormat` | Format JSON selection |
| `<leader>uU` | `UrlEncode` | URL encode selection |
| `<leader>uu` | `UrlDecode` | URL decode selection |
| `<leader>ug` | `UuidGenerate` | Insert UUID at cursor (normal mode) |
| `<leader>ur` | `RaysoGenerate` | Generate ray.so snippet URL |
| `<leader>uR` | `RaysoWithOptions` | Generate ray.so URL with custom theme/title |
| `<leader>ut` | `UtilsPicker` | Open Telescope utils picker |
| `<leader>uJ` | `JwtDecode` | Decode JWT token and show details |
| `<leader>us` | `TimestampConvert` | Convert between timestamp and date |
| `<leader>uS` | `TimestampInsert` | Insert Unix timestamp (normal mode) |
| `<leader>uc` | `CaseConvert` | Convert text case (camel, snake, etc.) |

### Examples

#### Base64 Encoding

Select text in visual mode and press `<leader>ue`:

```
Before: Hello World
After:  SGVsbG8gV29ybGQ=
```

#### JSON Formatting

Select minified JSON and press `<leader>uj`:

```json
Before: {"name":"John","age":30,"city":"New York"}
After:
{
  "name": "John",
  "age": 30,
  "city": "New York"
}
```

#### UUID Generation

In normal mode, press `<leader>ug` to insert a UUID at cursor:

```
Insert: 550e8400-e29b-41d4-a716-446655440000
```

#### Ray.so Code Sharing

Select code and press `<leader>ur`:

1. A URL is generated and copied to clipboard
2. Choose to:
   - Open in browser automatically
   - Just copy (default)
   - View the URL in a popup

Use `<leader>uR` to customize the theme and title before generating.

#### JWT Decoding

Select a JWT token and press `<leader>uJ`:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

Shows a popup with decoded header, payload, signature, and expiry info.

#### Timestamp Conversion

Select a Unix timestamp and press `<leader>us`:

```
Before: 1704067200
After:  2024-01-01 00:00:00
```

Or select a date to convert to timestamp:

```
Before: 2024-01-01 00:00:00
After:  1704067200
```

Press `<leader>uS` in normal mode to insert the current Unix timestamp.

#### Case Conversion

Select text and press `<leader>uc` to pick a case format:

```
Input: hello_world

Options:
- camelCase: helloWorld
- PascalCase: HelloWorld
- snake_case: hello_world
- SCREAMING_SNAKE: HELLO_WORLD
- kebab-case: hello-world
- Title Case: Hello World
```

#### Telescope Picker

Press `<leader>ut` to open the Telescope utils picker. The picker shows available utilities based on context:

- Utilities requiring a selection are hidden if no text is selected
- Navigate with arrow keys and press Enter to execute

## Modules

The plugin exports modules for programmatic use:

```lua
local utils = require('nvim-utils')

-- Access individual modules
utils.base64.encode(text)
utils.base64.decode(text)
utils.json.format(json_string)
utils.url.encode(text)
utils.url.decode(text)
utils.uuid.generate()
utils.rayso.generate_url(code, options)
utils.jwt.parse(token)
utils.timestamp.to_date(unix_timestamp)
utils.timestamp.to_timestamp(date_string)
utils.case.to_camel(text)
utils.case.to_snake(text)
```

## API Reference

### base64

```lua
base64.encode(data: string): string
base64.decode(data: string): string
base64.encode_selection()  -- Replaces visual selection
base64.decode_selection()  -- Replaces visual selection
```

### json

```lua
json.format(json_str: string): string
json.format_selection()  -- Replaces visual selection with formatted JSON
```

### url

```lua
url.encode(str: string): string
url.decode(str: string): string
url.encode_selection()  -- Replaces visual selection
url.decode_selection()  -- Replaces visual selection
```

### uuid

```lua
uuid.generate(): string  -- Returns a UUID v4 string
uuid.insert_uuid()  -- Inserts UUID at current cursor position
```

### rayso

```lua
rayso.generate_url(code: string, opts?: table): string
-- Options:
-- {
--   title: string,
--   theme: string,  -- vercel, supabase, tailwind, bitmap, noir, ice, sand, forest
--   background: boolean,
--   dark_mode: boolean,
--   padding: number,
--   language: string,  -- 'auto' or specific language
-- }

rayso.generate_from_selection(opts?: table)
rayso.generate_with_options()  -- Interactive theme/title selection
rayso.show_url_popup(url: string)  -- Display URL in a popup window
```

### jwt

```lua
jwt.parse(token: string): table|nil, string|nil
-- Returns { header, payload, signature } or nil with error message

jwt.decode_selection()  -- Shows decoded JWT in a popup
```

### timestamp

```lua
timestamp.to_date(unix_timestamp: number): string
-- Converts Unix timestamp to "YYYY-MM-DD HH:MM:SS"

timestamp.to_timestamp(date_str: string): number|nil, string|nil
-- Parses "YYYY-MM-DD" or "YYYY-MM-DD HH:MM:SS" to Unix timestamp

timestamp.now(): number  -- Returns current Unix timestamp
timestamp.insert_timestamp()  -- Inserts current timestamp at cursor
timestamp.convert_selection()  -- Interactive conversion
```

### case

```lua
case.to_camel(str: string): string    -- "hello_world" -> "helloWorld"
case.to_pascal(str: string): string   -- "hello_world" -> "HelloWorld"
case.to_snake(str: string): string    -- "helloWorld" -> "hello_world"
case.to_screaming(str: string): string -- "helloWorld" -> "HELLO_WORLD"
case.to_kebab(str: string): string    -- "helloWorld" -> "hello-world"
case.to_title(str: string): string    -- "hello_world" -> "Hello World"

case.convert_selection()  -- Interactive picker for case conversion
```

## Error Handling

The plugin provides clear error messages:

- **No selection found**: When attempting a selection-dependent operation without a selection
- **Invalid base64 input**: When decoding invalid base64 data
- **Invalid JSON input**: When formatting invalid JSON
- **Invalid URL encoded input**: When decoding invalid URL encoding

All errors are notified via Neovim's notification system.

## Dependencies

### Required

- Neovim >= 0.8.0

### Optional

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - For the utils picker
- [which-key.nvim](https://github.com/folke/which-key.nvim) - For keybinding help

## Testing

Run tests with [busted](https://olivinelabs.com/busted/):

```bash
busted tests/
```

Tests cover:
- Base64 encoding/decoding edge cases
- URL encoding/decoding
- UUID generation and format validation
- Ray.so URL generation

## Performance

All operations are lightweight and instant:

- Selection-based transforms operate on text in memory
- No external API calls except when opening Ray.so URLs in browser
- JSON validation uses Neovim's built-in `vim.fn.json_decode`

## Troubleshooting

### "Telescope not found, utils picker disabled"

Install [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) if you want to use the picker. Disable it in config if you don't plan to use it:

```lua
require('nvim-utils').setup({
  telescope = { enabled = false }
})
```

### "Cannot detect system to open browser"

Ray.so auto-open only works on macOS, Linux, and Windows. Select "Show URL" or "Just copied" instead.

### JSON formatting fails

Ensure the selected text is valid JSON. The formatter validates input before formatting and will notify if the JSON is malformed.

## Contributing

Contributions are welcome. Please ensure:

- Code follows Lua conventions
- Tests are added for new features
- Configuration changes maintain backward compatibility

## License

See LICENSE file for details.
