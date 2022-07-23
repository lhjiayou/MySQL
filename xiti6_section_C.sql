#练习一：行转列
create table row_to_col
(cdate DATE,
 result varchar(32) not null); 
insert into row_to_col values(20210101,'胜');
insert into row_to_col values(20210101,'胜');
insert into row_to_col values(20210101,'负');
insert into row_to_col values(20210103,'胜');
insert into row_to_col values(20210103,'负');
insert into row_to_col values(20210103,'负');
/*
创建的表为：
2021-01-01	胜
2021-01-01	胜
2021-01-01	负
2021-01-03	胜
2021-01-03	负
2021-01-03	负
 */
#解题思路：根据cdate对查询结果进行分组，通过count、if语句统计各天’胜’、'负’场次
SELECT * FROM row_to_col;
select cdate as '比赛日期',
	   count(if(result='胜',true,null)) as '胜',
	   count(if(result='负',true,null)) as '负'
from row_to_col
group by cdate;
/*
输出结果为：
2021-01-01	2	1
2021-01-03	1	2
 */


#练习二：列转行
create table col_to_row
(比赛日期 date,
 胜 integer(4) not null,
 负 integer(4) not null,
 primary key(比赛日期)); 
insert into col_to_row values(20210101,2,1);
insert into col_to_row values(20210103,1,2);
/*
创建的表为：
2021-01-01	2	1
2021-01-03	1	2
 */

SELECT * FROM col_to_row;
SELECT cdate,result FROM( 
SELECT * FROM
(SELECT 比赛日期 AS cdate, '胜' AS result, 胜 AS times
FROM col_to_row
UNION
SELECT 比赛日期 AS cdate, '负' AS result, 负 AS times
FROM col_to_row
)a
 
UNION
 
SELECT * FROM
(SELECT 比赛日期 AS cdate, '胜' AS result, 胜-1 AS times
FROM col_to_row
UNION
SELECT 比赛日期 AS cdate, '负' AS result, 负-1 AS times
FROM col_to_row
)b)c
WHERE times>0
ORDER BY cdate;
/*
输出结果为：
2021-01-01	胜
2021-01-01	负
2021-01-01	胜
2021-01-03	胜
2021-01-03	负
2021-01-03	负
 */

#练习三：连续登录
#有用户表行为记录表t_act_records表，包含两个字段：uid（用户ID），imp_date（日期）
#计算2021年每个月，每个用户连续登录的最多天数
#计算2021年每个月，连续2天都有登录的用户名单
#计算2021年每个月，连续5天都有登录的用户数
#首先创建表
DROP TABLE if EXISTS t_act_records;
CREATE TABLE t_act_records
(uid  VARCHAR(20),
imp_date DATE);
INSERT INTO t_act_records VALUES('u1001', 20210101);
INSERT INTO t_act_records VALUES('u1002', 20210101);
INSERT INTO t_act_records VALUES('u1003', 20210101);
INSERT INTO t_act_records VALUES('u1003', 20210102);
INSERT INTO t_act_records VALUES('u1004', 20210101);
INSERT INTO t_act_records VALUES('u1004', 20210102);
INSERT INTO t_act_records VALUES('u1004', 20210103);
INSERT INTO t_act_records VALUES('u1004', 20210104);
INSERT INTO t_act_records VALUES('u1004', 20210105);
/*创建的表为：
u1001	2021-01-01
u1002	2021-01-01
u1003	2021-01-01
u1003	2021-01-02
u1004	2021-01-01
u1004	2021-01-02
u1004	2021-01-03
u1004	2021-01-04
u1004	2021-01-05
*/
#第一个问题：计算2021年每个月，每个用户连续登录的最多天数，根据上面的表来看，应该是1 1 2 5
SELECT * FROM t_act_records;
select distinct uid,max(maxday) over(partition by uid) as consecutive_maxday
from(select uid,count(*) as maxday
    from (select *,date-cum as result from (select *,row_number() over(PARTITION by uid order by date) as cum 
                 from (select DISTINCT imp_date as date,uid 
                              from t_act_records)a)b)c 
GROUP BY uid,result)d;
/*输出结果为：
u1001	1
u1002	1
u1003	2
u1004	5
*/
#第二个问题：计算2021年每个月，连续2天都有登录的用户名单，根据上面的表来看，应该是u1003和u1004
SELECT * FROM t_act_records;
select * from
(select distinct uid,max(maxday) over(partition by uid) as consecutive_maxday
from(select uid,count(*) as maxday
    from (select *,date-cum as result from (select *,row_number() over(PARTITION by uid order by date) as cum 
                 from (select DISTINCT imp_date as date,uid 
                              from t_act_records)a)b)c 
GROUP BY uid,result)d)e
where consecutive_maxday>=2;
/*输出结果为：
u1003	2
u1004	5
*/
#第三个问题，计算2021年每个月，连续5天都有登录的用户数，根据上面的表来看，只有u1004一个人
SELECT * FROM t_act_records;
select count(*) as user_num from
(select distinct uid,max(maxday) over(partition by uid) as consecutive_maxday
from(select uid,count(*) as maxday
    from (select *,date-cum as result from (select *,row_number() over(PARTITION by uid order by date) as cum 
                 from (select DISTINCT imp_date as date,uid 
                              from t_act_records)a)b)c 
GROUP BY uid,result)d)e
where consecutive_maxday>=5;
/*输出结果为：1，符合上面的预期
*/

#练习四：用户购买商品推荐
#假设现在需要根据算法给每个 user_id 推荐购买商品，推荐算法比较简单，推荐和他相似的用户购买过的 product 即可，说明如下：
#排除用户自己购买过的商品
#相似用户定义：曾经购买过 2 种或 2 种以上的相同的商品

#先创建表orders
DROP TABLE if EXISTS orders;
CREATE TABLE orders
(user_id  VARCHAR(20),
product_id VARCHAR(20));
INSERT INTO orders VALUES('123', '1');
INSERT INTO orders VALUES('123', '2');
INSERT INTO orders VALUES('123', '3');
INSERT INTO orders VALUES('456', '1');
INSERT INTO orders VALUES('456', '2');
INSERT INTO orders VALUES('456', '4');
/*创建的表结果为：
123	1
123	2
123	3
456	1
456	2
456	4
*/
#第一步：先找出相似的用户，也就是购买相同的商品>=2的用户。用到了自连接，
#找到不同用户对应相同商品的记录。再通过COUNT计算每个用户有多少条这样的记录。
SELECT a.user_id as uid_a,b.user_id as uid_b,
COUNT(DISTINCT b.product_id) as same_pro
FROM orders AS a
JOIN orders AS b
ON a.user_id != b.user_id 
AND a.product_id = b.product_id
GROUP BY uid_a,uid_b
HAVING same_pro>=2
/*输出：
123	456	2
456	123	2
*/
#第二步：将第一步得到的结果集，再通过uid_a连接orders表，
#连接条件是x.uid_a = y.user_id，这一步是为了得到product_id这一列。
SELECT x.uid_a,x.uid_b,y.product_id
FROM(
    SELECT a.user_id AS uid_a,b.user_id AS uid_b,
    COUNT(DISTINCT b.product_id) AS same_pro
    FROM orders AS a
    JOIN orders AS b
    ON a.user_id != b.user_id
    AND a.product_id = b.product_id
    GROUP BY uid_a,uid_b
    HAVING same_pro>=2
) AS x
JOIN orders AS y
ON x.uid_a = y.user_id
/*输出：
123	456	1
123	456	2
123	456	3
456	123	1
456	123	2
456	123	4
*/
#第三步：将第二步得到的结果集，再通过uid_b左连接orders表，
#连接条件是x.uid_b = z.user_id，y.product_id = z.product_id。
SELECT x.uid_a,x.uid_b,y.product_id,z.product_id
FROM(
    SELECT a.user_id AS uid_a,b.user_id AS uid_b,
    COUNT(DISTINCT b.product_id) AS same_pro
    FROM orders AS a
    JOIN orders AS b
    ON a.user_id != b.user_id
    AND a.product_id = b.product_id
    GROUP BY uid_a,uid_b
    HAVING same_pro>=2
) AS x
JOIN orders AS y
ON x.uid_a = y.user_id
LEFT JOIN orders AS z
ON x.uid_b = z.user_id
AND y.product_id = z.product_id
/*输出：
123	456	1	1
123	456	2	2
123	456	3	null
456	123	1	1
456	123	2	2
456	123	4	null
*/
#第四步：根据第三步获得的结果集，判断第四列z.product_id为null，
#并且显示第二列x.uid_b和第三列y.product_id
SELECT x.uid_b AS user_id,y.product_id
FROM(
    SELECT a.user_id AS uid_a,b.user_id AS uid_b,
    COUNT(DISTINCT b.product_id) AS same_pro
    FROM orders AS a
    JOIN orders AS b
    ON a.user_id != b.user_id
    AND a.product_id = b.product_id
    GROUP BY uid_a,uid_b
    HAVING same_pro>=2
) AS x
JOIN orders AS y
ON x.uid_a = y.user_id
LEFT JOIN orders AS z
ON x.uid_b = z.user_id
AND y.product_id = z.product_id
WHERE z.product_id IS NULL;
/*输出最终的结果：
123	4
456	3
*/

#练习五：hive 数据倾斜的产生原因及优化策略？
/*产生原因包括：
1）key分布不均匀
2）业务数据本身的特性
3）建表考虑不周全
4）某些HQL语句本身就存在数据倾斜
优化策略参考：https://www.cnblogs.com/suixingc/p/hive-de-shu-ju-qing-xie.html
*/


#练习六：LEFT JOIN 是否可能会出现多出的行？为什么？
#假设 t1 表有6行（关联列 name 有2行为空），t2 表有6行（关联列 name 有3行为空）,
#那么 SELECT * FROM t1 LEFT JOIN t2 on t1.name = t2.name 会返回多少行结果？

#首先创建两个表
drop table if exists t1;
CREATE TABLE t1
(id VARCHAR(8) NOT NULL,
 name VARCHAR(8) ,
 score INTEGER);
INSERT INTO t1 VALUES('1', 'aaa', 90);
INSERT INTO t1 VALUES('2', 'bbb', 80);
INSERT INTO t1 VALUES('3', 'ccc', 70);
INSERT INTO t1 VALUES('4', 'ddd', 60);
INSERT INTO t1 VALUES('5', '', 90);
INSERT INTO t1 VALUES('6', '', 100);

drop table if exists t2;
CREATE TABLE t2 
(id VARCHAR(8) NOT NULL,
 name VARCHAR(8) ,
 city VARCHAR(16));
INSERT INTO t2 VALUES('1', 'aaa', 'beijing');
INSERT INTO t2 VALUES('2', 'bbb', 'tianjin');
INSERT INTO t2 VALUES('3', 'ccc', 'chengdu');
INSERT INTO t2 VALUES('4', '', 'shenzhen');
INSERT INTO t2 VALUES('5', '', 'qingdao');
INSERT INTO t2 VALUES('6', '', 'guangzhou');

#执行LEFT JOIN语句
SELECT * FROM t1 LEFT JOIN t2 on t1.name = t2.name
/*输出结果为：
1	aaa	90	1	aaa	beijing
2	bbb	80	2	bbb	tianjin
3	ccc	70	3	ccc	chengdu
4	ddd	60			
5		90	4		shenzhen
5		90	5		qingdao
5		90	6		guangzhou
6		100	4		shenzhen
6		100	5		qingdao
6		100	6		guangzhou

解答：
左表关联列为NULL的行会与右表关联列为NULL的行去关联，
条件就是NULL= NULL，所以由NULL产生的行数是左表NULL的行数m 乘以右表NULL的行数n
总行数= 左表的非空行数+ m * n
*/


