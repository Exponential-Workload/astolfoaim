<svelte:head>
  <title>AstolfoAim - Free Roblox Aimbot Script</title>
  <link rel="stylesheet" href="https://ministyles.astolfo.gay/all.css" />
  <meta name="og:title" content="AstolfoAim - Free Roblox Aimbot Script" />
  <meta property="og:type" content="website" />
  <meta
    name="description"
    content="Improve your Roblox Aim.
No strings attached."
  />
  <meta
    name="og:description"
    content="Improve your Roblox Aim.
No strings attached."
  />
  <meta
    name="og:image"
    content="https://cdn.discordapp.com/attachments/1055251018536988783/1055254618701049956/69c8ae64c9874319994759bbb0822b5f.png"
  />
  <meta name="theme-color" content="#fc2cd9" />
  <meta name="twitter:card" content="summary_large_image" />
</svelte:head>

<main>
  <section>
    <div>
      <h1>AstolfoAim</h1>
      <p>Customizable Aimbot that just works.<br />No strings attached.</p>
      <p style="color: #fff4;">
        //
        <a href="/join">Discord</a> //
        <a href="/get">Get</a> //
        <a href="/ui">Web UI</a> //
        <br />
        //
        <a href="/links">Links</a> //
        <span class="nosmol"
          ><a href="https://nexuspipe.com">NexusPIPE</a> //</span
        >
        <a href="/media">Media</a> //
      </p>
      <a href="https://nexuspipe.com?utm_source=astolfoaim"
        ><img
          class="nobig"
          style="position:fixed;bottom:0;left:50vw;transform:translate(-50%,0);max-width: 50vw;max-height: 30vh;"
          src="https://cdn.discordapp.com/attachments/1068827149848559637/1086683614344921088/pipe.png"
          alt="buy nexuspipe now for high-quality L3/L7 DDOS protection - click here"
        /></a
      >
    </div>
  </section>
</main>

<style lang="scss">
  @media screen and (min-height: 550px) {
    .nosmol {
      display: none;
    }
  }
  @media screen and (max-height: 550px) {
    .nobig {
      display: none;
    }
  }
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
  }
</style>
