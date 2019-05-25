# Apache Spark on AWS
**Philosophy:** Write your code on your local machine, scale it out in the cloud when you want to use the whole dataset or run 10.000.000 epochs in your Neural Network. The cluster is created, data processed and stored, and the cluster is destroyed. Minimal cost, maximal usage.

What is [Apache Spark?](https://spark.apache.org/)

**Spark** cluster is provisioned using **Hashistack** - **Terraform** and **Consul** - and **Ansible**. The cluster is provisioned on **AWS**, work environment is **Docker** on Windows.

The idea is to automate the Spark cluster provision, clone and run the code from **GitHub** and use data from an external source (for example S3). Once the data processing is done, results are saved to an external storage, the cluster is destroyed.

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
- This project depends on two other GitHub projects and a third one is used as example.
- YAML files are used to feed the Consul server which Terraform scripts read values from.

### VPC on AWS
The GitHub project [Provision VPC on AWS](https://github.com/markokole/iac-aws-vpc) sets up the **Virtual Private Cloud** in AWS. One can first build a **Docker** container on Windows to prepare the development environment and local Consul server where the configuration parameters are stored.
The documentation in that project will help you create the Docker container and prepare the development environment.

### Configuration to Consul
The provisioning of the cluster uses Consul to fetch the parameters for provisioned cluster. *Externalization of parameters is still work in progress*. The [configuration project](https://github.com/markokole/iac-consul-config) holds *yaml* files used for feeding Consul which Terraform scripts use to get parameters from.

The YAML file for the Spark cluster configuration is the [spark.yml](https://github.com/markokole/iac-consul-config/blob/master/spark.yml). The *ami* is a pre-build image with Spark installed to minimize the time at provision. Spark 2.4.0 is used. It is possible to choose instance type for master and workers and number of workers in a cluster.
The GitHub repository has to be defined, with the destination at the client (which is the master). *If you plan to do some demanding work locally (for example with pandas) choose an instance with more resources.*
The arguments taken by the python script are a semi-colon separated script which the user should parse in the code. The execution file must be written with the path where *git_dest* is HOME to the project.

### Data Science examples
This [project](https://github.com/markokole/ds-code-for-ias) holds some **pyspark** and **scala** examples to test the automatization - the provisioning process, once **Spark** cluster is established, the GitHub repository is cloned and the code is run. Input datasets are in S3 and are given as input parameters in the spark submit command.

## Generalization
Even though this repository focuses on Apache Spark, the idea stays the same for any other service either distributed or single server - pay as you go. Instead of short-lived Spark cluster, a [Hadoop cluster can be provisioned](https://github.com/markokole/iac-aws-hadoop), or just an R-server with huge resources to do the job.
