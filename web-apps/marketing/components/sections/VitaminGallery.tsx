"use client";

import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import {
  AnimatePresence,
  motion,
  useReducedMotion,
  useScroll,
  useTransform,
} from "motion/react";
import { proteinNatureGallery } from "@/lib/images";
import { Eyebrow } from "../primitives/Eyebrow";

type Caption = { kicker: string; line: string; tag: string; hue: string };

const captions: Caption[] = [
  {
    kicker: "Salmon",
    line: "Protein, vitamin D, and omega-rich food in one plain meal.",
    tag: "Protein and D",
    hue: "var(--color-nut-d)",
  },
  {
    kicker: "Greens",
    line: "A bowl can carry folate, magnesium, vitamin C, and real texture.",
    tag: "Plants and minerals",
    hue: "var(--color-nut-c)",
  },
  {
    kicker: "Almonds",
    line: "Small foods still matter: vitamin E, magnesium, and steady fats.",
    tag: "Dense foods",
    hue: "var(--color-nut-e)",
  },
  {
    kicker: "Avocado",
    line: "Fiber, potassium, and soft fats read better as food than pills.",
    tag: "Whole-food energy",
    hue: "var(--color-nut-mg)",
  },
  {
    kicker: "Chickpeas",
    line: "Plant protein, iron, and folate without turning the page clinical.",
    tag: "Plant protein",
    hue: "var(--color-nut-fe)",
  },
  {
    kicker: "Spinach",
    line: "Quiet green volume, with vitamin K and minerals doing the work.",
    tag: "Daily greens",
    hue: "var(--color-nut-k)",
  },
];

// Each fruit hangs off the central hub. Coordinates in a 100x100 viewBox
// so the tree scales with whatever aspect ratio the section is given.
const branches: { x: number; y: number; cx: number; cy: number }[] = [
  { x: 18, y: 16, cx: 30, cy: 38 }, // top-left
  { x: 82, y: 16, cx: 70, cy: 38 }, // top-right
  { x: 6, y: 50, cx: 26, cy: 50 }, // mid-left
  { x: 94, y: 50, cx: 74, cy: 50 }, // mid-right
  { x: 22, y: 86, cx: 32, cy: 64 }, // bottom-left
  { x: 78, y: 86, cx: 68, cy: 64 }, // bottom-right
];

const branchPath = (b: (typeof branches)[number]) =>
  `M50 50 Q ${b.cx} ${b.cy} ${b.x} ${b.y}`;

// One viewport-height "slice" of scroll per fruit feels deliberate without
// dragging on. Lower this if the section feels too long.
const TRACK_VH_PER_ITEM = 70;

export function VitaminGallery() {
  const reduce = useReducedMotion();
  const sectionRef = useRef<HTMLElement>(null);

  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start start", "end end"],
  });

  const [active, setActive] = useState(0);
  useEffect(() => {
    return scrollYProgress.on("change", (v) => {
      const i = Math.min(
        captions.length - 1,
        Math.max(0, Math.floor(v * captions.length)),
      );
      setActive(i);
    });
  }, [scrollYProgress]);

  // Linear scroll-progress bar under the heading
  const progressWidth = useTransform(scrollYProgress, [0, 1], ["0%", "100%"]);

  const activeCaption = captions[active] ?? captions[0];

  // Scroll the page so a given fruit's slice is roughly centered. Keeps the
  // fruit buttons usable as direct navigation even though scroll is the
  // primary driver.
  const scrollToIndex = (i: number) => {
    const el = sectionRef.current;
    if (!el) return;
    const rect = el.getBoundingClientRect();
    const sectionTop = window.scrollY + rect.top;
    const scrollableDistance = el.offsetHeight - window.innerHeight;
    const target =
      sectionTop + ((i + 0.5) / captions.length) * scrollableDistance;
    window.scrollTo({
      top: target,
      behavior: reduce ? "auto" : "smooth",
    });
  };

  return (
    <section
      ref={sectionRef}
      className="relative bg-[var(--color-bg)] overflow-hidden"
      style={{ height: `${captions.length * TRACK_VH_PER_ITEM}vh` }}
    >
      <div className="sticky top-0 h-screen flex flex-col justify-center py-10 md:py-14">
        <div className="mx-auto max-w-7xl px-5 sm:px-6 w-full">
          <div className="relative z-20 mx-auto mb-8 md:mb-10 max-w-3xl text-center">
            <Eyebrow className="justify-center text-[var(--color-warn)]">
              Food first
            </Eyebrow>
            <h2
              className="display mt-5 text-[36px] sm:text-[56px] lg:text-[68px] text-[var(--color-text)]"
              style={{ letterSpacing: 0 }}
            >
              A tree of nutrients.
            </h2>
            <p className="mx-auto mt-5 max-w-2xl text-base sm:text-lg leading-relaxed text-[var(--color-text-muted)]">
              Six whole foods, one living branch. Scroll to see what each one
              quietly carries.
            </p>

            <div className="mx-auto mt-6 max-w-xs">
              <div className="relative h-px overflow-hidden rounded-full bg-[var(--color-border)]">
                <motion.div
                  className="absolute inset-y-0 left-0 rounded-full"
                  style={{
                    width: progressWidth,
                    background: activeCaption.hue,
                  }}
                />
              </div>
              <p className="eyebrow mt-3 text-[10px] text-[var(--color-text-muted)]">
                Keep scrolling
              </p>
            </div>
          </div>

          <div
            className="relative mx-auto w-full max-w-[940px] aspect-[3/4] sm:aspect-[5/4] lg:aspect-[16/10]"
            role="group"
            aria-label="Vitamin tree — active fruit follows scroll"
          >
            <BranchSvg activeIndex={active} reduce={!!reduce} />

            <CenterHub caption={activeCaption} reduce={!!reduce} />

            {proteinNatureGallery.map((photo, i) => {
              const pos = branches[i];
              const cap = captions[i] ?? captions[0];
              const isActive = active === i;
              return (
                <motion.button
                  key={photo.id}
                  type="button"
                  onClick={() => scrollToIndex(i)}
                  className="absolute -translate-x-1/2 -translate-y-1/2 group focus:outline-none"
                  style={{ left: `${pos.x}%`, top: `${pos.y}%` }}
                  initial={reduce ? { opacity: 1 } : { opacity: 0, scale: 0.5 }}
                  whileInView={{ opacity: 1, scale: 1 }}
                  viewport={{ once: true, amount: 0.3 }}
                  transition={{
                    duration: 0.7,
                    ease: [0.16, 1, 0.3, 1],
                    delay: 0.2 + i * 0.06,
                  }}
                  aria-pressed={isActive}
                  aria-label={`Jump to ${cap.kicker}`}
                >
                  <motion.span
                    animate={reduce ? undefined : { y: [0, -5, 0] }}
                    transition={{
                      duration: 4.5 + i * 0.35,
                      repeat: Infinity,
                      ease: "easeInOut",
                      delay: i * 0.4,
                    }}
                    className="block"
                  >
                    <span
                      className="relative block w-14 h-14 sm:w-20 sm:h-20 lg:w-28 lg:h-28 rounded-full overflow-hidden bg-white transition-all duration-500 group-hover:scale-[1.04]"
                      style={{
                        boxShadow:
                          "0 18px 40px -22px rgba(19,26,22,0.45), 0 4px 10px -6px rgba(19,26,22,0.18)",
                        transform: isActive ? "scale(1.08)" : undefined,
                        outline: isActive
                          ? `2px solid ${cap.hue}`
                          : "1px solid rgba(255,255,255,0.7)",
                        outlineOffset: isActive ? 4 : 0,
                      }}
                    >
                      <Image
                        src={photo.url}
                        alt={photo.alt}
                        fill
                        sizes="(max-width: 640px) 56px, (max-width: 1024px) 80px, 112px"
                        className="object-cover transition-transform duration-700 group-hover:scale-110"
                        priority={i < 2}
                      />
                    </span>
                  </motion.span>
                  <span
                    className="mt-2 block eyebrow text-center transition-colors"
                    style={{
                      color: isActive ? cap.hue : "var(--color-text-muted)",
                    }}
                  >
                    {cap.kicker}
                  </span>
                </motion.button>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
}

function BranchSvg({
  activeIndex,
  reduce,
}: {
  activeIndex: number;
  reduce: boolean;
}) {
  return (
    <svg
      viewBox="0 0 100 100"
      preserveAspectRatio="none"
      className="absolute inset-0 z-0 h-full w-full"
      aria-hidden
    >
      {branches.map((b, i) => {
        const cap = captions[i] ?? captions[0];
        const isActive = activeIndex === i;
        return (
          <g key={i}>
            <motion.path
              d={branchPath(b)}
              fill="none"
              stroke="var(--color-border)"
              strokeWidth={0.25}
              strokeLinecap="round"
              vectorEffect="non-scaling-stroke"
              initial={reduce ? { pathLength: 1 } : { pathLength: 0 }}
              whileInView={{ pathLength: 1 }}
              viewport={{ once: true, amount: 0.3 }}
              transition={{
                duration: 1.4,
                ease: [0.16, 1, 0.3, 1],
                delay: 0.1 * i,
              }}
            />
            <motion.path
              d={branchPath(b)}
              fill="none"
              stroke={cap.hue}
              strokeWidth={0.5}
              strokeLinecap="round"
              vectorEffect="non-scaling-stroke"
              initial={{ pathLength: 0, opacity: 0 }}
              animate={{
                pathLength: isActive ? 1 : 0,
                opacity: isActive ? 0.85 : 0,
              }}
              transition={{ duration: 0.9, ease: [0.16, 1, 0.3, 1] }}
            />
            <motion.circle
              cx={b.x}
              cy={b.y}
              r={isActive ? 1.1 : 0.7}
              fill={cap.hue}
              opacity={isActive ? 0.9 : 0.45}
              animate={{ r: isActive ? 1.1 : 0.7 }}
              transition={{ duration: 0.4 }}
            />
          </g>
        );
      })}
    </svg>
  );
}

function CenterHub({
  caption,
  reduce,
}: {
  caption: Caption;
  reduce: boolean;
}) {
  return (
    <div className="absolute left-1/2 top-1/2 z-10 w-[60%] sm:w-[44%] lg:w-[36%] -translate-x-1/2 -translate-y-1/2">
      <div className="relative aspect-square">
        <div className="absolute inset-[-7%] rounded-full border border-dashed border-[var(--color-border)] opacity-40 pointer-events-none" />
        <div className="relative flex h-full w-full items-center justify-center rounded-full bg-[var(--color-accent-soft)] border border-[var(--color-border)] px-5 sm:px-7 text-center shadow-[0_30px_70px_-40px_rgba(19,26,22,0.35)]">
          <AnimatePresence mode="wait">
            <motion.div
              key={caption.kicker}
              initial={
                reduce ? { opacity: 1 } : { opacity: 0, scale: 0.96 }
              }
              animate={{ opacity: 1, scale: 1 }}
              exit={reduce ? { opacity: 0 } : { opacity: 0, scale: 0.98 }}
              transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
            >
              <span
                className="eyebrow inline-flex items-center gap-2"
                style={{ color: caption.hue }}
              >
                <span className="block h-px w-6 bg-current opacity-50" />
                {caption.tag}
              </span>
              <h3
                className="display mt-3 text-[22px] sm:text-[32px] lg:text-[42px] leading-none text-[var(--color-text)] text-balance"
                style={{ letterSpacing: 0 }}
              >
                {caption.kicker}.
              </h3>
              <p className="mt-3 text-xs sm:text-sm lg:text-base leading-relaxed text-[var(--color-text-muted)] text-balance">
                {caption.line}
              </p>
            </motion.div>
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}
