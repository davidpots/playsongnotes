---
layout: page
title: Sandbox of Song Notes layout stuff
permalink: /sandbox/
---

## Shows the first item successfully!

{% assign individual_post = site.lessons | where: 'slug', 1 %}

{% for song in individual_post %}
  {{ forloop.index }} - {{song.song_title}}
{% endfor %}

## Trying to count to arbitrary number with a loop

{% for i in (1..3) %}
  {{ i }}
{% endfor %}

## Trying to show first 10 lessons

{% for i in (1..3) %}
{% assign song = site.lessons | where: 'slug', i %}
  {% if song[0] %}
#{{ i }}: {{song[0].song_title}}
  {% endif %}
{% endfor %}

## What's the latest lesson number?

{% for i in (1..1000) reversed %}
  {% assign song = site.lessons | where: 'slug', i %}
  {% if song[0] %}
    <h1>{{song[0].slug}}</h1>
    {% break %}
  {% endif %}
{% endfor %}

<!-- <div class="song-listing">
  <h3><a href="">"Cowboy in the Jungle" by Jimmy Buffett</a></h3>
  <p>Lesson #284 • Full Song Lesson</p>
  <p class="featured_label"><a class="">PDF</a></p>
</div> -->

## Latest 10 lessons, starting with most recent

{% assign num_to_show = 11 %}
{% assign shown_so_far = 0 %}

{% for i in (1..1000) reversed %}
  {% assign song = site.lessons | where: 'slug', i %}
  {% if song[0] %}
    {% assign shown_so_far = shown_so_far | plus:1 %}
    {% if shown_so_far == 10 %}
      {% break %}
    {% endif %}


  <div class="song-listing">
    <h3>
    {% if song[0].category == "full_song" %}
<a href="{{ song[0].url | relative_url }}"><span>"{{song[0].song_title}}" by {{ song[0].artist }}</span></a>
    {% else %}
<a href="{{ song[0].url | relative_url }}"><span>{{song[0].title}}</span></a>
    {% endif %}
</h3>
    <p>Lesson #{{song[0].slug }} • {% if song[0].category == "full_song" %}Full Song Lesson{% elsif song[0].category == "warmup" %}Warm Up Exercise{% elsif song[0].category == "tip_technique" %}Tip & Technique{% elsif song[0].category == "practice_log" %}Practice Log{% endif %}</p>

{% if song[0].patreon_lesson_url %}
  <p class="featured_label"><a href="{{ song[0].url | relative_url }}" class="">PDF</a></p>
{% endif %}
  </div>

  {% endif %}
{% endfor %}





<hr />

{% assign last_lesson = site.lessons.last %}
{% assign last_lesson_slug = last_lesson.slug %}
<h1>{{last_lesson_slug}}</h1>


{% assign starting_point = site.lessons.size | minus:10 %}
{% for i in (1..300) reversed %}
{% assign test_song = site.lessons | where: 'slug', i %}
<h1>{{test_song[0].slug}}</h1>
{% break %}
{% endfor %}


{% for i in (1..300) reversed %}
{% assign song = site.lessons | where: 'slug', i %}
  {% if song[0] %}


  <div class="song-listing">
    <h3>
    {% if song[0].category == "full_song" %}
<a href="{{ song[0].url | relative_url }}"><span>"{{song[0].song_title}}" by {{ song[0].artist }}</span></a>
    {% else %}
<a href="{{ song[0].url | relative_url }}"><span>{{song[0].title}}</span></a>
    {% endif %}
</h3>
    <p>Lesson #{{song[0].slug }} • {% if song[0].category == "full_song" %}Full Song Lesson{% elsif song[0].category == "warmup" %}Warm Up Exercise{% elsif song[0].category == "tip_technique" %}Tip & Technique{% elsif song[0].category == "practice_log" %}Practice Log{% endif %}</p>

{% if song[0].patreon_lesson_url %}
  <p class="featured_label"><a href="{{ song[0].url | relative_url }}" class="">PDF</a></p>
{% endif %}
  </div>

  {% endif %}
{% endfor %}


## Big ole' table

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
