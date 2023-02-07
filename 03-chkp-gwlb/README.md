
Get CME provisioning command
```bash
 terraform output -json | jq -r '."cme-command".value'
```

To generate hashed GaiaOS password
```
[Expert@HostName]# cpopenssl passwd {-1 | -5 | -6} <New Password>
```