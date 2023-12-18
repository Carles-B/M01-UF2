#!/bin/bash

#Vaciar todas las tablas
#Llamo a Script que lo hace.
./firewall_reset.sh

#iptables -X
#iptables -Z
#iptables -t nat -F

#Politica por defecto denegar todo
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#Aceptar ssh desde mi maquina windows
iptables -A INPUT -p tcp --dport 22 -s 10.65.0.75 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d 10.65.0.75 -j ACCEPT


#Aceptar eftp (nuestro protocolo)
#================================================#
												 #
#Recibir datos									 #
iptables -A INPUT -p tcp --dport 3333 -j ACCEPT  #
iptables -A OUTPUT -p tcp --sport 3333 -j ACCEPT #
												 #
#Enviar respuestas								 #
iptables -A OUTPUT -p tcp --dport 3333 -j ACCEPT #	
iptables -A INPUT -p tcp --sport 3333 -j ACCEPT  #
												 #
#================================================#
