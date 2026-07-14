# Couple silhouette

Save the couple silhouette here as `couple.png` (or `couple.webp`) — a
transparent-background PNG/WebP of a solid silhouette, like the walking
hand-in-hand couple picked from the stock listing.

The app tints it to the wedding burgundy automatically at render time, so
the source colour (black or anything else) does not matter — only the shape
and the transparent background do.

Make sure the file comes from the actual download of a licensed/free listing,
not a screenshot of the preview page. Until the file is present, the site
falls back to the built-in painted silhouette. After adding it, rebuild:
`flutter build web --release`.
