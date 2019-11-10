---
layout: page
title: Print-friendly PDF Downloads for Song Notes guitar lessons - playsongnotes.com
permalink: /downloads/
---

  <!-- <div style="background: #FFA; padding: 16px; margin: 24px auto; max-width: 480px;">
    <p style="margin: 0;"><strong>Psst... I just launched a Patreon page!</strong> Get print-friendly PDFs for each new lesson I make for only $3/month. <a href="https://www.patreon.com/songnotes">Learn more »</a></p>
  </div> -->

## Free PDF sampler pack

Here's a free sample pack of some of the songs I've written up nicely formatted PDFs for. Download these as you please, and print them out! They're designed to fit well on notebook-sized paper. If you find these helpful, please consider tossing a few dollars into my Paypal tip jar. If you want access to PDFs for all new lessons I create, please consider [supporting me on Patreon](https://www.patreon.com/songnotes) ($3/month).

<ul>
  <li><strong><a href="/printables/[Animals] House of the Rising Sun.pdf">House of the Rising Sun</a></strong> by The Animals</li>
  <li><strong><a href="/printables/[Bonnie Tyler] Total Eclipse of the Heart.pdf">Total Eclipse of the Heart</a></strong> by Bonnie Tyler</li>
  <li><strong><a href="/printables/[Eric Clapton] Layla.pdf">Layla</a></strong> by Eric Clapton</li>
  <li><strong><a href="/printables/[Game of Thrones] Theme Song.pdf">Game of Thrones</a></strong> theme song</li>
  <!-- <li><strong><a href="/printables/[Guy Clark] L.A. Freeway.pdf">LA Freeway</a></strong> by Guy Clark</li> -->
  <!-- <li><strong><a href="/printables/[Johnny Cash] Sunday Morning Coming Down.pdf">Sunday Morning Coming Down</a></strong> by Johnny Cash</li> -->
  <!-- <li><strong><a href="/printables/[Loggins and Messina] Dannys Song.pdf">Danny's Song</a></strong> by Loggins and Messina</li> -->
  <li><strong><a href="/printables/[Lynyrd Skynyrd] Tuesdays Gone.pdf">Tuesday's Gone</a></strong> by Lynyrd Skynyrd</li>
  <li><strong><a href="/printables/[Neil Young] Harvest Moon.pdf">Harvest Moon</a></strong> by Neil Young</li>
  <li><strong><a href="/printables/[Nirvana] About a Girl.pdf">About a Girl</a></strong> by Nirvana</li>
  <li><strong><a href="/printables/[Nirvana] Where Did You Sleep Last Night.pdf">Where Did You Sleep Last Night</a></strong> by Nirvana</li>
  <li><strong><a href="/printables/[Post Malone] Feeling Whitney.pdf">Feeling Whitney</a></strong> by Post Malone</li>
  <li><strong><a href="/printables/[Radiohead] High and Dry.pdf">High and Dry</a></strong> by Radiohead</li>
  <li><strong><a href="/printables/[Tom Petty] Runnin Down a Dream.pdf">Runnin' Down a Dream</a></strong> by Tom Petty</li>
  <li><strong><a href="/printables/[Tom Petty] Learnin to Fly.pdf">Learnin' to Fly</a></strong> by Tom Petty</li>
  <li><strong><a href="/printables/[Waylon Jennings] Honky Tonk Heroes.pdf">Honky Tonk Heroes</a></strong> by Wayon Jennings</li>
</ul>

## Premium PDFs available to Patreon supporters

All those supporting me on Patreon ($3/month) have access to this growing list of PDFs I've been creating since August 2018. I have been adding ~2 new lessons a week (video and PDF), while also adding PDFs for older videos that are requested by fans. Here's what's currently available. Is there a song you want to request I add as PDF? Let me know! Send an email to play.songnotes@gmail.com

{% assign number_of_pdfs = 0 %}



{% assign songs_by_artist = site.lessons | where: "category", "full_song" | group_by: "artist" | sort: "name" %}
<div style="column-count: 3; column-width: 300px;">
{% for artist in songs_by_artist %}
{% assign artist_count = 0 %}

{% for song in artist.items %}

  {% if song.patreon_lesson_available == true %}
    {% assign artist_count = artist_count | plus: 1 %}
  {% endif %}

{% endfor %}

{% if artist_count > 0 %}
  <h3 class="mbn">{{artist.name}}</h3>
  <ul>

  {% assign sorted_by_song_name = artist.items | sort: "song_title" %}
  {% for song in sorted_by_song_name %}
  {% if song.patreon_lesson_available == true %}
    {% assign number_of_pdfs = number_of_pdfs | plus: 1 %}
  <li><a href="{{song.patreon_lesson_url}}"><strong>{{song.song_title}}</strong></a></li>
  {% endif %}
  {% endfor %}


  </ul>
{% endif %}
{% endfor %}
</div>




## Warm Up Exercise PDFs:

    {% assign sorted_warmups = site.lessons | where: "category","warmup" | sort: 'date' | reverse %}
<ul>
    {% for warmup in sorted_warmups %}
      {% if warmup.patreon_lesson_available == true %}
      {% assign number_of_pdfs = number_of_pdfs | plus: 1 %}
<li><strong><a href="{{warmup.patreon_lesson_url}}">{{ warmup.title }}</a></strong><br /> <span class="small">{{ warmup.date | date: "%b %-d, %Y" }} • Lesson #{{ warmup.slug }}</span></li>
      {% endif %}
    {% endfor %}
</ul>

## Practice Log PDFs:

    {% assign sorted_plogs = site.lessons | where: "category","practice_log" | sort: 'date' | reverse %}
<ul>
    {% for plog in sorted_plogs %}
      {% if plog.patreon_lesson_available == true %}
      {% assign number_of_pdfs = number_of_pdfs | plus: 1 %}
<li><strong><a href="{{plog.patreon_lesson_url}}">{{ plog.title }}</a></strong><br /><span class="small">{{ plog.date | date: "%b %-d, %Y" }} • Lesson #{{ plog.slug }}</span></li>
      {% endif %}
    {% endfor %}
</ul>

## Tips & Technique PDFs:

    {% assign sorted_tips = site.lessons | where: "category","tip_technique" | sort: 'date' | reverse %}
<ul>
    {% for tip in sorted_tips %}
      {% if tip.patreon_lesson_available == true %}
      {% assign number_of_pdfs = number_of_pdfs | plus: 1 %}
<li><strong><a href="{{tip.patreon_lesson_url}}">{{ tip.title }}</a></strong><br /><span class="small">{{ tip.date | date: "%b %-d, %Y" }} • Lesson #{{ tip.slug }}</span></li>
      {% endif %}
    {% endfor %}
</ul>

## {{number_of_pdfs}} PDFs, and counting!

If you'd like access to all the lessons above, please consider supporting me on Patreon! It's truly appreciated, and goes to support my independent efforts (and costs) of creating all these lessons to share with the world. Thank you.

<a style="display: inline-block; padding: 10px 18px; background: #0074D9; font-weight: bold; color: white; border-radius: 5px;" href="http://patreon.com/songnotes">Support me on Patreon</a>
