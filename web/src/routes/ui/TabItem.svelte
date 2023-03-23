<script lang="ts">
  import type { AvailableTab } from './AvailableTab';
  import Nl from './Nl.svelte';

  export let currentTab: AvailableTab;
  export let tab: AvailableTab;
  export let vcenter = false;
  export let hcenter = false;
  export let noSpacer = false;
  $: flex = vcenter || hcenter;
</script>

{#if tab === currentTab}
  <div
    class="tabItem {flex ? ' flex' : ''}{vcenter ? ' venter' : ''}{hcenter
      ? ' hcenter'
      : ''}"
    data-tab={tab}
  >
    <div>
      <slot />
    </div>
  </div>
  {#if !noSpacer}
    <Nl />
  {/if}
{/if}

<style lang="scss">
  .tabItem {
    &.flex {
      display: flex;
    }
    &.vcenter {
      align-items: center;
    }
    &.hcenter {
      justify-content: center;
    }
  }
</style>
