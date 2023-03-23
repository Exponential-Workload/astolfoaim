<script lang="ts">
  import { dev } from '$app/environment';
  import { asyncAlert, asyncConfirm, asyncPrompt } from '$lib/asyncnotif';
  import { fly } from 'svelte/transition';

  let connectioncode = '';
  let connected = false;
  let connecting = false;
  let rbxResponded = false;
  let socket: WebSocket | null;
  let notifs: string[] = [];
  const log = (prefix: string, text: string) =>
    console.log(`%c${prefix}: %c${text}`, 'color: #888;', 'color: #aaf');
  const showNotif = (text: string) => {
    log('Show Notification', text);
    notifs = [...notifs, text];
    setTimeout(
      () => {
        notifs.shift();
        notifs = [...notifs];
      },
      notifs.length > 3 ? 2000 : 5000
    );
  };
  const connect = () => {
    rbxResponded = false;
    connecting = true;
    const socketLocation = `${
      location.protocol.includes('https') ? 'wss' : 'ws'
    }://${
      dev ? 'localhost:5595' : location.host ?? location.hostname
    }/c/${connectioncode}`;
    log('Attempt Connection', socketLocation);
    const ws = new WebSocket(socketLocation);
    ws.onmessage = (event) => {
      let { data } = event;
      log('data', data);
      if (data === '+READY+') {
        showNotif('Connection to Server Established Successfully!');
        connected = true;
        socket = ws;
        socket.send("exec:return 'rbxResponse'");
        setTimeout(() => {
          if (!rbxResponded) {
            showNotif('Could not receive a connection from Roblox');
            ws.close();
            disconnectStuff();
          }
        }, 4000);
      } else if (data === 'notif:rbxResponse') {
        rbxResponded = true;
        return;
      }
      if (!data.startsWith('notif:')) return;
      data = data.replace('notif:', '');
      if (!data.startsWith('OK') && data !== '+READY+') showNotif(data);
    };
    const disconnectStuff = () => {
      connected = false;
      rbxResponded = false;
      connecting = false;
      socket = null;
    };
    ws.onerror = () => {
      disconnectStuff();
      try {
        ws.close();
      } catch (error) {}
    };
    ws.onclose = () => {
      showNotif(
        connected ? `Connection Closed` : `Couldn't establish Connection.`
      );
      disconnectStuff();
      try {
        ws.close();
      } catch (error) {}
    };
  };
  setInterval(() => {
    if (socket) socket.send('keepalive');
  }, 20000);
  const ls =
    typeof localStorage !== 'undefined'
      ? localStorage
      : {
          getItem: () => void 0,
          setItem: () => void 0,
          removeItem: () => void 0,
        };
  let profileList: string[] = JSON.parse(ls.getItem('profile-list') ?? '[]');
  let profileName: string | undefined;
  type action =
    | 'fov'
    | 'maxdistance'
    | 'wallcheck'
    | 'triggerbot'
    | 'keybindtoggle'
    | 'esp'
    | 'hlesp'
    | 'circlesides'
    | 'smoothing'
    | 'jitter'
    | 'linkaimbotesp'
    | 'usemousemove'
    | 'teamed'
    | 'recursionCount'
    | 'aimTarget'
    | 'legitesp'
    | 'refreshcap'
    | 'limitraycasttocircle'
    | 'legithlesp'
    | 'additionalsmoothing'
    | 'accountforsensitivity'
    | 'maxpixelspersecond'
    | 'maxpixelsperframe'
    | 'finaldiv';
  let profile: Partial<Record<action, any>> | undefined;
  const actions: Record<action, (value: any) => string> = {
    fov: (value: number) => `api.fov=${value};`,
    maxdistance: (value: number) => `api.maxdistance=${value};`,
    keybindtoggle: (value: boolean) => `api.keybindtoggle=${value};`,
    triggerbot: (value: boolean) => `api.triggerbot=${value};`,
    wallcheck: (value: boolean) => `api.wallcheck=${value};`,
    esp: (value: boolean) =>
      `api.esp=${ls.getItem('showdotesp') === 'true' ? value : 'false'};`,
    hlesp: (value: boolean) => `api.hlesp=${value};`,
    circlesides: (value: number) => `api.circlesides=${value};`,
    jitter: (value: number) => `api.jitter=${value};`,
    smoothing: (value: number) => `api.smoothing=${value};`,
    linkaimbotesp: (value: boolean) => `api.linkaimbotesp=${value};`,
    usemousemove: (value: boolean) => `api.usemousemove=${value};`,
    teamed: (value: boolean) => `api.teamed=${value};`,
    recursionCount: (value: number) => `api.recursionCount=${value};`,
    aimTarget: (value: string) => `api.aimTarget='${value}';`,
    legitesp: (value: boolean) => `api.legitesp=${value};`,
    legithlesp: (value: boolean) => `api.legithlesp=${value};`,
    refreshcap: (value: number) => `api.refreshcap=${value};`,
    limitraycasttocircle: (value: boolean) =>
      `api.limitraycasttocircle=${value};`,
    additionalsmoothing: (value: number) => `api.__minsmoothing=${value};`,
    accountforsensitivity: (value: boolean) =>
      `api.accountforsensitivity=${value};`,
    maxpixelsperframe: (value: number) => `api.maximumpixelsperframe=${value};`,
    maxpixelspersecond: (value: number) =>
      `api.maximumPixelsPerSecond=${value};`,
    finaldiv: (value: number) => `api.finaldiv=${Number(value)};`,
  };
  const addProfile = async (name?: string | null | void) => {
    name =
      name ?? (await asyncPrompt('Profile Name', undefined, undefined, true));
    log('Profiles', `Create Profile ${name}`);
    if (!name) return;
    profileList = [...profileList, name];
    ls.setItem('profile-list', JSON.stringify(profileList));
  };
  const removeProfile = async (name: string) => {
    log('Profiles', `Delete Profile Prompt ${name}`);
    if (await asyncConfirm('Remove this profile?')) {
      log('Profiles', `Delete Profile ${name}`);
      profileList = profileList.filter((v) => v !== name);
      ls.setItem('profile-list', JSON.stringify(profileList));
      ls.removeItem('profile-' + name);
    }
  };
  const sendRbx = () => {
    const isUsingPcall =
      typeof localStorage === 'undefined' ||
      localStorage.getItem('avoidpcall') !== 'true';
    console.log('pcall:', isUsingPcall);
    let script = '';
    for (const action in actions) {
      const getScript = actions[action as action];
      const value = document.querySelector(
        `[data-action="${action}"]`
      ) as HTMLInputElement;
      if (value) {
        const part = `--[[${action}]]${
          isUsingPcall ? `pcall` : ''
        }(function()${getScript(
          value.type === 'checkbox' ? value.checked : value.value
        )}end)${isUsingPcall ? '' : '()'};
`;
        log('SendRBX Generate', `Add Part for Action ${action}: ${part}`);
        script += part;
      } else
        console.warn(
          `%cSendRBX Generate: %cCould not find data-action=${action}`,
          'color: #d7b600;',
          'color: inherit;'
        );
    }
    script += `
return 'Settings Applied!';`;
    log(
      'SendRBX Send',
      `Send Script:
${script}`
    );
    socket?.send('exec:' + script);
  };
  const setProfile = (name: string) => {
    socket?.send(
      "exec:if rconsolehide or rconsoledestroy then (rconsolehide or rconsoledestroy)() end; return 'OK';"
    );
    socket?.send(
      "exec:if syn and syn.websocket then return 'Warning: (likely) Synapse 2.0 Detected. Some Behaviour may not work as expected.';else return 'OK';end;"
    );
    log('Profiles', `Set Profile to ${name}`);
    profileName = name;
    try {
      profile = JSON.parse(ls.getItem('profile-' + name) ?? '[]');
    } catch (error) {
      profile = {};
    }
    profile = {
      fov: 180,
      maxdistance: 512,
      wallcheck: false,
      triggerbot: true,
      keybindtoggle: true,
      circlesides: 42,
      esp: false,
      hlesp: false,
      linkaimbotesp: false,
      jitter: 0,
      smoothing: 0.1,
      teamed: true,
      usemousemove: true,
      recursionCount: 0,
      legitesp: false,
      legithlesp: false,
      refreshcap: 0.02,
      limitraycasttocircle: false,
      accountforsensitivity: true,
      finaldiv: 2,
      maxpixelspersecond: 2000,
      maxpixelsperframe: 2000,
      aimTarget: 'Head',
      additionalsmoothing: 0,
      ...profile,
    };
    setTimeout(sendRbx, 500);
  };
  const unsetProfile = () => {
    profile = undefined;
    profileName = undefined;
  };
  const apply = (shouldShowNotif: boolean = true) => {
    log('Profiles', `Save & Send Data on Profile ${profileName}`);
    ls.setItem('profile-' + profileName, JSON.stringify(profile));
    sendRbx();
    if (shouldShowNotif) showNotif('Saved & Sent to Roblox');
  };
  let hasQueuedChange = false;
  const changed = () => {
    if (hasQueuedChange) return;
    hasQueuedChange = true;
    setTimeout(() => {
      apply(false);
      hasQueuedChange = false;
    }, 500);
  };
</script>

<svelte:head>
  <title>AstolfoAim Web UI</title>
  <link rel="stylesheet" href="https://ministyles.astolfo.gay/all.css" />
  <meta name="og:title" content="AstolfoAim Web UI" />
  <meta property="og:type" content="website" />
  <meta
    name="description"
    content="Web Interface for https://aim.femboy.cafe/"
  />
  <meta
    name="og:description"
    content="Web Interface for https://aim.femboy.cafe/"
  />
  <meta
    name="og:image"
    content="https://cdn.discordapp.com/attachments/1055532494180589578/1055919490002583682/0F1B7A10-CF58-4C4C-B963-D051E07298A3.jpg"
  />
  <meta name="theme-color" content="#fc2cd9" />
  <meta name="twitter:card" content="summary_large_image" />
</svelte:head>

<main>
  <section>
    <div>
      <noscript>heyyyyy this site wont work without js</noscript>
      {#if !connected}
        <h1>AstolfoAim WebUI</h1>
        <p style="width: 100%; margin-bottom: 0.5em; max-width: 95vw;">
          <input
            type="text"
            name="data"
            id="data"
            placeholder="Please enter your Connection Code here."
            style="width: 100%; text-align: center; font-size: 0.9em"
            bind:value={connectioncode}
          />
        </p>
        <button
          on:click={connect}
          disabled={connectioncode.length === 0}
          style="font-size: 1.05rem; color: #dedede; background: #9b7fc4;"
          class="button effect"
        >
          Connect
        </button>
      {:else if !rbxResponded}
        <h1>Waiting on Roblox</h1>
        <p style="width: 100%; margin-bottom: 0.5em; max-width: 95vw;">
          Attempting to get a response from Roblox...
        </p>
        <button
          on:click={() => (rbxResponded = true)}
          disabled={connectioncode.length === 0}
          style="font-size: 1.05rem; color: #dedede; background: #1e2030;"
          class="button effect"
        >
          Skip
        </button>
      {:else if !profile}
        <h1>Select a Profile</h1>
        <span style="display: block;height: 0.5em" />
        <p style="font-size: 1.2em; margin: 0 0;">
          {#each profileList as profileName}
            <a href="/ui-old/" on:click={() => setProfile(profileName)}
              >{profileName}</a
            >
            <a
              href="/ui-old/"
              on:click={() => removeProfile(profileName)}
              style="color: #faa; text-decoration: none">🗑</a
            ><br />
          {/each}
          <span style="display: block;height: 0.5em" />
          <button
            on:click={() => addProfile()}
            class="button effect"
            style="font-size: 1.05rem; background: #9b7fc4;">New Profile</button
          >
        </p>
      {:else}
        <h1>Profile {profileName}</h1>
        <div style="font-size: 1.2em">
          <br />
          <label for="fov">FOV</label>
          <input
            type="number"
            name="fov"
            id="fov"
            data-action="fov"
            min="5"
            bind:value={profile.fov}
            on:change={changed}
          />
          <br />
          <label for="maxdistance">Max Dist</label>
          <input
            type="number"
            name="maxdistance"
            id="maxdistance"
            data-action="maxdistance"
            min="0"
            bind:value={profile.maxdistance}
            on:change={changed}
          />
          <div style={`display:${profile.usemousemove ? 'contents' : 'none'}`}>
            <br />
            <label for="finaldiv">
              Div
              <!-- svelte-ignore a11y-invalid-attribute -->
              <a
                href="javascript:void 0;"
                on:keypress={(e) =>
                  asyncAlert(
                    e.currentTarget.getAttribute('data-helptext') ??
                      'oops an error occurred'
                  )}
                on:click={(e) =>
                  asyncAlert(
                    e.currentTarget.getAttribute('data-helptext') ??
                      'oops an error occurred'
                  )}
                data-helptext={`Amount to divide the final pixel count by.<br/>
If you get a lot of weird shaking/apparent additional jitter, increasing this may fix it.<br/>
Try increasing this if your pointer (NOT CIRCLE) seems a bit more delayed than it should be.`}
              >
                (help)
              </a>
            </label>
            <input
              type="number"
              name="finaldiv"
              id="finaldiv"
              data-action="finaldiv"
              min="0.01"
              bind:value={profile.finaldiv}
              on:change={changed}
            />
          </div>
          <br />
          <label for="wallcheck">Wall Check</label>
          <input
            type="checkbox"
            name="wallcheck"
            id="wallcheck"
            data-action="wallcheck"
            bind:checked={profile.wallcheck}
            on:change={changed}
          />
          <span class="check">&ZeroWidthSpace;</span>
          <br />
          <label for="triggerbot">Triggerbot</label>
          <input
            type="checkbox"
            name="triggerbot"
            id="triggerbot"
            data-action="triggerbot"
            bind:checked={profile.triggerbot}
            on:change={changed}
          />
          <span class="check">&ZeroWidthSpace;</span>
          <br />
          <label for="keybindtoggle">Keybind Toggle</label>
          <input
            type="checkbox"
            name="keybindtoggle"
            id="keybindtoggle"
            data-action="keybindtoggle"
            bind:checked={profile.keybindtoggle}
            on:change={changed}
          />
          <span class="check">&ZeroWidthSpace;</span>
          <br />
          <label for="accountforsensitivity">Account for Sensitivity</label>
          <input
            type="checkbox"
            name="accountforsensitivity"
            id="accountforsensitivity"
            data-action="accountforsensitivity"
            bind:checked={profile.accountforsensitivity}
            on:change={changed}
          />
          <span class="check">&ZeroWidthSpace;</span>
          <br />
          <div
            style={`display: ${
              typeof localStorage !== 'undefined' &&
              localStorage.getItem('showdotesp') === 'true'
                ? 'inline'
                : 'none'
            }`}
          >
            <label for="esp">Dot ESP (CAN LAG)</label>
            <input
              type="checkbox"
              name="esp"
              id="esp"
              data-action="esp"
              bind:checked={profile.esp}
              on:change={changed}
            />
            <span class="check">&ZeroWidthSpace;</span>
            <br />
            <label for="linkaimbotesp">Link Aimbot &amp; Dot ESP</label>
            <input
              type="checkbox"
              name="linkaimbotesp"
              id="linkaimbotesp"
              data-action="linkaimbotesp"
              bind:checked={profile.linkaimbotesp}
              on:change={changed}
            />
            <span class="check">&ZeroWidthSpace;</span>
            <div style={`display: ${profile.esp ? 'inline' : 'none'};`}>
              <br />
              <label for="legitesp">Legit ESP</label>
              <input
                type="checkbox"
                name="legitesp"
                id="legitesp"
                data-action="legitesp"
                bind:checked={profile.legitesp}
                on:change={changed}
              />
              <span class="check">&ZeroWidthSpace;</span>
            </div>
            <br />
          </div>
          <label for="hlesp">(NOT STREAMPROOF) Highlight ESP</label>
          <input
            type="checkbox"
            name="hlesp"
            id="hlesp"
            data-action="hlesp"
            bind:checked={profile.hlesp}
            on:change={changed}
          />
          <span class="check">&ZeroWidthSpace;</span>
          <div style={`display: ${profile.hlesp ? 'inline' : 'none'};`}>
            <br />
            <label for="legithlesp">Legit ESP</label>
            <input
              type="checkbox"
              name="legithlesp"
              id="legithlesp"
              data-action="legithlesp"
              bind:checked={profile.legithlesp}
              on:change={changed}
            />
            <span class="check">&ZeroWidthSpace;</span>
          </div>
          <br />
          <label for="limitraycasttocircle">Only Raycast within Circle</label>
          <input
            type="checkbox"
            name="limitraycasttocircle"
            id="limitraycasttocircle"
            data-action="limitraycasttocircle"
            bind:checked={profile.limitraycasttocircle}
            on:change={changed}
          />
          <span class="check">&ZeroWidthSpace;</span>
          <br />
          <label for="usemousemove"
            >Use mousemoverel (if off, uses camera)</label
          >
          <input
            type="checkbox"
            name="usemousemove"
            id="usemousemove"
            data-action="usemousemove"
            bind:checked={profile.usemousemove}
            on:change={changed}
          />
          <span class="check">&ZeroWidthSpace;</span>
          <br />
          <label for="teamed">Team Check</label>
          <input
            type="checkbox"
            name="teamed"
            id="teamed"
            data-action="teamed"
            bind:checked={profile.teamed}
            on:change={changed}
          />
          <span class="check">&ZeroWidthSpace;</span>
          <br />
          <label for="aimTarget">Aim Part</label>
          <select
            name="aimTarget"
            id="aimTarget"
            data-action="aimTarget"
            style="padding: 8px 8px; background: #1e2030; border: none; color: #dedede;"
            bind:value={profile.aimTarget}
            on:change={(self) => {
              // const target = self.currentTarget;
              if (profile?.aimTarget === 'customvalue')
                asyncPrompt(
                  'What instance name do you wish to use? (CASE SENSITIVIE)',
                  undefined,
                  'Confirm',
                  'Cancel'
                ).then((val) => {
                  if (val) {
                    // @ts-ignore
                    profile.aimTarget = val;
                    // target.value = val;
                    changed();
                  }
                });
              else changed();
            }}
          >
            <option value="Head">Head</option>
            <option value="Torso">Torso (R6)</option>
            <option value="UpperTorso">UpperTorso (R15)</option>
            <option value="LowerTorso">LowerTorso (R15)</option>
            {#if !['head', 'torso', 'uppertorso', 'lowertorso', 'customvalue'].includes((profile.aimTarget ?? 'Head').toLowerCase())}
              <option value={profile.aimTarget}
                >{profile.aimTarget} (Custom)</option
              >
            {/if}
            <option value="customvalue">Custom Value</option>
          </select>
          <br />
          <hr />
          <label for="smoothing">Smoothing</label><br />
          <input
            type="range"
            name="smoothing"
            id="smoothing"
            data-action="smoothing"
            min="0"
            max="0.95"
            step="0.01"
            bind:value={profile.smoothing}
            on:change={changed}
          />
          <br />
          <small class="infothing">{profile.smoothing}</small>
          <div
            style={`display: ${
              profile.usemousemove ? 'block;opacity:1' : 'none;opacity:0'
            };transition:1s`}
          >
            <label
              for="recursionCount"
              title="Repeats the mousemove multiple times per frame, as to allow more accurate movement tracking when 0 smoothing overshoots. Experiment with this value a bit if necessary."
              >(Blatant + BETA) Recursion Steps</label
            ><br />
            <input
              type="range"
              name="recursionCount"
              id="recursionCount"
              data-action="recursionCount"
              min="0"
              max="8"
              step="1"
              bind:value={profile.recursionCount}
              on:change={changed}
            />
            <br />
            <small class="infothing"
              >{profile.recursionCount} recursion{profile.recursionCount === 1
                ? ''
                : 's'}</small
            >
            <label for="jitter">Jitter</label><br />
            <input
              type="range"
              name="jitter"
              id="jitter"
              data-action="jitter"
              min="0"
              max="25"
              step="0.5"
              bind:value={profile.jitter}
              on:change={changed}
            />
            <br />
            <small class="infothing"
              >{profile.jitter} pixel{profile.jitter === 1 ? '' : 's'}</small
            >
            <label for="maxpixelsperframe">Maximum Pixels per Frame</label><br
            />
            <input
              type="range"
              name="maxpixelsperframe"
              id="maxpixelsperframe"
              data-action="maxpixelsperframe"
              min="1"
              max={Math.max(profile.fov + 16, 512)}
              step="1"
              bind:value={profile.maxpixelsperframe}
              on:change={changed}
            />
            <br />
            <small class="infothing"
              >{profile.maxpixelsperframe} pixel{profile.maxpixelsperframe === 1
                ? ''
                : 's'}</small
            >
            <label for="maxpixelspersecond">Maximum Pixels per Second</label><br
            />
            <input
              type="range"
              name="maxpixelspersecond"
              id="maxpixelspersecond"
              data-action="maxpixelspersecond"
              min="1"
              max="5000"
              step="1"
              bind:value={profile.maxpixelspersecond}
              on:change={changed}
            />
            <br />
            <small class="infothing"
              >{profile.maxpixelspersecond} pixel{profile.maxpixelspersecond ===
              1
                ? ''
                : 's'}</small
            >
          </div>
          <label for="refreshcap"
            >Minimum Update Time (lower=more responsive but more calculations)</label
          ><br />
          <input
            type="range"
            name="refreshcap"
            id="refreshcap"
            data-action="refreshcap"
            min="0.004"
            max="0.1"
            step="0.004"
            bind:value={profile.refreshcap}
            on:change={changed}
          />
          <br />
          <small class="infothing">
            {profile.refreshcap}s
          </small>
          <br />
          <button
            on:click={() => apply(true)}
            style="background: #886fab;"
            class="button effect"
          >
            Save & Apply
          </button>
          <button
            on:click={() => {
              socket?.send(`exec:local connection, isDone;
connection = game:GetService('UserInputService').InputBegan:Connect(function(inputobject,gameProcessed)
  local keycode = inputobject.KeyCode;
  if keycode ~= Enum.KeyCode.Unknown then
    api.keybind = keycode;
    connection:Disconnect();
    isDone = keycode;
  end;
end);
repeat task.wait() until isDone; return 'Assigned to: '..tostring(isDone);
`);
              showNotif(
                "Press the desired key on your PC.\nIt won't be saved as of now.\nLimited to a single Key."
              );
            }}
            style="background: #1e2030;"
            class="button"
          >
            Change Keybind
          </button>
          <button
            on:click={unsetProfile}
            style="background: #1e2030;"
            class="button"
          >
            Change Profile
          </button>
          <br />
          <span style="display: block;height: 0.5em" />
          <small
            ><span style="color: #fff4;"
              >Need an OBS-proof ESP? <a
                href="https://github.com/ic3w0lf22/Unnamed-ESP"
                target="_blank"
                rel="noopener noreferrer">Try Unnamed ESP</a
              ><br />
              (See
              <a
                href="https://github.com/ic3w0lf22/Unnamed-ESP/issues/25#issuecomment-1356897560"
                target="_blank"
                rel="noopener noreferrer">this workaround</a
              > for Phantom Forces)
            </span>
            <br />
            <br />
            <a
              href="https://i-just-have-a-good.gaming-c.hair/⁠‌⁠⁠​​​‍‌‌⁠‍⁠​⁠​⁠‍‍‌‍⁠‍⁠​​‌‍‌‍​"
              target="_blank"
              rel="noopener noreferrer">Config Option Meaning</a
            >
          </small>
        </div>
      {/if}
    </div>
  </section>
</main>

<div class="notifContainer">
  {#each notifs as notif}
    <div
      class="notif"
      in:fly={{
        y: 50,
        duration: 1000,
      }}
      out:fly={{
        y: -50,
        duration: 1000,
      }}
    >
      <p>{notif}</p>
    </div>
  {/each}
</div>

<style lang="scss">
  @use '../../lib/btn.scss';
  // https://github.com/YieldingFluxus/fluxuswebsite/blob/main/src/Routes/index.scss
  @mixin title($a: rgb(141, 115, 176), $b: #c7a0f66b) {
    // webkit
    -webkit-text-fill-color: transparent;
    -webkit-background-clip: text;
    // colour
    text-decoration-color: currentcolor;
    background-image: linear-gradient(180deg, $a, $b, $a);
    background-clip: text;
    text-decoration: none;
  }
  @keyframes animtitle {
    0% {
      background-position: 0 0;
    }
    50% {
      background-position: 100% 100%;
    }
    100% {
      background-position: 200% 200%;
    }
  }
  input[type='number'] {
    appearance: textfield;
  }
  input[type='text']:focus,
  input[type='number']:focus {
    outline: none;
    border-right: 2px solid #fff;
    margin-right: -2px;
  }
  .notifContainer {
    position: fixed;
    pointer-events: none;
    bottom: 25px;
    right: 25px;
    @media screen and (max-width: 500px) {
      right: 50vw;
      transform: translate(50%, 0);
      text-align: center;
    }
    .notif {
      padding: 8px 8px;
      min-width: 128px;
      background: #1e2030aa;
      pointer-events: none;
      border-radius: 16px;
      display: flex;
      justify-content: center;
      align-items: center;
      text-align: center;
      margin-top: 6px;
    }
  }
  .infothing {
    margin-top: -0.5em;
    padding-bottom: 0.25em;
    display: block;
    color: #dededeaa;
  }
  section:not(.nodefault) {
    width: 100vw;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    & > div {
      overflow-y: auto;
      overflow-x: hidden;
      max-height: calc(100vh - 20px);
    }
    h1 {
      @include title;
      background-size: 200% 200%;
      animation-name: animtitle;
      animation-duration: 2s;
      animation-iteration-count: infinite;
      animation-timing-function: linear;
      font-size: 2.5em;
      margin: 0 0;
      font-weight: 700;
    }
    p {
      font-size: 1.2em;
    }
    a {
      color: #7287fd;
    }
  }
</style>
