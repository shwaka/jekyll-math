---
magiccomment: "-*- engine: liquid -*-"
layout: mylayout
---

# Introduction
{% theorem label=quadratic %}
  {% caption %}
    二次方程式の解の公式
    {% cite wikipedia-ja %}
  {% endcaption %}
  {% zotica a \neq> 0 %} に対し，二次方程式
  {% zotica a\sp<x><2> + bx + c = 0 %}
  の(重複を込めて)2つの解は
  {% zotica x = \frac<-b \pm> \sqrt<\sp<b><2> - 4 ac>><2 a> %}
  で与えられる．
{% endtheorem %}
{% proof %}
  左辺を平方完成すれば良い．
{% endproof %}

{% cref quadratic %} の根号の中に現れる式は重要である．

{% definition caption="判別式" %}
  {% zotica \sp<b><2> - 4ac %} を *判別式* という．
{% enddefinition %}

{% example %}
  数式のテスト． $$ a\sp<x><2> + bx + c = 0 $$ はインライン数式です．

  下の数式は別行立て数式です．

  $$ a\sp<x><2> + bx + c = 0 $$
{% endexample %}

  数式のテスト． $$ a\sp<x><2> + bx + c = 0 $$ はインライン数式です．

  下の数式は別行立て数式です．

  $$ a\sp<x><2> + bx + c = 0 $$

  これも別行立て数式です．

  $$ x = \frac<-b \pm> \sqrt<\sp<b><2> - 4 ac>><2 a> $$

{% cref hoge %}
{% cref bar%}

{% theorem label=bar %}
  - list
  - list
{% endtheorem %}

{% definition label=hoge caption="foo bar" %}
  何かの定義
{% enddefinition %}

{% proposition %}
  これは命題
{% endproposition %}
{% proof %}
  {% cref hoge %} から明らかに成り立つ．
{% endproof %}
{% theorem label=baz %}
  {% caption %}
    This is a caption for
    {% cref baz %}.
  {% endcaption %}
  This is an awesome theorem!!!
  <pre>hoge</pre>
{% endtheorem %}

This is some text!!!
<pre>hoge</pre>

{% cref quadratic %}

{% remark %}
  {{ page.layout }}
{% endremark %}

{% example %}
  This is an example of {% cref baz %}.
{% endexample %}

# References
{% bibliography %}
{% bibitem wikipedia-ja Wja %}
  [二次方程式の解の公式 - Wikipedia](https://ja.wikipedia.org/wiki/%E4%BA%8C%E6%AC%A1%E6%96%B9%E7%A8%8B%E5%BC%8F%E3%81%AE%E8%A7%A3%E3%81%AE%E5%85%AC%E5%BC%8F)
{% endbibitem %}
{% bibitem wikipedia-en Wen %}
  [Quadratic formula - Wikipedia](https://en.wikipedia.org/wiki/Quadratic_formula)
{% endbibitem %}
{% endbibliography %}
