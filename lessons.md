---
layout: page-wide
title: List of all lessons
permalink: /lessons/
---

<div style="text-align: center;">
  <form action="/search/" method="get" style="width: 100%; max-width: 720px; position: relative; text-align: left; margin: 0 auto;">
    <div style="position: relative; display: table; width: 100%;">
      <input style="font-size: 14px;  float: left; width: 80%;" type="text" id="search-box" name="query" placeholder="Search by song, artist, or lesson number">
      <input type="submit" value="Search" id="search-button" style="float: left; width: 20%; max-width: 120px;">
    </div>
  </form>
</div>

{% comment %}
  # ======================================================
  # Figure out number of the latest lesson: latest_lesson_number
  # ======================================================
{% endcomment %}
{% for i in (1..1000) reversed %}
  {% assign song = site.lessons | where: 'slug', i %}
  {% if song[0] %}
    {% assign latest_lesson_number = song[0].slug %}
    {% break %}
  {% endif %}
{% endfor %}

{% comment %}
  # ======================================================
  # How many lessons have PDF v2
  # ======================================================
{% endcomment %}
{% assign pdf_v2_count = 0 %}
{% assign pdf_v1_count = 0 %}
{% assign pdf_noV_count = 0 %}
{% for i in (1..site.lessons.size) reversed %}
  {% assign song = site.lessons | where: 'slug', i %}
  {% if song[0].pdf_version == "v2" %}
    {% assign pdf_v2_count = pdf_v2_count | plus:1 %}
  {% elsif song[0].pdf_version == "v1" %}
    {% assign pdf_v1_count = pdf_v1_count | plus:1 %}
  {% elsif song[0].patreon_lesson_url %}
    {% assign pdf_noV_count = pdf_noV_count | plus:1 %}
  {% endif %}
{% endfor %}

<script src="/js/jquery.js"></script>
<script>
{% assign num_to_show = latest_lesson_number %}
{% assign shown_so_far = 0 %}
  var lessons = [
{% for i in (1..num_to_show) reversed %}
  {% assign lesson = site.lessons | where: 'slug', i %}
  {% if lesson[0] %}
    {% assign shown_so_far = shown_so_far | plus:1 %}
    {% if shown_so_far == num_to_show %}
      {% break %}
    {% endif %}
      {

    {% assign lesson_title = lesson[0].title | replace: '"','\"' %}
    {% assign lesson_patreon_url_size = lesson[0].patreon_lesson_url %}

    {% case lesson[0].category %}
      {% when 'full_song' %}
        {% assign lesson_category = "Full Song" %}
      {% when 'playalong_cover' %}
        {% assign lesson_category = "Play-along Cover" %}
      {% when 'warmup' %}
        {% assign lesson_category = "Warm Up Exercise" %}
      {% when 'practice_log' %}
        {% assign lesson_category = "Practice Log" %}
      {% when 'tip_technique' %}
        {% assign lesson_category = "Tip & Technique" %}
      {% when 'generic' %}
        {% assign lesson_category = "General & About This Channel" %}
    {% endcase %}
        "title": "{{ lesson_title }}",
        "category": "{{ lesson_category }}",
        "url": "{{ lesson[0].url }}",
        "date": "{{ lesson[0].date_published | date: '%b %-d, %Y' }}",
        "patreon_url": "{{ lesson[0].patreon_lesson_url }}",
        "pdf_image": "{% if lesson[0].patreon_lesson_url %}<img src='/images/pdfs/preview/{{ lesson[0].slug}}.jpg' />{% endif %}",
        "pdf_v2": "{{ lesson[0].pdf_version }}",
        "slug": "{{ lesson[0].slug }}"
      },
  {% endif %}
{% endfor %}
  ];
$(document).ready(function(){

  for (i = 0; i < {{latest_lesson_number}}; i++) {
    $('#all_lessons_list tr:last').after('<tr data-pdf-v2="'+ lessons[i].pdf_v2 +'"><td>' + lessons[i].slug + '</td>\
                                    <td>' + lessons[i].pdf_image + '</td>\
                                    <td><a href="' + lessons[i].url + '">' + lessons[i].title + '</a></td>\
                                    <td>' + lessons[i].date + '</td>\
                                    <td>' + lessons[i].category + '</td>\
                                    <td><a data-patreon-url="' + lessons[i].patreon_url + '" href="' + lessons[i].patreon_url + '">PDF</td>\
                                    <td></td></tr>');
  }


});
</script>
<script src="/js/search.js"></script>












## List of all lessons
I have made {{latest_lesson_number}} YouTube videos so far... {{ site.lessons.size }} of which have pages on this website. They are listed below. You can also [browse by category](/search) if you're looking for something specific!

{% assign pdf_total_boi = pdf_v1_count | plus: pdf_v2_count %}

<div class="tile_metric">
  <h3>PDF no version</h3>
  <p>{{ pdf_noV_count }}</p>
</div>
<div class="tile_metric">
  <h3>PDF some version</h3>
  <p>{{ pdf_total_boi }}</p>
</div>
<hr />
<div class="tile_metric">
  <h3>PDF v1</h3>
  <p>{{ pdf_v1_count }}</p>
</div>
<div class="tile_metric">
  <h3>PDF v2</h3>
  <p>{{ pdf_v2_count }}</p>
</div>
<hr />


<table id="all_lessons_list">
  <tbody>
    <tr>
      <th>Lesson ID</th>
      <th>Date</th>
      <th>PDF Preview</th>
      <th>Title</th>
      <th>Category</th>
      <th>PDF</th>
      <th>Redirects To?</th>
    </tr>
  </tbody>
</table>
