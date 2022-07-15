---
layout: page
course_id: PMT
title: Practical Music Theory
description: A general overview of must-know theory concepts that relate to everyday guitar playing.
course_items: [PMT-100, PMT-101, PMT-102, PMT-103, PMT-104, PMT-105]
landing_page: /courses/practical-music-theory/
---

<p class="breadcrumbs_2022"><a href="/">Home</a> ❯ <a href="/courses">Courses</a> ❯</p>

# {{ page.title }}

<ul>
  {% for c in page.course_items %}
    {% assign course_item = site.course_lessons | where: "lesson_id", c %}
    <li><a href="{{course_item[0].url}}">{{ course_item[0].title }}</a></li>
  {% endfor %}
</ul>
