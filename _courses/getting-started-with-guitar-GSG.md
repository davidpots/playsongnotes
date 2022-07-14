---
layout: page
course_id: GSG
title: Getting Started with Guitar
description: Everything you need to pick up your guitar and play! Learn the basics of the instrument & how to practice. Also learn how to read tabs, fretboard diagrams, chord charts, and more.
course_items: [GSG-100]
permalink: /courses/getting-started-with-guitar/
---

<p class="breadcrumbs_2022"><a href="/">Home</a> ❯ <a href="/courses">Courses</a> ❯</p>

# {{ page.title }}

<ul>
  {% for c in page.course_items %}
    {% assign course_item = site.course_lessons | where: "lesson_id", c %}
    <li><a href="{{course_item[0].url}}">{{ course_item[0].title }}</a></li>
  {% endfor %}
</ul>
