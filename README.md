# Apache Spark on AWS

**Philosophy:** Write your code on your local machine, scale it out in the cloud when you want to either use the whole dataset or run 10.000.000 epochs in your Neural Network.
The cluster is provisioned, data processed and stored to an external storage, and the cluster is destroyed. Minimal cost, maximal usage. Everything is automated.

What is [Apache Spark?](https://spark.apache.org/)

**Spark** cluster is provisioned using **Hashistack** - **Terraform** and **Consul** - and **Ansible**. The cluster is provisioned on **AWS**, work environment is **Docker** on Windows.

The idea is to automate the Spark cluster provision, clone the code from **GitHub** and run it on data from an external source (for example S3). Once the data processing is done, results are saved to an external storage and the cluster is destroyed.

![alt text](https://github.com/markokole/iac-aws-spark/blob/master/files/iac.JPG "Infrastructure as Code")

1. The **Virtual Private Cloud** is provisioned using **Terraform**. VPC's parameters are stored in Consul. This is a long live provision and serves multiple cluster provisions.
2. Data is loaded into S3. This is optional, depending on the data storage solution. Hadoop/Hive on top of S3 is also an option. A NoSql is also an option. Data Scientist inside the code handles data connection.
If S3 is used, make sure you have access to the S3 storage. More on this, check out this [post](https://markobigdata.com/2019/09/27/automating-access-from-apache-spark-to-s3-with-ansible/).

3. Code (or JAR application) to be run in Spark is put in a repository in GitHub. More here [Data Science examples](#Data Science examples)
4. Cluster provisioning creates the cluster, clones the repository, runs the code which points to the data storage (S3 bucket for example).
5. Data is processed and results are saved to an external storage (S3).
6. The cluster is destroyed after the processing is done.

## Dependencies

- AWS credentials are needed. This is described in the [VPC on AWS](#VPC on AWS) section.
- This project depends on two other GitHub projects: [Provision VPC on AWS](https://github.com/markokole/iac-aws-vpc) which builds the mandatory VPC. The other project is the Docker for creating the [container for development and testing](https://github.com/markokole/docker-on-wins-hashistack)
- Configuration in [local Consul](#Configuration to Consul)

### VPC on AWS

The GitHub project [Provision VPC on AWS](https://github.com/markokole/iac-aws-vpc) sets up the **Virtual Private Cloud** in AWS. One can first build a **Docker** container on Windows to prepare the development environment and Consul agent where the configuration parameters are stored.
The documentation in that project will help you create the Docker container and prepare the development environment.

### Configuration to Consul

The provisioning of the cluster uses Consul to fetch the parameters for provisioned cluster. *Externalization of parameters is still work in progress*. In the [configuration project](https://github.com/markokole/iac-consul-config) *yaml* files are stored and these files are used to feed the global Consul in AWS. At runtime, Terraform connects to the global Consul with a local Consul agent.

The YAML file for the Spark cluster configuration is the [spark.yml](https://github.com/markokole/iac-consul-config/blob/master/spark.yml).
The GitHub repository with the code has to be entered in the configuration. This code is cloned to the Spark client (which is also the master). *If you plan to do some demanding work locally (for example with pandas) choose an instance with more resources.*

The python script takes no arguments, they all have to be written in the code - they are Data SCientist's responsibility.
The above mentioned spark.yml file has a block with description of all parameters used.

### Data Science examples

This [project](https://github.com/markokole/ds-code-for-ias) holds some **pyspark** and **scala** examples to test the automatization - the provisioning process, once **Spark** cluster is established, the GitHub repository is cloned to the Spark Master and the code is run.

## Generalization

Even though this repository focuses on Apache Spark, the idea stays the same for any other service either distributed or single server - pay as you go. Instead of short-lived Spark cluster, a [Hadoop cluster can be provisioned](https://github.com/markokole/iac-aws-hadoop), or just an R-server with huge resources to do the job.
