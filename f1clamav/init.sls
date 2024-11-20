amazon-linux-extras-install-epel:
  cmd.run:
    - name: amazon-linux-extras install epel -y
    - unless:
      - /bin/amazon-linux-extras list | grep epel | grep -c enabled

clamav-pkg:
  pkg.installed:
    - name: clamav

clamav-update:
  pkg.installed

clamd:
  pkg.installed

/var/log/clamav:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 750

freshclam-log:
  file.managed:
    - name: /var/log/clamav/freshclam.log
    - replace: False
    - mode: 660
    - require:
      - pkg: clamav-update
      - file: /var/log/clamav

freshclam:
  cmd.run:
    - name: /usr/bin/freshclam -u root --log=/var/log/clamav/freshclam.log
    - require:
      - pkg: clamav-update
      - file: freshclam-log
      - file: /etc/clamd.d/freshclam.conf
      - file: /var/log/clamav

clamd@service:
  service.running:
    - require:
      - cmd: freshclam
      - pkg: clamd
      - file: /etc/clamd.d/service.conf
    - enable: True
    - init_delay: 30
    - watch:
      - file: /etc/clamd.d/service.conf

# only run on non utility instances
{% if grains.roles is defined and 'utility' not in grains.roles %}
clamonacc.service:
  service.running:
    - require:
      - cmd: freshclam
      - pkg: clamav-pkg
      - file: /etc/clamd.d/scan.conf
      - service: clamd@service
    - watch:
      - file: /etc/clamd.d/scan.conf
{% endif %}

clamav-freshclam.service:
  service.running:
    - require:
      - cmd: freshclam

# conf file for clamd
/etc/clamd.d/service.conf:
  file.managed:
    - source:
      - salt://f1clamav/files/service.conf
    - template: jinja
    - replace: True
    
# conf file for clamonacc
/etc/clamd.d/scan.conf:
  file.managed:
    - source:
      - salt://f1clamav/files/scan.conf
    - template: jinja
    - replace: True

# conf file for freshclam
/etc/clamd.d/freshclam.conf:
  file.managed:
    - source:
      - salt://f1clamav/files/freshclam.conf
    - replace: True

# updated systemd unit file for clamonacc
/etc/systemd/system/clamonacc.service:
  file.managed:
    - source:
      - salt://f1clamav/files/clamonacc.service
    - replace: True

fs.inotify.max_user_watches:
  sysctl.present:
    - value: 524288

{% if grains.roles is defined and 'utility' in grains.roles %}
/root/bin/detected.sh:
  file.managed:
    - source: 
      - salt://f1clamav/files/detected.sh
    - template: jinja
    - replace: True
    - makedirs: True

{% for key, data in pillar.clamav.cron.items() %}

{{ data.identifier }}_cron:
  cron.present:
    - name: {{ data.command }}
    - user: {{ data.user }}
    - minute: {{ data.minute }}
    - hour: {{ data.hour }}
    - identifier: {{ data.identifier }}

{% if data.daymonth is defined %}
    - daymonth: {{ data.daymonth }}
{% endif %}

{% if data.month is defined %}
    - month: {{ data.month }}
{% endif %}

{% if data.dayweek is defined %}
    - dayweek: {{ data.dayweek }}
{% endif %}

{% if data.special is defined %}
    - special: {{ data.special }}
{% endif %}

{% endfor %}
    
{% endif %}

