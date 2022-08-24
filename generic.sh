################################################## PREREQ ##########################################################
# sudo checker
if (( $EUID != 0 )); then
        echo "Please run as root."
        exit
fi


############################################### WIFI SETTINGS ######################################################

echo "WIFI"

# wifi section 


# credentials 
echo "Username: "
read username 

echo "Password: "
read password

echo 'Autoconnect: ("yes" or "no")'
read autocon


#credentials check
usernamecheck=$( echo $username | grep  \\. )

if [[ $usernamecheck = "" ]]; then
	echo "Invalid username, try firstname.lastname"
fi



if [[ $autocon = "no" ]]; then
	autoconnect=$(echo "false")
else
	autoconnect=$(echo "true")
fi



touch /etc/NetworkManager/system-connections/WIRELESS-2.4.nmconnection


interface=$(iw dev | awk '$1=="Interface"{print $2}' )

echo $interface



nmcli connection add \
ipv4.method auto \
type 802-11-wireless \
802-11-wireless.ssid WIRELESS-2.4 \
autoconnect $autoconnect \
connection.interface-name $interface \
802-1x.eap peap   \
802-1x.password $password  \
802-1x.identity $username \
802-1x.phase2-auth mschapv2  \
wifi-sec.key-mgmt wpa-eap \
con-name WIRELESS-2.4 \



nmcli connection reload

echo "Connecting to Wi-Fi"
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


DOECheck=$(curl -S https://certs.education.wa.edu.au/);

echo $DOECheck


if [[ $DOECheck = "" ]]; then
        echo "Could not reach certificate repository, please try connecting to your organisation's WiFi"
	exit
fi



if [[ $CA = "Education-CA.pem" ]]; then
	echo "CA cert located"
else
	
	echo "Installing Edu-CA"
	curl https://certs.education.wa.edu.au/education-pki/cert/Education-CA.cer > certs/imp/Education-CA.cer
	openssl x509 -in certs/imp/Education-CA.cer -out certs/system-cert/Education-CA.pem
	cp certs/system-cert/Education-CA.pem /etc/ssl/certs/
fi


systemctl restart NetworkManager

########################################### FEDORA NETWORKING #####################################################

echo "FEDORA"

if (($OSTYPE != "linux-gnu")); then
	echo "This script is for GNU/Linux only:"
	exit
fi

DNF=$(ls /etc/ | grep dnf);

if [[ $DNF != "dnf" ]]; then
	exit
fi

echo "Please wait..."

sleep 2
dnf install crypto-policies-scripts -y

update-crypto-policies --set LEGACY

update-crypto-policies --set DEFAULT:FEDORA32

systemctl restart NetworkManager
