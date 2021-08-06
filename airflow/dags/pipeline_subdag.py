from airflow import DAG


def load_dimension_tables_dag(
    parent_dag,
    task_id,
    redshift_conn_id,
    aws_credentials_id,
    table,
    query,
    *args,
    **kwargs,
):

    dag = DAG(
        f"{parent_dag}.{task_id}",
        **kwargs,
    )

    # load task
    load_dimension_tables_dag

    return dag
