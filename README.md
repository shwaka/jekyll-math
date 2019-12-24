- Generate `zotica.js` by `zotica -j -o zotica.js`.
- Generate `zotica.css` by `zotica -s -o zotica.css`.
- Download `font.otf` from [ZenithalMathWeb/font.otf](https://github.com/Ziphil/ZenithalMathWeb/blob/master/source/zotica/resource/font.otf)
  and put it at the same directory with `zotica.css`.

Then write the following in the header of your layout html.
```html
  <script src="{{ site.baseurl }}/assets/js/zotica.js"></script>
  <link rel="stylesheet" type="text/css" href="{{ site.baseurl }}/assets/css/zotica.css"/>
```
