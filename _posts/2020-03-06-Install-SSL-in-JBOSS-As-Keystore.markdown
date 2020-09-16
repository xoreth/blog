---
layout: post
title: Install SSL in JBOSS As Keystore
author: Galuh D Wijatmiko
categories: [SecurityTunningAndHardening]
tags: [SSL]
draft: false
published: true
---

Change directory where all *CERTIFICATE* available
```bash
cd Certicate-2019-2020
```
Download or Copy and rename as ImportKey.java
```java

import java.security.*;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.DataInputStream;
import java.io.ByteArrayInputStream;
import java.io.FileOutputStream;
import java.security.spec.*;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.util.Collection;
import java.util.Iterator;


public class ImportKey  {

    private static InputStream fullStream ( String fname ) throws IOException {
        FileInputStream fis = new FileInputStream(fname);
        DataInputStream dis = new DataInputStream(fis);
        byte[] bytes = new byte[dis.available()];
        dis.readFully(bytes);
        ByteArrayInputStream bais = new ByteArrayInputStream(bytes);
        return bais;
    }
        
 
    public static void main ( String args[]) {
        
        // change this if you want another password by default
        String keypass = "importkey";
        
        // change this if you want another alias by default
        String defaultalias = "importkey";

        // change this if you want another keystorefile by default
        String keystorename = System.getProperty("keystore");

        if (keystorename == null)
            keystorename = System.getProperty("user.home")+
                System.getProperty("file.separator")+
                "keystore.ImportKey"; // especially this ;-)


        // parsing command line input
        String keyfile = "";
        String certfile = "";
        if (args.length < 2 || args.length>3) {
            System.out.println("Usage: java comu.ImportKey keyfile certfile [alias]");
            System.exit(0);
        } else {
            keyfile = args[0];
            certfile = args[1];
            if (args.length>2)
                defaultalias = args[2];
        }

        try {
            // initializing and clearing keystore 
            KeyStore ks = KeyStore.getInstance("JKS", "SUN");
            ks.load( null , keypass.toCharArray());
            System.out.println("Using keystore-file : "+keystorename);
            ks.store(new FileOutputStream ( keystorename  ),
                    keypass.toCharArray());
            ks.load(new FileInputStream ( keystorename ),
                    keypass.toCharArray());

            // loading Key
            InputStream fl = fullStream (keyfile);
            byte[] key = new byte[fl.available()];
            KeyFactory kf = KeyFactory.getInstance("RSA");
            fl.read ( key, 0, fl.available() );
            fl.close();
            PKCS8EncodedKeySpec keysp = new PKCS8EncodedKeySpec ( key );
            PrivateKey ff = kf.generatePrivate (keysp);

            // loading CertificateChain
            CertificateFactory cf = CertificateFactory.getInstance("X.509");
            InputStream certstream = fullStream (certfile);

            Collection c = cf.generateCertificates(certstream) ;
            Certificate[] certs = new Certificate[c.toArray().length];

            if (c.size() == 1) {
                certstream = fullStream (certfile);
                System.out.println("One certificate, no chain.");
                Certificate cert = cf.generateCertificate(certstream) ;
                certs[0] = cert;
            } else {
                System.out.println("Certificate chain length: "+c.size());
                certs = (Certificate[])c.toArray();
            }

            // storing keystore
            ks.setKeyEntry(defaultalias, ff, 
                           keypass.toCharArray(),
                           certs );
            System.out.println ("Key and certificate stored.");
            System.out.println ("Alias:"+defaultalias+"  Password:"+keypass);
            ks.store(new FileOutputStream ( keystorename ),
                     keypass.toCharArray());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

}// KeyStore


```


Download or Copy and rename as InstallCert.java
```java


import javax.net.ssl.*;
import java.io.*;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

public class InstallCert {

    public static void main(String[] args) throws Exception {
        String host;
        int port;
        char[] passphrase;
        if ((args.length == 1) || (args.length == 2)) {
            String[] c = args[0].split(":");
            host = c[0];
            port = (c.length == 1) ? 443 : Integer.parseInt(c[1]);
            String p = (args.length == 1) ? "changeit" : args[1];
            passphrase = p.toCharArray();
        } else {
            System.out.println("Usage: java InstallCert <host>[:port] [passphrase]");
            return;
        }

        File file = new File("jssecacerts");
        if (file.isFile() == false) {
            char SEP = File.separatorChar;
            File dir = new File(System.getProperty("java.home") + SEP
                    + "lib" + SEP + "security");
            file = new File(dir, "jssecacerts");
            if (file.isFile() == false) {
                file = new File(dir, "cacerts");
            }
        }
        System.out.println("Loading KeyStore " + file + "...");
        InputStream in = new FileInputStream(file);
        KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
        ks.load(in, passphrase);
        in.close();

        SSLContext context = SSLContext.getInstance("TLS");
        TrustManagerFactory tmf =
                TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(ks);
        X509TrustManager defaultTrustManager = (X509TrustManager) tmf.getTrustManagers()[0];
        SavingTrustManager tm = new SavingTrustManager(defaultTrustManager);
        context.init(null, new TrustManager[]{tm}, null);
        SSLSocketFactory factory = context.getSocketFactory();

        System.out.println("Opening connection to " + host + ":" + port + "...");
        SSLSocket socket = (SSLSocket) factory.createSocket(host, port);
        socket.setSoTimeout(10000);
        try {
            System.out.println("Starting SSL handshake...");
            socket.startHandshake();
            socket.close();
            System.out.println();
            System.out.println("No errors, certificate is already trusted");
        } catch (SSLException e) {
            System.out.println();
            e.printStackTrace(System.out);
        }

        X509Certificate[] chain = tm.chain;
        if (chain == null) {
            System.out.println("Could not obtain server certificate chain");
            return;
        }

        BufferedReader reader =
                new BufferedReader(new InputStreamReader(System.in));

        System.out.println();
        System.out.println("Server sent " + chain.length + " certificate(s):");
        System.out.println();
        MessageDigest sha1 = MessageDigest.getInstance("SHA1");
        MessageDigest md5 = MessageDigest.getInstance("MD5");
        for (int i = 0; i < chain.length; i++) {
            X509Certificate cert = chain[i];
            System.out.println
                    (" " + (i + 1) + " Subject " + cert.getSubjectDN());
            System.out.println("   Issuer  " + cert.getIssuerDN());
            sha1.update(cert.getEncoded());
            System.out.println("   sha1    " + toHexString(sha1.digest()));
            md5.update(cert.getEncoded());
            System.out.println("   md5     " + toHexString(md5.digest()));
            System.out.println();
        }

        System.out.println("Enter certificate to add to trusted keystore or 'q' to quit: [1]");
        String line = reader.readLine().trim();
        int k;
        try {
            k = (line.length() == 0) ? 0 : Integer.parseInt(line) - 1;
        } catch (NumberFormatException e) {
            System.out.println("KeyStore not changed");
            return;
        }

        X509Certificate cert = chain[k];
        String alias = host + "-" + (k + 1);
        ks.setCertificateEntry(alias, cert);

        OutputStream out = new FileOutputStream("jssecacerts");
        ks.store(out, passphrase);
        out.close();

        System.out.println();
        System.out.println(cert);
        System.out.println();
        System.out.println
                ("Added certificate to keystore 'jssecacerts' using alias '"
                        + alias + "'");
    }

    private static final char[] HEXDIGITS = "0123456789abcdef".toCharArray();

    private static String toHexString(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 3);
        for (int b : bytes) {
            b &= 0xff;
            sb.append(HEXDIGITS[b >> 4]);
            sb.append(HEXDIGITS[b & 15]);
            sb.append(' ');
        }
        return sb.toString();
    }

    private static class SavingTrustManager implements X509TrustManager {

        private final X509TrustManager tm;
        private X509Certificate[] chain;

        SavingTrustManager(X509TrustManager tm) {
            this.tm = tm;
        }

        public X509Certificate[] getAcceptedIssuers() {
            throw new UnsupportedOperationException();
        }

        public void checkClientTrusted(X509Certificate[] chain, String authType)
                throws CertificateException {
            throw new UnsupportedOperationException();
        }

        public void checkServerTrusted(X509Certificate[] chain, String authType)
                throws CertificateException {
            this.chain = chain;
            tm.checkServerTrusted(chain, authType);
        }
    }

}
```

Compile Import Java
```bash
javac ImportKey.java
```
Conver All certificate as DER (The DER extension is used for binary DER encoded certificates)  

```bash
openssl pkcs8 -topk8 -nocrypt -in roomit.tech.key -inform PEM -out roomit.tech.key.der -outform DER
openssl x509 -in roomit.tech.crt -inform PEM -out roomit.tech.crt.der -outform DER
openssl x509 -in roomit.tech-int.crt -inform PEM -out roomit.tech-int.crt.der -outform DER
```

Import KEY And CRT to KeyStore
```bash
java ImportKey roomit.tech.key.der roomit.tech.crt.der 
```

Output :  
```bash
 Using keystore-file : /home/wajatmaka/keystore.ImportKey
One certificate, no chain.
Key and certificate stored.
Alias:importkey  Password:importkey
```

Create PEM crt and intermediate / CA
```bash
cat roomit.tech-int.crt.der roomit.tech.crt.der > roomit.tech.int.crt.der
cp roomit.tech.int.crt.der /home/wajatmaka
```

Back to your home, in my case /home/wajatmaka. Import your CA to Keystore
```bash
cd /home/wajatmaka
keytool -importcert -alias importkey -file roomit.tech.int.crt.der -keystore keystore.ImportKey
```
Set Password KeyStore
```bash
keytool -storepasswd -keystore keystore.ImportKey

#Enter keystore password:
#New keystore password:
#Re-enter new keystore password:
#To change key password:
```
Change alias ImportKey
```bash
keytool -keypasswd -keystore keystore.ImportKey -alias importkey

#Enter keystore password:
#Enter key password for <importkey>
#New key password for <importkey>:
#Re-enter new key password for <importkey>:
```
Change rename import key
```bash
keytool -changealias -keystore keystore.ImportKey -alias importkey

#Enter destination alias name:  1
#Enter keystore password:
```
Lets Verify
```bash
keytool -list -v -keystore keystore.ImportKey
```

Output :
```bash
Keystore type: JKS
Keystore provider: SUN

Your keystore contains 1 entry

Alias name: 1
Creation date: Aug 11, 2016
Entry type: PrivateKeyEntry
Certificate chain length: 2
Certificate[1]:
Owner: CN=*.roomit.tech
Issuer: CN=RapidSSL SHA256 CA, O=GeoTrust Inc., C=US
Serial number: 7fd09c4db3d0494ad7e15b2aaa05a6d
Valid from: Mon Aug 01 00:00:00 GMT+00:00 2016 until: Thu Aug 31 23:59:59 GMT+00:00 2017
Certificate fingerprints:
	 MD5:  96:11:1D:45:54:D6:64:BC:56:83:ED:83:87:3B:80:7C
	 SHA1: 83:F5:83:33:70:69:36:FA:AF:44:CB:47:8F:F4:96:9B:0A:A0:E1:59
	 SHA256: 77:DB:3F:AC:07:C9:A4:D9:16:56:33:06:FD:98:31:65:30:81:89:B7:5F:BC:8F:A5:79:F8:34:8A:05:6D:78:8F
	 Signature algorithm name: SHA256withRSA
	 Version: 3

Extensions: 

#1: ObjectId: 1.3.6.1.4.1.11129.2.4.2 Criticality=false
0000: 04 81 F1 00 EF 00 75 00   DD EB 1D 2B 7A 0D 4F A6  ......u....+z.O.
0010: 20 8B 81 AD 81 68 70 7E   2E 8E 9D 01 D5 5C 88 8D   ....hp......\..
0020: 3D 11 C4 CD B6 EC BE CC   00 00 01 56 45 D6 8C E2  =..........VE...
0030: 00 00 04 03 00 46 30 44   02 20 03 7D FC BC CA 1A  .....F0D. ......
0040: 07 89 4E AD C4 BD 81 69   0E 44 34 CE 28 3A 1D 55  ..N....i.D4.(:.U
0050: 48 FE B5 D4 1D 6A EC 04   CA 40 02 20 75 30 B6 85  H....j...@. u0..
0060: C4 BA F1 D6 5F 44 6D D9   A6 20 CA 92 93 F4 15 64  ...._Dm.. .....d
0070: E5 7A D4 A0 9B 76 FB 4A   5B 43 5D 67 00 76 00 A4  .z...v.J[C]g.v..
0080: B9 09 90 B4 18 58 14 87   BB 13 A2 CC 67 70 0A 3C  .....X......gp.<
0090: 35 98 04 F9 1B DF B8 E3   77 CD 0E C8 0D DC 10 00  5.......w.......
00A0: 00 01 56 45 D6 8D 83 00   00 04 03 00 47 30 45 02  ..VE........G0E.
00B0: 21 00 8F 7B 36 F6 1B B4   16 E9 CA D7 0B B6 45 D9  !...6.........E.
00C0: D7 89 1A C5 ED FE 4D 83   85 CC 62 4F 95 FE 33 57  ......M...bO..3W
00D0: AE 29 02 20 72 29 7A 6E   9D E3 B9 FD E0 1C 80 5E  .). r)zn.......^
00E0: 2A 56 EE 25 2C B5 5D A6   C4 82 CF B7 CC 7C 99 38  *V.%,.]........8
00F0: 35 86 6F 5D                                        5.o]

#2: ObjectId: 1.3.6.1.5.5.7.1.1 Criticality=false
AuthorityInfoAccess [
  [
   accessMethod: ocsp
   accessLocation: URIName: http://gp.symcd.com
, 
   accessMethod: caIssuers
   accessLocation: URIName: http://gp.symcb.com/gp.crt
]
]

#3: ObjectId: 2.5.29.35 Criticality=false
AuthorityKeyIdentifier [
KeyIdentifier [
0000: 97 C2 27 50 9E C2 C9 EC   0C 88 32 C8 7C AD E2 A6  ..'P......2.....
0010: 01 4F DA 6F                                        .O.o
]
]

#4: ObjectId: 2.5.29.19 Criticality=false
BasicConstraints:[
  CA:false
  PathLen: undefined
]

#5: ObjectId: 2.5.29.31 Criticality=false
CRLDistributionPoints [
  [DistributionPoint:
     [URIName: http://gp.symcb.com/gp.crl]
]]

#6: ObjectId: 2.5.29.32 Criticality=false
CertificatePolicies [
  [CertificatePolicyId: [2.23.140.1.2.1]
[PolicyQualifierInfo: [
  qualifierID: 1.3.6.1.5.5.7.2.1
  qualifier: 0000: 16 1E 68 74 74 70 73 3A   2F 2F 77 77 77 2E 72 61  ..https://www.ra
0010: 70 69 64 73 73 6C 2E 63   6F 6D 2F 6C 65 67 61 6C  pidssl.com/legal

], PolicyQualifierInfo: [
  qualifierID: 1.3.6.1.5.5.7.2.2
  qualifier: 0000: 30 20 0C 1E 68 74 74 70   73 3A 2F 2F 77 77 77 2E  0 ..https://www.
0010: 72 61 70 69 64 73 73 6C   2E 63 6F 6D 2F 6C 65 67  rapidssl.com/leg
0020: 61 6C                                              al

]]  ]
]

#7: ObjectId: 2.5.29.37 Criticality=false
ExtendedKeyUsages [
  serverAuth
  clientAuth
]

#8: ObjectId: 2.5.29.15 Criticality=true
KeyUsage [
  DigitalSignature
  Key_Encipherment
]

#9: ObjectId: 2.5.29.17 Criticality=false
SubjectAlternativeName [
  DNSName: *.roomit.tech
  DNSName: roomit.tech
]

Certificate[2]:
Owner: CN=RapidSSL SHA256 CA, O=GeoTrust Inc., C=US
Issuer: CN=GeoTrust Global CA, O=GeoTrust Inc., C=US
Serial number: 23a71
Valid from: Wed Dec 11 23:45:51 GMT+00:00 2013 until: Fri May 20 23:45:51 GMT+00:00 2022
Certificate fingerprints:
	 MD5:  90:11:03:DB:64:90:BC:BA:38:2E:65:F9:65:38:65:19
	 SHA1: C8:6E:DB:C7:1A:B0:50:78:F6:1A:CD:F3:D8:DC:5D:B6:1E:B7:5F:B6
	 SHA256: E6:68:3E:88:31:5C:D1:CB:40:3C:0C:EA:49:0F:7C:4B:4C:82:C9:1C:D4:85:03:74:89:AA:DB:AA:90:83:9F:61
	 Signature algorithm name: SHA256withRSA
	 Version: 3

Extensions: 

#1: ObjectId: 1.3.6.1.5.5.7.1.1 Criticality=false
AuthorityInfoAccess [
  [
   accessMethod: ocsp
   accessLocation: URIName: http://g2.symcb.com
]
]

#2: ObjectId: 2.5.29.35 Criticality=false
AuthorityKeyIdentifier [
KeyIdentifier [
0000: C0 7A 98 68 8D 89 FB AB   05 64 0C 11 7D AA 7D 65  .z.h.....d.....e
0010: B8 CA CC 4E                                        ...N
]
]

#3: ObjectId: 2.5.29.19 Criticality=true
BasicConstraints:[
  CA:true
  PathLen:0
]

#4: ObjectId: 2.5.29.31 Criticality=false
CRLDistributionPoints [
  [DistributionPoint:
     [URIName: http://g1.symcb.com/crls/gtglobal.crl]
]]

#5: ObjectId: 2.5.29.32 Criticality=false
CertificatePolicies [
  [CertificatePolicyId: [2.16.840.1.113733.1.7.54]
[PolicyQualifierInfo: [
  qualifierID: 1.3.6.1.5.5.7.2.1
  qualifier: 0000: 16 25 68 74 74 70 3A 2F   2F 77 77 77 2E 67 65 6F  .%http://www.geo
0010: 74 72 75 73 74 2E 63 6F   6D 2F 72 65 73 6F 75 72  trust.com/resour
0020: 63 65 73 2F 63 70 73                               ces/cps

]]  ]
]

#6: ObjectId: 2.5.29.15 Criticality=true
KeyUsage [
  Key_CertSign
  Crl_Sign
]

#7: ObjectId: 2.5.29.17 Criticality=false
SubjectAlternativeName [
  CN=SymantecPKI-1-569
]

#8: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: 97 C2 27 50 9E C2 C9 EC   0C 88 32 C8 7C AD E2 A6  ..'P......2.....
0010: 01 4F DA 6F                                        .O.o
]
]
```

Ensure that this value is corect :
```
 Certificate chain length: 2
```
Install Keystore in Java 1.7 above $HOME/jboss/standalone/configuration/
```xml
<connector name="https" protocol="HTTP/1.1" scheme="https" socket-binding="https" secure="true">
  <ssl name="https" password="roomit" certificate-key-file="/app/jboss/cacerts/roomit.keystore" protocol="TLSv1,TLSv1.1,TLSv1.2"/>
</connector>
```

Modify and add HTTPS supported argument , Java 1.7 above :
```bash
if [ "x$JAVA_OPTS" = "x" ]; then
   JAVA_OPTS="-Xms2048m -Xmx2048m -XX:MaxPermSize=512m -Djava.net.preferIPv4Stack=true -Dorg.jboss.resolver.warning=true -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"
   JAVA_OPTS="$JAVA_OPTS -Djboss.modules.system.pkgs=$JBOSS_MODULES_SYSTEM_PKGS -Djava.awt.headless=true"
   JAVA_OPTS="$JAVA_OPTS -Djboss.server.default.config=standalone.xml"
   JAVA_OPTS="$JAVA_OPTS -Ddefault.config.dir=#jboss.server.config.dir"
   JAVA_OPTS="$JAVA_OPTS -Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2"
else
   echo "JAVA_OPTS already set in environment; overriding default settings with values: $JAVA_OPTS"
fi
```

Check SSL Expired
```bash
echo | openssl s_client -servername smsapiv2.roomit.tech -connect smsapiv2.roomit.tech:8443 2>/dev/null | openssl x509 -noout -issuer -subject -dates
```
