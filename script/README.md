# AstolfoAim Script
API & Web-UI for AstolfoAim (& [a tiny example](./example.lua) for using the api on stock settings)

## Building
There's no build process for the script.

## Developing
Start a static server ([sirv-cli](https://npm.im/sirv-cli) | [Live Server VSC](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer)) on port 5500 in the parent directory, then, run this script:
```lua
getgenv().__astofloaim_show_debug_info = true
getgenv().__astolfoaim_api             = nil
getgenv().AstolfoAimDomain             = nil
getgenv().AstolfoAPIDomain             = nil

if pcall(game.HttpGetAsync,game,'http://127.0.0.1:5595/') then getgenv().AstolfoAPIDomain='http://127.0.0.1:5595' end
if pcall(game.HttpGetAsync,game,'http://127.0.0.1:5500/script/api.lua') then getgenv().AstolfoAimDomain='http://127.0.0.1:5500/script' end
local url = (AstolfoAimDomain and AstolfoAimDomain..'/' or 'https://astolfoaim.femboy.cafe/')..'web-ui.lua'
local script = game:HttpGetAsync(url)
local api = loadstring(script,'wui')('web-ui');
-- interact with api here if you so desire
```

This will attempt to use the local build of AstolfoAim, alongside, if available, a [local socket server](../server/).