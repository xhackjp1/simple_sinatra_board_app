require 'pg'
require 'dotenv/load'

conn = PG::connect(
  host: ENV['DATABASE_HOST'],
  user: ENV['DATABASE_USER'],
  password: ENV['DATABASE_PASSWORD'],
  dbname: ENV['DATABASE_NAME'],
  port: ENV['DATABASE_PORT']
)
conn.exec("
  drop table board_contents;
  CREATE TABLE board_contents (
    id serial,
    name text,
    comment text,
    commented_at timestamp,
    PRIMARY KEY (id)
  );"
)
