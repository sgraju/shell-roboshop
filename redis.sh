#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-roboshop/mondgodb.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}


dnf module disable redis -y  &>>$LOG_FILE
VALIDATE $? "Installing Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enabled Redis:7" 

dnf install redis -y  &>>$LOG_FILE
VALIDATE $? "Installing Redis" 

sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf  -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Allowing remote connection to Redis"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling Redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "starting Redis"

END_TIME=$(date +%s)
TOTAL_TIME=$(($END_TIME - $START_TIME))

echo "Total time taken to execute the script:$TOTAL_TIME"