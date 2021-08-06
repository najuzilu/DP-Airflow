from airflow import DAG
from airflow.operators.subdag_operator import SubDagOperator
from airflow.operators.dummy_operator import DummyOperator
from pipeline_subdag import load_dimension_tables_dag
from operators import (
    StageToRedshiftOperator,
    LoadFactOperator,
    DataQualityOperator,
    CreateTablesOperator,
    DropTablesOperator,
)
from helpers import SqlQueries
import datetime
import os

AWS_KEY = os.environ.get("AWS_KEY")
AWS_SECRET = os.environ.get("AWS_SECRET")
S3_BUCKET = "udacity-dend"

default_args = {
    "owner": "udacity",
    "start_date": datetime.datetime.utcnow(),
    "end_date": datetime.timedelta(day=5),
    "depends_on_past": False,
    "retries": 3,
    "retry_delay": datetime.timedelta(minutes=5),
    "catchup": False,
    "email_on_retry": False,
}

dag_name = "etl_pipeline_with_airflow"
dag = DAG(
    dag_name,
    default_args=default_args,
    description="Load and transform data in Redshift with Airflow",
    max_active_runs=3,
    schedule_interval="@monthly",
)

start_operator = DummyOperator(task_id="Begin_execution", dag=dag)

drop_tables = DropTablesOperator(
    task_id="Drop_tables",
    dag=dag,
    redshift_conn_id="redshift",
)

create_tables = CreateTablesOperator(
    task_id="Create_tables",
    dag=dag,
    redshift_conn_id="redshift",
)

stage_events_to_redshift = StageToRedshiftOperator(
    task_id="Stage_events",
    dag=dag,
    redshift_conn_id="redshift",
    aws_credentials_id="aws_credentials",
    region="us-west-2",
    table="staging_events",
    s3_bucket=S3_BUCKET,
    s3_key="log_data",
    json_file="s3://udacity-dend/log_json_path.json",
)

stage_songs_to_redshift = StageToRedshiftOperator(
    task_id="Stage_songs",
    dag=dag,
    redshift_conn_id="redshift",
    aws_credentials_id="aws_credentials",
    region="us-west-2",
    table="staging_songs",
    s3_bucket=S3_BUCKET,
    s3_key="song_data",
    json_file="auto",
)

load_songplays_table = LoadFactOperator(
    task_id="Load_songplays_fact_table",
    dag=dag,
    redshift_conn_id="redshift",
    query=SqlQueries.songplay_table_insert,
    provide_context=True,
)

load_user_task_id = "Load_user_table"
load_user_table = SubDagOperator(
    subdag=load_dimension_tables_dag(
        parent_dag=dag_name,
        task_id=load_user_task_id,
        redshift_conn_id="redshift",
        aws_credentials_id="aws_credentials",
        table="users",
        query=SqlQueries.user_table_insert,
    ),
    task_id=load_user_task_id,
    dag=dag,
)

load_song_task_id = "Load_song_table"
load_song_table = SubDagOperator(
    subdag=load_dimension_tables_dag(
        parent_dag=dag_name,
        task_id=load_song_task_id,
        redshift_conn_id="redshift",
        aws_credentials_id="aws_credentials",
        table="songs",
        query=SqlQueries.song_table_insert,
    ),
    task_id=load_song_task_id,
    dag=dag,
)

load_artist_task_id = "Load_artist_table"
load_artist_table = SubDagOperator(
    subdag=load_dimension_tables_dag(
        parent_dag=dag_name,
        task_id=load_artist_task_id,
        redshift_conn_id="redshift",
        aws_credentials_id="aws_credentials",
        table="artists",
        query=SqlQueries.artist_table_insert,
    ),
    task_id=load_artist_task_id,
    dag=dag,
)

load_time_task_id = "Load_time_table"
load_time_table = SubDagOperator(
    subdag=load_dimension_tables_dag(
        parent_dag=dag_name,
        task_id=load_time_task_id,
        redshift_conn_id="redshift",
        aws_credentials_id="aws_credentials",
        table="time",
        query=SqlQueries.time_table_insert,
    ),
    task_id=load_time_task_id,
    dag=dag,
)

run_quality_checks = DataQualityOperator(
    task_id="Run_data_quality_checks",
    dag=dag,
    redshift_conn_id="redshift",
    tables=["songplays", "users", "songs", "artists", "time"],
    provide_context=True,
)

end_operator = DummyOperator(task_id="Stop_execution", dag=dag)

start_operator >> drop_tables
drop_tables >> create_tables

create_tables >> [stage_events_to_redshift, stage_songs_to_redshift]
[stage_events_to_redshift, stage_songs_to_redshift] >> load_songplays_table
load_songplays_table >> [
    load_user_table,
    load_song_table,
    load_artist_table,
    load_time_table,
]
[
    load_user_table,
    load_song_table,
    load_artist_table,
    load_time_table,
] >> run_quality_checks
run_quality_checks >> end_operator
