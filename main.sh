# sudo check

if (( $EUID != 0 )); then
        echo "please run as root"
        exit
fi

echo "make sure that git & curl are both installed. these are needed for the program"

# directory check

Gitdir=$(ls | grep scripts);

if [[ $Gitdir != "scripts" ]]; then
	mkdir scripts
fi


# wifi section 

Wificonf=$(ls /etc/NetworkManager/system-connections/ | grep WIRELESS-2.4.nmconnection)

if [[ $Wificonf = "WIRELESS-2.4.nmconnection" ]]; then
       echo "a network configuration already exists for this network, are you sure that you want to override it?"
       echo "y/n"
       read yorn

       if [[ $yorn != "y" ]]; then 
	       echo "exiting..."
	       exit
       else
	       echo "old configuration will be renamed to old.WIRELESS-2.4.nmconnection"
       fi
fi

# credentials 
echo "username: "
read username 

echo "password: "
read password

echo 'autoconnect: ("yes" or "no")'
read autocon


#credentials check
usernamecheck=$( echo $username | grep  \\. )

if [[ $usernamecheck = "" ]]; then
	echo "invalid username, try firstname.lastname"
fi

if [[ $autocon = "yes" ]]; then
	autoconnect=$(echo "true")
else
	autoconnect=$(echo "false")
fi


# if the script has gotten this far, it is assumed that all input is valid and the user is willing to continue

#touch /etc/NetworkManager/system-connections/WIRELESS-2.4.nmconnection

parse=$(cat <<EOF
[connection]\n
id=WIRELESS-2.4\n
uuid=ac9c73e7-783d-46f9-a10a-936807a87d08\n
type=wifi\n
autoconnect=$autoconnect\n
interface-name=wlp8s0\n
\n
[wifi]\n
mode=infrastructure\n
ssid=WIRELESS-2.4\n
\n
[wifi-security]\n
key-mgmt=wpa-eap\n
\n
[802-1x]\n
eap=peap;\n
identity=$username\n
password=$password\n
phase2-auth=mschapv2\n
\n
[ipv4]\n
method=auto\n
\n
[ipv6]\n
addr-gen-mode=stable-privacy\n
method=auto\n
\n
[proxy]\n
EOF
)

# disabled for safety
#echo -e $parse > /etc/NetworkManager/system-connections/WIRELESS-2.4.nmconnection

Fedora=$(cat /etc/os-release | grep 'NAME="Fedora Linux"')

if [[ $Fedora = 'NAME="Fedora Linux"' ]]; then

	dnf install git -y 
	git clone https://github.com/toastxc/Fedora-Network-Fix.git
	sh Fedora-Network-Fix/main.sh
fi

sh certificate.sh
