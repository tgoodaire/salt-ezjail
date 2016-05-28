{% from 'ezjail/map.jinja' import lookup %}

ezjail.pkgs:
  pkg.installed:
    - pkgs: {{ lookup.pkgs }}

