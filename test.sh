#!/bin/bash


  record_ip="$(echo "123.213.123.123" | grep -E "(25[0-5]|2[0-4][[:digit:]]|[0-1][[:digit:]]{2}|[1-9]?[[:digit:]])\.(25[0-5]|2[0-4][[:digit:]]|[0-1][[:digit:]]{2}|[1-9]?[[:digit:]])\.(25[0-5]|2[0-4][[:digit:]]|[0-1][[:digit:]]{2}|[1-9]?[[:digit:]])\.(25[0-5]|2[0-4][[:digit:]]|[0-1][[:digit:]]{2}|[1-9]?[[:digit:]])")"


echo $record_ip