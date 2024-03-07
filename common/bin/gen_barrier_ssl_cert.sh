#!/usr/bin/env bash
# Generates an SSL certificate to be used by barrier.
# Steps taken from: https://wiki.archlinux.org/title/Input_Leap#Set_up_encryption_on_server

mkdir -p ~/.local/share/barrier/SSL/Fingerprints
openssl req -x509 -nodes -days 365 -subj /CN=Barrier -newkey rsa:4096 -keyout ~/.local/share/barrier/SSL/Barrier.pem -out ~/.local/share/barrier/SSL/Barrier.pem
fingerprint=$(openssl x509 -fingerprint -sha256 -noout -in ~/.local/share/barrier/SSL/Barrier.pem | cut -d"=" -f2)
echo "v2:sha256:$fingerprint" > ~/.local/share/barrier/SSL/Fingerprints/Local.txt
