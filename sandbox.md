---
layout: page
title: Sandbox of Song Notes layout stuff
permalink: /sandbox/
---

<!-- &nbsp;&nbsp;•&nbsp;&nbsp;{{ l.date_published | date: '%b %-d, %Y' }} -->

## Aug 2021 stuff



### Landscape: songs

{% assign lessons = site.lessons | where: "category","full_song" | sort: 'date_published' | reverse %}

<div class="tile-wrapper clearfix">
{% for l in lessons limit:6 %}
  <div class="tile tile-landscape">
    <div class="tile-head">
      <p>{{ l.date_published | date: '%B %-d, %Y' }}</p>
    </div>
    <div class="tile-media">
      <a href=""><img src="http://img.youtube.com/vi/{{l.yt_video_id}}/maxresdefault.jpg" /></a>
    </div>
    <div class="tile-body">
      <h3 class="tile-title"><a href="">{{l.song_title}}</a></h3>
      <p class="tile-meta"><a href="">{{l.artist}}</a>&nbsp;&nbsp;•&nbsp;&nbsp;Lesson #{{l.slug}}</p>
      <p class="tile-description">In this week’s guitar lesson, you’ll be playing in the key of the song (so no worrying about following chord changes). You’ll be playing everything from...</p>
      {% if l.pdf_version And l.pdf_version != "" And l.pdf_version != nil %}
        <p class="tile-badge">
          <a class="pdf-badge" data-pdf-version="musicnotes" href="{{ l.url | relative_url }}"><span class='pdf-icon'>$</span> Sheet Music</a>
        </p>
      {% endif %}
    </div>
  </div>
{% endfor %}
</div>

### Landscape: non-songs

{% assign lessons = site.lessons | where: "category","tip_technique" | sort: 'date_published' | reverse %}

<div class="tile-wrapper clearfix">
{% for l in lessons limit:6 %}
  <div class="tile tile-landscape">
    <div class="tile-media">
      <a href=""><img src="http://img.youtube.com/vi/{{l.yt_video_id}}/maxresdefault.jpg" /></a>
    </div>
    <div class="tile-body">
      <h3 class="tile-title"><a href="">{{l.title}}</a></h3>
      <p class="tile-meta"><a href="">Tips & Techniques</a>&nbsp;&nbsp;•&nbsp;&nbsp;Lesson #{{l.slug}}</p>
      <!-- <p class="tile-description">In this week’s guitar lesson, you’ll be playing in the key of the song (so no worrying about following chord changes). You’ll be playing everything from...</p> -->
      {% if l.pdf_version And l.pdf_version != "" And l.pdf_version != nil %}
      <p class="tile-badge">
        <a class="pdf-badge" data-pdf-version="v2" href="{{ l.url | relative_url }}"><span class='pdf-icon'>★</span> Patreon PDF</a>
      </p>
      {% endif %}
    </div>
  </div>
{% endfor %}
</div>







### Portrait tile

<div class="tile tile-portrait">Hello</div>

### Wide tile

<div class="tile tile-wide">Hello</div>
