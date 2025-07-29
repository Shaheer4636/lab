Hey, the file taapmtin.txt is in /home/ec2-user, not in the LIBRARY/ directory.
That’s why the rename is failing — it’s looking in the wrong path.
Update the script to rename the file directly in the current directory.
