# jailed-sftp-user
Bash script to create a jailed (restricted) SFTP user that will restrict user access to a certain directory. The SFTP user can perform all GET/PUT operations in this directory but not outside. This specified directory will act as "/" for the user.

* Use below command to execute the script in terminal:

		sudo bash jailed_sftp_user.sh    

"sudo" is necessary to execute the script.
