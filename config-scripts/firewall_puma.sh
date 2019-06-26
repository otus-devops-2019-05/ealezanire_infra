#!/bin/bash
gcloud compute firewall-rules create puma-server --target-tags puma-server --allow tcp:9292
