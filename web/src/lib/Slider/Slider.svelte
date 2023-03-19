<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let min = 1;
  export let max = 100;
  export let value = 1;
  export let step = 1;
  export let id: string = Math.random().toString(16);
  export let valueInterceptor = (value: number) => value;
  let inputRange: HTMLInputElement;

  $: initialValue = value;

  const dispatch = createEventDispatcher<{
    changed: number;
    apply: number;
  }>();

  const bindInputRange = (el: any) => (inputRange = el);
  let mouseIsDown = false;
  $: size = (value - min) / (max - min);
</script>

<input
  type="range"
  {min}
  {max}
  {step}
  {id}
  value={initialValue}
  class="slider {size > 0.5 ? 'radiusBehaviour2' : 'radiusBehaviour1'}"
  style="--sizePercent: {size};"
  on:keypress={() => {
    value = valueInterceptor(inputRange.valueAsNumber);
    dispatch('changed', value);
  }}
  on:change={() => {
    value = valueInterceptor(inputRange.valueAsNumber);
    dispatch('changed', value);
  }}
  on:mousedown={() => {
    mouseIsDown = true;
  }}
  on:mouseup={() => {
    mouseIsDown = false;
  }}
  on:mousemove={() => {
    if (mouseIsDown) {
      value = valueInterceptor(inputRange.valueAsNumber);
      dispatch('changed', value);
    }
  }}
  use:bindInputRange
/>

<style lang="scss">
  @use './Slider.scss';
</style>
