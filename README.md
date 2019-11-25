# ReportPortal Non-docker Installation

ReportPortal is a service that provides great capabilities for speeding up results analysis and reporting by means of built-in analytical features.  

This guide is intended to provide you with sufficient information to get started with ReportPortal on CentOS/RHEL Linux distributions with no Docker/Kubernetes usage.  

### Installing ReportPortal requirements  

Before you deploy ReportPortal you should have installed all its dependencies.  
- `PostgreSQL` 
- `RabbitMQ`
- `ElasticSearch`

##### PostgreSQL Installation and configuration   

In order to install PostgreSQL 11 on your CentOS/RHEL 7/6 systems please follow the steps below.  

1. Configure Yum Repository  

```sh
## CentOS/RHEL - 7
rpm -Uvh https://yum.postgresql.org/11/redhat/rhel-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

## CentOS/RHEL - 6
rpm -Uvh https://yum.postgresql.org/11/redhat/rhel-6-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

2. Install PostgreSQL 11  

```sh
yum install postgresql11-server
```

3. Initialize PGDATA

This will create a data directory and other configuration files on your system  

```sh
/usr/pgsql-11/bin/postgresql-11-setup initdb
```

4. Start PostgreSQL Server  

To enable and start PostgreSQL service using the following commands as per your operating systems  

CentOS/RHEL – 7
```sh
systemctl enable postgresql-11.service
systemctl start postgresql-11.service
```

CentOS/RHEL – 6
```sh
service postgresql-11 start
chkconfig postgresql-11 on
```

5. Verify PostgreSQL installation  

After completing the above all steps. Your PostgreSQL 11 server is ready to use. Log in to postfix instance to verify the connection  

```sh
su - postgres -c "psql"

psql (11.0)
Type "help" for help.

postgres=# 
```

6. Create ReportPortal user and database

Please run the following commands, having previously determined the name and the password for your ReportPortal db user 

```sh
create database reportportal; 
```

```sh
create user <your_rpdbuser> with encrypted password '<your_rpdbuser_password>';
```

```sh
grant all privileges on database reportportal to <your_rpdbuser>;
ALTER USER rpuser WITH SUPERUSER;
```

7. Change your PostgreSQL authentication methods  

Edit the /var/lib/pgsql/11/data/pg_hba.conf file, and change peer to md5 in the following lines  

```sh
# "local" is for Unix domain socket connections only
local   all             all                                     md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
```

Restart PostgreSQL service  

8. Install the contrib utilities from the PostgreSQL distribution 

```sh
yum install postgresql11-contrib
```

9. Install 'pgcrypto' Postgres extension for 'reportportal' database  

PGPASSWORD=<your_rpdbuser_password> psql -U <your_rpdbuser> -d reportportal -c "CREATE EXTENSION pgcrypto;"

##### RabbitMQ Installation and configuration  

1. Install Erlang

RabbitMQ is written in Erlang Language. Erlang is not available in default YUM repository, hence you will need to install EPEL repository  

```sh
yum -y install epel-release
```

Now install Erlang using following command  

```sh
yum -y install erlang socat
```

You can now check the Erlang version using   

```sh
erl -version
```

2. Install RabbitMQ  

RabbitMQ provides RPM package for enterprise Linux systems which are precompiled and can be installed directly. The only required dependency was to install Erlang into the system  

Download the Erlang RPM package by running  

```sh
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.10/rabbitmq-server-3.6.10-1.el7.noarch.rpm
```

Import the GPG key  

```sh
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
```

Install the RPM package  

```sh
rpm -Uvh rabbitmq-server-3.6.10-1.el7.noarch.rpm
```

3. Start RabbitMQ  

To enable and start RabbitMQ  service using the following commands as per your operating systems  

CentOS/RHEL – 7
```sh
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
```

CentOS/RHEL – 6
```sh
chkconfig rabbitmq-server on
chkconfig --list | grep rabbitmq
sudo service rabbitmq-server start
```

4. Enable Web Console on the default port 15672

Enable RabbitMQ web management console  
```sh
rabbitmq-plugins enable rabbitmq_management
```

Provide ownership of RabbitMQ files to the RabbitMQ user by running  
```sh
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/
```

Now you will need to create an administrative user for RabbitMQ web management console. Run the following commands for same  
```sh
rabbitmqctl add_user admin StrongPassword
 rabbitmqctl set_user_tags admin administrator
 rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
```

5. Configure user, permissions and vhost for ReportPortal

Run the following commands in order to configure your RabbitMQ work with ReportPortal. Please determine the name and the password for your ReportPortal Rabbitmq user in advance  

```sh
rabbitmqctl add_user <your_rpmquser> <your_rpmquser_password>
rabbitmqctl set_user_tags <your_rpmquser> administrator
rabbitmqctl set_permissions -p / <your_rpmquser> ".*" ".*" ".*"
rabbitmqctl add_vhost analyzer
rabbitmqctl set_permissions -p analyzer <your_rpmquser> ".*" ".*" ".*"
```

##### Elasticseach Installation  

The recommended way to install Elasticsearch on CentOS 7 is by installing the rpm package from the official Elasticsearch repository  

1. Install OpenJDK 8 on your CentOS system type  

```sh
sudo yum install java-1.8.0-openjdk-devel
```

Verify the Java installation by printing the Java version

```sh
java -version
```

2. Download and install the public signing key  

```sh
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
```

3. Installing from the RPM repository  

Create a file called elasticsearch.repo in the /etc/yum.repos.d/ directory for RedHat based distributions, or in the /etc/zypp/repos.d/ directory for OpenSuSE based distributions, containing:  

```sh
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
```

You can now install Elasticsearch  

```sh
sudo yum install elasticsearch
```

Once the installation process is complete, start and enable the service by running  

CentOS/RHEL – 7
```sh
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
```

CentOS/RHEL – 6
```sh
chkconfig --add elasticsearch
chkconfig elasticsearch on
service elasticsearch start
```

4. Verify installation

You can verify that Elasticsearch is running by sending an HTTP request to port 9200 on localhost with the following curl command

```sh
curl -X GET "localhost:9200/"
```

The output will look similar to the following  

```sh
{
  "name" : "fLVNqN_",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "6zKcQppYREaRH0tyfJ9j7Q",
  "version" : {
    "number" : "6.7.0",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "8453f77",
    "build_date" : "2019-03-21T15:32:29.844721Z",
    "build_snapshot" : false,
    "lucene_version" : "7.7.0",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}
```


### Download all ReportPortal services & traefik config file

1. Run the following script 'download_services.sh'(<Link>) in order to have all RP services and configuration files on your local system    

```sh
./download_services.sh
```

2. Make sure the files are executable

Use 'chmod +x' on the files if it's not. 


### Use bash script 'start_rp.sh' to start the application

1. Update the script with your db and rabbitmq users and passwords  

```sh
RP_POSTGRES_USER=<your_rpdbuser>
RP_POSTGRES_PASSWORD=<your_rpdbuser_password>
RP_RABBITMQ_USER=<your_rpmquser>
RP_RABBITMQ_PASSWORD=<your_rpmquser_password>
```

You can also change heap size values for API and UAT services by adjusting the following variables  

```sh
# API
SERVICE_API_JAVA_OPTS="-Xms1024m -Xmx2048m"
# UAT
SERVICE_UAT_JAVA_OPTS="-Xms512m -Xmx512m"
```

2. Run the script

```sh
./start_rp.sh 
```


### Check your ReportPortal installation available

```sh
http://localhost:3000
```

or

```sh
http://<your_public_ip>:3000
```




