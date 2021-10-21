data "template_file" "shell-script" {
  template = file("scripts/git.sh")
}

# Render a part using a 'template_file' for customizing GitLab Configuration
data "template_file" "gitlab_application_user_data" {
  template = file("templates/gitlab_application_user_data.tpl")
  vars = {
    postgres_database = "${aws_db_instance.gitlab_postgresql.name}"
    postgres_username = "${aws_db_instance.gitlab_postgresql.username}"
    postgres_password = "${var.gitlab_postgresql_password}"
    postgres_endpoint = "${aws_db_instance.gitlab_postgresql.address}"
    redis_endpoint    = "${aws_elasticache_replication_group.gitlab_redis.primary_endpoint_address}"
    cidr              = "${var.vpc_cidr}"
    gitlab_url        = "http://${aws_lb.alb_apps.dns_name}"
  }
}

#Render a multi-part cloudinit config making use of the part above, and other source files
data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "gitlab_application_user_data.tpl"
    content_type = "text/cloud-config"
    content      = data.template_file.gitlab_application_user_data.rendered
  }

  part {
    content_type = "tect/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}

output "Gitlab_One-Time_DB_Creation_Command-Primary_Only" {
  value = "force=yes; export force; gitlab-rake gitlab:setup"
}

output "Gitlab_One-Time_DB_Creation_Command-Primary_Only_2" {
  value = "sudo gitlab-ctl reconfigure"
}

output "Bastion_Public_IP" {
  value = aws_instance.bastion.public_ip
} #

output "Arkcom_Apps_Public_IP" {
  value = aws_lb.alb_apps.dns_name
}