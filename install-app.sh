#!/bin/bash
#Autor: Guilherme Rodrigues
#Finalidade: Criaçao de VHOST com laravel
#DATA: 30/04/2018
# Algumas documentaçoes:
#https://webtatic.com/packages/php71/
#https://laravel.com/docs/5.6/installation
#https://nodejs.org/en/download/package-manager/
#VERIFICA SE EH ROOT

if [ "$(whoami)" != 'root' ]; then
        echo $"Sem permissao para rodar o $0. Use root"
                exit 1;
fi

osname=$(cat /etc/redhat-release | awk {'print $1'})
if [ "$osname" == "Fedora" ]; then
  SERVICE_="httpd"
  VHOST_PATH="/etc/httpd/conf.d"
  CFG_TEST="service httpd configtest"
else
  echo "Funciona somente no CentOS"
  exit 1;
fi

nome=$(hostname)
cname1='www'
cname2='laraerp'
dir='/var/www/'
docrootfront='laraerp/front'
docrootapi='laraerp/api'
usuario='apache'
listen='*'
porta='80'


echo "Parametros do Front"
echo $dir$cname1_$nome/$docrootfront
echo $VHOST_PATH/$cname1_$nome.conf
echo "  "
echo "Parametros da API"
echo $dir$cname2_$nome/$docrootapi
echo $VHOST_PATH/$cname2_$nome.conf

echo "Acesse o Front-End: http://$cname1.$nome"

echo "Acesse o Back-End: http://$cname2.$nome"

#exit 1

#sleep 10



alias=$cname1.$nome
if [[ "${cname1}" == "" ]]; then
alias=$nome
fi
echo "127.0.0.1 $nome" >> /etc/hosts
if [ "$alias" != "$nome" ]; then
echo "127.0.0.1 $alias" >> /etc/hosts
fi

echo "#### $cname1.$nome
<VirtualHost $listen:$porta>
      ServerAdmin guilhermerodrigues.it@gmail.com
      ServerAlias $alias
      ServerName  $nome
      DocumentRoot $dir$cname_$nome/$docrootfront
      ErrorLog "/var/log/httpd/$alias-error_log"
      CustomLog "/var/log/httpd/$alias-access_log" combined
      <Directory $dir$cname1_$nome/$docrootfront>
      AllowOverride All
       </Directory>
</VirtualHost>" > $VHOST_PATH/$cname1_$nome.conf


if ! mkdir -p $dir$cname1_$nome/; then
echo "Nao foi possivel criar o Diretorio Web !"
else
echo "Diretorio Web criado com sucesso !"
fi

cd $dir$cname1_$nome/

wget https://github.com/almasaeed2010/AdminLTE/archive/v2.4.3.tar.gz

tar -xzvf v2.4.3.tar.gz -C $dir$cname1_$nome/

mv AdminLTE-2.4.3 $docrootfront


alias=$cname2.$nome
if [[ "${cname2}" == "" ]]; then
alias=$nome
fi
echo "127.0.0.1 $nome" >> /etc/hosts
if [ "$alias" != "$nome" ]; then
echo "127.0.0.1 $alias" >> /etc/hosts
fi

echo "#### $cname2.$nome
<VirtualHost $listen:$porta>
      ServerAdmin guilhermerodrigues.it@gmail.com
      ServerAlias $alias
      ServerName  $nome
      DocumentRoot $dir$cname2_$nome/$docrootapi/public
      ErrorLog "/var/log/httpd/$alias-error_log"
      CustomLog "/var/log/httpd/$alias-access_log" combined
      <Directory $dir$cname2_$nome/$docrootapi/public>
      AllowOverride All
       </Directory>
</VirtualHost>" >> $VHOST_PATH/$cname2_$nome.conf



if ! mkdir -p $dir$cname2_$nome/$docrootapi; then
echo "Nao foi possivel criar o Diretorio Web !"
else
echo "Diretorio Web criado com sucesso !"
fi


curl -sS https://getcomposer.org/installer | php

mv composer.phar /usr/local/bin/composer

/usr/local/bin/composer create-project --prefer-dist laravel/laravel $dir$cname2_$nome/$docrootapi

chown -Rf apache:apache $dir$cname2_$nome/$docrootapi

chmod -R 755 $dir$cname2_$nome/$docrootapi/storage

semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/$dir$cname2_$nome/$docrootapi/bootstrap/cache(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/$dir$cname2_$nome/$docrootapi/storage(/.*)?'
restorecon -Rv '/usr/share/nginx/html/testapp'

timedatectl set-timezone America/Sao_Paulo

echo "Testar configuraçao"
$CFG_TEST
read -p "Reiniciar o web server [s/n]? " q
if [[ "${q}" == "sim" ]] || [[ "${q}" == "s" ]]; then
systemctl reload $SERVICE_
fi
echo -e "\n \033[01;32m Processo de Instalaçao Finalizado! \033[01;37m"

echo "Acesse o Front-End: http://$cname1.$nome"

echo "Acesse o Back-End: http://$cname2.$nome"

echo -e "\n \033[01;32m SISTEMA INSTALADO! \033[01;37m"
