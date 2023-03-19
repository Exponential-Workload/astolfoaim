<script lang="ts">
  import { dev } from '$app/environment';

  let isReal = true;
  if (
    !dev &&
    typeof location !== 'undefined' &&
    !(location.host ?? location.hostname).includes('femboy.cafe') &&
    !(location.host ?? location.hostname).includes('astolfo.gay')
  )
    isReal = false;
  const realLink = atob('aHR0cHM6Ly9haW0uZmVtYm95LmNhZmUv');
</script>

{#if !isReal}
  <main class="scamwarning">
    <div>
      <h1>Warning</h1>
      <p>
        Hey, this seems to be a fake site simply proxying/copying the content of
        the AstolfoAim site.<br />Note we cannot control the contents of this
        fake site.<br />
        This fake site may contain malicious stuff. We STRONGLY recommend going to
        the real site.<br />
        Do you want to go to the real site?<br />
      </p>
      <p>
        <a
          href={realLink}
          style="color:#fff;padding:10px 10px;text-decoration:none;margin:4px 4px;background:#00aa00;"
          >Go to the real site</a
        >
      </p>
      <p>
        <a
          href="/"
          style="color:#ff0000"
          on:click={() =>
            confirm('Are you 10000% sure you trust this proxy?')
              ? confirm('Do you wish to go to the real site?')
                ? location.replace(realLink)
                : confirm('Final Warning: Are you COMPLETELY sure?')
                ? (() => {
                    alert(
                      "Alright, you're the boss.\nReload to see this page again."
                    );
                    isReal = true;
                  })()
                : location.replace(realLink)
              : location.replace(realLink)}
          >I know what I'm doing, I trust this potentially malicious proxy</a
        >
      </p>
    </div>
  </main>
{:else}
  <slot />
{/if}

<style lang="scss">
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
  main.scamwarning {
    text-align: center;
    font-family: Inter, sans-serif;
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #24273a;
    color: #cad3f5;
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
  }
  :global(*)::-webkit-scrollbar {
    width: 6px; /* width of the entire scrollbar */
  }

  :global(*)::-webkit-scrollbar-track {
    background: #24273a33; /* color of the tracking area */
    border-radius: 20px;
  }

  :global(*)::-webkit-scrollbar-thumb {
    background-color: #5f4d77; /* color of the scroll thumb */
    border-radius: 20px; /* roundness of the scroll thumb */
  }
</style>
