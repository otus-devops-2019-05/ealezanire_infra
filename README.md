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
		
		Запуск ssh-agent: val `ssh-agent`
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

			Дополнительное задание не делал. 
