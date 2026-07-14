# Flower images

Place five flower images (transparent background, .webp or .png) in this
folder, named by their left-to-right position in the garland:

- `flower1.webp` (or `.png`) — leftmost bloom
- `flower2.webp`
- `flower3.webp`
- `flower4.webp`
- `flower5.webp` — rightmost, largest bloom

When all five files are present, the site renders them as the flower band in
the hero and details sections. If any are missing, the site falls back to the
painted (vector) flowers.

Make sure you have the rights to whatever images you place here (e.g. images
from a template you have purchased/licensed, or free stock images with a
suitable license). After adding files, rebuild: `flutter build web --release`.
