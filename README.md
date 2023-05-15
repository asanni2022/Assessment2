# Assessment2

## Django Code Assessment: 05/15/2023

### Architectural Diagram
![Django Web Framework assmt2](https://github.com/asanni2022/Assessment2/assets/104282577/02196ddc-021e-466e-9eab-7a64aaff9a82)


### create Terraform folder
```
  * add main.tf
    # Create security groups Master Node
resource "aws_security_group" "master_SG" {
    name_prefix = "master_SG"

    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
   #create Security Group Child Nodes
resource "aws_security_group" "node1_SG" {
    name_prefix = "node1_SG"

    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

  # create EC2 Instance Master
resource "aws_instance" "ans_master" {
    ami       = var.ami
    instance_type = "t2.micro"
    subnet_id = var.subnet_assmt_pub[0]
    vpc_security_group_ids = [aws_security_group.node1_SG.id]
    key_name = "ola-keypair"

    tags = {
      Name = "my_assessmt_ans_master"
    }
  
}
   # create EC2 Instance Node1
resource "aws_instance" "ans_node1" {
    ami       = var.ami
    instance_type = "t2.micro"
    subnet_id = var.subnet_assmt_pub[1] 
    vpc_security_group_ids = [aws_security_group.node1_SG.id]
    key_name = "ola-keypair"

    tags = {
      Name = "my_assessmt_ans_node1"
    }
  
}
      # create EC2 Instance Node2
resource "aws_instance" "ans_node2" {
    ami       = var.ami
    instance_type = "t2.micro"
    subnet_id = var.subnet_assmt_pub[2]
    vpc_security_group_ids = [aws_security_group.node1_SG.id]
    key_name = "ola-keypair"

    tags = {
      Name = "my_assessmt_ans_node2"
    }
  
}%  
  * add providers.tf
     # Provider login
# Create EC2 Instance
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}%  
  * add variables.tf
     variable "ami" {
    default = "ami-0a695f0d95cefc163"
    description = "ubuntu AMI"
  
}

variable "subnet_assmt_pub" {
    type = list(string)
    default = ["subnet-027f11bae0aa230ee" ,"subnet-017b912d593d1de5b" , "subnet-095b6e69f2e8d13a7"]
  
}

variable "vpc_id" {
    type = string
    default = "vpc-04b83f94794021510"
  
}% 
  * add output.tf
```
### Confirm Instances (Master, Node1 and Node2 all created)

### SSH into Master Node and Run commands below:
```
   * sudo apt update -y
   * sudo apt install ansible -y
```
### mkdir todolist
```
mkdir todolist
cd todolist/
```
### create env file
```
   echo '
# Database settings
USE_POSTGRESQL=False
DB_NAME=todolist
DB_USER=postgres
DB_PASSWORD=WSs9yTSHghMi6Sp
DB_HOST=db1.chzveui56egk.us-east-1.rds.amazonaws.com
DB_PORT=5432' > .env
```
### Add keypair and permission

### create Ansible files
```
  * Add Inventory file
      [webservers]
node1 ansible_host=3.138.142.200 ansible_user=ubuntu
node2 ansible_host=18.219.191.108 ansible_user=ubuntu


[all:vars]
ansible_ssh_private_key_file=/home/ubuntu/ola-keypair.pem
repo_url=https://github.com/chandradeoarya/
repo=todo-list
home_dir=/home/ubuntu
repo_dir={{ home_dir}}/{{ repo }}
django_project=to_do_proj

[defaults]
host_key_checking=no 
```
### Test inventory file
```
ansible all -m ping -i inventory.ini 
```
### add yaml updates file to run updates 
```
  * Add updates yaml file
     nano updates.yml
---
- hosts: all
  become: yes
  become_user: root
  gather_facts: no
  tasks:
    - name: Runing system update
      apt: update_cache=yes
        upgrade=safe
      register: result
    - debug: var=result.stdout_lines
```
### Run updates playbook
```
ansible-playbook -i inventory.ini updates.yml
```
### add yaml packagees file to run required packages 
```
  * Add packages yaml file
     nano packages.yml
---
- hosts: all
  become: yes
  become_user: root
  gather_facts: no
  tasks:
    - name: Running apt update
      apt: update_cache=yes
    - name: Installing required packages
      apt: name={{item}} state=present
      with_items:
       - python3.10-venv
       - python-pip
       - nginx
 ```
 ### Run Packages playbook
```
ansible-playbook -i inventory.ini packages.yml
```
### add yaml code file to run required codes 
 ```
  * Add code yaml file
      nano code.yml
      - hosts: all
  become: yes
  become_user: ubuntu
  gather_facts: no

  tasks:
    - name: pull branch master
      git:
        repo: "{{ repo_url }}/{{ repo }}.git"
        dest: "{{ repo_dir }}"
        accept_hostkey: yes

- hosts: all
  gather_facts: no
  tasks:
    - name: Create virtual environment
      command: python3 -m venv venv
      args:
        chdir: "{{ repo_dir }}"

    - name: install python requirements
      pip:
        requirements: "{{ repo_dir }}/requirements.txt"
        state: present
        executable: "{{ repo_dir }}/venv/bin/pip"
```
 ### Run Packages playbook
```
ansible-playbook -i inventory.ini code.yml
```
### add yaml copyenv file to copy environment variable file
```
  * Add copyenv yaml file
      nano copyenv.yml
---
- name: Set environment variables on hosts
  hosts: all
  become: true
  become_user: ubuntu
  tasks:
    - name: Copy env file to hosts
      copy:
        src: /home/ubuntu/todolist/.env
        dest: /home/ubuntu/todo-list/.env
        mode: 0644
```
### Run copyenv yaml file
```
ansible-playbook -i inventory.ini copyenv.yml
```
### Runnung App
### add gunicorn service, systemd daemon service
```
echo '
[Unit]
Description=Gunicorn instance to serve todolist

Wants=network.target
After=syslog.target network-online.target

[Service]
Type=simple
WorkingDirectory=/home/ubuntu/todo-list
ExecStart=/home/ubuntu/todo-list/venv/bin/gunicorn -c /home/ubuntu/todo-list/gunicorn_config.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target' > todolist.service
```
### Ansible playbook for todolist daemon service
```
   * Add gunicorn ansible playbook file
        nano gunicorn.yml
  ---
- hosts: all
  become: yes
  become_user: root
  gather_facts: no
  tasks:
    - name: Copy Gunicorn systemd service file
      template:
        src: /home/ubuntu/todolist/todolist.service
        dest: /etc/systemd/system/todolist.service
      register: gunicorn_service

    - name: Enable and start Gunicorn service
      systemd:
        name: todolist
        state: started
        enabled: yes
      when: gunicorn_service.changed
      notify:
        - Restart Gunicorn

    - name: Restart Gunicorn
      systemd:
        name: todolist
        state: restarted
      when: gunicorn_service.changed

  handlers:
    - name: Restart Gunicorn
      systemd:
        name: todolist
        state: restarted
```
### Run gunicorn yaml file
```
ansible-playbook -i inventory.ini gunicorn.yml
```
### todolist file
```
echo '
server {
    listen 80;

    server_name public_ip;

    location / {
        proxy_pass http://localhost:9876;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}' > todolist
```
### Nginx playbook for port forwarding
```
   * Add nginx yaml file
         nano nginx.yml 
  ---
- name: Configure Nginx port forwarding
  hosts: all
  become: true
  become_user: root
  gather_facts: no
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present

    - name: Configure Nginx
      template:
        src: todolist
        dest: /etc/nginx/sites-available/todolist
        owner: root
        group: root
        mode: 0644
      notify: Restart Nginx

    - name: Change public_ip in Nginx configuration
      replace:
        path: /etc/nginx/sites-available/todolist
        regexp: 'server_name public_ip;'
        replace: 'server_name {{ ansible_host }};'

    - name: Enable Nginx site
      file:
        src: /etc/nginx/sites-available/todolist
        dest: /etc/nginx/sites-enabled/todolist
        state: link
      notify: Restart Nginx

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```
### Run nginx yaml file
```
ansible-playbook -i inventory.ini nginx.yml 
```

DevOps Class 2
