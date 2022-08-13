echo "Shenton Cert Kit"
echo "If you are not attending Shenton College DO NOT RUN THIS SCRIPT"

mkdir certs
mkdir certs/curled
mkdir certs/system
mkdir certs/firefox

#wget -b https://certs.education.wa.edu.au/education-pki/cert/Education-CA.cer
#wget -b https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA1.cer
#wget -b https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA2.cer

curl --create-dirs -O --output-dir certs https://certs.education.wa.edu.au/education-pki/cert/Education-CA.cer
curl -O --output-dir https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA1.cer
curl -O --output-dir  https://certs.education.wa.edu.au/education-pki/cert/Education-SubCA2.cer

mkdir system-cert

openssl x509 -in certs/Education-CA.cer -out system-cert/Education-CA.pem
openssl x509 -in certs/Education-SubCA2.cer -out system-cert/Education-SubCA2.pem
openssl x509 -in certs/Education-SubCA1.cer -out system-cert/Education-SubCA1.pem

sudo cp system-cert/Education-CA.pem /etc/certs/
sudo cp system-cert/Education-SubCA1.pem /etc/certs/
sudo cp system-cert/Education-SubCA2.pem /etc/certs/
