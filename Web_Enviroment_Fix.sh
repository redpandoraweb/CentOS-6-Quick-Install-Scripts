echo 'THIS SCRIPT WILL SHOW U HOW TO FIX MONGODB AND MYSQL ERRORS-----------------------------------'

echo 'You meed this error:'
echo '---tarting mongod: about to fork child process, waiting until server is ready for connections.'
echo '---ERROR: child process failed, exited with error number 100'
echo 'Run: mongod --smallfiles'
echo 'Run: sed -i 's/#nojournal = true/nojournal = true/g' /etc/mongod.conf'
echo 'Run: service mongod restart'

echo 'You meed this error:'
echo '---Another MySQL daemon already running with the same unix socket'
echo 'Run: service mysqld stop'
echo 'Run: mv /var/lib/mysql/mysql.sock /var/lib/mysql/mysql.sock.bak'
echo 'Run: service mysqld start'

echo 'You meed this error:'
echo '---exception in initAndListen: 12596 old lock file, terminating'
echo 'Run: rm /var/lib/mongo/mongod.lock'
echo 'Run: service mysqld restart'
