# Install HTTPS proxy using Squid
Thansk to [Build a Squid transparent proxy from source code](https://gist.github.com/e7d/1f784339df82c57a43bf)
and [squid3-ssl-docker](https://github.com/fgrehm/squid3-ssl-docker)

* change user to root and run the squid-install.sh, You need known the IP address of your VPS first.

```
su root
cd ~
./squid-install.sh
```

* start the service 

```
service squid restart
```

* test the proxy

```
netstat -anop |grep 31
# get the access denied page
curl --proxy http://127.0.0.1:3128 http://example.com

# will fetch the page through proxy
curl --proxy-user proxy:Jasdfa79aslocUsdRqcda3 --proxy http://127.0.0.1:3128 http://example.com

# get the access denied page
openssl s_client -connect 127.0.0.1:3130 -CAfile /etc/squid/squid_proxy.pem
>>GET http://example.com HTTP/1.1 [ENTER] [ENTER]
>>[Ctrl-D]

```

* Change firewall rules to allow TCP incoming for HTTP(3128) and HTTPS(3130) port

```
iptables -A INPUT -s 127.0.0.1 -p tcp --dport 3128 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3130 -j ACCEPT
```


* Open Chrome browser and install [SwitchOmega plugin](https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif?hl=en), add HTTPS(or SSL) Proxy setting to IP:3130

* Import the cert file squid_proxy.pem to the System. 
	* For Mac OS, just double click the file, then it will be open with KeyChain Access, choose 'Always Trust' for this 
	certificate. 

## Side effects
The installation script will install these files to system:

* config file: /etc/squid/squid.conf
* log file: /var/log/squid/
* service script: /etc/init.d/squid
* certificate/private key for squid: /etc/squild/squid_private.pem、/etc/squild/squid_proxy.pem

## Security

* Allow only few IP for accessing 3128/3130 port.
* Disable HTTP proxy if possible.
* Use user/password for auth.

## TODO
* verify the client, only clients with certificate can login this https proxy.
* No response to client if auth fail!
