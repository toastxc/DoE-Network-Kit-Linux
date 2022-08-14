################################################## PREREQ ##########################################################
# sudo checker
if (( $EUID != 0 )); then
        echo "please run as root"
        exit
fi

wifiadapt=$(ls /sys/class/net  | grep w)

if [[ $wifiadapt = "" ]]; then
	echo "no wifi compatible devie found"
	exit
fi

if (($OSTYPE != "linux-gnu")); then
	echo "this script is for GNU/Linux only:"
	exit
fi

############################################### WIFI SETTINGS ######################################################


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



touch /etc/NetworkManager/system-connections/WIRELESS-2.4.nmconnection

parse=$(cat <<EOF
[connection]\n
id=WIRELESS-2.4\n
uuid=ac9c73e7-783d-46f9-a10a-936807a87d08\n
type=wifi\n
autoconnect=$autoconnect\n
interface-name=$wifiadapt\n
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

# disable for safety
echo -e $parse > /etc/NetworkManager/system-connections/WIRELESS-2.4.nmconnection

systemctl restart NetworkManager
######################################### CERTIFICATE INSTALLATION #################################################



Certdir=$(ls | grep certs);
Syscertdir=$(ls | grep system-cert);

if [[ $Certdir != "certs" ]]; then
	mkdir certs
fi

if [[ $Syscertdir != "system-cert" ]]; then
	mkdir system-cert
fi


CA=$(ls /etc/ssl/certs | grep Education-CA);
SubCA1=$(ls /etc/ssl/certs | grep Education-SubCA1);
SubCA2=$(ls /etc/ssl/certs | grep Education-SubCA2);


Shencheck=$(curl -s enrol.shenton.wa.edu.au);

echo $Shencheck

if [[ $Shencheck = "" ]]; then
        echo "Could not reach Shenton repository, please try connecting to Shenton WiFi"
	exit
fi


if [[ $CA = "Education-CA.pem" ]]; then
	echo "CA cert found"
else
	curl -O --output-dir certs https://certs.education.wa.edu.au/education-pki/cert/Education-CA.cer
	openssl x509 -in certs/Education-CA.cer -out system-cert/Education-CA.pem
	cp system-cert/Education-CA.pem /etc/certs/
fi

if [[ $SubCA1 = "Education-SubCA1.pem" ]]; then
        echo "SubCA1 cert found"
else
	curl -O --output-dir https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA1.cer
	openssl x509 -in certs/Education-SubCA1.cer -out system-cert/Education-SubCA1.pem
	cp system-cert/Education-SubCA1.pem /etc/certs/

fi

if [[ $SubCA2 = "Education-SubCA2.pem" ]]; then
        echo "SubCA2 cert found"
else
	curl -O --output-dir  https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA2.cer
	openssl x509 -in certs/Education-SubCA2.cer -out system-cert/Education-SubCA2.pem
	cp system-cert/Education-SubCA2.pem /etc/certs/
fi


systemctl restart NetworkManager

########################################### FEDORA NETWORKING #####################################################

DNF=$(ls /etc/ | grep dnf);

if [[ $DNF != "dnf" ]]; then
	exit
fi


dnf install crypto-policies-scripts -y

update-crypto-policies --set LEGACY

update-crypto-policies --set DEFAULT:FEDORA32

systemctl restart NetworkManager
