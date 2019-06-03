#!/bin/sh



# 1. 生成 intermediate.p12
keytool -importkeystore -srckeystore key -destkeystore intermediate.p12 -srcstoretype JKS -deststoretype PKCS12 -srcstorepass qfwlkj2013 -deststorepass qfwlkj2013 -srcalias texas -destalias texas -srckeypass qfwlkj2013 -destkeypass qfwlkj2013 -noprompt

# 2. 将 p2 转成 intermediate.pem
openssl pkcs12 -in intermediate.p12 -out intermediate.pem -passin pass:qfwlkj2013 -passout pass:qfwlkj2013

# 3. 生成 private.rsa.pem
# 拷贝
# -----BEGIN RSA PRIVATE KEY-----
# -----END RSA PRIVATE KEY-----
# 之间的部分，生成新文件
# 注意包括起始和结束的部分


# 显示私钥在命令行界面上
# openssl rsa -in private.rsa.pem -check

# 4. 生成 cert.x509.pem (for signapk.jar)
# 拷贝
# -----BEGIN CERTIFICATE-----
# -----END CERTIFICATE-----
# 之间的部分，生成新文件
# 注意包括起始和结束的部分

# 5. 生成 private.pk8 (for signapk.jar)
# 文档说要 private.rsa.pem 来生成，但是直接用 intermediate.pem 也可以
openssl pkcs8 -topk8 -outform DER -in intermediate.pem  -inform PEM -out private.pk8 -nocrypt  


# 6. 通过 signapk.jar 生成新包
# java -jar signapk.jar cert.x509.pem private.pk8 unsigned.apk signed.apk
