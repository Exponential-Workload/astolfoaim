<script lang="ts">
  import Slider from '$lib/Slider/Slider.svelte';
  import { createEventDispatcher } from 'svelte';

  export let value: number = 1;
  export let min: number = 0;
  export let max: number = 100;
  export let step: number = 1;
  export let name: string = 'No Name';
  export let unit: string = '';

  const dispatch = createEventDispatcher<{
    changed: number;
  }>();
  let _lastVal = value;
  $: {
    if (value === null) value = _lastVal;
    else _lastVal = value;
  }
</script>

<div
  class="trolSlider"
  data-value={value}
  data-min={min}
  data-max={max}
  data-step={step}
  data-name={name}
  data-unit={unit}
>
  <div class="label">
    <label for={name}>
      {name}
      <span style="opacity:0.7">
        <input
          inputmode="numeric"
          bind:value
          style="appearance: none;width:{value.toString()
            .length}ch;text-align:center;outline:none;"
          on:change={() => {
            dispatch('changed', value);
          }}
          on:keyup={() => {
            dispatch('changed', value);
          }}
        /><span class="unit">{unit}</span>
      </span>
    </label>
  </div>
  <div style="cursor: pointer;">
    <Slider
      bind:value
      bind:min
      bind:max
      bind:step
      bind:id={name}
      on:changed={(e) => dispatch('changed', e.detail)}
    />
  </div>
</div>

<style lang="scss">
  .label {
    margin-bottom: 0.1em;
    .unit {
      font-size: 0.9em;
    }
  }
</style>
