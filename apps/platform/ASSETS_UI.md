# Recursos de interfaz compartida

Marca de cabecera19/10: SiteBrand/SiteHeader reutilizan /brand.png original
con medidas/color/fuente de landing en todos los recorridos web (ADR-077).
Sin nuevo recurso ni modificación de la marca del footer.

## Inter e ilustraciones — solo onboarding web,19/10/2026

- Inter variable100–900, latino con acentos, en public/fonts/inter-latin.woff2.
  Misma familia del layout de sader-panel, autorizada por su referencia expresa
  para /bienvenida; no cambia Arial del login ni DM Sans de legales.
- CSS oficial: https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap
- WOFF2: https://fonts.gstatic.com/s/inter/v20/UcC73FwrK3iLTeHuS_nVMrMxCp50SjIa1ZL7.woff2
- Licencia SIL OFL en public/licenses/Inter-OFL.txt; origen:
  https://raw.githubusercontent.com/google/fonts/main/ofl/inter/OFL.txt
- public/images/onboarding/dog_waving.png, dog_with_map.png y dog_and_cat.png
  son copias byte a byte de apps/mobile/assets/onboarding. Sin recorte,
  recreación ni recompresión. Procedencia/prompts en el README móvil existente.
- Archivos servidos desde el propio origen; sin petición a Google al navegar.
  [ADR-074](../../docs/decisiones/074-onboarding-web-referencia-sader-y-mobile.md).

## DM Sans — solo páginas legales

- Archivo: public/fonts/dm-sans-latin.woff2.
- Familia variable DM Sans, pesos100–1000; fuente oficial de Google Fonts,
  solicitada con óptica9–40 y subconjunto latino que incluye acentos castellanos.
- Fuente CSS de adquisición: https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,100..1000&display=swap
- Archivo oficial adquirido: https://fonts.gstatic.com/s/dmsans/v17/rP2Hp2ywxg089UriCZOIHQ.woff2
- Licencia SIL OFL local: public/licenses/DM-Sans-OFL.txt.
- Licencia origen: https://github.com/google/fonts/blob/main/ofl/dmsans/OFL.txt
- Uso autorizado18/10/2026: /terms y /privacy. Login/landing conservan Arial.
- Se sirve desde el mismo origen, sin consulta a Google al visitar la web.

## Material Symbols — vectores oficiales

AppIcon.vue y material_symbol_paths.ts contienen trazados de
https://github.com/google/material-design-icons (Apache2).
Licencia local: public/licenses/Material-Symbols-LICENSE.txt.

| Uso | Familia / recurso oficial | Tamaño renderizado |
| --- | --- | --- |
| Retorno glass | symbols/web/chevron_left/materialsymbolsrounded/chevron_left_fill1_24px.svg | 28px |
| Fecha legal | symbols/web/schedule/materialsymbolsoutlined/schedule_fill1_20px.svg | 16px |
| Anuncio legal | symbols/web/campaign/materialsymbolsoutlined/campaign_fill1_20px.svg | 16px |

La metadata reproduce FILL1/peso400/óptica20 de sader-panel. El retorno sigue
el chevrón Rounded del móvil. Los SVG se incluyen en Vue, sin fuente externa
ni redibujos aproximados. Los recursos de landing conservan LANDING_ASSETS.md.

## Iconos del toast móvil

TopToast usa los trazados Material Icons Rounded oficiales de Google,
Apache2 (licencia existente), en AppIcon con viewBox24:
- src/alert/error_outline/materialiconsround/24px.svg
- src/navigation/check/materialiconsround/24px.svg

Origen: https://github.com/google/material-design-icons/tree/master/src
Render20px, equivalentes a Icons.error_outline_rounded y Icons.check_rounded
del ConfirmationToastHost Flutter. Sin fuente ni consulta externa en ejecución.
