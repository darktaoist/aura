#!/bin/bash
/Applications/Android\ Studio.app/Contents/jbr/Contents/Home/bin/keytool -genkeypair -v -keystore ~/works/gwansang/android/app/aura-release.jks -alias aura -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=taoist, O=taoist.co.kr, L=Seoul, ST=Seoul, C=KR" -storetype PKCS12
