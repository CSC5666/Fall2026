---
title: Resources
description: Syllabus, notes, and textbook resources for Cal Poly CSC 5666.
permalink: /resources/
---
# Resources

<p class="subtitle">Course documents, notes, readings, and the primary textbook.</p>

{% assign resources = site.data.resources %}

## Syllabus


<ul class="resource-list">
  {% for document in resources.syllabus %}
    <li>
      {% if document.file %}<a href="{{ document.file | relative_url }}">{{ document.title }}</a>{% else %}{{ document.title }}{% endif %}
      {% if document.status %}<span class="status">{{ document.status }}</span>{% endif %}
    </li>
  {% endfor %}
</ul>

## Final Project

<ul class="resource-list">
  {% for document in resources.project %}
    <li>
      {% if document.file %}<a href="{{ document.file | relative_url }}">{{ document.title }}</a>{% else %}{{ document.title }}{% endif %}
      {% if document.status %}<span class="status">{{ document.status }}</span>{% endif %}
    </li>
  {% endfor %}
</ul>

## Course notes and readings

Lecture notes and supplementary readings will be posted throughout the quarter. 

<ol class="resource-list course-notes">
  {% for reading in resources.readings %}
    <li>
      <strong>{{ reading.title }}</strong>
      <span class="resource-meta">{{ reading.chapters }}</span>
      <span class="resource-links">
        {% for material in reading.materials %}
          <a href="{{ material.url | relative_url }}">{{ material.label }}</a>{% unless forloop.last %}<span aria-hidden="true"> · </span>{% endunless %}
        {% endfor %}
      </span>
    </li>
  {% endfor %}
</ol>

### Compiling the source

The Typst files use the shared template and bibliography below. Download them into the same directory as a note source before compiling it.

<ul class="resource-list">
  {% for resource in resources.source_support %}
    <li><a href="{{ resource.url | relative_url }}">{{ resource.title }}</a> <span class="status">{{ resource.label }}</span></li>
  {% endfor %}
</ul>

## Primary textbook

> {{ resources.textbook.author }}. *{{ resources.textbook.title }}*. {{ resources.textbook.publisher }}, {{ resources.textbook.year }}.

[Visit the author’s official book page]({{ resources.textbook.official_url }}) for the book, supporting materials, and updates.

[View the publisher’s catalog entry]({{ resources.textbook.publisher_url }}).
