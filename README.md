# terraform
Task Accomplished:<br />
1.Create the key and security group which allow the port 80.<br />
2.Launch EC2 instance.<br />
3.In this Ec2 instance use the key and security group which we have created in step 1.<br />
4.Launch one Volume (EBS) and mount that volume into /var/www/html<br />
5.Developer have uploded the code into github repo also the repo has some images.<br />
6.Copy the github repo code into /var/www/html<br />
7.Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.<br />
8.Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html

To create a same infrastructure like this by your own see my medium blog:
URL:https://medium.com/@dhairya.chugh77/creating-ias-infrastruture-as-code-using-terraform-to-build-an-infrastructure-on-aws-cloud-e1f4b92ad484
