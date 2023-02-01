################################################## PREREQ ##########################################################
# sudo checker
if (( $EUID != 0 )); then
	echo 'Please run as root (try sudo !!).'
        exit
fi


############################################### WIFI SETTINGS ######################################################

echo "WIFI"


# credentials 
echo "Username: "
read username 

echo "Password: "
read -s password

echo 'Would you like to autoconnect: ("yes" or "no")'
read autocon


#credentials check
usernamecheck=$( echo $username | grep  \\. )

if [[ $usernamecheck = "" ]]; then
	echo "Username invalid, try firstname.lastname."
else
	username=$( echo $username)
fi

if [[ $autocon = "no" ]]; then
	autoconnect=$(echo "false")
else
	autoconnect=$(echo "true")
fi



interface=$(iw dev | awk '$1=="Interface"{print $2}' )

echo $interface

nmcli connection delete 'WIRELESS-2.4'

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
con-name 'WIRELESS-2.4' \



echo "Connecting to Wi-Fi..."
nmcli connection up 'WIRELESS-2.4'

echo "Please wait..."
wait 5s

######################################### CERTIFICATE INSTALLATION #################################################

echo "CERTIFICATES"


Certdir=$(ls | grep certs);

if [[ $Certdir != "certs" ]]; then
	mkdir certs
	mkdir certs/imp
	touch certs/imp/Education-CA.cer
	touch certs/imp/Education-SubCA1.cer
	touch certs/imp/Education-SubCA2.cer

	mkdir certs/system-cert
fi



CA=$(ls /etc/ssl/certs | grep Education-CA);
SubCA1=$(ls /etc/ssl/certs | grep Education-SubCA1);
SubCA2=$(ls /etc/ssl/certs | grep Education-SubCA2);



DOECheck=$(curl -S https://certs.education.wa.edu.au);

echo $DOECheck


if [[ $DOECheck = "" ]]; then
        echo "Could not reach the certificate repository. Please try connecting to your school's Wi-Fi."
	exit
fi



if [[ $CA = "Education-CA.pem" ]]; then
	echo "Education-CA cert found locally."
else
	
	echo "Installing Education-CA..."
	curl https://certs.education.wa.edu.au/education-pki/cert/Education-CA.cer > certs/imp/Education-CA.cer
	openssl x509 -inform der -in certs/imp/Education-CA.cer -out certs/system-cert/Education-CA.pem
	cp certs/system-cert/Education-CA.pem /etc/ssl/certs/
fi

if [[ $SubCA1 = "Education-SubCA1.pem" ]]; then
        echo "Education-SubCA1 cert found locally."
else
	echo "Installing Education-SubCA1..."
	curl https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA1.cer > certs/imp/Education-SubCA1.cer
	openssl x509 -inform der -in certs/system-cert/Education-SubCA1.cer -out certs/system-cert/Education-SubCA1.pem
	cp certs/system-cert/Education-SubCA1.pem /etc/ssl/certs/
fi

if [[ $SubCA2 = "Education-SubCA2.pem" ]]; then
        echo "Education-SubCA2 cert found locally."
else
	
	echo "Installing Education-SubCA2..."
	curl https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA2.cer > certs/imp/Education-SubCA1.cer
	openssl x509 -inform der -in certs/imp/Education-SubCA1.cer -out certs/system-cert/Education-SubCA2.pem
	cp certs/system-cert/Education-SubCA2.pem /etc/ssl/certs/
fi

systemctl restart NetworkManager

########################################### FEDORA NETWORKING #####################################################
echo "FEDORA"


DNF=$(ls /etc/ | grep dnf);

if [[ $DNF != "dnf" ]]; then
	echo "Non RHEL-based system detected, exiting..."
	exit
fi


dnf install crypto-policies-scripts -y

update-crypto-policies --set LEGACY

update-crypto-policies --set DEFAULT:FEDORA32

systemctl restart NetworkManager
