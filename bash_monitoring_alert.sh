#!/bin/bash

#
# Bashscript ---> Pushgateway <--- Prometheus <--- Grafana
#
#
# - alert: KeepalivedProcessRunning
#   expr: bash_monitoring_alert_keepalived == 0
#   for: 0m
#   labels:
#     severity: Warning
#   annotations:
#     Summary: Keepalived process running (instance {{ $labels.instance }})
#     Description: "A Keepalived process running\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
#
# - alert: KeepalivedProcessMysql
#   expr: bash_monitoring_alert_mysql == 0
#   for: 0m
#   labels:
#     severity: Warning
#   annotations:
#     Summary: Mysql process running (instance {{ $labels.instance }})
#     Description: "A Mysql process running\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
#
# - alert: TomcatProcessRunning
#   expr: bash_monitoring_alert_tomcat == 0
#   for: 0m
#   labels:
#     severity: Warning
#   annotations:
#     Summary: Tomcat process running (instance {{ $labels.instance }})
#     Description: "A Tomcat process running\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
#

pushgateway='http://127.0.0.1:9091/metrics/job/bash_monitoring_alert/instance/pushgateway'

if ( 2> /dev/null </dev/tcp/127.0.0.1/3306 );then
  echo 'bash_monitoring_alert_mysql 1' | curl --data-binary @- $pushgateway
else
  echo 'bash_monitoring_alert_mysql 0' | curl --data-binary @- $pushgateway
fi

if ( 2> /dev/null </dev/tcp/127.0.0.1/8086 );then
  echo 'bash_monitoring_alert_tomcat 1' | curl --data-binary @- $pushgateway
else
  echo 'bash_monitoring_alert_tomcat 0' | curl --data-binary @- $pushgateway
fi

if ( pidof keepalived > /dev/null );then
  echo 'bash_monitoring_alert_keepalived 1' | curl --data-binary @- $pushgateway
else
  echo 'bash_monitoring_alert_keepalived 0' | curl --data-binary @- $pushgateway
fi

exit
