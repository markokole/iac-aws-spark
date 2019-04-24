# Apache Spark on AWS
**Philosophy:** Write your code on your local machine, scale it out in the cloud when you want to use the whole dataset or run 10.000.000 epochs in your Neural Network. The cluster is created, data processed and stored, and the cluster is destroyed. Minimal cost, maximal usage.

What is [Apache Spark?](https://spark.apache.org/)

**Spark** cluster is provisioned using **Hashistack** - **Terraform** and **Consul** - and **Ansible**. The cluster is provisioned on **AWS**, work environment is **Docker** on Windows.

The idea is to automate the Spark cluster provision, clone and run the code from **GitHub** and use data from an external source (for example S3). Once the data processing is done, results are saved to an external storage, the cluster is destroyed.

![alt text](https://github.com/markokole/spark-on-aws/blob/master/docs/iac.JPG "Infrastructure as Code")

1. The **Virtual Private Cloud** is provisioned using **Terraform**. VPC's parameters are stored in Consul. This is a long live provision and serves multiple cluster provisions
2. Data is loaded into S3. This is optional, depending on the data storage solution. Hadoop/Hive on top of S3 is also an option.
3. Code to be run in Spark is put in a repository in GitHub.
4. Cluster provisioning creates the cluster, clones the repository, runs the code which points to the data storage (S3 bucket for example)
5. Data is processed and results are saved to an external storage (S3)
6. The cluster is destroyed after the processing is done


## Dependencies
- AWS credentials are needed. This is described in the [VPC on AWS](#VPC on AWS) section.
- This project depends on two other GitHub projects and a third one is used as example.
- YAML files are used to feed the Consul server which Terraform scripts read values from.

### VPC on AWS
The GitHub project [Provision VPC on AWS](https://github.com/markokole/aws-with-terraform) sets up the **Virtual Private Cloud** in AWS. One can first build a **Docker** container on Windows to prepare the development environment and local Consul server where the configuration parameters are stored.
The documentation in that project will help you create the Docker container and prepare the development environment.

### Configuration to Consul
The provisioning of the cluster uses Consul to fetch the parameters for provisioned cluster. *Externalization of parameters is still work in progress*. The [configuration project](https://github.com/markokole/aws-terraform-hdp-config) holds *yaml* files used for feeding Consul which Terraform scripts use to get parameters from.

### Data Science examples
This [project](https://github.com/markokole/ds-code-for-ias) holds some **pyspark** examples to show the automatization - the provisioning process, once **Spark** cluster is established, clones the GitHub repository and runs the code. Input datasets are in S3 and are given as input parameters to the **pyspark** script.

## Generalization
Even though this repository focuses on Apache Spark, the idea stays the same for any other service or cluster that needs to be automized. Instead of short-lived Spark cluster, a [Hadoop cluster can be provisioned](https://github.com/markokole/hdp-on-aws), or just an R-server with huge resources to do the job.
