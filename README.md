# Aim of this gem
The aim of this gem is to write simple mathematical documents within jekyll.
This gem contains two features

- theorem environments with cross references
- mathematical equations in markdown (typeset by [Zotica](https://github.com/Ziphil/ZenithalMathWeb))

# Preparation for zotica

- Generate `zotica.js` by `zotica -j -o zotica.js`.
- Generate `zotica.css` by `zotica -s -o zotica.css`.
- Download `font.otf` from [ZenithalMathWeb/font.otf](https://github.com/Ziphil/ZenithalMathWeb/blob/master/source/zotica/resource/font.otf)
  and put it at the same directory as `zotica.css`.

Then write the following in the header of your layout html.
```html
  <script src="{{ site.baseurl }}/assets/js/zotica.js"></script>
  <link rel="stylesheet" type="text/css" href="{{ site.baseurl }}/assets/css/zotica.css"/>
```
