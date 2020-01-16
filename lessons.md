---
layout: page
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
    {% case lesson[0].category %}
      {% when 'full_song' %}
        {% assign lesson_category = "Full Song" %}
      {% when 'warmup' %}
        {% assign lesson_category = "Warm Up Exercise" %}
      {% when 'practice_log' %}
        {% assign lesson_category = "Practice Log" %}
      {% when 'tip_technique' %}
        {% assign lesson_category = "Tip & Technique" %}
    {% endcase %}
        "title": "{{ lesson_title }}",
        "category": "{{ lesson_category }}",
        "url": "{{ lesson[0].url }}",
        "patreon_url": "{{ lesson[0].patreon_lesson_url}}",
        "slug": "{{ lesson[0].slug }}"
      },
  {% endif %}
{% endfor %}
  ];
$(document).ready(function(){

  for (i = 0; i < {{latest_lesson_number}}; i++) {
    $('#search-results').append('<li class="song-listing"><h3><a href="'+ lessons[i].url +'"><span>'+ lessons[i].title +'</span></a></h3><p>Lesson #'+ lessons[i].slug +' • '+ lessons[i].category +'</p><p class="featured_label" data-patreon-url="' + lessons[i].patreon_url + '">PDF</p></li>');
  }

});
</script>
<script src="/js/search.js"></script>












## List of all lessons
I have made {{latest_lesson_number}} YouTube videos so far... {{ site.lessons.size }} of which have pages on this website. They are listed below.

<ul id="search-results" class="song-listing-wrapper"></ul>
