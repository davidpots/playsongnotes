---
layout: page-wide
title: List of all MN lessons to add to YT
permalink: /lessons-key/
---

<div style="text-align: center;">
  <form action="/search/" method="get" style="width: 100%; max-width: 720px; position: relative; text-align: left; margin: 0 auto;">
    <div style="position: relative; display: table; width: 100%;">
      <input style="font-size: 14px;  float: left; width: 80%;" type="text" id="search-box" name="query" placeholder="Search by song, artist, or lesson number">
      <input type="submit" value="Search" id="search-button" style="float: left; width: 20%; max-width: 120px;">
    </div>
  </form>
</div>

  {% assign lessons = site.lessons | sort: 'song_title' %}

{% for l in lessons | where: "category", "full_song" %}
  {% if l.tags contains "Key of C" %}
  <strong>{{ l.song_title }}</strong> by {{ l.artist}} <a href="https://playsongnotes.com/lessons/{{l.slug}}">https://playsongnotes.com/lessons/{{l.slug}}</a>
  {% endif %}
{% endfor %}



<h1>Songs with COPYRIGHT pdf version</h1>

<ul>
  {% assign lessons = site.lessons | where: "pdf_version","copyright" | sort: 'song_title' %}
  {% for l in lessons %}
    {% if l.category == "full_song" %}
      <li>
        <p><a href="https://playsongnotes.com/{{ l.url }}"><strong>{{ l.song_title }}</strong></a> by {{l.artist}}</p>
      </li>
    {% endif %}
  {% endfor %}
</ul>

<h1>Songs with V2 pdf version</h1>

<ul>
  {% assign lessons = site.lessons | where: "pdf_version","v2" | sort: 'song_title' %}
  {% for l in lessons %}
    {% if l.category == "full_song" %}
      <li>
        <p><a href="https://playsongnotes.com/{{ l.url }}"><strong>{{ l.song_title }}</strong></a> by {{l.artist}}</p>
      </li>
    {% endif %}
  {% endfor %}
</ul>

<h1>Songs with V1 pdf version</h1>

<ul>
  {% assign lessons = site.lessons | where: "pdf_version","v1" | sort: 'song_title' %}
  {% for l in lessons %}
    {% if l.category == "full_song" %}
      <li>
        <p><a href="https://playsongnotes.com/{{ l.url }}"><strong>{{ l.song_title }}</strong></a> by {{l.artist}}</p>
      </li>
    {% endif %}
  {% endfor %}
</ul>
