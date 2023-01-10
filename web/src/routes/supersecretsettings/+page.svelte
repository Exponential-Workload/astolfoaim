<script lang="ts">
  let isUsingDotEsp =
    typeof localStorage !== 'undefined' &&
    localStorage.getItem('showdotesp') === 'true';
  const setDotEsp = (newValue: boolean) => {
    localStorage.setItem('showdotesp', newValue.toString());
    isUsingDotEsp = newValue;
  };
  let isUsingPcall =
    typeof localStorage === 'undefined' ||
    localStorage.getItem('avoidpcall') !== 'true';
  const setPcall = (newValue: boolean) => {
    localStorage.setItem('avoidpcall', (!newValue).toString());
    isUsingPcall = newValue;
  };
</script>

<svelte:head>
  <title>Super Secret AstolfoAim</title>
  <meta name="og:title" content="Super Secret AstolfoAim" />
  <meta property="og:type" content="website" />
  <meta
    name="description"
    content="shhhhh this secret page has ui settings you can change!"
  />
  <meta
    name="og:description"
    content="shhhhh this secret page has ui settings you can change!"
  />
  <meta
    name="og:image"
    content="https://cdn.discordapp.com/attachments/1055251018536988783/1055254618701049956/69c8ae64c9874319994759bbb0822b5f.png"
  />
  <meta name="theme-color" content="#fc2cd9" />
  <meta name="twitter:card" content="summary_large_image" />
  <link rel="stylesheet" href="https://ministyles.astolfo.gay/all.css" />
</svelte:head>

<main>
  <section>
    <div>
      <h1>Super Secret Settings</h1>
      <p>
        This page allows you to enable secret settings (primarily ones that are
        deprecated, buggy, or in general WIP).<br />USE WITH CAUTION.<br />SOME
        SETTINGS CAN ONLY BE RESET BY RESETTING ALL SITE DATA (INCLUDING
        PROFILES).<br />SOME OF THESE SETTINGS CAN CAUSE YOU TO FLAG IN SOME
        GAMES OR REDUCE STABILITY!
      </p>
      <p style="margin: 3px 3px;">
        <button
          on:click={() => setDotEsp(true)}
          class={`button${isUsingDotEsp ? '' : ' active effect'}`}
          >Enable Dot ESP</button
        >
        <button
          on:click={() => setDotEsp(false)}
          class={`button${isUsingDotEsp ? ' active effect' : ''}`}
          >Disable Dot ESP</button
        >
      </p>
      <p style="margin: 3px 3px;">
        <button
          on:click={() => setPcall(true)}
          class={`button${isUsingPcall ? '' : ' active effect'}`}
          >Enable PCalling Options</button
        >
        <button
          on:click={() => setPcall(false)}
          class={`button${isUsingPcall ? ' active effect' : ''}`}
          >Disable PCalling Options</button
        >
      </p>
    </div>
  </section>
</main>

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
  section:not(.nodefault) {
    width: 100vw;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
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
    button.button.active {
      background: #886fab;
    }
  }
</style>
