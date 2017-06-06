files:
  "/tmp/01_set_deployment_permissions.sh":
    mode: "000755"
    owner: root
    group: root
    content: |
      #! /bin/bash
      chown -R nodejs:nodejs /tmp/

container_commands:
  00_appdeploy_rewrite_hook:
    command: cp -v /tmp/01_set_deployment_permissions.sh /opt/elasticbeanstalk/hooks/appdeploy/enact
  01_configdeploy_rewrite_hook:
    command: cp -v /tmp/01_set_deployment_permissions.sh /opt/elasticbeanstalk/hooks/configdeploy/enact
  02_rewrite_hook_perms:
    command: chmod 755 /opt/elasticbeanstalk/hooks/appdeploy/enact/01_set_deployment_permissions.sh /opt/elasticbeanstalk/hooks/configdeploy/enact/01_set_deployment_permissions.sh
