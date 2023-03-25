<script lang="ts">
  import { dev } from '$app/environment';
  import { asyncAlert, asyncConfirm, asyncPrompt } from '$lib/asyncnotif';
  import Slider from '$lib/Slider/Slider.svelte';
  import { onDestroy, onMount } from 'svelte';
  import { loop_guard } from 'svelte/internal';
  import { fly } from 'svelte/transition';
  import Nl from './Nl.svelte';
  import UiSlider from './UISlider.svelte';
  import type { AvailableTab } from './AvailableTab';
  import Tabs from './Tabs.svelte';
  import TabItem from './TabItem.svelte';
  import Checkbox from '$lib/Checkbox/Checkbox.svelte';
  import Dropdown from '$lib/Dropdown/Dropdown.svelte';

  let connectioncode = '';
  let connected = false;
  let connecting = false;
  let rbxResponded = false;
  let socket: WebSocket | null;
  let notifs: string[] = [];
  let autoConnect =
    typeof localStorage !== 'undefined'
      ? localStorage.getItem('autoconnect')
      : false;

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
  const server = dev
    ? 'localhost:5595'
    : typeof location !== 'undefined'
    ? location.host ?? location.hostname
    : 'aim.femboy.cafe';
  const protocol = dev ? 'http://' : 'https://';
  const connect = () => {
    rbxResponded = false;
    connecting = true;
    const socketLocation = `${
      location.protocol.includes('https') ? 'wss' : 'ws'
    }://${server}/c/${connectioncode}`;
    log('Attempt Connection', socketLocation);
    const ws = new WebSocket(socketLocation);
    if (dev)
      // @ts-ignore
      window.Socket = ws;
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
  type Action =
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
    | 'finaldiv'
    | 'onlytriggerbotwhilermb'
    | 'triggerbotminimumrmbtime'
    | 'deathcheck'
    | 'useHumanoidsShouldDetectPlayersViaFindPlrs'
    | 'humanoidsearch'
    | 'espColour'
    | 'espTransparency'
    | 'espOutlineTransparency'
    | 'espOutlineColour';
  let currentTab: AvailableTab = 'General';
  let hasLoadedTab = false;
  onMount(() => {
    const t = localStorage.getItem('tab');
    if (t) currentTab = t as AvailableTab;
    hasLoadedTab = true;
  });
  $: {
    if (hasLoadedTab) {
      localStorage.setItem('tab', currentTab);
    }
  }
  let profile: Partial<Record<Action, any>> | undefined;
  const actions: Record<Action, (value: any) => string> = {
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
    onlytriggerbotwhilermb: (value: boolean) =>
      `api.onlytriggerbotwhilermb=${value};`,
    triggerbotminimumrmbtime: (value: number) =>
      `api.triggerbotminimumrmbtime=${value};`,
    deathcheck: (value: boolean) => `api.deathcheck=${value};`,
    useHumanoidsShouldDetectPlayersViaFindPlrs: (value: boolean) =>
      `api.useHumanoidsShouldDetectPlayersViaFindPlrs=${value};`,
    humanoidsearch: (value: boolean) => `api.usefindhumanoids=${value};`,
    espColour: (value: Record<'r' | 'g' | 'b', number>) =>
      `api.espColour=Color3.fromRGB(${value.r},${value.g},${value.b});`,
    espTransparency: (value: number) => `api.espTransparency=${value};`,
    espOutlineTransparency: (value: number) =>
      `api.espOutlineTransparency=${value};`,
    espOutlineColour: (value: Record<'r' | 'g' | 'b', number>) =>
      `api.espOutlineColour=Color3.fromRGB(${value.r},${value.g},${value.b});`,
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
    if (!profile) return;
    console.log('pcall:', isUsingPcall);
    let script = '';
    for (const action in actions) {
      const getScript = actions[action as Action];
      const value = profile[action as Action];
      if (typeof value !== 'undefined') {
        const part = `${isUsingPcall ? `pcall` : ''}(function()${getScript(
          value
        )}end)${isUsingPcall ? '' : '()'};
`;
        log('SendRBX Generate', `Add Part for Action ${action}: ${part}`);
        script += part;
      } else
        console.warn(
          `%cSendRBX Generate: %cCould not find profile['${action.replace(
            /'/giu,
            "\\'"
          )}']`,
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
      maxpixelspersecond: 5000,
      maxpixelsperframe: 4000,
      aimTarget: 'Head',
      additionalsmoothing: 0,
      onlytriggerbotwhilermb: true,
      triggerbotminimumrmbtime: 1 / 4,
      deathcheck: true,
      humanoidsearch: false,
      useHumanoidsShouldDetectPlayersViaFindPlrs: false,
      espColour: {
        r: 255,
        g: 20,
        b: 40,
      },
      espTransparency: 0.5,
      espOutlineColour: {
        r: 255,
        g: 255,
        b: 255,
      },
      espOutlineTransparency: 0,
      ...profile,
    };
    const searchResult = baseTargetItems.find(
      (item) => profile?.aimTarget === (item.value ?? item.name)
    );
    targetItem = searchResult ?? {
      name: `${profile?.aimTarget} (Custom)`,
      value: profile?.aimTarget,
    };
    if (searchResult) customTargetItem = undefined;
    else customTargetItem = targetItem;
    setTimeout(sendRbx, 300);
  };
  const unsetProfile = () => {
    profile = undefined;
    profileName = undefined;
    targetItem = {
      name: 'Head',
      value: 'Head',
    };
  };
  const apply = (shouldShowNotif: boolean = true) =>
    setTimeout(() => {
      log('Profiles', `Save & Send Data on Profile ${profileName}`);
      ls.setItem('profile-' + profileName, JSON.stringify(profile));
      sendRbx();
      if (shouldShowNotif) showNotif('Saved & Sent to Roblox');
    }, 10);
  // let hasQueuedChange = false;
  let queueId = 0;
  const changed = () => {
    // if (hasQueuedChange) return;
    // hasQueuedChange = true;
    const ourQueueId = ++queueId;
    setTimeout(() => {
      if (ourQueueId === queueId) {
        apply(false);
        queueId--;
      }
      // hasQueuedChange = false;
    }, 300);
  };
  $: {
    if (connected && autoConnect) {
      rbxResponded = true;
      if (profileList[0]) setProfile(profileList[0]);
    }
  }
  let i: ReturnType<typeof setTimeout>;
  let d = 10000;
  let c = 0;
  const updateCode = async () => {
    if (!connected && !connectioncode) {
      c++;
      const rs = await fetch(
        `${protocol}${server}/get-connection-code?onlyIfExists=true`
      );
      const rst = await rs.text();
      if (rst === '!code!') return;
      else connectioncode = rst;
    }
    i = setTimeout(updateCode, d);
    if (c > 10 && d < 60000) {
      d = d + 1000;
      c = 7;
    }
  };
  onMount(async () => {
    i = setTimeout(updateCode, 10000);
    await updateCode();
    if (autoConnect) {
      if (!connectioncode) connectioncode = '1';
      connect();
    }
  });
  onDestroy(() => {
    clearTimeout(i);
    if (socket) socket.close();
  });
  const baseTargetItems = [
    {
      name: 'Head',
      value: 'Head',
    },
    {
      name: 'Torso (R6)',
      value: 'Torso',
    },
    {
      name: 'UpperTorso (R15)',
      value: 'UpperTorso',
    },
    {
      name: 'LowerTorso (R15)',
      value: 'LowerTorso',
    },
  ];
  let customTargetItem:
    | {
        name: string;
        value: string;
      }
    | undefined = undefined;
  $: targetItems = [
    ...baseTargetItems,
    ...(customTargetItem ? [customTargetItem] : []),
    {
      name: 'Custom',
      value: 'create_new',
    },
  ];
  let targetItem = {
    name: 'Head',
    value: 'Head',
  } as {
    name: string;
    value: string;
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
            <a href="/ui" on:click={() => setProfile(profileName)}
              >{profileName}</a
            >
            <a
              href="/ui"
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
          <Nl />
          <Tabs bind:value={currentTab}>
            <TabItem {currentTab} tab="General">
              <UiSlider
                on:changed={changed}
                bind:value={profile.smoothing}
                max={0.99}
                step={0.01}
                name="Smoothing"
                unit="/1"
              />
            </TabItem>
            <TabItem {currentTab} tab="General">
              <UiSlider
                on:changed={changed}
                bind:value={profile.jitter}
                max={6}
                step={1}
                name="Jitter"
                unit=" Pixels"
              />
            </TabItem>
            <TabItem {currentTab} tab="General">
              <UiSlider
                on:changed={changed}
                bind:value={profile.maxdistance}
                max={4096}
                step={1}
                name="Maximum Distance"
                unit=" Stud{profile.maxdistance === 1 ? '' : 's'}"
              />
              <Nl />
              <label for="" style="margin-bottom: 0.2em;display:block;"
                >Aim Target</label
              >
              <Dropdown
                items={targetItems}
                bind:value={targetItem}
                on:changed={async (e) => {
                  if (e.detail === 'create_new') {
                    const target = await asyncPrompt(
                      'What Aim Target do you want?'
                    );
                    customTargetItem = {
                      name: target + ' (Custom)',
                      value: target,
                    };
                    targetItem = customTargetItem;
                  } else {
                    targetItem = targetItems.find(
                      (item) => (item.value ?? item.name) === e.detail
                    ) ?? {
                      name: e.detail,
                      value: e.detail,
                    };
                  }
                  (profile ?? {}).aimTarget =
                    targetItem.value ?? targetItem.name;
                  changed();
                }}
              />
            </TabItem>
            <TabItem {currentTab} tab="General" hcenter vcenter>
              <Checkbox
                bind:checked={profile.keybindtoggle}
                on:changed={changed}
              >
                Keybind Is Toggle
              </Checkbox>
              <Checkbox bind:checked={profile.wallcheck} on:changed={changed}>
                Wallcheck
              </Checkbox>
              <Checkbox bind:checked={profile.teamed} on:changed={changed}>
                Teamcheck
              </Checkbox>
              <Checkbox
                bind:checked={profile.humanoidsearch}
                on:changed={changed}
              >
                Also Aim at NPCs (BETA)
              </Checkbox>
            </TabItem>
            <TabItem {currentTab} tab="FOV">
              <UiSlider
                on:changed={changed}
                bind:value={profile.fov}
                min={16}
                max={2160}
                step={1}
                name="FOV Radius"
                unit="px"
              />
            </TabItem>
            <TabItem {currentTab} tab="FOV">
              <UiSlider
                on:changed={changed}
                bind:value={profile.circlesides}
                min={3}
                max={128}
                step={1}
                name="Circle Sides"
                unit=" Sides"
              />
            </TabItem>
            <TabItem {currentTab} tab="ESP" vcenter hcenter>
              <Checkbox bind:checked={profile.hlesp} on:changed={changed}>
                Highlight ESP&nbsp;
                <span style="opacity:0.5">- Not OBS-Proof</span>
              </Checkbox>
              <Checkbox bind:checked={profile.legithlesp} on:changed={changed}>
                Legit ESP
              </Checkbox>
            </TabItem>
            <TabItem {currentTab} tab="ESP">
              <label style="margin: 0 0;" for="preview">ESP Colour</label>
              <div
                style="width: calc(100% - 8px); height: 32px; background:rgba({profile
                  .espColour.r},{profile.espColour.g},{profile.espColour.b},{1 -
                  profile.espTransparency});border-radius: 8px;margin: 0 4px;margin-top:4px;border: 2px solid rgba({profile
                  .espOutlineColour.r},{profile.espOutlineColour.g},{profile
                  .espOutlineColour.b},{1 - profile.espOutlineTransparency})"
                id="preview"
              />
              <Nl />
              <UiSlider
                name="ESP Red"
                min={0}
                max={255}
                on:changed={changed}
                bind:value={profile.espColour.r}
              />
              <UiSlider
                name="ESP Green"
                min={0}
                max={255}
                on:changed={changed}
                bind:value={profile.espColour.g}
              />
              <UiSlider
                name="ESP Blue"
                min={0}
                max={255}
                on:changed={changed}
                bind:value={profile.espColour.b}
              />
              <UiSlider
                name="ESP Transparency"
                min={0}
                max={1}
                step={0.01}
                on:changed={changed}
                bind:value={profile.espTransparency}
              />
            </TabItem>
            {#if typeof localStorage !== 'undefined' && localStorage.getItem('showdotesp') === 'true'}
              <TabItem {currentTab} tab="ESP" vcenter hcenter>
                <label for="_" style="margin: 0 0;">Deprecated: DotESP</label>
                <Checkbox bind:checked={profile.esp} on:changed={changed}>
                  Dot ESP&nbsp;
                  <span style="opacity:0.5">- OBS-Proof - LAG</span>
                </Checkbox>
                <Checkbox bind:checked={profile.legitesp} on:changed={changed}
                  >Legit ESP</Checkbox
                >
              </TabItem>
            {/if}
            <TabItem {currentTab} tab="Trigger Bot" hcenter vcenter>
              <Checkbox bind:checked={profile.triggerbot} on:changed={changed}>
                Trigger Bot
              </Checkbox>
              <Checkbox
                bind:checked={profile.onlytriggerbotwhilermb}
                on:changed={changed}
              >
                Limit to while RMB is held
              </Checkbox>
            </TabItem>
            <TabItem {currentTab} tab="Trigger Bot">
              <UiSlider
                on:changed={changed}
                bind:value={profile.triggerbotminimumrmbtime}
                min={0.1}
                max={0.9}
                step={0.01}
                name="Minimum RMB Time"
                unit=" Seconds"
              />
            </TabItem>
            <TabItem {currentTab} tab="Advanced">
              <UiSlider
                on:changed={changed}
                bind:value={profile.refreshcap}
                min={0.01}
                max={0.3}
                step={0.01}
                name="Min. Update Delta"
                unit=" Seconds"
              />
              {#if profile.usemousemove}
                <UiSlider
                  on:changed={changed}
                  bind:value={profile.maxpixelsperframe}
                  min={1}
                  max={4000}
                  step={1}
                  name="Max. Pixels"
                  unit=" Pixel{profile.maxpixelsperframe === 1
                    ? ''
                    : 's'}/Frame"
                />
                <UiSlider
                  on:changed={changed}
                  bind:value={profile.maxpixelspersecond}
                  min={1}
                  max={5000}
                  step={1}
                  name="Max. Pixels"
                  unit=" Pixel{profile.maxpixelsperframe === 1 ? '' : 's'}/Sec"
                />
                <UiSlider
                  on:changed={changed}
                  bind:value={profile.finaldiv}
                  min={0.1}
                  max={5}
                  step={0.1}
                  name="Pixel Divider"
                  unit=""
                />
                <UiSlider
                  on:changed={changed}
                  bind:value={profile.recursionCount}
                  min={0}
                  max={8}
                  step={1}
                  name="Recursion Steps"
                  unit=" Step{profile.recursionCount === 1 ? '' : 's'}"
                />
              {/if}
            </TabItem>
            <TabItem {currentTab} tab="Advanced" vcenter hcenter>
              {#if profile.usemousemove}
                <Checkbox
                  bind:checked={profile.accountforsensitivity}
                  on:changed={changed}
                >
                  Account for Sensitivity
                </Checkbox>
              {/if}
              {#if profile.humanoidsearch}
                <Checkbox
                  bind:checked={profile.useHumanoidsShouldDetectPlayersViaFindPlrs}
                  on:changed={changed}
                >
                  NPC Searcher use findPlrs()
                </Checkbox>
              {/if}
              <Checkbox bind:checked={profile.deathcheck} on:changed={changed}>
                Check if player is dead (BETA)
              </Checkbox>
              <Checkbox
                bind:checked={profile.limitraycasttocircle}
                on:changed={changed}
              >
                Only Raycast in Circle
              </Checkbox>
              <Checkbox
                bind:checked={profile.usemousemove}
                on:changed={changed}
              >
                Use mousemoverel
              </Checkbox>
            </TabItem>
          </Tabs>
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
      padding: 0 10px;
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
