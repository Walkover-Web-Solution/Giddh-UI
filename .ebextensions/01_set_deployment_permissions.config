files:
    "/tmp/01_set_deployment_permissions.sh":
        mode: 755
        owner: root
        group: root
        content: |
            #! /bin/bash
            chmod -R 755 /tmp/

container_commands:
    00_run_command:
        command: "/tmp/01_set_deployment_permissions.sh"
