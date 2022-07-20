---
layout: course_landing_page
course_id: PMT
icon: treble-clef
title: Practical Music Theory
description: A general overview of must-know theory concepts. The goal here is practical, easy-to-understand explanations — all of which provide clarity to your everyday guitar playing.
course_items: [PMT-100, PMT-101, PMT-102, PMT-103, PMT-104, PMT-105]
permalink: /courses/practical-music-theory/
---



{% for c in page.course_items %}
  {% assign course_item = site.course_lessons | where: "lesson_id", c %}
  {% assign course_item_id = course_item[0].lesson_id %}
  {% include course-item.html l_id = course_item_id %}
{% endfor %}
