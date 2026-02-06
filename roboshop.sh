#!/binbash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-019646167c2b38fb7" # take the SG ID from your AWS account

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.micro --security-group-ids sg-019646167c2b38fb7 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' --query 'Instances[0].InstanceId' --output text)

    # Get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids i-0927c21f1232f7b2d --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids i-0927c21f1232f7b2d --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
        echo "$instace: $IP"
done