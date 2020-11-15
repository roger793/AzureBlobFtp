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
</head>
<body>"

echo "<h1>Azure Blob Storage FTP Server</h1>"

eval `echo "${QUERY_STRING}"|tr '&' ';'`

eval `echo "${POST_DATA}"|tr '&' ';'`


case $option in
        "add") #Add a client
                ( echo ${password} ; echo ${password} ) | pure-pw useradd $username -f /ftp/ftp.passwd -u ftpuser -d /ftp/ftp-files/staging/$username > /dev/null 2>&1
                mkdir /ftp/ftp-files/staging/$username
                pure-pw mkdb  /ftp/ftp.pdb -f /ftp/ftp.passwd
                echo "<h3>Account created for dealer <span style='color:red'>$username</span> added.</h3>"
        ;;
        "addsup") #Add a supervisor
                ( echo ${password} ; echo ${password} ) | pure-pw useradd $username -f /ftp/ftp.passwd -u ftpuser -d /ftp/ftp-files/import > /dev/null 2>&1
                mkdir /ftp/ftp-files/import
                pure-pw mkdb  /ftp/ftp.pdb -f /ftp/ftp.passwd
                echo "<h3>Account created for supervisor <span style='color:red'>$username</span> added.</h3>"
        ;;
        "delete") #Revoke a client
                pure-pw userdel $username -f /ftp/ftp.passwd > /dev/null 2>&1
                pure-pw mkdb  /ftp/ftp.pdb -f /ftp/ftp.passwd
                echo "<h3>Account created for <span style='color:red'>$username</span> deleted.</h3>"
        ;;
        "edit") #Edit a client
                echo "New password for user <span style='color:red'>$username</span>: <form action='index.sh' method='get'><input type='hidden' name='option' value='change'><input type='hidden' name='username' value='$username'><input type='password' name='password'><input type='submit' value='Change'></form>"
        ;;
        "change") #Change a pasword
                ( echo ${password} ; echo ${password} ) | pure-pw passwd $username -f /ftp/ftp.passwd  > /dev/null 2>&1
                pure-pw mkdb  /ftp/ftp.pdb -f /ftp/ftp.passwd
                echo "<h3>Password changed for <span style='color:red'>$username</span>.</h3>"
        ;;


esac


FILE=/ftp/ftp.passwd
echo "<table border=1><tr><th>User</th><th>Folder</th><th></th><th></th></td>"
while read LINE; do
        IFS=':'; userInfo=($LINE); unset IFS;
        echo "<tr><td>${userInfo[0]}</td><td>${userInfo[5]}</td><td><a href='?option=delete&username=${userInfo[0]}'>Delete</a></td><td><a href='?option=edit&username=${userInfo[0]}'>Change Password</a></td></tr>"
done < $FILE
echo "</table>"

echo "<hr>"

echo "
<form action='index.sh' method='get'>
  <div class='form-group'>
    <input type='hidden' name='option' id='option' value='add'>
    <input type='text' class='form-control' name='username' placeholder='Username'>
  </div>
  <div class='form-group'>
    <input type='password' class='form-control' name='password' placeholder='Password'>
  </div>
  <div class='form-group'>
    <input type='checkbox' class='form-check-input' id='makeSupervisor'>
    <label class='form-check-label' for='makeSupervisor'>New user is supervisor</label>  
  </div>
  <button type='submit' class='btn btn-primary'>Create</button>
</form>
"

echo "
<script>
$(document).ready(function () {
  $('#makeSupervisor').change(function () {
    $('#option').val($(this).prop('checked') ? 'addsup' : 'add');
  });
});
</script>
"

echo "
<script src='https://code.jquery.com/jquery-3.5.1.slim.min.js' integrity='sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj' crossorigin='anonymous'></script>
<script src='https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.bundle.min.js' integrity='sha384-ho+j7jyWK8fNQe+A12Hb8AhRq26LrZ/JpcUGGOn+Y7RsweNrtN/tE3MoK7ZeZDyx' crossorigin='anonymous'></script>
</body></html>
"

exit 0
