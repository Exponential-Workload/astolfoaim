<script lang="ts">
  const target = 'https://github.com/YieldingExploiter/AstolfoAim/';
  if (typeof document !== 'undefined') document.location.href = target;
</script>

<svelte:head>
  <title>AstolfoAim Github</title>
  <link rel="stylesheet" href="https://ministyles.astolfo.gay/all.css" />
  <meta name="og:title" content="AstolfoAim Github" />
  <meta property="og:type" content="website" />
  <meta name="description" content="The github for https://aim.femboy.cafe" />
  <meta
    name="og:description"
    content="The github for https://aim.femboy.cafe"
  />
  <meta
    name="og:image"
    content="https://repository-images.githubusercontent.com/588184116/24a0ff01-3265-4a14-a881-f1d8dfda0947"
  />
  <meta name="theme-color" content="#f3ad61" />
  <meta name="twitter:card" content="summary_large_image" />
</svelte:head>

<p class="astolfoaimontop">
  Not getting redirected? <a href={target}>Click here!</a>
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
