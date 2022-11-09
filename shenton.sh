################################################## PREREQ ##########################################################

# sudo checker
if (( $EUID != 0 )); then
	echo "Please run as root (try: sudo !!)."
        exit
fi


############################################### WIFI SETTINGS ######################################################

echo "WI-FI"

# credentials 
echo "Username: "
read username 

echo "Password: "
read -s password

echo 'Autoconnect: ("yes" or "no")'
read autocon


#credentials check
usernamecheck=$( echo $username | grep  \\. )

if [[ $usernamecheck = "" ]]; then
	echo "Username invalid, try 'firstname.lastname'."
else
	username=$( echo 'BLUE\'$username)
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

echo "connecting to wifi"
nmcli connection up 'WIRELESS-2.4'

echo "please wait"
wait 3s

######################################### CERTIFICATE INSTALLATION #################################################

echo "CERTIFICATES"

Certdir=$(ls | grep certs);

if [[ $Certdir != "certs" ]]; then
	mkdir certs
	mkdir certs/imp
	mkdir certs/system-cert
fi


CA=$(ls /etc/ssl/certs | grep Education-CA);
SubCA1=$(ls /etc/ssl/certs | grep Education-SubCA1);
SubCA2=$(ls /etc/ssl/certs | grep Education-SubCA2);

Shencheck=$(curl -S https://enrol.shenton.wa.edu.au);

echo $Shencheck

if [[ $Shencheck = "" ]]; then
        echo "Could not reach the Shenton repository. Please try connecting to Shenton WiFi."
	exit
fi


if [[ $CA = "Education-CA.pem" ]]; then
	echo "Education-CA cert found locally."
else
	
	echo "Installing Education-CA..."
	touch certs/imp/Education-CA.cer
	curl https://certs.education.wa.edu.au/education-pki/cert/Education-CA.cer > certs/imp/Education-CA.cer
	openssl x509 -in certs/imp/Education-CA.cer -out certs/system-cert/Education-CA.pem
	cp certs/system-cert/Education-CA.pem /etc/ssl/certs/

	cp certs/system-cert/Education-CA.pem /etc/pki/ca-trust/source/anchors/
fi


if [[ $SubCA1 = "Education-SubCA1.pem" ]]; then
        echo "Education-SubCA1 cert found locally."
else
	echo "Installing Education-SubCA1..."
	touch certs/imp/Education-SubCA1.cer
	curl https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA1.cer > certs/imp/Education-SubCA1.cer
	openssl x509 -in certs/imp/Education-SubCA1.cer -out certs/system-cert/Education-SubCA1.pem
	cp certs/system-cert/Education-SubCA1.pem /etc/ssl/certs/

	cp certs/system-cert/Education-SubCA1.pem /etc/pki/ca-trust/source/anchors/
fi


if [[ $SubCA2 = "Education-SubCA2.pem" ]]; then
        echo "Education-SubCA2 cert found locally."
else
	
	echo "Installing Education-SubCA2..."
	touch certs/imp/Education-SubCA2.cer
	curl https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA2.cer > certs/imp/Education-SubCA1.cer
	openssl x509 -in certs/imp/Education-SubCA1.cer -out certs/system-cert/Education-SubCA2.pem
	cp certs/system-cert/Education-SubCA2.pem /etc/ssl/certs/

	cp certs/system-cert/Education-SubCA2.pem /etc/pki/ca-trust/source/anchors/
fi


update-ca-trust
systemctl restart NetworkManager

########################################### FEDORA NETWORKING #####################################################
echo "FEDORA"

DNF=$(ls /etc/ | grep dnf);

if [[ $DNF != "dnf" ]]; then
	exit
fi


dnf install crypto-policies-scripts -y

update-crypto-policies --set LEGACY

update-crypto-policies --set DEFAULT:FEDORA32

systemctl restart NetworkManager
