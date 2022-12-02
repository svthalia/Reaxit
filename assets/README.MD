# Assets

## Placeholder Images

The placeholder images have background color `#c5c5c5` and foreground `#ffffff`. They are made in GIMP from SVG files as follows:

- Create a background canvas of twice the required size (e.g. 900x500 for the 450x250 map placeholder), with the background color.
- Add the SVG in the right size (e.g. 400x400 for the map placeholder), and paint it to foreground color.
- Scale the imge to the right size.
- Save and export it to PNG, unchecking any stored info, such as Exif or color profile. If the image does not need to be transparant, do check 'save background color' to reduce file size.

Some of them use SVGs of Material Design icons, that can be downloaded from <https://fonts.google.com/icons>.

## Images on background

Some images (sad-cloud.png, tosti-logo.png) are used directly on the app's background, with transparency around it. To have a nice amount of contrast both in dark mode and in light mode, we use a color and transparency. The app's light background is `#fafafa`. The dark background is `#111111`. In order to use a single image that looks good on both, we use color `#898989` which is halfway between the two backgrounds. The transparency is 0.45, so that the image on a background looks good in both modes.

## Google Fonts

See https://pub.dev/packages/google_fonts#font-bundling-in-assets.