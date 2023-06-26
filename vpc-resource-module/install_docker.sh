#! /bin/bash
yum update -y
yum install docker -y
service docker start
chkconfig docker on
