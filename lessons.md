---
layout: page
title: List of all my lessons
permalink: /lessons/
---


{% assign songs_by_date = site.lessons | sort: 'date_published' %}

<table class="lesson-table">
{% for song in songs_by_date %}
<tr>
  <td>{{song.slug}}</td>
  <td>{{song.date_published | date: "%b %-d, %Y"}}</td>
  <td><a href="{{ song.url | relative_url }}">{{song.song_title}}</a></td>
</tr>
{% endfor %}
</table>
