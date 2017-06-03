files:
  "/opt/elasticbeanstalk/hooks/appdeploy/post/01_set_deployment_permissions.sh":
    mode: "000755"
    owner: root
    group: root
    content: |
      #!/usr/bin/env bash
      chown -R nodejs:nodejs /tmp/deployment/
