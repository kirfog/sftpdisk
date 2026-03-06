# /etc/apt/sources.list.d/debian.sources
Types: deb deb-src
URIs: https://deb.debian.org/debian/
Suites: trixie trixie-updates
Components: main non-free-firmware contrib non-free
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: https://deb.debian.org/debian-security/
Suites: trixie-security
Components: main non-free-firmware contrib non-free
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

# server
sudo apt update
sudo apt install openssh-server -y

sudo groupadd sftp_users
sudo chown root:root /sftproot
sudo chmod 755 /sftproot

sudo mkdir -p /sftproot/public
sudo chown root:sftp_users /sftproot/public
sudo chmod 1777 /sftproot/public

# /etc/ssh/sshd_config
Subsystem sftp internal-sftp

Match Group sftp_users
    ChrootDirectory /sftproot
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication yes

sudo sshd -t
sudo systemctl restart ssh

# user
USER=duser
sudo useradd -m -d /sftproot/$USER -g sftp_users -s /usr/sbin/nologin -k /tmp/empty $USER
sudo passwd $USER

# sudo mkdir /sftproot/$USER
# sudo chown $USER:sftp_users /sftproot/$USER
# sudo chmod 700 /sftproot/$USER
________________________________________

sudo apt install fail2ban -y

# sudo nano /etc/fail2ban/jail.local

[DEFAULT]
bantime  = 365d
findtime = 1d
maxretry = 3
banaction = nftables-allports

[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s

sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

________________________________________

sudo apt install nftables -y
sudo systemctl enable --now nftables

# sudo nano /etc/nftables.conf 

#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        ct state established,related accept

        iif lo accept

        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept

        tcp dport 22 accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}


# sudo nano /etc/sysctl.d/99-disable-ipv6.conf

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

sudo sysctl -p /etc/sysctl.d/99-disable-ipv6.conf