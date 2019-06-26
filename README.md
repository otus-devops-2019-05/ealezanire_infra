# ealezanire_infra
ealezanire Infra repository

Homework №3 cloud-bastion:

	1. Произведена регистрация на GCP.
	Создание виртуальных хостов и настройка сети:
		bastion_IP = 35.207.159.187
		someinternalhost_IP = 10.156.0.3
		
	2. Настройка подключения по ssh:
		В конфигурации ssh включаем ForwardAgent:
			echo "ForwardAgent Yes" >> /etc/ssh/ssh_config
		Запуск ssh-agent: eval `ssh-agent`
		Подключение к узлам:
			ssh-add ~/.ssh/appuser
			bastion:
				ssh -i ~/.ssh/appuser -A appuser@35.207.159.187
			someinternalhost:
				ssh -i ~/.ssh/appuser -tt -A appuser@35.207.159.187 ssh appuser@10.156.0.3
				
		Дополнительное задание:
		
			В /etc/ssh/ssh_config добавляем alias:
				Host bastion
					User appuser
					HostName 35.207.159.187
					Port 22
					IdentityFile ~/.ssh/appuser
					ServerAliveCountMax 10
					ServerAliveInterval 30
					StrictHostKeyChecking no
					ForwardAgent yes
				Host someinternalhost
					User appuser
					HostName 10.156.0.3
					Port 22
					ProxyCommand ssh bastion nc %h %p		
				Теперь, для подключения к хосту за basion достаточно ввести команду:
					ssh someinternalhost
					
		3. Создание VPN-сервера для GCP.
			На bastion создаем скрипт setupvpn.sh.
			https://gist.github.com/Nklya/df07e99e63e4043e6a699060a7e30b66
			Запускаем установку: sudo bash setupvpn.sh
			В браузере перешел на страницу настройки vpn сервера.(С Windows зайти не удалось,
			фаервол постоянно ругается на серты и не пускает на сайт. Использовал ВМ с Debian)
			Проведена настройка pritunl, настройка фаервола GCP.
			Скачал файл с конфигурацией для подключения по VPN. Проверил подключение с Windows 
			и Debian. Подключился по ssh напрямую к someinternalhost.
			
Homework №4 cloud-testapp:

	1. Установлен gcloud
		echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
		apt-get install apt-transport-https ca-certificates
		apt install curl
		curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
		apt-get update && sudo apt-get install google-cloud-sdk
		gcloud init
		Проведена инициализация gloud.
		
	2. Через gcloud cli создана виртуальная машина reddit-app.
		https://gist.githubusercontent.com/Nklya/5bc429c6ca9adce1f7898e7228788fe5/raw/01f9e4a1bf00b4c8a37ca6046e3e4d4721a3316a/gcloud
		Установлены ruby и bundler:
			sudo apt update
			sudo apt install -y ruby-full ruby-bundler build-essential
		Установлено MongoDB:
			sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
			sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
			sudo systemctl start mongod
			sudo systemctl enable mongod
		Установлена puma:
			cd /home/appuser
			git clone -b monolith https://github.com/express42/reddit.git
			cd reddit && bundle install
			puma -d
		Через вебинтерфейс настроен фаерволл на порт 9292.
		Подключился к веб интерфейсу приложения через http://35.198.165.5:9292
		testapp_IP = 35.198.165.5
		testapp_port = 9292
		
	3. Созданы скрипты для развертывания приложения на сервере:
		install_ruby.sh
		install_mongodb.sh
		deploy.sh
		
	4. Создан startup_script.sh для автоматической настройки и запуска приложения при создании инстанса:
		#!/bin/bash
		DIRECTORY='/home/appuser'
		sudo apt update
		sudo apt install -y ruby-full ruby-bundler build-essential
		sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
		sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.l$
		sudo apt update
		sudo apt install -y mongodb-org
		sudo systemctl start mongod
		sudo systemctl enable mongod
		echo $DIRECTORY
		if [ -d "$DIRECTORY" ]; then
			cd $DIRECTORY
		else
			mkdir "$DIRECTORY"
			cd $DIRECTORY
		fi
		git clone -b monolith https://github.com/express42/reddit.git
		cd reddit && bundle install
		puma -d
		
	5. Обновлен скрипт для создания инстанса deploy_puma.sh:
		#!/bin/sh
		gcloud compute instances create reddit-app\
			  --boot-disk-size=10GB \
			  --image-family ubuntu-1604-lts \
			  --image-project=ubuntu-os-cloud \
			  --machine-type=g1-small \
			  --tags puma-server \
			  --restart-on-failure \
			  --metadata-from-file startup-script=startup_script.sh
			  
	6. Создан скрипт для создания правила фаерволла firewall_puma.sh:
		#!/bin/bash
		gcloud compute firewall-rules create puma-server --target-tags puma-server --allow tcp:9292

Homework №5 packer:

	1. Установка Packer:
		wget https://releases.hashicorp.com/packer/1.4.1/packer_1.4.1_linux_amd64.zip /opt
		unzip packer_1.4.1_linux_amd64.zip
		rm *.zip
		ln -s /opt/packer /usr/bin/

	2. Настройка Application Default Credentials (ADC):
		gcloud auth application-default login
		Переходим по ссылке, получаем код и копируем его в поле : "Enter verification code"
		
		Получаем следующий вывод:
		
			Credentials saved to file: [/root/.config/gcloud/application_default_credentials.json]

			These credentials will be used by any library that requests
			Application Default Credentials.

			To generate an access token for other uses, run:
			gcloud auth application-default print-access-token

	3. Packer builder:
		
		В параметре project_id указываем свой id(можно достать из GCP или командой за консоли:
			gcloud projects list)

		Создаем шаблон следующего содержания:
		{
			"builders": [
		        {
		            "type": "googlecompute",
		            "project_id": "infra-244218",
		            "image_name": "reddit-base-{{timestamp}}",
		            "image_family": "reddit-base",
		            "source_image_family": "ubuntu-1604-lts",
		            "zone": "europe-west1-b",
		            "ssh_username": "appuser",
		            "machine_type": "f1-micro"
		        }
		    ],
		    "provisioners": [
				{
					"type": "shell",
					"script": "scripts/install_ruby.sh",
					"execute_command": "sudo {{.Path}}"
				},
				{
					"type": "shell",
					"script": "scripts/install_mongodb.sh",
					"execute_command": "sudo {{.Path}}"
				}
			]
		}
		
			Подправляем скрипты, поскольку в конфиге packer уже указано, что все команды используются
			с sudo. В корне packer создаем директорию для инсталяционных скриптов и копируем их из
			config-scripts, в корне проекта, туда. После, проверяем наш темплейт:
				packer validate ./ubuntu16.json

		После запуска скрипта проверяем, что в GCP ->Compute Engine ->Images появился созданный нами образ.

	4. Gcloud custom image:
		https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images

		Создаем инстанс на основе нашего образа командой:
			gcloud compute instances create reddit-app\
				--boot-disk-size=10GB \
				--image-family reddit-base \
				 --machine-type=g1-small \
				--tags puma-server \
				--restart-on-failure 

		Найти имя созданного образа можно командой:
			gcloud compute images list | grep reddit

		Задаем правило фаерволла для инстансов с тегом puma-server:
			gcloud compute firewall-rules create puma-server --target-tags puma-server --allow tcp:9292
	
		Вывести список всех правил фаерволла:
			gcloud compute firewall-rules list
		
		Получаем информацию о нашем инстансе:
			gcloud compute instances list | grep reddit-app

	5. Донастраиваем наше приложение согласно предидущим заданиям:
		eval `ssh-agent`
		ssh-add ~/.ssh/appuser
		ssh -i ~/.ssh/appuser -A appuser@35.242.193.91
		Попутно обновляем known_hosts, поскольку за этим ip у нас уже были записи.
		После установки и запуска приложения puma, проверяем, что она работает (ps aux | grep puma).
		Подключаемся, создаем пользователя и логинимся. 





