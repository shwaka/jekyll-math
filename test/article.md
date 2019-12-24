---
magiccomment: "-*- engine: liquid -*-"
layout: mylayout
---

# Introduction
In this article, we prove an awesome theorem.

# Background
hoge

{% theorem foo %}
  content of theorem
{% endtheorem %}

{% cref foo %}
{% cref hoge %}
{% cref bar%}

{% theorem bar %}
  content of theorem
{% endtheorem %}

{% definition hoge %}
  何かの定義
{% enddefinition %}

{% proposition aaa %}
  これは命題
{% endproposition %}
{% proof %}
  {% cref hoge %} から明らかに成り立つ．
{% endproof %}
{% theorem baz %}
  This is an awesome theorem!!!
  <pre>hoge</pre>
{% endtheorem %}

This is some text!!!
<pre>hoge</pre>

{% cref foo %}

{% remark rem %}
  {{ page.layout }}
{% endremark %}

{% example ex %}
  This is an example of {% cref baz %}.
{% endexample %}
# Proof of main theorem
fuga
- hoge
  - fuga
    piyo
a

{% zotica \sb<x><0> = \frac<-b \pm> \sqrt<\sp<b><2> - 4 ac>><2 a> %}
