import '../assets/stagger-reveal.css';
import { computed, onBeforeUnmount, onBeforeUpdate, onMounted, ref, toValue, watch, type CSSProperties, type ObjectDirective, type MaybeRefOrGetter } from 'vue';

type Side = 'top' | 'bottom';
export const STAGGER_GAP_MS = 90;

interface UseStaggerRevealOptions {
  active?: MaybeRefOrGetter<boolean>;
  count?: number;
  gap?: number;
  duration?: number;
  blur?: number;
  offset?: number;
  reveal?: Side;
  cover?: Side;
  revealOrder?: Side;
  coverOrder?: Side;
  easing?: string;
  initialDelay?: number;
  animateInitial?: boolean;
}

/** Vue port of sader-panel/src/hooks/use-stagger-reveal.tsx.
 * Keeps the same defaults, ordering, inline styles and double-rAF start.
 * Explicit indices also support conditional groups without changing their order.
 */
export function useStaggerReveal(options: UseStaggerRevealOptions = {}) {
  const {
    active = true, count, gap = STAGGER_GAP_MS, duration = 850,
    blur = 18, offset = 28, reveal = 'top', cover,
    revealOrder = 'top', coverOrder,
    easing = 'cubic-bezier(0.22, 1, 0.36, 1)',
    initialDelay = 0, animateInitial = true,
  } = options;
  const revealed = ref(!animateInitial && toValue(active));
  const exiting = ref(false);
  let autoIndex = 0;
  let raf1 = 0;
  let raf2 = 0;
  function cancelFrames() {
    cancelAnimationFrame(raf1);
    cancelAnimationFrame(raf2);
  }
  onBeforeUpdate(() => { autoIndex = 0; });
  onMounted(() => {
    watch(() => toValue(active), value => {
      cancelFrames();
      if (!value) {
        exiting.value = true;
        revealed.value = false;
        return;
      }
      exiting.value = false;
      raf1 = requestAnimationFrame(() => {
        raf2 = requestAnimationFrame(() => { revealed.value = true; });
      });
    }, { immediate: true });
  });
  onBeforeUnmount(() => { if (import.meta.client) cancelFrames(); });

  function revealStyle(index?: number): CSSProperties {
    const idx = index ?? autoIndex++;
    const enterY = reveal === 'bottom' ? offset : -offset;
    const exitY = (cover ?? reveal) === 'bottom' ? offset : -offset;
    const hiddenY = exiting.value ? exitY : enterY;
    const order = exiting.value ? (coverOrder ?? revealOrder) : revealOrder;
    const pos = order === 'bottom' && count != null ? count - 1 - idx : idx;
    const delay = initialDelay + Math.max(0, pos) * gap;
    return {
      transition: `opacity ${duration}ms ${easing}, filter ${duration}ms ${easing}, transform ${duration}ms ${easing}`,
      transitionDelay: `${delay}ms`,
      opacity: revealed.value ? 1 : 0,
      filter: blur === 0 ? 'none' : revealed.value ? 'blur(0px)' : `blur(${blur}px)`,
      transform: revealed.value ? 'translateY(0)' : `translateY(${hiddenY}px)`,
      willChange: blur === 0 ? 'opacity, transform' : 'opacity, filter, transform',
    };
  }
  const exitMs = duration + Math.max(0, (count ?? 1) - 1) * gap;
  return { revealed: computed(() => revealed.value), revealStyle, exitMs };
}

/** Apply the source styles via CSSOM: the platform CSP disallows SSR style
 * attributes. The shared class supplies the same hidden state before hydration. */
export const vStaggerReveal: ObjectDirective<HTMLElement, CSSProperties> = {
  beforeMount(el, { value }) { Object.assign(el.style, value); },
  updated(el, { value }) { Object.assign(el.style, value); },
  getSSRProps() { return {}; },
};
