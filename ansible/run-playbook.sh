#!/bin/sh
exec ansible-playbook playbook.yml --extra-vars '@variables.json'
