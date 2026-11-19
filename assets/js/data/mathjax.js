---
layout: compress
# Overrides the theme's MathJax config.
# WARNING: Don't use '//' to comment out code, use '{% comment %}' and '{% endcomment %}' instead.
---

{%- comment -%}
  fonts: served from this site instead of cdn.jsdelivr.net
  displayAlign left: display math is left-aligned, as on the old blog
  displayOverflow scroll: long equations scroll sideways on narrow screens
{%- endcomment -%}

MathJax = {
  loader: {
    paths: { fonts: '{{ "/assets/mathjax-fonts" | relative_url }}' }
  },
  tex: {
    inlineMath: [
      ['$', '$'],
      ['\\(', '\\)']
    ],
    displayMath: [
      ['$$', '$$'],
      ['\\[', '\\]']
    ],
    tags: 'ams'
  },
  output: {
    displayAlign: 'left',
    displayIndent: '0',
    displayOverflow: 'scroll'
  }
};
