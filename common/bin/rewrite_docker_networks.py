#!/usr/bin/env python
#
# Updates a docker-compose file with a declaration of an external network and with adding all services from the file in
# that network. Useful to enable connectivity between various containers starting from different compose configs.
# Usage: rewrite_docker_networks.py <docker_compose_file> <existing_docker_network_name>

import yaml
import sys


def main():
    docker_compose_file = sys.argv[1]
    docker_network_name = sys.argv[2]
    with open(docker_compose_file) as f:
        config = yaml.safe_load(f)
    config['networks'] = {'e2e-network': {'external': {'name': docker_network_name}}}

    # Code assumes docker-compose file has at least one service.
    for service in config['services']:
        config['services'][service]['networks'] = ['e2e-network']

    serialized = yaml.safe_dump(config, sort_keys=False).replace(': null', ':')
    with open(docker_compose_file, 'w') as f:
        f.write(serialized)


if __name__ == '__main__':
    main()
