---
layout: page
course_id: BAR
title: Learning Barre Chords
description: A guide to the left-hand technique of fretting multiple strings with a single finger (used in chords, triads, licks, etc). An essential technique as you move beyond the beginner stage.
course_items: [BAR-100, BAR-101, BAR-102, BAR-103, BAR-104, BAR-105]
landing_page: /courses/learning-barre-chords/
---

<p class="breadcrumbs_2022"><a href="/">Home</a> ❯ <a href="/courses">Courses</a> ❯</p>

# {{ page.title }}

<ul>
  {% for c in page.course_items %}
    {% assign course_item = site.course_lessons | where: "lesson_id", c %}
    <li><a href="{{course_item[0].url}}">{{ course_item[0].title }}</a></li>
  {% endfor %}
</ul>
