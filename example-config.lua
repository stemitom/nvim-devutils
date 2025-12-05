-- Example Neovim configuration for nvim-devutils

-- Basic setup with defaults
require('nvim-utils').setup()

-- Or with custom configuration:
-- require('nvim-utils').setup({
--   mappings = {
--     base64_encode = "<leader>ue",
--     base64_decode = "<leader>ud",
--     json_format = "<leader>uj",
--     url_encode = "<leader>uU",
--     url_decode = "<leader>uu",
--     uuid_generate = "<leader>ug",
--     rayso_generate = "<leader>ur",
--     rayso_options = "<leader>uR",
--     telescope_utils = "<leader>ut",
--   },
--   telescope = {
--     enabled = true,
--   }
-- })

-- Disable specific mappings:
-- require('nvim-utils').setup({
--   mappings = {
--     rayso_options = false,  -- Don't bind this
--   }
-- })

-- Disable telescope integration:
-- require('nvim-utils').setup({
--   telescope = {
--     enabled = false,
--   }
-- })

-- Programmatic usage example:
-- local nvim_utils = require('nvim-utils')
--
-- -- Encode a string to base64
-- local encoded = nvim_utils.base64.encode("Hello World")
-- print(encoded)  -- SGVsbG8gV29ybGQ=
--
-- -- Generate a UUID
-- local uuid = nvim_utils.uuid.generate()
-- print(uuid)  -- e.g., 550e8400-e29b-41d4-a716-446655440000
--
-- -- Generate a ray.so URL
-- local url = nvim_utils.rayso.generate_url("console.log('hello')", {
--   title = "My Code",
--   theme = "supabase",
-- })
-- print(url)
