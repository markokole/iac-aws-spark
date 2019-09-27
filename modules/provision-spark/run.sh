#!/bin/bash

//time sh -c "terraform apply -auto-approve ; pause 5  ; terraform destroy -auto-approve"

terraform apply -auto-approve && terraform destroy -auto-approve

