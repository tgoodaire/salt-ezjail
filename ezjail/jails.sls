{% from 'ezjail/map.jinja' import lookup %}
{% from 'ezjail/map.jinja' import options %}

{% if options.jails is defined %}
{% for jail, args in options.jails.items() %}
{% for interface, ip in args['networks'].items() %}
ezjail.jails.{{ jail }}_{{ interface }}.configure_ip:
  cmd.run:
    - name: 'sysrc cloned_interfaces+={{ interface }}'
    - require:
      - service: 'ezjail.service'
{% endfor %}

ezjail.jails.{{ jail }},reclone:
  cmd.run:
    - name: service netif cloneup

ezjail.jails.{{ jail }}.configure:
  cmd.run:
    - name: 'ezjail-admin create {{ jail }} "{% for interface, ip in
    args['networks'].items() %}{{ interface }}|{{ ip }}{% if not loop.last %},{% endif %}{% endfor %}"'
    - creates: '{{ salt['file.join'](options.jaildir, jail) }}'
    - require:
      - service: 'ezjail.service'

# jail: {{ jail }}
# args: {{ args }}

{% if args['salted']['grains'] is defined %}
ezjail.jails.{{ jail }}.configure.grains:
  file.managed:
    - name: '{{ lookup.config.path }}'
    - name: '{{ salt['file.join'](options.jaildir, jail, 'usr/local/etc/salt/grains') }}'
    - source: 'salt://ezjail/files/grains'
    - template: 'jinja'
    - template_grains: {{ args['salted']['grains'] }}
    - require_on:
      - cmd: 'ezjail.jails.{{ jail }}.start'
{% endif %}

{% set enabled = args['enabled'] | default(True) %}
{% if enabled %}
ezjail.jails.{{ jail }}.start:
  cmd.run:
    - name: 'ezjail-admin start {{ jail }}'
    - unless: 'jls | grep {{ jail }}'
{% else %}
ezjail.jails.{{ jail }}.stop:
  cmd.run:
    - name: 'ezjail-admin stop {{ jail }}'
    - onlyif: 'jls | grep {{ jail }}'
{% endif %}
{% endfor %}
{% endif %}
