# vault_unseal
Bash script to auto-unseal secondary vault (Transit Vault) using unseal keys in production vault.
This script fits a very specific need; to automatically unseal a secondary (Transit Vault) if it goes down without needing manual intervention.  It assumes that the Production Vault or cluster is still available.
## Hashicorp does not recommend using a method like this to unseal a production vault for obvious security reasons.
### Prerequisites:
  - Production Vault environment (HA or standalone) properly secured which is using auto-unseal with Transit Engine in a standalone separate Vault instance (Transit Vault). 
  - KV Secrets location which has all unseal keys for the Transit Vault with keys as Key1, Key2, Key3, etc.
  - A token issued to the server running the Transit Vault which has access to the KV secret location where the unseal keys are stored

You can modify this script easily to use fewer unseal keys if your shamir key share is less than 5 (or more)

How it works / installation
This requires Vault to be started by a systemd-unit named vault.service, which typically is the case when installing from a distribution package. The script vault-unseal.sh should be placed in /root and secured with 700 permissions.
Place the required unseal-key in that script as well. This example assumes Vault can be unsealed using just one key.
When executed, it will perform the necessary POST unseal-request to the Vault instance that is running on 127.0.0.1:8200.

Store the unit-file vault-unseal.service in /etc/systemd/system, then execute:

systemctl daemon-reload
systemctl enable vault-unseal.service
Now whenever the system boots or Vault is restarted, the vault-unseal-unit will automatically be started.
It will unseal the Vault with a delay of 10 seconds.

Further thoughts about security
Obviously the vault-unseal.sh script contains the unseal-key in plaintext, which is really bad.
However, it should only be accessible by root. And if an attacker already has that level of access, he probably also will be able to spawn a malicious service that intercepts / forwards regular unseal-requests anyways.
Since he is root he can just use the same certificate / key that Vault is using and nobody would notice the keys are being leaked.

vault-unseal.service
