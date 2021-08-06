![Language](https://img.shields.io/badge/language-python--3.8-blue) [![Contributors][contributors-shield]][contributors-url] [![Stargazers][stars-shield]][stars-url] [![Forks][forks-shield]][forks-url] [![Issues][issues-shield]][issues-url] [![MIT License][license-shield]][license-url] [![LinkedIn][linkedin-shield]][linkedin-url]

<br />
<p align="center">
    <a href="https://github.com/najuzilu/DP-Airflow">
        <img src="./images/logo.png" alt="Logo" width="400" height="200">
    </a>
    <h3 align="center">Data Pipelines with Airflow</h3>
</p>

## About the Project

Sparkify has decided that it is time to introduce more automation and monitoring to their data warehouse ETL pipelines and come to the conclusion that the best tool to achieve this is Apache Airflow.

They have decided to bring you into the project and expect you to create high grade data pipelines that are dynamic and built from reusable tasks, can be monitored, and allow easy backfills. They have also noted that the data quality plays a big part when analyses are executed on top the data warehouse and want to run tests against their datasets after the ETL steps have been executed to catch any discrepancies in the datasets.

## Description

You will create your own Airflow custom operators to perform tasks such as staging the data, filling the data warehouse, and running checks on the data as the final step.

The source data resides in S3 and needs to be processed in Sparkify's data warehouse in Amazon Redshift. The source datasets consist of JSON logs that tell about user activity in the application and JSON metadata about the songs the users listen to.

### Tools

* Python 3.8
* AWS
* Apache Airflow

## Datasets

For this project, you'll be working with two datasets. Here are the s3 links for each:

* Log data: `s3://udacity-dend/log_data`
* Song data: `s3://udacity-dend/song_data`

## DAG Configuration

### Operators

You will build four main operators that will stage the data, transform the data, and run checks on data quality. All the operators and tasks instances will run SQL statements against the Redshift database.

* **Stage Operator**: loads any JSON formatted file from S3 to Amazon Redshift. It creates and runs a SQL COPY statement based on the parameters provided.
* **Fact and Dimension Operators**: utilizes the SQL helper class to run data transformations.
* **Data Quality Operator**: is used to run checks on the data itself.

The task dependencies for the DAG are shown in the image below.

![final_DAG](./images/final-dag.png)

## Getting Started

Clone this repository

```bash
git clone https://github.com/najuzilu/DP-Airflow.git
```

### Prerequisites

* Python 3.8
* AWS
* Apache Airflow

## Project Steps

1. Use `dwh_example.cfg` to create and populate a `dwh.cfg` file with the AWS Access Key/ Secret Key fields and workstation IP address.
2. Run `setup_redshift_cluster.sh` and `setup_redshift_conn.sh` to setup the redshift cluster with the appropriate configurations.
3. Copy the last line printed during the execution of the previous step and run on the workstation to set the redshift cluster endpoint.
4. Then, execute `setup_airflow_conn.sh` to create the Airflow connections to AWS and Redshift.
5. Lastly, use Airflow's WebUI to run the pipeline.

Once the project is completed, run `terminate_redshift_cluster.sh` to terminate the Redshift cluster.


## Authors

Yuna Luzi - @najuzilu

## License

Distributed under the MIT License. See `LICENSE` for more information.

<!-- Links --->

[contributors-shield]: https://img.shields.io/github/contributors/najuzilu/DP-Airflow.svg?style=flat-square
[contributors-url]: https://github.com/najuzilu/DP-Airflow/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/najuzilu/DP-Airflow.svg?style=flat-square
[forks-url]: https://github.com/najuzilu/DP-Airflow/network/members
[stars-shield]: https://img.shields.io/github/stars/najuzilu/DP-Airflow.svg?style=flat-square
[stars-url]: https://github.com/najuzilu/DP-Airflow/stargazers
[issues-shield]: https://img.shields.io/github/issues/najuzilu/DP-Airflow.svg?style=flat-square
[issues-url]: https://github.com/najuzilu/DP-Airflow/issues
[license-shield]: https://img.shields.io/badge/License-MIT-yellow.svg
[license-url]: https://github.com/najuzilu/DP-Airflow/blob/master/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/yuna-luzi/
