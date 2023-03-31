You4:57 PM
https://github.com/f-ficacious/dockerfiles
You5:00 PM
git clone https://github.com/f-ficacious/dockerfiles.git
You5:06 PM
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
You5:07 PM
sudo systemctl enable docker
sudo systemctl start docker
You5:11 PM
grep docker /etc/group
You5:13 PM
sudo dnf -y update
You5:19 PM
$HOME/docker/appdata
$HOME/docker/data
echo $HOME
You5:21 PM
echo ~
You5:24 PM
sudo dnf search docker
You5:25 PM
sudo dnf install docker-compose
sudo systemctl enable --now s=docker
You5:28 PM
sudo dnf -y install dnf-plugins-core
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager \ --add-repo \ https://download.docker.com/linux/fedora/docker-ce.repo
https://www.fosslinux.com/95109/how-to-install-docker-on-fedora.htm
You5:29 PM
sudo dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin
You5:31 PM
sudo dnf makecache
You5:33 PM
sudo systemctl enable --now docker
sudo docker ps
You5:34 PM
cd ./dockerfiles
You5:36 PM
./media_create
chmod +x ./media_cre
You5:39 PM
sudo docker-compose -f ./media.yml up -d
You5:40 PM
sudo docker pull -f ./media.yml
You5:42 PM
/home/patrick
You5:43 PM
sudo docker volume rm $(sudo docker volume ls | awk '{print $1}')
sudo docker volume rm $(sudo docker volume ls | awk '{print $2}')
You5:45 PM
0.0.0.0:17442
cze-vrkx-fyq
