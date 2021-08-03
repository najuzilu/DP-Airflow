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

## DAG Configuration/Structure

![final_DAG](./images/final-dag.png)

## Getting Started

Clone this repository

```bash
git clone https://github.com/najuzilu/DP-Airflow.git
```

### Prerequisites


## Project Steps


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
