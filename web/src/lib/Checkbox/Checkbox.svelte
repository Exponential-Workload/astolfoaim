<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let checked = false;
  export let padding = '12px 0';
  const dispatch = createEventDispatcher<{
    changed: boolean;
  }>();
</script>

<div style={`padding: ${padding}`}>
  <label class="container">
    <slot />
    <input
      type="checkbox"
      bind:checked
      on:change={() => dispatch('changed', checked)}
    />
    <span class="checkmark" />
  </label>
</div>

<style lang="scss">
  @use './Checkbox.scss';
</style>
