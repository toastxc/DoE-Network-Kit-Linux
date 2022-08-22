################################################## PREREQ ##########################################################
# sudo checker
if (( $EUID != 0 )); then
        echo "please run as root"
        exit
fi


############################################### WIFI SETTINGS ######################################################

echo "WIFI"

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
else
	username=$( echo 'identity='$username)
fi

if [[ $autocon = "no" ]]; then
	autoconnect=$(echo "false")
else
	autoconnect=$(echo "true")
fi



touch /etc/NetworkManager/system-connections/WIRELESS-2.4.nmconnection


interface=$(iw dev | awk '$1=="Interface"{print $2}' )

echo $interface


parse=$(cat <<EOF
[connection]\nid=WIRELESS-2.4\nuuid=ac9c73e7-783d-46f9-a10a-936807a87d08\ntype=wifi\nautoconnect=$autoconnect\ninterface-name=$interface\n\n[wifi]\nmode=infrastructure\nssid=WIRELESS-2.4\n\n[wifi-security]\nkey-mgmt=wpa-eap\n\n[802-1x]\neap=peap\n$username\npassword=$password\nphase2-auth=mschapv2\n\n[ipv4]\nmethod=auto\n\n[ipv6]\naddr-gen-mode=stable-privacy\nmethod=auto\n\n[proxy]
EOF
)


# disable for safety

touch login.info
echo -e $parse > login.info
echo -e $parse > /etc/NetworkManager/system-connections/WIRELESS-2.4.nmconnection

nmcli connection reload

echo "connecting to wifi"
nmcli connection up 'WIRELESS-2.4'


######################################### CERTIFICATE INSTALLATION #################################################

echo "CERTIFICATES"


Certdir=$(ls | grep certs);

if [[ $Certdir != "certs" ]]; then
	mkdir certs
	mkdir certs/imp
	touch certs/imp/Education-CA.cer

	mkdir certs/system-cert
fi



CA=$(ls /etc/ssl/certs | grep Education-CA);


<< 'MULTILINE-COMMENT'

Shencheck=$(curl -S https://enrol.shenton.wa.edu.au);

echo $Shencheck


if [[ $Shencheck = "" ]]; then
        echo "Could not reach Shenton repository, please try connecting to Shenton WiFi"
	exit
fi


MULTILINE-COMMENT

if [[ $CA = "Education-CA.pem" ]]; then
	echo "CA cert found"
else
	
	echo "installing Edu-CA"
	curl https://certs.education.wa.edu.au/education-pki/cert/Education-CA.cer > certs/imp/Education-CA.cer
	openssl x509 -in certs/imp/Education-CA.cer -out certs/system-cert/Education-CA.pem
	cp certs/system-cert/Education-CA.pem /etc/ssl/certs/
fi


systemctl restart NetworkManager

########################################### FEDORA NETWORKING #####################################################

echo "FEDORA"

if (($OSTYPE != "linux-gnu")); then
	echo "this script is for GNU/Linux only:"
	exit
fi

DNF=$(ls /etc/ | grep dnf);

if [[ $DNF != "dnf" ]]; then
	exit
fi

echo "please wait..."

sleep 2
dnf install crypto-policies-scripts -y

update-crypto-policies --set LEGACY

update-crypto-policies --set DEFAULT:FEDORA32

systemctl restart NetworkManager
