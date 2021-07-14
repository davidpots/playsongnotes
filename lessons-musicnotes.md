---
layout: page-wide
title: List of all Musicnotes lessons
permalink: /lessons-musicnotes/
---

<div style="text-align: center;">
  <form action="/search/" method="get" style="width: 100%; max-width: 720px; position: relative; text-align: left; margin: 0 auto;">
    <div style="position: relative; display: table; width: 100%;">
      <input style="font-size: 14px;  float: left; width: 80%;" type="text" id="search-box" name="query" placeholder="Search by song, artist, or lesson number">
      <input type="submit" value="Search" id="search-button" style="float: left; width: 20%; max-width: 120px;">
    </div>
  </form>
</div>

<h1>Songs with MUSICNOTES pdf version</h1>

<ul>
  {% assign lessons = site.lessons | where: "pdf_version","musicnotes" | sort: 'song_title' %}
  {% for l in lessons %}
    <li>
      <p><a href="{{ l.musicnotes_url }}"><strong>{{ l.song_title }}</strong></a> by {{l.artist}}</p>
    </li>
  {% endfor %}
</ul>

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
