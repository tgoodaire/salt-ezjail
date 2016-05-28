{% from 'ezjail/map.jinja' import lookup %}

ezjail.config:
  file.managed:
    - name: '{{ lookup.config.path }}'
    - source: 'salt://ezjail/files/ezjail.conf'
    - template: 'jinja'
    - require:
      - pkg: 'ezjail.pkgs'
