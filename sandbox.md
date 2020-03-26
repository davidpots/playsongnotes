---
layout: page
title: Sandbox of Song Notes layout stuff
permalink: /sandbox/
---

## Search test

<div class="row">
  <div class="col col-3">
    <div style="">
      <h4>Browse by category</h4>
      <ul>
        <li><a href="?query=Full Song Lesson">Full Song Lesson</a></li>
        <li><a href="?query=Play-Along Covers">Play-Along Covers</a></li>
        <li><a href="?query=Warm Up Exercises">Warm Up Exercises</a></li>
        <li><a href="?query=Tips & Techniques">Tips & Techniques</a></li>
      </ul>
      <h4>Browse by song decade</h4>
      <ul>
        <li><a href="?query=2000s">2000s</a></li>
        <li><a href="?query=1990s">1990s</a></li>
        <li><a href="?query=1980s">1980s</a></li>
        <li><a href="?query=1970s">1970s</a></li>
        <li><a href="?query=1960s">1960s</a></li>
        <li><a href="?query=1950s">1950s</a></li>
      </ul>
      <h4>Browse by genre</h4>
      <ul>
        <li><a href="?query=Classic Rock">Classic Rock</a></li>
        <li><a href="?query=Country">Country</a></li>
        <li><a href="?query=Rock">Rock</a></li>
        <li><a href="?query=Pop">Pop</a></li>
        <li><a href="?query=Holiday">Holiday</a></li>
      </ul>
      <h4>Browse by technique</h4>
      <ul>
        <li><a href="?query=Learning Chords">Learning Chords</a></li>
        <li><a href="?query=Strumming">Strumming</a></li>
        <li><a href="?query=Fingerstyle">Fingerstyle</a></li>
        <li><a href="?query=Travis Picking">Travis Picking</a></li>
      </ul>
      <h4>Browse by musical key</h4>
      <ul>
        <li><a href="?query=Key of C">Key of C</a></li>
        <li><a href="?query=Key of D">Key of D</a></li>
        <li><a href="?query=Key of E">Key of E</a></li>
        <li><a href="?query=Key of F">Key of F</a></li>
        <li><a href="?query=Key of G">Key of G</a></li>
        <li><a href="?query=Key of A">Key of A</a></li>
      </ul>
      <h4>Browse by popular artist</h4>
      <ul>
        <li><a href="?query=Johnny Cash">Johnny Cash</a></li>
        <li><a href="?query=Tyler Childers">Tyler Childers</a></li>
        <li><a href="?query=Tom Petty">Tom Petty</a></li>
        <li><a href="?query=Neil Young">Neil Young</a></li>
        <li><a href="?query=Nirvana">Nirvana</a></li>
        <li><a href="?query=Lynyrd Skynyrd">Lynyrd Skynyrd</a></li>
        <li><a href="?query=Willie Nelson">Willie Nelson</a></li>
        <li><a href="?query=John Denver">John Denver</a></li>
        <li><a href="?query=Guns N' Roses">Guns N' Roses</a></li>
      </ul>
    </div>
  </div>
  <div class="col col-9">
    <div style="background: green; height: 1800px;">col-8</div>
  </div>
</div>

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

{% assign num_to_show = 10 %}
{% assign shown_so_far = 0 %}

{% for i in (1..1000) reversed %}
  {% assign song = site.lessons | where: 'slug', i %}
  {% if song[0] %}
    {% assign shown_so_far = shown_so_far | plus:1 %}
    {% if shown_so_far == num_to_show %}
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



# Stuff from old lessons page

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
