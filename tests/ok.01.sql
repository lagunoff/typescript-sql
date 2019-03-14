delete from users where 1=1;
select a, b, c from d where 1=1;
select a from b;
select c01, c02 from t01 join t02 cross join t03 cross join t03 on 1=1;


WITH
  users as ($fields) => (select $fields from users) => 
  drivers as (select * from drivers)
SELECT (
  users('id', 'name'),
  users('updated_at', 'created_at')
);


WITH
  users AS (SELECT xs FROM users)
  drivers AS c => (SELECT * FROM drivers).filter(IS NOT NULL driver.name)
  one AS (1 + )
SELECT ( users('id', 'name').map(x => ), users('updated_at', 'created_at'), );


WITH
   get_users AS (user_keys) => {
      users: (SELECT user_keys FROM users),
      users: (SELECT user_keys FROM users),
   }
SELECT
  WITH new_record_id AS values => (INSERT INTO users (id, name) VALUES (1, 'Vladislav'))
  SELECT 
    WITH 
  
)


vasya_id <- INSERT INTO users (id, name) VALUES (1, 'Vasya');

vasya_id <- CASE WHEN vasya_id > 0 THEN { tag: 'Failure' }
     WHEN vasya_id < 0 THEN { tag: 'Failure' }
     WHEN vasya_id == 0 THEN { tag: 'Ok' }
     ELSE
END;

DO
  vasya_id <- INSERT INTO users (id, name) VALUES (1, 'Vasya');
END;

{ users: vasya_id };
