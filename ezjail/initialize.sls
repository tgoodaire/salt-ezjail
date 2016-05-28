{% from 'ezjail/map.jinja' import lookup %}
{% from 'ezjail/map.jinja' import options %}

ezjail.initialize:
  cmd.run:
    - name: 'ezjail-admin install'
    - creates: '{{ options.jaildir }}'
    - require:
      - file: 'ezjail.config'

{% for flavour in options.flavours %}
ezjail.initialize.flavour.{{ flavour }}:
  file.recurse:
    - name: '{{ salt['file.join'](options.jaildir, "flavours", flavour) }}'
    - source: 'salt://{{ salt['file.join']("ezjail/files/flavours", flavour) }}'
    - makedirs: True
    - clean: True
    - require:
      - cmd: 'ezjail.initialize'
    - template: 'jinja'

ezjail.initialize.flavour.{{ flavour }}.flavour_rc_script:
  file.managed:
    - name: '{{ salt['file.join'](options.jaildir, "flavours", flavour, "etc/rc.d", "ezjail.flavour.%s" % flavour) }}'
    - mode: 0755
    - require:
      - cmd: 'ezjail.initialize'
      - file: 'ezjail.initialize.flavour.{{ flavour }}'
{% endfor %}

