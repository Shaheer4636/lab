sudo yum install -y automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel
cd /usr/local/src
sudo git clone https://github.com/s3fs-fuse/s3fs-fuse.git
cd s3fs-fuse
sudo ./autogen.sh
sudo ./configure
sudo make
sudo make install


s3fs your-bucket-name /mnt/your-mount -o allow_other -o passwd_file=~/.passwd-s3fs


sudo s3fs buyspeed-nys-uat /mnt/buyspeed-nys-uat -o allow_other -o iam_role=auto
