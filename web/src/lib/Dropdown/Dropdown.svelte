<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import {
    ArrowLeft,
    CaretDownFill,
    CaretLeft,
    CaretRight,
    CaretRightFill,
  } from 'svelte-bootstrap-icons';
  const dispatch = createEventDispatcher<{
    changed: string;
  }>();
  type Item =
    | {
        name: string;
        value?: string;
      }
    | {
        name?: string;
        value: string;
      };
  export let items: Item[];
  export let value = items[0] ?? {
    name: 'unknown',
    value: 'unknown',
  };
  export let valueDotValue = value.value ?? (value.name as string);
  $: {
    valueDotValue = value.value ?? (value.name as string);
  }
  export let style = 'width: 100%;';
  let isDropShown: boolean = false;
  const clickHandler = () => (isDropShown = !isDropShown);
  const getClickHandler = (item: Item) => () => {
    value = item;
    isDropShown = false;
  };
  let lastValue: string = '____';
  $: {
    if (valueDotValue !== lastValue) {
      lastValue = valueDotValue;
      dispatch('changed', valueDotValue);
    }
  }
</script>

<div
  class="drop{isDropShown ? ' open' : ''}"
  {style}
  data-value={valueDotValue}
>
  <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
  <div
    class="dropCurrent"
    on:click={clickHandler}
    on:keypress={clickHandler}
    tabindex="0"
  >
    {#if isDropShown}
      <CaretDownFill />
    {:else}
      <CaretRightFill />
    {/if}
    {value.name ?? value.value}
  </div>
  {#if isDropShown}
    <div class="dropOptions">
      {#each items as item}
        <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
        <div
          class="dropOption"
          data-name={item.name}
          data-value={item.value}
          on:click={getClickHandler(item)}
          on:keypress={getClickHandler(item)}
          tabindex="0"
        >
          {(item.name ?? item.value)?.replace(/\./giu, '.​')}
          <!-- ^ replace adds zwsp -->
        </div>
      {/each}
    </div>
  {/if}
</div>

<style lang="scss">
  $r: 8px;
  .drop {
    position: relative;
    background: #fff1;
    border-top-left-radius: $r;
    border-top-right-radius: $r;
    &:not(.open) {
      border-bottom-left-radius: $r;
      border-bottom-right-radius: $r;
    }
    ::selection {
      background: #0000;
    }
    .dropCurrent {
      cursor: pointer;
      padding: 10px 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.2ch;
    }
    .dropOptions {
      position: absolute;
      z-index: 50;
      top: 100%;
      width: 100%;
      min-height: 100%;
      left: 0;
      backdrop-filter: blur(32px);
      padding-top: 10px;
      background: #aaa1;
      border-bottom-left-radius: $r;
      border-bottom-right-radius: $r;
      display: flex;
      flex-direction: column;
      align-items: center;
      max-height: 140px;
      overflow-y: auto;
      .dropOption {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
      }
      .dropOption {
        padding: 10px 0;
        cursor: pointer;
        width: 100%;
        &:first-child {
          padding-top: 0;
        }
      }
    }
  }
</style>
