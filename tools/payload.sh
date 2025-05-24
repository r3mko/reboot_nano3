# Set admin password to "admin"
echo -ne "admin\nadmin\n" | passwd admin

# Generate ED25119 SSH key
yes | ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''

# Create jail sshd environment
addgroup -S sshd
adduser -S -G sshd sshd
mkdir /var/empty/

# Start sshd automatically on boot
echo -ne "#!/bin/sh\n\n/usr/sbin/sshd\n" > /etc/init.d/S50sshd.sh

# Now launch sshd
/usr/sbin/sshd
