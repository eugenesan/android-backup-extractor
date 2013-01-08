#!/bin/sh

JAVA=$(which java)
[ -n "${JAVA}" ] || JAVA=/usr/lib/jvm/default-java/bin/java

$JAVA -cp bin:./lib/bcprov.jar org.nick.abe.Main $*
