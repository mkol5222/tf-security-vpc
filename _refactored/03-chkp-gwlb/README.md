
Get CME provisioning command
```bash
 terraform output -json | jq -r '."cme-command".value'
```