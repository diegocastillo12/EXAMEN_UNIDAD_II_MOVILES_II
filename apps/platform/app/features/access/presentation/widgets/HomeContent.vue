<template>
  <h1 class="home-title" aria-label="Su regreso empieza contigo">Su regreso<br><span>empieza contigo</span></h1>
  <nav class="home-shortcuts" aria-label="Accesos de Inicio">
    <NavigationLink to="/reportar" origin class="home-shortcut">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5" /><path d="m16 16 5 5" /></svg>
      <span>Reportar</span>
    </NavigationLink>
    <NavigationLink to="/explorar" class="home-shortcut">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9" /><path d="m16 8-2.5 5.5L8 16l2.5-5.5Z" /></svg>
      <span>Explorar</span>
    </NavigationLink>
    <NavigationLink to="/mis-mascotas" class="home-shortcut">
      <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><ellipse cx="5" cy="9" rx="2.2" ry="2.8" transform="rotate(-25 5 9)" /><ellipse cx="10" cy="5.5" rx="2.1" ry="2.7" /><ellipse cx="16" cy="6" rx="2.1" ry="2.7" transform="rotate(20 16 6)" /><ellipse cx="20" cy="11" rx="2" ry="2.6" transform="rotate(35 20 11)" /><path d="M6.5 17c0-2 2-3 3-4.5 1.2-1.8 3.4-1.8 4.6 0 1 1.5 3.4 2.5 3.4 4.5 0 3-3 3.8-5.5 2.5C9.5 20.8 6.5 20 6.5 17Z" /></svg>
      <span>Mis mascotas</span>
    </NavigationLink>
  </nav>
  <GlassSurface as="section" class="home-reunion" aria-label="Nuestra comunidad">
    <img src="/images/landing/pets-home.webp" width="1536" height="1024" alt="Un perro y un gato de la comunidad Entre Huellas" fetchpriority="high" />
    <p>Una comunidad para conectar mascotas perdidas con quienes pueden ayudar.</p>
  </GlassSurface>
  <section class="home-nearby" aria-labelledby="nearby-title">
    <h2 id="nearby-title">Cerca de ti</h2>
    <GlassSurface class="home-notice">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 10c0 5-7 11-7 11S5 15 5 10a7 7 0 1 1 14 0Z" /><circle cx="12" cy="10" r="2.5" /></svg>
      <h3>Explora cerca de ti</h3>
      <p>Consulta los casos en el mapa y elige la zona donde quieres ayudar.</p>
    </GlassSurface>
    <NavigationLink to="/explorar" class="home-explore">Conoce Explorar <span aria-hidden="true">→</span></NavigationLink>
  </section>
</template>
