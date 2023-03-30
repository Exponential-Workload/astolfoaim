# AstolfoAim

See the Client Code [here](./script/), the P2P Proxy [here](./server/) & the website & webui [here](./web/).

## Licensing

AstolfoAim is licensed under the [AGPL-3.0](./COPYING).

## Running a custom build
To run a simple custom build of the API or the Client-UI-Socket, here's all you need to do:

1. Install [NodeJS](https://nodejs.org)
2. Install sirv-cli: `npm i -g sirv-cli` ([using pnpm](https://pnpm.io): `pnpm i -g sirv-cli`)
3. In the main folder (the one with this readme), run `sirv --port 5500 --host` ([VSCode Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) also works)
4. Run the below script:
```lua
getgenv().__astofloaim_show_debug_info = true -- Show debug info
getgenv().__astolfoaim_api             = nil --  No API Overwrite
getgenv().AstolfoAimDomain             = nil --  No API Fetch Overwrite
getgenv().AstolfoAPIDomain             = nil --  No Socket API Overwrite

-- Check for custom socket server running on local:5595
if pcall(game.HttpGetAsync,game,'http://127.0.0.1:5595/') then getgenv().AstolfoAPIDomain='http://127.0.0.1:5595' end
-- Check for custom api server running on local:5500
if pcall(game.HttpGetAsync,game,'http://127.0.0.1:5500/script/api.lua') then getgenv().AstolfoAimDomain='http://127.0.0.1:5500/script' end

-- Get the URL to fetch for the loader
local url = (AstolfoAimDomain and AstolfoAimDomain..'/' or 'https://astolfoaim.femboy.cafe/')..'web-ui.lua'
-- Fetch the script
local script = game:HttpGetAsync(url)
-- Load it
local api = loadstring(script,'wui')('web-ui');
-- interact with api here if you so desire
```

## Running off of a specific commit/branch/fork
```lua
local globalEnv = getgenv();

-- set any of the below; note commit overwrites branch:
--> globalEnv.AstolfoAimBranch = 'branch';
--> globalEnv.AstolfoAimCommit = 'commit';
--> globalEnv.AstolfoAimUsername = 'github-username';

-- load as normal:
import(5311); --> sw loader; load using the loadstring on other execs
```