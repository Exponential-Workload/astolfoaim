-- Example usage of the API
local API = loadstring(game:HttpGetAsync 'http://127.0.0.1:5500/api.lua')()
API:Cleanup() -- attempt to remove whatever the last instance is | DO NOT RUN THIS AFTER ENABLING THIS INSTANCE.
API.SetState(true, true)
