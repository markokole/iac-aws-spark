# Apache Spark on AWS

**Philosophy:** Write your code on your local machine, scale it out in the cloud when you want to either use the whole dataset or run 10.000.000 epochs in your Neural Network.
The cluster is provisioned, data processed and stored, and the cluster is destroyed. Minimal cost, maximal usage. Everything is automized.

What is [Apache Spark?](https://spark.apache.org/)

**Spark** cluster is provisioned using **Hashistack** - **Terraform** and **Consul** - and **Ansible**. The cluster is provisioned on **AWS**, work environment is **Docker** on Windows.

The idea is to automate the Spark cluster provision, clone the code from **GitHub**, run it on data from an external source (for example S3). Once the data processing is done, results are saved to an external storage and the cluster is destroyed.

![alt text](https://github.com/markokole/iac-aws-spark/blob/master/files/iac.JPG "Infrastructure as Code")

1. The **Virtual Private Cloud** is provisioned using **Terraform**. VPC's parameters are stored in Consul. This is a long live provision and serves multiple cluster provisions.
2. Data is loaded into S3. This is optional, depending on the data storage solution. Hadoop/Hive on top of S3 is also an option.
If S3 is used, the following lines should be executed in Docker to add keys to Consul:
`consul kv put test/master/aws/access_key <ACCESS_KEY>`
`consul kv put test/master/aws/secret_access_key <SECRET_ACCESS_KEY>`
Keys used are keys that have access to the bucket the application is accessing.
3. Code (or JAR application) to be run in Spark is put in a repository in GitHub. More here [Data Science examples](#Data Science examples)
4. Cluster provisioning creates the cluster, clones the repository, runs the code which points to the data storage (S3 bucket for example).
5. Data is processed and results are saved to an external storage (S3).
6. The cluster is destroyed after the processing is done.

## Dependencies

- AWS credentials are needed. This is described in the [VPC on AWS](#VPC on AWS) section.
- This project depends on two other GitHub projects: [Provision VPC on AWS](https://github.com/markokole/iac-aws-vpc) which builds the mandatory VPC. The other project is the Docker for creating the [container for development and testing](https://github.com/markokole/docker-on-wins-hashistack)
- Configuration in [local Consul](#Configuration to Consul)

### VPC on AWS

The GitHub project [Provision VPC on AWS](https://github.com/markokole/iac-aws-vpc) sets up the **Virtual Private Cloud** in AWS. One can first build a **Docker** container on Windows to prepare the development environment and local Consul server where the configuration parameters are stored.
The documentation in that project will help you create the Docker container and prepare the development environment.

### Configuration to Consul

The provisioning of the cluster uses Consul to fetch the parameters for provisioned cluster. *Externalization of parameters is still work in progress*. In the [configuration project](https://github.com/markokole/iac-consul-config) *yaml* files are stored and these files are used to feed the local Consul in the Docker. At runtime, Terraform connects to the local Consul and populates the variables pointing to Consul.

The YAML file for the Spark cluster configuration is the [spark.yml](https://github.com/markokole/iac-consul-config/blob/master/spark.yml).
The GitHub repository with the code has to be entered in the configuration. This code is cloned to the Spark client (which is also the master). *If you plan to do some demanding work locally (for example with pandas) choose an instance with more resources.*
The arguments taken by the python script are a semi-colon separated script which the user should parse in the code.
The above mentioned spark.yml file has a block with description of all parameters used.

### Data Science examples

This [project](https://github.com/markokole/ds-code-for-ias) holds some **pyspark** and **scala** examples to test the automatization - the provisioning process, once **Spark** cluster is established, the GitHub repository is cloned and the code is run. Input datasets are in S3 and are given as input parameters in the spark submit command.

## Generalization

Even though this repository focuses on Apache Spark, the idea stays the same for any other service either distributed or single server - pay as you go. Instead of short-lived Spark cluster, a [Hadoop cluster can be provisioned](https://github.com/markokole/iac-aws-hadoop), or just an R-server with huge resources to do the job.
