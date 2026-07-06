---
name: pixel-art-sprite-generation
description: Create, refine, and repair prompts for AI-generated 2D pixel art game assets, especially character sprites, sprite sheets, animation frames, combat VFX, UI icons, and game-ready pixel assets. Use this skill when the user asks to generate pixel art for games, make a sprite sheet, preserve a character design across frames, fix inconsistent animation, control baseline/pivot/scale, prepare prompts for image models, or create production-ready assets for Godot/Unity-style 2D games.
---

# Pixel Art Sprite Generation

## Core Purpose

Use this skill to help produce consistent, game-ready 2D pixel art assets with AI. Prioritize animation continuity, character identity, readable silhouettes, clean pixel clusters, fixed frame layout, stable baseline, and production usability inside a game engine.

For game sprite work, never treat the image as a single illustration. Treat it as a controlled asset with technical rules: frame size, total sheet size, direction, pivot, baseline, scale consistency, palette behavior, and layer separation.

## Primary Workflow

Follow this workflow whenever creating or refining a sprite/sprite sheet prompt:

1. Identify the asset type.
   - Character concept
   - Character turnaround
   - Idle sprite sheet
   - Walk/run sprite sheet
   - Dash/back step sprite sheet
   - Attack sprite sheet
   - Hurt/death sprite sheet
   - Boss animation
   - Combat VFX
   - Ambient overlay
   - UI/game icon

2. Lock the character identity before requesting animation.
   - Use the latest approved character image as the canonical reference.
   - Preserve silhouette, outfit structure, hairstyle, weapon design, hand dominance, scarf/cloak shape, color roles, and mood.
   - Do not let the AI redesign the character while animating.

3. Specify the technical sheet contract.
   - Frame count
   - Frame layout
   - Canvas size per frame
   - Total sheet size
   - Direction/facing
   - Background color
   - Pivot logic
   - Baseline rule
   - Scale consistency

4. Describe motion as readable gameplay states.
   - Use anticipation, active/action frame, follow-through, and recovery.
   - For combat, describe the sword path and body weight shift.
   - Keep the motion readable at mobile size.

5. Separate layers when quality matters.
   - Character body sheet
   - Weapon slash/VFX sheet
   - Dust/smoke/impact sheet
   - Ambient overlay sheet

6. Add negative constraints.
   - Prevent chibi/cute redesigns.
   - Prevent blurred or painterly pixels.
   - Prevent inconsistent frame sizes.
   - Prevent floating feet, cropped weapons, and random costume changes.

7. Validate the result before accepting it.
   - Check whether every frame uses the same scale.
   - Check whether the feet align to the baseline.
   - Check whether the character identity stayed intact.
   - Check whether the grid can be sliced cleanly.
   - Check whether the result needs manual cleanup in Aseprite/Krita/Photoshop.

## Non-Negotiable Sprite Rules

Always include these constraints for sprite sheets:

```text
Consistent character scale across all frames.
Consistent bottom-center pivot logic.
Feet aligned to the same ground baseline unless the animation intentionally jumps.
Same frame canvas size for every frame.
No cropped body parts or cropped weapon.
Clean silhouette readable at mobile size.
Clean pixel clusters, no muddy noise.
No blur, no soft painting, no anti-aliased smearing.
No random redesign between frames.
```

For grounded animations, use:

```text
Baseline rule: both feet must align to the same ground line in every frame.
The character may change pose, but the visual anchor must remain stable.
Do not change the character's scale or crop between frames.
```

For airborne or dash animations, use:

```text
Keep the frame canvas and character scale consistent.
Keep the intended gameplay pivot predictable.
If the body rises, show the motion intentionally while preserving the same sprite scale.
```

## Reference Locking

When a reference image exists, use it as mandatory design control:

```text
Use the attached/latest approved character image as the canonical design reference.
Preserve the same established character identity, silhouette, outfit structure, hairstyle, sword design, scarf/cloak shape, color role, and overall pixel art style.
If multiple references are provided, prioritize the latest approved in-game sprite reference over older concept art.
Do not redesign the character. Only change the pose for the requested animation.
```

When facing direction or weapon hand matters, state it explicitly:

```text
Direction: facing right.
Weapon hand: keep the katana in the left hand.
Do not switch the weapon hand when changing direction.
Do not simply mirror the sprite if mirroring would make the weapon hand wrong.
Redraw the pose naturally while preserving hand dominance.
```

If the user asks for opposite facing:

```text
Create the same character facing the opposite direction from the reference.
Do not simply mirror the image.
Preserve the exact same identity, outfit, weapon, silhouette logic, and hand dominance.
```

## Recommended Frame Counts

Use conservative frame counts for AI generation. More frames increase the risk of character drift.

| Animation Type | Recommended Frames | Notes |
|---|---:|---|
| Idle | 4-6 | Small cloth/hair breathing motion only |
| Walk | 6-8 | Clear foot cycle, stable body scale |
| Run | 6-8 | Stronger lean and cloth motion |
| Dash | 4-6 | Better with separate afterimage/VFX layer |
| Back step | 4-6 | Watch baseline and scale carefully |
| Light attack | 5-6 | Clear anticipation, slash, recovery |
| Heavy attack | 6-8 | More anticipation and follow-through |
| Parry | 4-6 | Strong readable guard pose |
| Hurt | 3-5 | Short recoil, no major redesign |
| Death | 6-8 | Break into stages if complex |
| Boss special | 6-10 | Consider separate VFX layers |

If the animation is complex, split it into smaller prompts:

1. Anticipation sheet
2. Active slash/action sheet
3. Recovery sheet
4. Separate VFX sheet

## Canvas and Sheet Specification

Always define both per-frame and total sheet sizes. Examples:

```text
Frame count: 6 frames
Frame layout: 3 frames on the top row and 3 frames on the bottom row
Canvas per frame: 160x128 pixels
Total sheet size: 480x256 pixels exactly
Direction: facing right
Background: solid pure chroma green (#00FF00), flat single-color background, no checkerboard, no fake transparency, no gradient
Pivot logic: bottom center
Baseline rule: both feet in every frame must align correctly
```

For smaller prototype sprites:

```text
Frame count: 6 frames
Frame layout: 6 frames in one horizontal row
Canvas per frame: 64x64 pixels
Total sheet size: 384x64 pixels exactly
Direction: facing right
Background: solid pure chroma green (#00FF00)
Pivot logic: bottom center
```

For mobile-readable combat sprites, prefer larger source frames such as 128x128, 160x128, 192x160, or 256x192, then scale down in-engine if needed using nearest-neighbor filtering.

## Background Rules

Use backgrounds according to asset type:

| Asset Type | Recommended Background | Reason |
|---|---|---|
| Character sprite | Solid pure chroma green `#00FF00` | Easy keying/cutout |
| Hard-edged VFX | Solid pure chroma green `#00FF00` or magenta `#FF00FF` | Easy separation |
| UI icon | Solid color or transparent only if the model supports true alpha | Avoid fake checkerboard |
| Fog/mist/smoke overlay | Pure black `#000000` | Useful for screen/additive or black-to-alpha workflow |
| Ash/embers overlay | Pure black `#000000` if soft atmospheric; chroma if hard-edged particles | Depends on blending method |
| Final background illustration | Normal painted/pixel background | Not a cutout asset |

Never request "transparent if possible" for AI sprite generation unless the tool reliably supports true alpha. Prefer a flat chroma key background.

For chroma key:

```text
Background: solid pure chroma green (#00FF00), flat single-color background, no checkerboard, no fake transparency, no gradient, no shadows cast onto the background.
```

For black-to-alpha atmospheric overlays:

```text
Background: pure black (#000000).
Create only soft fog/mist/smoke/ash light values on black.
No chroma green.
No scenery.
No character.
```

## Style Rules for Dark Anime Pixel Duel Games

When working on a dark anime sword-duel game, use:

```text
Style: 2D side-view dark anime pixel art, serious tone, strong silhouette, clean pixel clusters, mobile readability, restrained palette, sharp gameplay readability.
Mood: quiet, skilled, intense, lonely, dangerous, elegant.
Avoid: cute, chibi, comedic, toy-like, overly bright fantasy, soft painterly rendering.
```

For a protagonist swordsman:

```text
Lean unnamed swordsman, dark blue-black clothing, subtle cyan accents, katana with faint cyan glow, scarf/short cloak/waist cloth movement, cool determined posture, not cute, not bulky, not comedic.
```

For bosses:

```text
Readable boss silhouette, slightly larger and heavier presence than the player, distinctive weapon and posture, clear attack wind-up shapes, no excessive detail that becomes muddy at mobile size.
```

## Animation Motion Language

Describe animation using gameplay-readable phases.

For idle:

```text
Animation: idle breathing loop.
Motion: subtle torso rise/fall, slight cloth movement, minimal sword movement, feet planted, calm ready stance.
Keep the silhouette stable and readable.
```

For dash/back step:

```text
Animation: quick back step evasive movement.
Motion: compressed anticipation, rapid backward slide, cloth trailing behind, then stable recovery stance.
Keep character scale consistent. Do not make later frames larger than idle.
Keep the feet and gameplay pivot visually stable.
```

For light attack:

```text
Animation: quick katana slash attack.
Motion order: ready stance, anticipation, fast slash, slash follow-through, recovery.
The sword arc must be readable.
Do not let the slash trail hide the hands, face, or body silhouette.
```

For two-handed attack:

```text
Animation: continuous two-handed katana slash attack.
Motion: both hands grip the katana, torso twists into anticipation, blade cuts in a strong readable arc, cloth follows the motion, then the body returns to combat stance.
The attack should feel sharp, controlled, and deadly.
```

For death:

```text
Animation: death/fall sequence.
Motion order: impact reaction, loss of balance, knees weaken, body falls, final still pose.
Keep the character identity visible. Do not dissolve the body unless specifically requested.
```

## VFX Layer Strategy

Separate VFX from character sheets whenever possible.

Use separate layers for:

- Blue-white crescent slash trail
- Sword glow
- Impact spark
- Dust burst
- Ground scrape
- Afterimage
- Fog/mist
- Ash/embers

Character sheet prompt:

```text
Create the character animation only.
No large slash trail.
No dust cloud.
No impact spark.
Leave enough visual clarity around the body and weapon.
```

Slash VFX prompt:

```text
Create a separate 2D pixel art slash VFX sprite sheet.
Blue-white crescent slash trail.
No character.
No weapon handle.
No scenery.
Solid pure chroma green (#00FF00) background.
Each frame must align to the same canvas and timing as the character attack.
```

Fog overlay prompt:

```text
Create a 2D side-view pixel art fog overlay layer.
Low drifting fog only.
Pure black (#000000) background for black-to-alpha workflow.
No chroma green.
No characters, no buildings, no scenery.
Subtle, sparse, readable, not covering the combat silhouettes.
```

## Prompt Template: General Sprite Sheet

Use this template when the user asks for a sprite sheet:

```text
Create a 2D side-view pixel art sprite sheet for [CHARACTER_NAME] from [GAME_NAME].

Use the attached/latest approved character image as the canonical design reference.
Preserve the same character identity, silhouette, outfit structure, hairstyle, weapon design, cloth/scarf/cloak shape, color role, and overall pixel art style.
Do not redesign the character.

Asset type: [player/boss/enemy] [animation type] sprite sheet
Animation: [specific animation]
Frame count: [number] frames
Frame layout: [columns/rows]
Canvas per frame: [width]x[height] pixels
Total sheet size: [width]x[height] pixels exactly
Direction: facing [left/right]
Background: solid pure chroma green (#00FF00), flat single-color background, no checkerboard, no fake transparency, no gradient
Pivot logic: bottom center
Baseline rule: both feet in every grounded frame must align to the same ground line

Motion details:
[Describe anticipation, action, follow-through, and recovery.]

Style:
2D side-view dark anime pixel art, strong silhouette, clean pixel clusters, mobile readability, restrained palette, sharp gameplay readability.

Quality constraints:
Consistent scale across all frames.
Consistent character proportions across all frames.
No cropped weapon or body parts.
No blurred pixels.
No painterly rendering.
No chibi/cute style.
No random costume changes.
No inconsistent frame spacing.
```

## Prompt Template: Character Concept Lock

Use this before making animation if the character design is not yet stable:

```text
Create a 2D pixel art character concept for [CHARACTER_NAME] from [GAME_NAME].

Purpose: canonical character design reference for future sprite sheets.
Style: 2D side-view compatible dark anime pixel art, strong silhouette, clean pixel clusters, mobile readability.

Character design:
[Describe body type, outfit, hairstyle, weapon, colors, mood, and signature shapes.]

Pose:
Neutral combat-ready side-view pose, facing [left/right].
Full body visible.
Weapon clearly visible.
Feet planted on a simple ground line.

Background:
Solid pure chroma green (#00FF00), no checkerboard, no fake transparency.

Output goal:
This image will be used as the canonical reference for all future animation prompts.
```

## Prompt Template: Repair an Existing Sprite Sheet

Use this when the user needs corrections:

```text
Edit the provided sprite sheet while preserving the existing character design.

Fix only the following issues:
[List exact issues.]

Preserve:
Same character identity.
Same outfit.
Same hairstyle.
Same weapon design.
Same frame count.
Same frame layout.
Same canvas size.
Same background color.

Corrections:
Align all grounded feet to the same baseline.
Make character scale consistent across frames.
Keep the bottom-center pivot visually stable.
Do not crop the weapon.
Do not redesign the character.
Do not change the animation timing unless necessary.
```

## Prompt Template: Opposite Direction Without Wrong Hand

Use this when changing facing direction but preserving weapon hand:

```text
Create the same character facing [left/right].

Use the provided image as the canonical design reference.
Do not simply mirror the image.
Redraw the pose naturally for the new direction.

Important hand rule:
The character must still hold the katana in the [left/right] hand.
Do not switch the weapon to the other hand.
Preserve the same hand dominance naturally in side view.

Preserve:
Character identity, hairstyle, outfit, scarf/cloak, sword design, color palette, body proportions, and dark anime pixel art style.
```

## Negative Prompt Library

Add relevant negative constraints to every production prompt:

```text
Avoid: chibi proportions, cute style, comedic style, toy-like design, random armor, random hairstyle, changed weapon, changed weapon hand, inconsistent costume, inconsistent face, inconsistent frame size, inconsistent character scale, floating feet, uneven baseline, cropped sword, cropped body, blurry pixels, soft painting, smooth vector art, muddy pixel noise, excessive glow, slash trail hiding the body, fake transparency checkerboard, gradient background.
```

For mobile readability:

```text
Avoid tiny unreadable details, over-detailed clothing, low contrast silhouette, thin unclear weapon shapes, noisy texture, excessive particles around the character.
```

## Quality Control Checklist

Before accepting an AI image, check:

- Does the character still look like the same character?
- Is the weapon the same weapon?
- Is the weapon held in the correct hand?
- Are all frames the same size?
- Is the total sheet size correct?
- Is the grid sliceable?
- Are the feet aligned to the intended baseline?
- Is the scale consistent compared with idle?
- Is the animation readable at small mobile size?
- Are important body parts or weapon tips cropped?
- Is the background a flat usable key color?
- Is there fake transparency or checkerboard?
- Are the pixels clean or muddy?
- Does VFX hide the gameplay silhouette?

If three or more checks fail, regenerate with stricter constraints instead of trying to salvage the image.

## Common Failure Repairs

When the sprite floats after resizing:

```text
The issue is not only scale; the frame height and visual anchor changed.
Use a consistent canvas height and align the feet to the same baseline.
Keep bottom-center pivot logic across all frames.
```

When back step looks larger than idle:

```text
Match the character's body height and head size to the approved idle sprite.
Do not enlarge the character during the back step.
Only the pose and cloth motion should change.
```

When the AI changes the character:

```text
Use the approved character image as the canonical reference.
Do not redesign the outfit, hairstyle, sword, scarf, body proportions, or color palette.
Only change the pose for the requested animation.
```

When slash VFX ruins readability:

```text
Reduce the slash trail opacity and visual density.
Keep the face, torso, hands, and sword grip readable.
Move large VFX to a separate sprite sheet.
```

When the model creates fake transparency:

```text
Use solid pure chroma green (#00FF00), flat single-color background.
No checkerboard.
No fake transparency.
No gradient.
```

## Game Engine Readiness Notes

For Godot or similar 2D engines:

- Prefer source sprites large enough for mobile readability.
- Use nearest-neighbor scaling/import settings.
- Keep sprite origins consistent across animations.
- Align animation sets by bottom-center gameplay pivot.
- Avoid trimming each frame differently if the engine depends on a stable frame canvas.
- If individual PNG frames have different heights, the visual center will shift unless the pivot/offset is corrected.
- For sprite sheets, stable canvas size is usually safer than tight per-frame cropping.

Use this principle:

```text
Game animation consistency comes from stable canvas, stable pivot, stable baseline, and stable scale.
Tight cropping every frame may look neat in an image editor but can cause floating or shaking in-engine.
```

## Final Response Behavior

When responding to the user:

- Provide a production-ready prompt, not vague advice, when the user asks for generation.
- Ask for missing technical values only when necessary; otherwise choose conservative defaults.
- If the user is a beginner, explain exactly which part of the prompt controls which problem.
- For image prompts, keep the final prompt easy to copy.
- If the prompt is for an existing project, preserve its established art direction and naming.
- If the user is working on Last Blade Trial / ดาบไร้นาม, default to dark anime pixel duel, 2D side-view, strong silhouette, clean pixel clusters, mobile readability, and solid chroma backgrounds for hard-edged sprites.
