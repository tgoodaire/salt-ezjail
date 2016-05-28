{% from 'ezjail/map.jinja' import lookup %}
{% from 'ezjail/map.jinja' import options %}

ezjail.service:
  {% if options.service.enabled %}
  service.enabled:
  {% else %}
  service.disabled:
  {% endif %}
    - name: '{{ lookup.service.name }}'
    - require:
      - cmd: 'ezjail.initialize'
