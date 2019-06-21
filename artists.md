---
layout: page
title: View all songs by artist
permalink: /artists/
---

{% assign postsByArtist = site.songs | group_by_exp:"site.songs", "site.artist" %}
{% for artist in postsByArtist %}
  <h3>{{ artist }}</h3>
    <ul>
      {% for post in postsByArtist.items %}
        <li>{{post.song_title}}</li>
      {% endfor %}
    </ul>
{% endfor %}
