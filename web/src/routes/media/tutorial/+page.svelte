<svelte:head>
  <title>AstolfoAim Tutorial</title>
  <link rel="stylesheet" href="https://ministyles.astolfo.gay/all.css" />
  <meta name="og:title" content="AstolfoAim Tutorial" />
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
    content="https://i.ytimg.com/vi/uX5G52-EpB8/hqdefault.jpg"
  />
  <meta name="theme-color" content="#fc2cd9" />
  <meta name="twitter:card" content="summary_large_image" />
</svelte:head>

<main>
  <section>
    <div>
      <h1>AstolfoAim Tutorial</h1>
      <br />
      <iframe
        width="1920"
        height="786"
        src="https://www.youtube.com/embed/uX5G52-EpB8"
        title="AstolfoAim Tutorial"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen
      />
      <p style="color: #fff4;">
        //
        <a href="/media/tutorial-old">Old Tutorial</a> //
        <a href="..">Back</a>
        //
      </p>
    </div>
  </section>
</main>

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
  section:not(.nodefault) {
    iframe {
      max-width: 75vw;
      max-height: 50vh;
    }
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
