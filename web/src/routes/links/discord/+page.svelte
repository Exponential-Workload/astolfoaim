<script lang="ts">
  fetch('https://cord.breadhub.cc/INVITE')
    .then((v) => v.text())
    .then((v) => {
      if (typeof document !== 'undefined') document.location.href = v;
    });
</script>

<svelte:head>
  <title>🍞+AstolfoAim Discord</title>
  <link rel="stylesheet" href="https://ministyles.astolfo.gay/all.css" />
  <meta name="og:title" content="🍞+AstolfoAim Discord" />
  <meta property="og:type" content="website" />
  <meta
    name="description"
    content="The discord for 🍞 + https://aim.femboy.cafe"
  />
  <meta
    name="og:description"
    content="The discord for 🍞 + https://aim.femboy.cafe"
  />
  <meta
    name="og:image"
    content="https://cdn.discordapp.com/attachments/927837421008191538/1057471171253256222/BreadHubJoinImage.png"
  />
  <meta name="theme-color" content="#f3ad61" />
  <meta name="twitter:card" content="summary_large_image" />
</svelte:head>

<p class="astolfoaimontop">
  Not getting redirected? <a href="https://cord.breadhub.cc/">Click here!</a>
</p>

<style>
  p.astolfoaimontop {
    position: fixed;
    top: 50vh;
    left: 50vw;
    transform: translate(-50%, -50%);
    text-align: center;
    max-width: 100vw;
  }
</style>
