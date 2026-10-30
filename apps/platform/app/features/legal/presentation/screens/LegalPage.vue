<script setup lang="ts">
import { legalDocuments } from '../legal_content';
import LegalIcon from '../widgets/LegalIcon.vue';
useHead({link:[{rel:'preload',as:'font',type:'font/woff2',href:'/fonts/dm-sans-latin.woff2',crossorigin:'anonymous'}]});
const props=defineProps<{ kind:'terms'|'privacy' }>();
const document=computed(()=>legalDocuments[props.kind]);
const other=computed(()=>props.kind==='terms'?{to:'/privacidad',label:'Política de privacidad'}:{to:'/terminos',label:'Términos de servicio'});
</script>
<template>
  <AmbientPageShell class="legal-shell" intensity="medium">
    <SiteHeader />
    <main id="view" class="legal-scroll">
      <div class="legal-document">
        <nav class="legal-toolbar" aria-label="Navegación del documento">
          <GlassNavigationButton label="Volver al inicio de sesión" @navigate="navigateTo('/iniciar-sesion')" />
          <NavigationLink class="legal-switch" :to="other.to"><span>{{other.label}}</span><LegalIcon name="arrow-right" /></NavigationLink>
        </nav>
        <header class="legal-heading">
          <h1>{{document.title}}</h1>
          <div class="legal-metadata">
            <p><LegalIcon name="schedule" /><span>18 de octubre de 2026</span></p>
            <p><LegalIcon name="campaign" /><span>Entre Huellas</span></p>
          </div>
        </header>
        <article class="legal-content">
          <section v-for="section in document.sections" :id="section.id" :key="section.id" :aria-labelledby="section.id+'-title'">
            <h2 :id="section.id+'-title'">{{section.title}}</h2>
            <p v-for="paragraph in section.paragraphs" :key="paragraph">{{paragraph}}</p>
          </section>
        </article>
        <footer class="legal-footer">
          <p>© 2026 Entre Huellas. Todos los derechos reservados.</p>
          <div><a href="mailto:sergiotlv51@gmail.com">Contactar</a><span aria-hidden="true">·</span><NavigationLink :to="other.to">{{other.label}}</NavigationLink><span aria-hidden="true">·</span><NavigationLink to="/iniciar-sesion">Inicio de sesión</NavigationLink></div>
        </footer>
      </div>
    </main>
  </AmbientPageShell>
</template>
<style scoped>
@font-face{font-family:'DM Sans';font-style:normal;font-weight:100 1000;font-display:swap;src:url('/fonts/dm-sans-latin.woff2') format('woff2')}

.reader-shell.legal-shell{font-family:'DM Sans',Arial,sans-serif;font-optical-sizing:auto;height:100svh;min-height:0;display:flex;flex-direction:column;align-items:stretch}
.reader-shell.legal-shell :deep(.background-glow){position:fixed;inset:0;mask-image:none}
.reader-shell.legal-shell :deep(.background-glow__viewport){position:absolute;inset:0;height:100%}
.reader-shell .legal-scroll{width:100%;max-width:none;height:auto;min-height:0;flex:1;margin:0;padding:48px 16px;overflow:auto;scrollbar-gutter:stable}
.legal-document{position:relative;isolation:isolate;max-width:896px;min-width:0;margin:0 auto;padding:24px}
.legal-document::before{content:'';position:absolute;inset:0;z-index:-1;pointer-events:none;backdrop-filter:blur(10px);mask-image:linear-gradient(to bottom,transparent 0%,#000 5%,#000 95%,transparent 100%),linear-gradient(to right,transparent 0%,#000 5%,#000 95%,transparent 100%);mask-composite:intersect}
.legal-toolbar{display:flex;align-items:center;justify-content:space-between;gap:16px;min-width:0;padding-bottom:24px;margin-bottom:32px;border-bottom:1px solid #dfe5eb}
.legal-toolbar :deep(.glass-navigation){position:static;flex-shrink:0;width:36px;height:36px}
.legal-toolbar :deep(.glass-navigation .app-icon){width:16px;height:16px}
.legal-switch{display:inline-flex;align-items:center;justify-content:center;gap:8px;min-height:36px;min-width:0;padding:8px 12px;border-radius:calc(.625rem + 8px);background:#edf5fa;color:#3c537b;text-decoration:none;font-size:.875rem;font-weight:500;line-height:1.25rem}
.legal-switch span{min-width:0;overflow-wrap:anywhere}
.legal-switch svg{width:16px;height:16px;flex-shrink:0}
.legal-heading{margin-bottom:32px}
.reader-shell .legal-heading h1{margin:0 0 24px;text-align:center;overflow-wrap:anywhere}
.legal-metadata{display:flex;align-items:center;flex-wrap:wrap;gap:12px 32px;padding-top:16px;color:#656861;font-size:.875rem;line-height:1.5}
.reader-shell .legal-metadata p{display:flex;align-items:center;gap:8px;min-width:0;margin:0;font-size:inherit;line-height:inherit}
.legal-metadata p:last-child{font-weight:600}
.legal-metadata svg{width:16px;height:16px;flex-shrink:0}
.legal-content section{scroll-margin-top:24px;margin-bottom:32px}
.reader-shell .legal-content h2{margin:1.6em 0 .35em;font-size:2rem;line-height:1.25;font-weight:400;letter-spacing:0;color:#3c537b;overflow-wrap:anywhere}
.reader-shell .legal-content section:first-child h2{margin-top:0}
.reader-shell .legal-content p{margin:0 0 .9em;font-size:1rem;line-height:1.5;letter-spacing:0;color:#656861;overflow-wrap:anywhere}
.reader-shell .legal-footer{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:16px;max-width:none;margin:48px 0 0;padding:24px 0 0;border-top:1px solid #dfe5eb;color:#656861;font-size:.75rem;line-height:1.5}
.reader-shell .legal-footer p{margin:0;font-size:inherit;line-height:inherit}
.legal-footer div{display:flex;justify-content:center;flex-wrap:wrap;gap:8px 12px;min-width:0}
.legal-footer a{color:inherit;text-underline-offset:4px;overflow-wrap:anywhere}
@media(min-width:640px){.reader-shell .legal-scroll{padding-inline:24px}.legal-document{padding:48px}}
@media(min-width:1024px){.reader-shell .legal-scroll{padding-inline:32px}}
@media(max-width:639px){.reader-shell .legal-footer{flex-direction:column;text-align:center}}
@media(max-width:360px){.legal-document{padding-inline:16px}.legal-toolbar{gap:12px}.legal-switch{padding-inline:12px}}
@media(forced-colors:active){.reader-shell .legal-heading h1{background:none;color:CanvasText}}
</style>
