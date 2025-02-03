# Installing Python 3.11 on Amazon Linux 2

Amazon Linux 2 doesn't include Python 3.11 by default.  This guide outlines the steps to enable the necessary repositories, build Python 3.11 from source, and optionally set it as the default `python3` command.

## 1. Update Packages


sudo yum update -y


sudo yum groupinstall -y "Development Tools"
sudo yum install -y gcc gcc-c++ make zlib-devel bzip2 bzip2-devel readline-devel \
sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel



cd /usr/src
sudo curl -O [https://www.python.org/ftp/python/3.11.6/Python-3.11.6.tgz](https://www.python.org/ftp/python/3.11.6/Python-3.11.6.tgz)  # Replace with desired version
sudo tar xvf Python-3.11.6.tgz
cd Python-3.11.6
sudo ./configure --enable-optimizations
sudo make altinstall


python3.11 --version
