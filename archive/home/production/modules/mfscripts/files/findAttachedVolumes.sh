#!/bin/bash

ls -la /dev/mapper/ | egrep "(sys.->|data.->)"|awk '{print $9}' | awk -F \- '{print $6"-"$7"-"$8}' | sort -u
