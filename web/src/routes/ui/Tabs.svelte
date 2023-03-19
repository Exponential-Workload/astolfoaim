<script lang="ts">
  import Dropdown from '$lib/Dropdown/Dropdown.svelte';
  import { type AvailableTab, Tabs } from './AvailableTab';
  import autoAnimate from '@formkit/auto-animate';
  import Nl from './Nl.svelte';
  let currentTab: {
    name?: string;
    value: string;
  } = {
    name: Tabs[0],
    value: Tabs[0],
  };
  export let value: AvailableTab = 'FOV';
</script>

<Dropdown
  items={Tabs.map((v) => ({
    name: v,
    value: v,
  }))}
  bind:value={currentTab}
  bind:valueDotValue={value}
/>
<Nl />
<div use:autoAnimate>
  <slot />
</div>
