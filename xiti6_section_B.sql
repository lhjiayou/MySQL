#Section B


#练习一：行转列
create table student_score
(name varchar(4) not null,
 subject varchar(64) not null,
 score integer(4) not null,
 primary key(name,subject)
 );
insert into student_score values('A','chinese',99);
insert into student_score values('A','math',98);
insert into student_score values('A','english',97);
insert into student_score values('B','chinese',92);
insert into student_score values('B','math',91);
insert into student_score values('B','english',90);
insert into student_score values('C','chinese',88);
insert into student_score values('C','math',87);
insert into student_score values('C','english',86);
/*
创建的表为：
A	chinese	99
A	math	98
A	english	97
B	chinese	92
B	math	91
B	english	90
C	chinese	88
C	math	87
C	english	86
 */

#思路为使用聚合函数sum+case语句，通过group by 语句将表格按学生名称(name)进行分组；
#通过case语句分别查询学生chinese]、math、english三门课程成绩
SELECT * FROM student_score;
select name, 
			 sum(case when subject = 'chinese' then score else null end)as chinese,
			 sum(case when subject = 'math' then score else null end)as math,
			 sum(case when subject = 'english' then score else null end)as english
from student_score
group by name;
/*
转换后的结果为：
A	99	98	97
B	92	91	90
C	88	87	86
 */

#练习二：列转行
create table student_score2
(name varchar(4) not null,
 chinese integer(4) not null,
 math integer(4) not null,
 english integer(4) not null,
 primary key(name)); 
insert into student_score2 values('A',99,98,97);
insert into student_score2 values('B',92,91,90);
insert into student_score2 values('C',88,87,86);
/*
创建的表为：
A	99	98	97
B	92	91	90
C	88	87	86
 */

#解题思路：模仿行转列，使用聚合函数加case语句，没有subject，
#故根据课程名称定义列subject，且分别查询chinese、math、english；
#将查询的集合相并，并根据name排序得到列转行
SELECT * FROM student_score2;
select name,
			 'chinese' as subject,
			 chinese as score
from student_score2
group by name
union
select name,
			 'math' as subject,
			 math as score
from student_score2
group by name
union
select name,
			'english' as subject,
			english as score
from student_score2
group by name
order by name;
/*
转换后的结果为：
A	chinese	99
A	math	98
A	english	97
B	chinese	92
B	math	91
B	english	90
C	chinese	88
C	math	87
C	english	86
 */

#练习三：谁是明星带货主播？
#假设，某平台2021年主播带货销售额日统计数据如下：需要创建的表名为 anchor_sales
#定义：如果某主播的某日销售额占比达到该平台当日销售总额的 90% 及以上，则称该主播为明星主播，当天也称为明星主播日。
#问题a. 2021年有多少个明星主播日？
#问题b. 2021年有多少个明星主播？

#首先创建表anchor_sales
create table anchor_sales
(anchor_name varchar(4) not null,
 date integer(32) not null,
 sales integer(64) not null,
 primary key(anchor_name,date)); 
insert into anchor_sales values('A',20210101,40000);
insert into anchor_sales values('B',20210101,80000);
insert into anchor_sales values('A',20210102,10000);
insert into anchor_sales values('C',20210102,90000);
insert into anchor_sales values('A',20210103,7500);
insert into anchor_sales values('C',20210103,80000);
/*
创建的表为：
A	20210101	40000
B	20210101	80000
A	20210102	10000
C	20210102	90000
A	20210103	7500
C	20210103	80000
 */
#解题思路：要统计明星主播和日期，故以日期和主播名进行分组。
#通过sum函数可以计算得到在以日期和主播名分组情况下的sales；
#通过聚合函数sum在窗口函数下的使用，统计平台每天的总销售额；
#上面两步相除，得到每个主播销售总额占该平台当天销售总额百分比sales_rate；
#使用where 选取出满足条件的明星主播和明星主播日

#首先计算平台每天各主播销售额占比，并排序
SELECT * FROM anchor_sales;
select date,anchor_name,
			(sum(sales)/sum(sales) over (partition by date))as sales_rate
from anchor_sales
group by date,anchor_name
order by date,sales_rate desc;
/*
创建的表为：
20210101	B	0.6667
20210101	A	0.3333
20210102	C	0.9000
20210102	A	0.1000
20210103	C	0.9143
20210103	A	0.0857
 */
#然后选取销售额占比超过90%的明星主播和明星主播日，即可解答两个问题
SELECT * FROM anchor_sales;
select *
from(	select date,anchor_name,
			(sum(sales)/sum(sales) over (partition by date))as sales_rate
			from anchor_sales
			group by date,anchor_name
			order by date,sales_rate desc)as p1
where sales_rate >= 0.9;
/*输出结果为：
20210102	C	0.9000
20210103	C	0.9143
可见存在两个明星主播日，一个明星主播
*/

#练习四：MySQL 中如何查看sql语句的执行计划？可以看到哪些信息？
#解答：MySQL 查看执行计划只需要在查询语句前加explain即可

#练习五：解释一下 SQL 数据库中 ACID 是指什么
/*解答：
1、原子性：语句要么都执行，要么都不是执行，是事务最核心的特性，事务本身来说就是以原子性历来定义的，实现主要是基于undo log
2、持久性：保证事务提交之后，不会因为宕机等其他的原因而导致数据的丢失，主要是基于redo log实现
3、隔离性：保证事务与事务之间的执行是相互隔离的，事务的执行不会受到其他事务的影响。InnoDB存储引擎默认的数据库隔离级别是RR，RR又主要是基于锁机制，数据的隐藏列，undo log类以及next-key lock机制
4、一致性：事务追求的最终目标，一致性的实现即需要数据库层面的保障，也需要应用层面的保障。
*/




