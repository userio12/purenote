# Premium Note-Taking App UI/UX Design Reference
## 2025-2026 Trends & Best Practices for Flutter

---

## 1. COLOR SYSTEM

### 1.1 Dark Mode Surface Hierarchy

Dark mode is NOT inverting light colors. It is a first-class design context with luminance-based elevation. Shadows do not read on dark backgrounds -- use **tonal elevation** (lighter = higher elevation).

| Token | Purpose | Hex |
|---|---|---|
| `surface-dimmest` | Base background | `#0F172A` |
| `surface-base` | Cards, panels | `#1E293B` |
| `surface-raised` | Hover states, nested cards | `#334155` |
| `surface-overlay` | Modals, tooltips | `#475569` |

**Rules:**
- Never use pure `#000000` -- causes eye strain and OLED smearing
- Each elevation steps luminance by 5-8%
- Text off-white `#E2E8F0` not pure `#FFFFFF`

### 1.2 Obsidian Slate Dark Palette

```
Background:    #0F172A  (Midnight Slate)
Surface:       #1E293B  (Slate 800)
Elevated:      #334155  (Slate 700)
Border:        #475569  (Slate 600)
Text Muted:    #94A3B8  (Slate 400)
Text Primary:  #E2E8F0  (Slate 200)
Text Heading:  #F1F5F9  (Slate 100)
Accent:        #38BDF8  (Sky 400)
Accent Alt:    #A78BFA  (Purple 400)
Success:       #34D399  (Emerald 400)
Warning:       #FBBF24  (Amber 400)
Error:         #F87171  (Red 400)
```

### 1.3 Clean Canvas Light Palette

```
Background:    #F8FAFC  (Slate 50)
Surface:       #FFFFFF
Elevated:      #F1F5F9  (Slate 100)
Border:        #E2E8F0  (Slate 200)
Text Muted:    #64748B  (Slate 500)
Text Primary:  #1E293B  (Slate 800)
Text Heading:  #0F172A  (Slate 900)
Accent:        #0284C7  (Sky 600)
```

### 1.4 Accent Mapping Light to Dark

| Role | Light | Dark |
|---|---|---|
| Primary | `#0284C7` | `#38BDF8` |
| Secondary | `#7C3AED` | `#A78BFA` |
| Success | `#059669` | `#34D399` |
| Error | `#DC2626` | `#F87171` |
| Warning | `#D97706` | `#FBBF24` |

### 1.5 60-30-10 Rule

- **60%** Neutrals: backgrounds, surfaces (`#0F172A`, `#1E293B`)
- **30%** Secondary: supporting UI, cards (`#334155`, `#475569`)
- **10%** Accent: CTAs, highlights (`#38BDF8`, `#A78BFA`)

---

## 2. TYPOGRAPHY

### 2.1 Recommended Font Pairing

**Inter (UI/headings) + Lora (body/editor)**

- Inter: Variable font, screen-optimized, excellent at all sizes
- Lora: Calligraphic serif, warm, readable for long-form writing

### 2.2 Type Scale

| Role | Size | Weight | Line Height | Font |
|---|---|---|---|---|
| Headline Large | 32sp | 600 | 40sp | Inter |
| Headline Medium | 28sp | 600 | 36sp | Inter |
| Title Large | 22sp | 500 | 28sp | Inter |
| Title Medium | 16sp | 500 | 24sp | Inter |
| Body Large | 16sp | 400 | 24sp | Lora |
| Body Medium | 14sp | 400 | 20sp | Lora |
| Label Large | 14sp | 500 | 20sp | Inter |
| Label Medium | 12sp | 500 | 16sp | Inter |

### 2.3 Dark Mode Typography

- Softened whites: `#E2E8F0` not `#FFFFFF`
- Minimum weight 400 for body
- Increase line-height 10-20% in dark mode
- Font size minimum 16sp body on mobile

### 2.4 Alternative Pairings

| Style | Heading | Body | Use Case |
|---|---|---|---|
| Modern Minimal | Inter | Inter | Clean, technical |
| Elegant Writer | Playfair Display | Lora | Literary, warm |
| Editorial Clean | Space Grotesk | DM Sans | Geometric modern |
| Classic Pro | Libre Baskerville | Source Sans Pro | Trustworthy |

---

## 3. LAYOUT & SPACING

### 3.1 Card Styles

- Border radius: 16-20px
- Padding: 16-20px
- Light shadow: `0 2px 8px rgba(0,0,0,0.06)`
- Dark: Use tonal elevation instead of shadow
- Optional 1px border: `#475569` dark / `#E2E8F0` light

### 3.2 Spacing (4px grid)

| Token | Value | Usage |
|---|---|---|
| xs | 4px | Icon gaps |
| sm | 8px | Chip padding |
| md | 12px | Card internals |
| lg | 16px | Card padding |
| xl | 20px | Section padding |
| 2xl | 24px | Screen margins |
| 3xl | 32px | Section gaps |
| 4xl | 48px | Tablet margins |

### 3.3 Screen Margins

| Device | Horizontal | Top |
|---|---|---|
| Phone | 16-20px | Safe area |
| Tablet | 24-48px | 24px |
| Desktop | Max 720px centered | 16px |

---

## 4. COMPONENTS

### 4.1 Bottom Navigation

- Height: 80px with labels
- Icon: 24px, Label: 12sp
- Active indicator: Rounded pill 64x32px, 12% accent opacity
- Glassmorphism: `BackdropFilter` blur 20px, opacity 0.85

### 4.2 FAB (Floating Action Button)

- Size: 56px standard, 96px extended
- Border radius: 16px (M3 default)
- Shadow: `0 6px 10px rgba(0,0,0,0.14), 0 1px 18px rgba(0,0,0,0.12), 0 3px 5px rgba(0,0,0,0.20)`
- Icon: 24px, white or onPrimary color
- Extended: Icon (24px) + Label (14sp, weight 500) + 16px padding
- Animation: Scale from 0 on appear, rotation on morph

### 4.3 Search Bar

- Height: 56px
- Border radius: 28px (pill shape)
- Leading icon: 24px, trailing action: 24px
- Background: surface-raised in dark, surface in light
- Placeholder: 16sp, text-secondary color

### 4.4 App Bar / Top Bar

- Height: 64px
- Title: 22sp, weight 600
- Background: Transparent (collapses on scroll)
- Leading action: 24px icon, 48px tap target

### 4.5 Chips / Tags

- Height: 32px
- Border radius: 8px
- Padding: Horizontal 12px
- Font: 14sp, weight 500
- Background: surface-raised, border: 1px surface-overlay
- Selected: primary container (12% opacity accent)

### 4.6 Empty States

- Illustration: 120-160px, centered, muted colors
- Headline: 22sp, weight 500, text-primary
- Body: 14sp, text-muted, max-width 280px
- CTA: Filled button, primary color, 16px padding
- Example: "No notes yet" with pen-writing Lottie animation

### 4.7 Toolbar / Formatting Bar

- Height: 48px
- Background: surface with top 1px border
- Icons: 24px, spacing 8px between
- Active state: Primary color fill, 8px padding, 20px border radius
- Scrollable horizontal

---

## 5. ANIMATIONS & TRANSITIONS

### 5.1 Micro-Interactions

| Action | Animation | Duration | Curve |
|---|---|---|---|
| Button press | Scale 0.95 | 100ms | easeOut |
| Card tap | Ripple from tap point | 300ms | easeInOut |
| Page transition | Shared axis (horizontal) | 300ms | easeInOut |
| Modal open | Slide up + fade | 250ms | easeOut |
| FAB appear | Scale 0 to 1 | 200ms | elasticOut |
| Note delete | Slide out + fade | 250ms | easeIn |
| Search expand | Width animate | 200ms | easeInOut |
| Theme toggle | Cross-fade | 300ms | linear |

### 5.2 Flutter Implementation

```dart
// Implicit animations for simple transitions
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeOut,
  // ...
)

// Hero transitions for note detail
Hero(
  tag: 'note-${note.id}',
  child: NoteCard(note: note),
)

// Staggered list animation
AnimatedList(
  initialItemCount: notes.length,
  itemBuilder: (context, index, animation) => SlideTransition(
    position: Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    )),
    child: NoteCard(note: notes[index]),
  ),
)
```

### 5.3 Loading States

- Skeleton shimmer: 16px radius cards, gradient from surface to surface-raised
- Shimmer duration: 1500ms, repeat
- Use `shimmer` package for consistent loading placeholders

### 5.4 Lottie Animations

- Empty states: Writing hand, floating notes, search illustration
- Success: Checkmark burst (0.5-1s)
- Error: Gentle shake
- Onboarding: Step-by-step illustration sequence

---

## 6. GLASSMORPHISM & MODERN EFFECTS

### 6.1 Glassmorphism (Use Sparingly)

- **When**: Navigation bars, modals, floating panels
- **Not for**: Reading content, long-form text areas
- Blur: 20-30px
- Opacity: 0.8-0.9
- Border: 1px white at 10-20% opacity (light), white at 5-10% (dark)
- Background tint: Primary color at 5-10% opacity

### 6.2 Dark Mode Glassmorphism

```dart
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: content,
    ),
  ),
)
```

### 6.3 Gradients

- App icon: Subtle gradient from primary to primary-dark
- Header backgrounds: 135deg linear from primary to secondary at 20% opacity
- FAB: Primary to primary-light gradient
- Avoid gradients on text or large surfaces

---

## 7. DARK MODE IMPLEMENTATION

### 7.1 Flutter Theme Setup

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    textTheme: lightTextTheme,
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    textTheme: darkTextTheme,
  ),
  themeMode: ThemeMode.system, // Respect system preference
)
```

### 7.2 Elevation Without Shadows

In dark mode, M3 uses surface tint color at varying opacities for elevation:
- Level 0: 0% tint
- Level 1: 5% tint
- Level 3: 8% tint
- Level 5: 11% tint
- Level 8: 12% tint

### 7.3 Key Differences from Light

| Element | Light | Dark |
|---|---|---|
| Background | `#F8FAFC` | `#0F172A` |
| Cards | White + shadow | `#1E293B` + tint |
| Dividers | `#E2E8F0` | `#475569` |
| Text primary | `#1E293B` | `#E2E8F0` |
| Text secondary | `#64748B` | `#94A3B8` |
| Disabled | `#CBD5E1` | `#475569` |
| Scrim | Black 32% | Black 60% |

---

## 8. EMPTY STATES & ONBOARDING

### 8.1 Empty State Pattern

1. Illustration (Lottie, 120-160px, muted colors)
2. Headline: "No notes yet" (22sp, weight 500)
3. Subtext: "Tap + to create your first note" (14sp, text-muted)
4. CTA button: Filled, primary color

### 8.2 Onboarding

- 3-4 screens max
- Large illustration per feature
- Skip button (top right, text-muted)
- Page indicator dots (8px active, 6px inactive)
- Get Started button: Full-width, primary color, 56px height

---

## 9. ACCESSIBILITY

### 9.1 Contrast Requirements (WCAG 2.2 AA)

- Normal text: 4.5:1 minimum
- Large text (18sp+): 3:1 minimum
- Icons/interactive: 3:1 minimum
- Focus indicators: 2px outline, 3:1 contrast

### 9.2 Touch Targets

- Minimum 44x44pt (iOS) / 48x48dp (Android)
- Spacing between targets: 8px minimum

### 9.3 Semantics

- Every tappable widget needs Semantics label
- Decorative images: `Semantics(ExcludeSemantics: true)`

---

## 10. FLUTTER PACKAGES

### 10.1 UI Enhancement

| Package | Purpose |
|---|---|
| `flex_color_scheme` | Advanced Material 3 theming |
| `google_fonts` | Google Fonts integration |
| `flutter_animate` | Declarative animations |
| `lottie` | Lottie animation support |
| `shimmer` | Skeleton loading effects |
| `glassmorphism` | Glass effect containers |
| `flutter_staggered_animations` | Staggered list animations |
| `cached_network_image` | Image caching with placeholders |

### 10.2 Theming Pattern

```dart
// Use FlexColorScheme for Material 3
final darkTheme = FlexThemeData.dark(
  scheme: FlexScheme.blue,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 10,
    blendOnColors: false,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
);
```

---

## 11. KEY DESIGN TRENDS 2025-2026

1. **Dark-first design** -- Linear, Arc, Raycast launched dark as primary
2. **Liquid Glass** -- Apple's new frosted-glass system material
3. **Adaptive toolbars** -- Context-aware toolbar that morphs based on usage
4. **Bento grids** -- Japanese-style compartmentalized layouts for dashboards
5. **Big typography** -- Oversized headings as visual elements
6. **Micro-interactions** -- Subtle haptic + visual feedback on every tap
7. **AI-enhanced notes** -- Auto-categorization, smart linking, summaries
8. **Gesture navigation** -- Swipe actions for archive, delete, pin
9. **Dynamic color** -- Material You wallpaper-based theming
10. **Hybrid reading** -- Dark chrome + light content area (Notion pattern)

---

## 12. REFERENCES

- Muzli: Dark Mode Design Systems (2026)
- ColorUxLab: Mobile App Color Design Guide (2026)
- Material Design 3: m3.material.io
- Bear App typography analysis
- Apple Notes iOS 26 Liquid Glass redesign
- Google Keep Material 3 Expressive update
- Flutter animation best practices (Oflight 2026)
