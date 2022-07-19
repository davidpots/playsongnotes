---
layout: course_landing_page
course_id: GSG
title: Welcome to Song Notes
icon: waving-hand
description: A quick guide on how to follow my video lessons & PDFs. Includes tips on how to approach daily practice routine. Also explains how to read tabs, fretboard diagrams, chord charts, and more.
course_items: [GSG-100,GSG-101,GSG-102,GSG-103,GSG-104,GSG-105]
permalink: /courses/getting-started-with-guitar/
---

{% for c in page.course_items %}
  {% assign course_item = site.course_lessons | where: "lesson_id", c %}
  {% assign course_item_id = course_item[0].lesson_id %}
  {% include course-item.html l_id = course_item_id %}
{% endfor %}
