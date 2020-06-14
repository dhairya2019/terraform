provider "aws" {
  region  = "ap-south-1"
  profile = "dhairya"
}

 resource "aws_instance" "myin" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name = "test"
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  
   connection {
    type     = "ssh"
    user     = "ec2-user"
   private_key = file("C:/Users/dhair/Downloads/test.pem")
	port = 22
    host     = aws_instance.myin.public_ip
  }
   provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd php git -y",
      "sudo systemctl start httpd",
	  "sudo systemctl enable httpd",
	  
    ]
	
  }


  tags = {
    Name = "dhairyaos"
  }
}



resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow TCP inbound traffic"
  vpc_id      = "vpc-00e9f468"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "allow_http"
  }
}


resource "aws_ebs_volume" "external_volume" {
  availability_zone = aws_instance.myin.availability_zone
  size              = 1
}
resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.external_volume.id
  instance_id = aws_instance.myin.id
  force_detach =true
}

output "myos_ip" {
  value = aws_instance.myin.public_ip
}
resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.myin.public_ip} > publicip.txt"
  	}
}

resource "null_resource" "execute" {

depends_on =[
aws_volume_attachment.ebs_attach,
]
connection {
    type     = "ssh"
    user     = "ec2-user"
     private_key = file("C:/Users/dhair/Downloads/test.pem")
	 port=22
    host     = aws_instance.myin.public_ip
  }

 provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdf",
	  "sudo mount /dev/xvdf /var/www/html",
	  "sudo rm -rf /var/www/html/*",
	  "sudo git clone https://github.com/dhairya2019/test1.git /var/www/html/"
    ]
  }
 

}

 
resource "aws_s3_bucket" "_500069956" {

depends_on =[
aws_instance.myin,
]
  bucket = "mybestbucket77"
  acl    = "public-read"
  
   provisioner "local-exec" {
        command     = "mkdir hello"
	
    }
	
  provisioner "local-exec" {
        command     = "git clone https://github.com/dhairya2019/bucket hello"
	
    }
	
	provisioner "local-exec"{
	
	when = destroy
	command     =   "echo Y | rmdir /s hello"
	}
	
	
	 tags = {
    Name = "your_bucket_500069956"
  }
	}

	
  resource "aws_s3_bucket_object" "upload" {
  depends_on =[
aws_s3_bucket._500069956,
]
  bucket = aws_s3_bucket._500069956.id
  key    = "1.png"
  source = "hello/1.png"
  content_type ="image/png"
  acl="public-read"
}


locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {

depends_on =[
aws_s3_bucket_object.upload,
]
  comment = "Some comment"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
depends_on =[
aws_cloudfront_origin_access_identity.origin_access_identity,
]
  origin {
    domain_name = aws_s3_bucket._500069956.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

  
	s3_origin_config {
  origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
}
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "1.png"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

 

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  connection {
    type     = "ssh"
    user     = "ec2-user"
     private_key = file("C:/Users/dhair/Downloads/test.pem")
	 port=22
    host     = aws_instance.myin.public_ip
  }
  
  provisioner "remote-exec" {
        inline  = [
		# "sudo su << \"EOF\" \n echo \"<img src='${self.domain_name}'>\" >> /var/www/html/index.html \n \"EOF\""
 "sudo su << EOF",
            "echo \"<img src='http://${self.domain_name}/${aws_s3_bucket_object.upload.key}'>\" >> /var/www/html/index.html",
            "EOF"
			]
			}

  
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket._500069956.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket._500069956.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "_500069956" {
  bucket = "${aws_s3_bucket._500069956.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}


output "description_ec2" {
value = aws_instance.myin
}

resource "null_resource" "local_execute" {
depends_on = [
    aws_cloudfront_distribution.s3_distribution,
  ]


provisioner "local-exec" {
   command = "start chrome ${aws_instance.myin.public_ip}"
  }


}
