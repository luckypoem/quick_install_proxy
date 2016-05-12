# Install Squid as HTTPS proxy
Thansk to [Build a Squid transparent proxy from source code](https://gist.github.com/e7d/1f784339df82c57a43bf)
 and [squid3-ssl-docker](https://github.com/fgrehm/squid3-ssl-docker)


1. change user to root and run the squid-install.sh, You may known the IP address of your VPS first.
```
su root
cd ~
./squid-install.sh
```
2. start the service 
```
service squid restart
```

3. open the Firewall of VPS that allow TCP incomimg for 3128(HTTP) and 3130(HTTP) port

4. use Chrome browser and install SwitchOmega plugin, configure the Proxy, HTTPS ip:3130  
     
5. import the cert file to the System. 
   * For Mac OS, just double click the file, then it will be open with KeyChain Access, choose 'Always Trust' for this 
   certificate.
      
6. test the proxy
   ```
   netstat -anop |grep 31
   
   # get the access denied page
   curl --proxy http://127.0.0.1:3128 http://example.com
   
   # will fetch the page through proxy
   curl --proxy-user proxy:Jasdfa79aslocUsdRqcda3 --proxy http://127.0.0.1:3128 http://example.com
      
   # get the access denied page
   openssl s_client -connect 127.0.0.1:3130 -cert /etc/squid/squid_https.cert
   >>GET http://example.com HTTP/1.1 [ENTER] [ENTER]
   >>[Ctrl-D]
      
   ```
      
## Side effects
The installation script will install these to system:

  * config file: /etc/squid/squid.conf
  * log file: /var/log/squid/
  * certificate: ~/squid_https.cert
  * start script: /etc/init.d/squid
  * pem for squid: /etc/squild/squid_private.pem、/etc/squild/squid_proxy.pem
  * start HTTP proxy at 3128 port and HTTPS proxy at 3130 port.