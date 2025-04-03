#!/bin/bash
#Set the address to the Transit Vault (or vault you wish to unlock automatically)
#Check Transit Vault seal status
yum install jq &>/dev/null
vault_status=$(su - admin -c 'vault status -format "json"' | jq --raw-output '.sealed')
if [[ $vault_status == 'false' ]]; then
        :
elif [[ $vault_status == 'true' ]]; then
		#Create keys array to temporarily store keys grabbed from the Production Vault (assumes key values are Key1, Key2, etc.)
        declare -A keys
        keys+=(["key1"]='<unseal_key1>' ["key2"]='<unseal-key2>' ["key3"]='<unseal-key3>')
		#Run unseal operation and iterate through the key values until the seal status changes to "false"
        i=1
        while [[ $vault_status == 'true' ]];
                do
                su - admin -c 'vault operator unseal ${keys[key$i]}' &>/dev/null
                vault_status=$( su - admin -c 'vault status -format "json"' | jq --raw-output '.sealed')
                i=$[$i+1]
        done
else
        :
fi
