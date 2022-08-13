
echo "Shenton Cert Kit"
echo "If you are not attending Shenton College DO NOT RUN THIS SCRIPT"

mkdir certs
mkdir system-cert

CA=$(ls /etc/ssl/certs | grep Education-CA);
SubCA1=$(ls /etc/ssl/certs | grep Education-SubCA1);
SubCA2=$(ls /etc/ssl/certs | grep Education-SubCA2);

# debug
echo $CA
echo $SubCA1
echo $SubCA2


if [[ $CA = "Education-CA.pem" ]]; then 
	echo "CA cert found"
else
	curl -O --output-dir certs https://certs.education.wa.edu.au/education-pki/cert/Education-CA.cer
	openssl x509 -in certs/Education-CA.cer -out system-cert/Education-CA.pem
	sudo cp system-cert/Education-CA.pem /etc/certs/
fi

if [[ $SubCA1 = "Education-SubCA1.pem" ]]; then  
        echo "SubCA1 cert found"
else
	curl -O --output-dir https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA1.cer
	openssl x509 -in certs/Education-SubCA1.cer -out system-cert/Education-SubCA1.pem
	sudo cp system-cert/Education-SubCA1.pem /etc/certs/
	
fi

if [[ $SubCA2 = "Education-SubCA2.pem" ]]; then
        echo "SubCA2 cert found"
else
	curl -O --output-dir  https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA2.cer
	openssl x509 -in certs/Education-SubCA2.cer -out system-cert/Education-SubCA2.pem
	sudo cp system-cert/Education-SubCA2.pem /etc/certs/
fi
