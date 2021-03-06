#!/bin/bash

#The admin interface for OpenVPN

echo "Content-type: text/html"
echo ""
echo "<!doctype html>
<html lang='en'>
<head>
<meta charset='UTF-8'>
<title>Azure Blob Storage FTP Server</title>
<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>
<link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/css/bootstrap.min.css' integrity='sha384-TX8t27EcRE3e/ihU7zmQxVncDAy5uIKz4rEkgIXeMed4M0jlfIDPvg6uqKI2xXr2' crossorigin='anonymous'>
<script src='https://code.jquery.com/jquery-3.5.1.slim.min.js' integrity='sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj' crossorigin='anonymous'></script>
<script src='https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.bundle.min.js' integrity='sha384-ho+j7jyWK8fNQe+A12Hb8AhRq26LrZ/JpcUGGOn+Y7RsweNrtN/tE3MoK7ZeZDyx' crossorigin='anonymous'></script>
<script src='./index.js'></script>
</head>
<body>
<div class='container pt-5'>
    <div class='toast mt-3 mr-3' role='alert' aria-live='polite' aria-atomic='true' data-delay='7000' style='position:absolute; top:0; right:0;'>
        <div class='toast-header'>
        <svg width='1em' height='1em' viewBox='0 0 16 16' class='bi bi-app-indicator' fill='currentColor' xmlns='http://www.w3.org/2000/svg'>
            <path fill-rule='evenodd' d='M5.5 2A3.5 3.5 0 0 0 2 5.5v5A3.5 3.5 0 0 0 5.5 14h5a3.5 3.5 0 0 0 3.5-3.5V8a.5.5 0 0 1 1 0v2.5a4.5 4.5 0 0 1-4.5 4.5h-5A4.5 4.5 0 0 1 1 10.5v-5A4.5 4.5 0 0 1 5.5 1H8a.5.5 0 0 1 0 1H5.5z'/>
            <path d='M16 3a3 3 0 1 1-6 0 3 3 0 0 1 6 0z'/>
        </svg>
        <strong class='mr-auto ml-2'>Info</strong>
        <small>&nbsp;</small>
        <button type='button' class='ml-2 mb-1 close' data-dismiss='toast' aria-label='Close'>
            <span aria-hidden='true'>&times;</span>
        </button>
        </div>
        <div class='toast-body'>&nbsp;</div>
    </div>
    <h1>Azure Blob Storage FTP Server</h1>
"

eval `echo "${QUERY_STRING}"|tr '&' ';'`

eval `echo "${POST_DATA}"|tr '&' ';'`


case $option in
        "add") #Add a client
                ( echo ${password} ; echo ${password} ) | pure-pw useradd $username -f /ftp/ftp.passwd -u ftpuser -d /ftp/ftp-files/staging/$username > /dev/null 2>&1
                mkdir /ftp/ftp-files/staging/$username
                pure-pw mkdb  /ftp/ftp.pdb -f /ftp/ftp.passwd
                echo "<script>notify('Account was created for dealer $username');</script>"
        ;;
        "addsup") #Add a supervisor
                ( echo ${password} ; echo ${password} ) | pure-pw useradd $username -f /ftp/ftp.passwd -u ftpuser -d /ftp/ftp-files/production > /dev/null 2>&1
                mkdir /ftp/ftp-files/production
                pure-pw mkdb  /ftp/ftp.pdb -f /ftp/ftp.passwd
                echo "<script>notify('Account was created for supervisor $username');</script>"
        ;;
        "delete") #Revoke a client
                pure-pw userdel $username -f /ftp/ftp.passwd > /dev/null 2>&1
                pure-pw mkdb  /ftp/ftp.pdb -f /ftp/ftp.passwd
                echo "<script>notify('Account of user $username was deleted');</script>"
        ;;
        "change") #Change a pasword
                ( echo ${password} ; echo ${password} ) | pure-pw passwd $username -f /ftp/ftp.passwd  > /dev/null 2>&1
                pure-pw mkdb  /ftp/ftp.pdb -f /ftp/ftp.passwd
                echo "<script>notify('Passwod of user $username was changed');</script>"
        ;;

esac

FILE=/ftp/ftp.passwd
echo "
    <table class='table table-hover w-75 mt-5'>
        <tr class='table-success'>
            <th class='pl-2'>User</th><th class='pl-2'>Folder</th><th></th><th></th></td>
        </tr>"

while read LINE; do
        IFS=':'; userInfo=($LINE); unset IFS;
        echo "
        <tr>
            <td class='pl-2 pr-2'>${userInfo[0]}</td>
            <td class='pl-2 pr-2'>${userInfo[5]%/./}</td>
            <td class='pl-2 pr-1 text-right' style='width:80px;'>
                <form action='index.sh' method='get'>
                    <input type='hidden' name='option' value='delete'>
                    <input type='hidden' name='username' value='${userInfo[0]}'>
                    <button type='submit' class='btn btn-sm btn-outline-danger'>Delete</button>
                </form>
            </a></td>
            <td class='pl-1' style='width:150px;'>
                <button class='btn btn-sm btn-outline-info' data-user='${userInfo[0]}'>Change Password</button>
            </td>
        </tr>"
done < $FILE

echo "
    </table><hr/>
    <form action='index.sh' method='get' style='max-width:300px;'>
        <div class='form-group' id='guide'>Create new user:</div>
        <div class='form-group'>
            <input type='hidden' name='option' id='option' value='add'>
            <input type='text' class='form-control mt-2' name='username' id='username' placeholder='Username'>
            <input type='password' class='form-control mt-2' name='password' id='password' placeholder='Password'>
        </div>
        <div class='form-group pl-5'>
            <input class='form-check-input' type='checkbox' id='makeSupervisor'>
            <label class='form-check-label' for='makeSupervisor'>New user is supervisor</label>  
        </div>
        <button type='submit' class='btn btn-primary' id='create'>Create</button>
        <button type='submit' class='btn btn-primary' id='change' hidden>Change</button>
        <button type='button' class='btn btn-outline-secondary' id='cancel' hidden>Cancel</button>
    </form>
</div>
<br/><br/><br/>
</body>
</html>
"

exit 0
