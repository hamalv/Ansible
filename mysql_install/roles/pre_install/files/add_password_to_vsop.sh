#!/usr/bin/bash
export http_proxy=************************************
export https_proxy=***********************************
unset http_proxy
unset https_proxy


tpm=*************
host=$1
username=$2
user_password=$3

# active directory user
aduser=$4

# dba project id = **
dba_project_id='**'
tag='root,MySQL'




echo -n Password:
read -s adpassword
id=$(curl --insecure -s -u ${aduser}:${adpassword} -H 'Content-Type: application/json; charset=utf-8' -d '{"name":"'${host}'", "project_id":"'${dba_project_id}'","username":"'${username}'","password":"'${user_password}'","tags":"'${tag}'"}' https://${tpm}/index.php/api/v4/passwords.json|jq  -r ".[]")
re='^[0-9]+$'
if ! [[ $id =~ $re ]] ; then
   echo "ERROR:  $id " >&2; exit 1
fi

 
curl --insecure  -X PUT  -s -u ${aduser}:${adpassword} -H 'Content-Type: application/json; charset=utf-8' -d '{ "groups_permissions": [ [7,20] ]}'  https://${tpm}/index.php/api/v4/passwords/${id}/security.json

