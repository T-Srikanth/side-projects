resource "aws_instance" "openops" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.openops_sg.name]
  iam_instance_profile = aws_iam_instance_profile.openops_instance_profile.name
  
  root_block_device {
    volume_size = var.root_block_volume_size
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash -ex
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

              sudo apt update -y
              sudo apt install awscli -y

              export HOME="/home/ubuntu"
              export SSH_CLIENT=true
              export INTERACTIVE=false

              # Run the OpenOps install script
              if bash -c "$(curl -fsSL https://openops.sh/install)"; then
                # Extract details from .env
                APP_URL=$(grep '^OPS_PUBLIC_URL=' $HOME/openops/.env | cut -d= -f2-)
                ADMIN_USER=$(grep '^OPS_OPENOPS_ADMIN_EMAIL=' $HOME/openops/.env | cut -d= -f2-)
                ADMIN_PASS=$(grep '^OPS_OPENOPS_ADMIN_PASSWORD=' $HOME/openops/.env | cut -d= -f2-)

                # After extracting values from .env
                SECRET_NAME="openops/credentials/$(hostname)"
                SECRET_VALUE="{admin_user: $ADMIN_USER, admin_pass: $ADMIN_PASS, app_url: $APP_URL}"

                # Create secret
                aws secretsmanager create-secret --name "$SECRET_NAME" --description "OpenOps admin credentials" \
                  --secret-string "$SECRET_VALUE" --region ${var.aws_region} || \
                aws secretsmanager put-secret-value --secret-id "$SECRET_NAME" \
                  --secret-string "$SECRET_VALUE" --region ${var.aws_region}

                # Format the message
                MESSAGE="✅ OpenOps is up and running on instance: $(hostname)\n"
                MESSAGE+="Application URL: $APP_URL\n"
                MESSAGE+="Admin credentials stored securely in AWS Secrets Manager. You can either get secret using aws cli or check .env file on the OpenOps instance.\n"
                MESSAGE+="Secret name: openops/credentials/$(hostname)"


              else
                MESSAGE="❌ OpenOps installation failed on instance $(hostname). Check logs for more datails"
              fi
              
              aws sns publish --region ${var.aws_region} --topic-arn "${aws_sns_topic.openops_notifications.arn}" --message "$(echo -e "$MESSAGE")"
              EOF
  tags = {
    Name = "OpenOps"
  }
}