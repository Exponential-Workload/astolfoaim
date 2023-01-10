-- Example usage of the API
local API = getgenv().__astolfoaim_api or loadstring(game:HttpGetAsync 'https://astolfoaim.femboy.cafe/', 'apiloader')()
API:Cleanup() -- attempt to remove whatever the last instance is | DO NOT RUN THIS AFTER ENABLING THIS INSTANCE.
API.SetState(true, true)
