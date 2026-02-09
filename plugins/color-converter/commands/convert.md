---
argument-hint: <color-value>
description: Convert a color between hex, RGB, and HSL formats
---

# Color Converter

Convert colors between different formats.

## Instructions

1. Read the color value from: **$ARGUMENTS**
2. Detect the input format (hex like #FF5733, RGB like rgb(255,87,51), HSL like hsl(11,100%,60%), or named like "coral")
3. Convert to all other formats and display:
   - Hex: #RRGGBB
   - RGB: rgb(R, G, B)
   - HSL: hsl(H, S%, L%)
   - CSS name (if one exists)

## Example

`/color-converter:convert #FF5733`
`/color-converter:convert rgb(255,87,51)`
