<script lang="ts">
  const vac = 'https://media.tenor.com/qo6eAIlkNBEAAAAC/vac-anti-cheats.gif';
  if (typeof document !== 'undefined') document.location.href = vac;
</script>

<svelte:head>
  <title>Valve Anti-Cheat System!</title>
  <link rel="stylesheet" href="https://ministyles.astolfo.gay/all.css" />
  <meta name="og:title" content="Valve Anti-Cheat System!" />
  <meta property="og:type" content="website" />
  <meta name="description" content="Valve's Anti-Cheat System is amazing fr!" />
  <meta
    name="og:description"
    content="Valve's Anti-Cheat System is amazing fr!"
  />
  <meta name="og:image" content={vac} />
  <meta name="theme-color" content="#f3ad61" />
  <meta name="twitter:card" content="summary_large_image" />
</svelte:head>

<p class="astolfoaimontop">
  Not getting redirected? <a href={vac}>Click here!</a>
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
