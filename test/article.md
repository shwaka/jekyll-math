---
magiccomment: "-*- engine: liquid -*-"
layout: mylayout
---

# Introduction
In this article, we prove an awesome theorem.

# Background
hoge

{% theorem label=foo caption=hoge%}
  content of theorem
{% endtheorem %}

{% cref foo %}
{% cref hoge %}
{% cref bar%}

{% theorem label=bar %}
  content of theorem
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

{% cref foo %}

{% remark %}
  {{ page.layout }}
{% endremark %}

{% example %}
  This is an example of {% cref baz %}.
{% endexample %}
# Proof of main theorem
fuga
- hoge
  - fuga
    piyo
a

{% zotica \sb<x><0> = \frac<-b \pm> \sqrt<\sp<b><2> - 4 ac>><2 a> %}
