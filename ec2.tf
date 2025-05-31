# Security group for the EC2 instance
resource "aws_security_group" "web_server" {
  name        = "web-server-sg"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For production, restrict to your IP
  }
  
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web-server-sg"
  }
}

# Create the second EC2 instance with IMDSv1 for vulnerability testing
resource "aws_instance" "vulnerable_server" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_server.id]
  # key_name             = var.key_name  # Your SSH key pair name
  iam_instance_profile   = aws_iam_instance_profile.test_profile.name
  
  # Configure to use IMDSv1 (HttpTokens=optional)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"  # This enables IMDSv1
    http_put_response_hop_limit = 1
  }
 
    user_data = <<-EOF
    #!/bin/bash

    sudo apt update -y
    echo "1"
    sudo mkdir -p /var/www/html/
    echo "2"
    cd /var/www/html/
    echo "7"
    sudo apt install nodejs npm -y
    echo "3"
    sudo apt install npm -y
    echo "4"
    sudo npm init -y
    echo "5"
    sudo npm install express axios -y
    echo "6"


    # Create the app file using multiple echo commands
    sudo echo "const express = require('express');" > /var/www/html/vulnerable-app.js
    sudo echo "const axios = require('axios');" >> /var/www/html/vulnerable-app.js
    sudo echo "const app = express();" >> /var/www/html/vulnerable-app.js
    sudo echo "const port = 80;" >> /var/www/html/vulnerable-app.js
    sudo echo "app.get('/fetch', async (req, res) => {" >> /var/www/html/vulnerable-app.js
    sudo echo "  const url = req.query.url;" >> /var/www/html/vulnerable-app.js
    sudo echo "  " >> /var/www/html/vulnerable-app.js
    sudo echo "  try {" >> /var/www/html/vulnerable-app.js
    sudo echo "    // Vulnerable SSRF endpoint - fetches any URL provided" >> /var/www/html/vulnerable-app.js
    sudo echo "    const response = await axios.get(url);" >> /var/www/html/vulnerable-app.js
    sudo echo "    res.send(response.data);" >> /var/www/html/vulnerable-app.js
    sudo echo "  } catch (error) {" >> /var/www/html/vulnerable-app.js
    sudo echo "    res.status(500).send('Error: ' + error.message);" >> /var/www/html/vulnerable-app.js
    sudo echo "  }" >> /var/www/html/vulnerable-app.js
    sudo echo "});" >> /var/www/html/vulnerable-app.js
    sudo echo "app.listen(port, '0.0.0.0', () => {" >> /var/www/html/vulnerable-app.js
    sudo echo "  console.log('Vulnerable app listening at http://0.0.0.0:80');" >> /var/www/html/vulnerable-app.js
    sudo echo "});" >> /var/www/html/vulnerable-app.js

    echo "7"
    sudo chmod +x /var/www/html/vulnerable-app.js
    echo "8"

    # Create the service file using multiple echo commands
    sudo echo "[Unit]" > /etc/systemd/system/vulnerable-app.service
    sudo echo "Description=Vulnerable Node.js Application" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "After=network.target" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "[Service]" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "Type=simple" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "User=root" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "WorkingDirectory=/var/www/html" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "ExecStart=/usr/bin/node /var/www/html/vulnerable-app.js" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "Restart=on-failure" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "[Install]" >> /etc/systemd/system/vulnerable-app.service
    sudo echo "WantedBy=multi-user.target" >> /etc/systemd/system/vulnerable-app.service

    echo "9"
    # Enable and start the service
    sudo systemctl enable vulnerable-app
    sudo systemctl start vulnerable-app
    echo "10"
    EOF
 
  tags = {
    Name = "vulnerable-server-imdsv1"
  }
}

output "vulnerable_server_public_ip" {
  value = aws_instance.vulnerable_server.public_ip
}
