use test;
drop table if exists admin;
CREATE TABLE if not exists admin (
                       id INT PRIMARY KEY,
                       username VARCHAR(255),
                       email VARCHAR(255)
);

insert into admin values (1, 'zhangsan', '11111');