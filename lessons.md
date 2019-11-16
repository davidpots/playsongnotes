---
layout: page
title: List of all lessons
permalink: /lessons/
---

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


## List of all lessons
I have made {{latest_lesson_number}} YouTube videos so far - {{ site.lessons.size }} of which have pages on this website. They are listed below.

<table class="lesson-table">
{% for i in (1..300) %}
{% assign song = site.lessons | where: 'slug', i %}
  {% if song[0] %}
<tr>
  <td>Lesson #{{song[0].slug }}</td>
  <!-- <td>{{song[0].date_published | date: "%b %-d, %Y"}}</td> -->
  <td>
    {% if song[0].category == "full_song" %}
      <a href="{{ song[0].url | relative_url }}">"{{song[0].song_title}}" by {{ song[0].artist }}</a>
    {% else %}
      <a href="{{ song[0].url | relative_url }}">{{song[0].title}}</a>
    {% endif %}
  </td>
  <td>
    {% if song[0].category == "full_song" %}
      Full Song Lesson
    {% elsif song[0].category == "warmup" %}
      Warm Up Exercise
    {% elsif song[0].category == "tip_technique" %}
      Tip & Technique
    {% elsif song[0].category == "practice_log" %}
      Practice Log
    {% endif %}
  </td>
  <td>
    {% if song[0].patreon_lesson_url %}
      <a href="{{ song[0].patreon_lesson_url }}">PDF</a>
    {% endif %}
  </td>
</tr>
  {% endif %}
{% endfor %}
</table>
