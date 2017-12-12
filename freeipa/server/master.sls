{%- from "freeipa/map.jinja" import server with context %}
{%- if server.enabled %}

include:
- freeipa.server.common

freeipa_server_install:
  cmd.run:
    - name: >
        ipa-server-install
        --realm {{ server.realm }}
        --domain {{ server.domain }}
        --hostname {% if server.hostname is defined %}{{ server.hostname }}{% else %}{{ grains['fqdn'] }}{% endif %}
        --ds-password {{ server.ldap.password }}
        --admin-password {{ server.admin.password }}
        --ssh-trust-dns
        {%- if not server.get('ntp', {}).get('enabled', True) %} --no-ntp{%- endif %}
        {%- if server.get('dns', {}).get('zonemgr', False) %} --zonemgr {{ server.dns.zonemgr }}{%- endif %}
        {%- if server.get('dns', {}).get('enabled', True) %} --setup-dns{%- endif %}
        {%- if server.get('dns', {}).get('forwarders', []) %}{%- for forwarder in server.dns.forwarders %} --forwarder={{ forwarder }}{%- endfor %}{%- else %} --no-forwarders{%- endif %}
        {%- if server.get('mkhomedir', True) %} --mkhomedir{%- endif %}
        {%- if server.get('ip-address', []) %}{%- for address in server.ip-address %} --ip-address={{ address }}{%- endfor %}{%- endif %}
        {%- if server.get('adtrust', False) %} --setup-adtrust{%- endif %}
        {%- if server.get('kra', False) %} --setup-kra{%- endif %}
        --auto-reverse
        --no-host-dns
        --unattended
    - creates: /etc/ipa/default.conf
    - require:
      - pkg: freeipa_server_pkgs
    - require_in:
      - service: sssd_service
      - file: ldap_conf

{%- endif %}
