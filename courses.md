---
permalink: /courses
layout: page
---

<p class="breadcrumbs_2022"><a href="/">Home</a> ❯</p>

# Courses

{% for course in site.courses %}

  {% assign current_course_id = course.course_id %}
  {% assign course_items = site.course_lessons | where: "parent_course", current_course_id %}

  <h2>{{ course.title }}</h2>
  <p>{{ course.description }} <a href="{{ course.url }}">View course details »</a></p>
  <ul>
    {% for c in course_items %}
    <li><a href="{{c.url}}">{{ c.title }}</a></li>
    {% endfor %}
  </ul>

{% endfor %}
