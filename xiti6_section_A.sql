#section-A

#练习一: 各部门工资最高的员工（难度：中等）
#要求1：创建Employee 表，包含所有员工信息，每个员工有其对应的 Id, salary 和 department Id。
create table employee(
	employee_id  char(4) not null,
    employee_name varchar(100) not null,
    salary integer not null,
    department_id char(4) not null,
    primary key(Employee_id)
);
insert into employee values('1','Joe','70000','1');
insert into employee values('2','Henry','80000','2');
insert into employee values('3','Sam','60000','2');
insert into employee values('4','Max','90000','1');
/*
 输出结果为：
1	Joe	70000	1
2	Henry	80000	2
3	Sam	60000	2
4	Max	90000	1
 */

#要求2，创建Department 表，包含公司所有部门的信息。
create table department(
	department_id char(4) not null,
		department_name varchar(100) not null,
        primary key(department_id)
);

insert into department values('1','IT');
insert into department values('2','Sales');
/*
 输出结果为：
1	IT
2	Sales
 */

#要求3，编写一个 SQL 查询，找出每个部门工资最高的员工。
#例如，根据上述给定的表格，Max 在 IT 部门有最高工资，Henry 在 Sales 部门有最高工资。
select d.department_name,employee_name,max_salary 
	from  employee
join department d on employee.department_id = d.department_id
join (select department_id,max(salary) as max_salary
		from employee
        group by department_id)temp
        on temp.department_id = d.department_id
        where employee.salary = max_salary
        order by
        max_salary desc;
/*
 输出结果为：
IT	Max	90000
Sales	Henry	80000
 */
       
       
#练习二: 换座位（难度：中等）
#小美是一所中学的信息科技老师，她有一张 seat 座位表，平时用来储存学生名字和与他们相对应的座位 id。
#其中纵列的id是连续递增的
#小美想改变相邻俩学生的座位。
#你能不能帮她写一个 SQL query 来输出小美想要的结果呢？
#请创建如下所示seat表：
#注意： 如果学生人数是奇数，则不需要改变最后一个同学的座位。

#首先创建seat表
create table seat(id int(11) not null,
					student varchar(100) not null,
					primary key(id));
insert into seat(id,student) values('1','Abbot');
insert into seat(id,student) values('2','Doris');
insert into seat(id,student) values('3','Emerson');
insert into seat(id,student) values('4','Green');
insert into seat(id,student) values('5','Jeames');
/*
则换座位之前的表为：
1	Abbot
2	Doris
3	Emerson
4	Green
5	Jeames
 */
SELECT
    (CASE
        WHEN MOD(id, 2) != 0 AND counts != id THEN id + 1
        WHEN MOD(id, 2) != 0 AND counts = id THEN id
        ELSE id - 1                                        
    END) AS id,
    student
FROM
    seat,
    (SELECT
        COUNT(*) AS counts
    FROM
        seat) AS seat_counts
ORDER BY id ASC;
/*
则换座位之后的表输出为：
1	Doris
2	Abbot
3	Green
4	Emerson
5	Jeames
 */

#练习三: 分数排名（难度：中等）
#假设在某次期末考试中，二年级四个班的平均成绩分别是 93、93、93、91，
#请问可以实现几种排名结果？分别使用了什么函数？排序结果是怎样的？（只考虑降序）

#首先创建表
DROP TABLE IF EXISTS grade;
CREATE TABLE grade
(class CHAR(1) NOT NULL,
score_avg CHAR(2) NOT NULL,
PRIMARY KEY(class)); 
INSERT INTO grade VALUES (1,93);
INSERT INTO grade VALUES (2,93);
INSERT INTO grade VALUES (3,93);
INSERT INTO grade VALUES (4,91);
/*
则现在的平均成绩表为：
1	93
2	93
3	93
4	91
 */
#第一种，使用ROW_NUMBER()进行排序：ROW_NUMBER()排序的序号是连续不重复的，即使表中存在多个一样的数值仍然按顺序依次编号。
SELECT score_avg, 
	   ROW_NUMBER() OVER(ORDER BY score_avg DESC) AS 'rank'
  FROM grade;
/*
输出如下，可见rank是不重复的
93	1
93	2
93	3
91	4
 */
 #第二种，使用rank()进行排序：rank()在排序时，会把多个数值相同的归为一组，以同样的序号进行编号。但是编号不连续，会按照实际次序编辑下一组序号。
SELECT score_avg, 
	   rank() OVER(ORDER BY score_avg DESC) AS 'rank'
  FROM grade;
/*
输出如下，可见rank=1有三个，但是不会存在连续的rank=2或者3
93	1
93	1
93	1
91	4
 */
#第三种，使用dense_rank()进行排序：dense_rank()在排序时，会把多个数值相同的归为一组，以同样的序号进行编号。但是他编号是连续的。
SELECT score_avg, 
	   dense_rank() OVER(ORDER BY score_avg DESC) AS 'rank'
  FROM grade;
/*
输出如下，可见rank=1有三个，但是rank是连续的
93	1
93	1
93	1
91	2
 */
#第四种，使用ntile()进行排序：ntile(num)会讲所有的记录分成num个组，每个组序号一样。但是编号连续。
SELECT score_avg, 
	   ntile(2) OVER(ORDER BY score_avg DESC) AS 'rank'   #还可以试试ntile=3等等
  FROM grade;
/*
输出如下，但是感觉不是很合理
93	1
93	1
93	2
91	2
 */
 
 
#练习四：连续出现的数字（难度：中等）
#编写一个 SQL 查询，查找所有至少连续出现三次的数字。
create table Logs(id int not null,
					num int not null,
				primary key(id)
);
insert into Logs(id,num) values('1','1');
insert into Logs(id,num) values('2','1');
insert into Logs(id,num) values('3','1');
insert into Logs(id,num) values('4','2');
insert into Logs(id,num) values('5','1');
insert into Logs(id,num) values('6','2');
insert into Logs(id,num) values('7','2');
/*
上面完成了logs表的创建
1	1
2	1
3	1
4	2
5	1
6	2
7	2
 */
select distinct A.num ConsecutiveNums from logs as a 
	inner join logs as B on A.id+1 = B.id and A.num=B.num
    inner join logs as C on B.id+1 = C.id and B.num=C.num;
#给定上面的 Logs 表， 1 是唯一连续出现至少三次的数字。输出的就是1
   

#练习五：树节点 （难度：中等）
#对于tree表，id是树节点的标识，p_id是其父节点的id。
create table tree(id char(1),
					p_id integer,
                    primary key(id));
insert into tree values('1',null);
insert into tree values('2',1);
insert into tree values('3',1);
insert into tree values('4',2);
insert into tree values('5',2);
commit;
/*
上面完成了tree表的创建
1	     #这儿是null
2	1
3	1
4	2
5	2
 */
SELECT id, 
   CASE WHEN p_id IS NULL THEN 'Root'
       WHEN id in (SELECT p_id FROM tree) THEN 'Inner'
       ELSE 'Leaf' END
   AS TYPE
FROM tree
ORDER BY id
/*
输出的结果是：
1	Root
2	Inner
3	Leaf
4	Leaf
5	Leaf
 */

#练习六：至少有五名直接下属的经理 （难度：中等）
#Employee表包含所有员工及其上级的信息。每位员工都有一个Id，并且还有一个对应主管的Id（ManagerId）。
#因为练习1中已经创建了employee，需要删除重新创建

drop table employee
create table employee (Id int primary key,
							Name varchar(255),
                            Department varchar(255),
                            Managerid varchar(255));
insert into employee values('101','John','A','null');
insert into employee values('102','Dan','A','101');
insert into employee values('103','James','A','101');
insert into employee values('104','Amy','A','101');
insert into employee values('105','Anne','A','101');
insert into employee values('106','Ron','B','101');
/*
创建完成的employee表如下：
101	John	A	null
102	Dan	A	101
103	James	A	101
104	Amy	A	101
105	Anne	A	101
106	Ron	B	101
 */
#针对Employee表，写一条SQL语句找出有5个下属的主管。
select name
	from (select ManagerId,count(ID) as n
					from employee
                    group by ManagerId) m, employee e
	where m.ManagerId = e.Id and n >=5;
#输出的就是John


#练习七：查询回答率最高的问题 （难度：中等）
#求出survey_log表中回答率最高的问题，表格的字段有：uid, action, question_id, answer_id, q_num, timestamp。
#uid是用户id；action的值为：“show”， “answer”， “skip”；当action是"answer"时，answer_id不为空，相反，当action是"show"和"skip"时为空（null）；q_num是问题的数字序号。
#写一条sql语句找出回答率（show 出现次数 / answer 出现次数）最高的 question_id。
#这是不是问题描述错了，应该是answer的出现次数/show的出现次数吧？

DROP TABLE IF EXISTS survey_log;
CREATE TABLE survey_log
(uid CHAR(1) NOT NULL,
action VARCHAR(6),
question_id CHAR(3) NOT NULL,
answer_id VARCHAR(12),
q_num CHAR(1) NOT NULL,
timestamp CHAR(3)); 
INSERT INTO survey_log VALUES (5,'SHOW',285,NULL,1,123);
INSERT INTO survey_log VALUES (5,'ANSWER',285,'124124',1,124);
INSERT INTO survey_log VALUES (5,'SHOW',369,NULL,2,125);
INSERT INTO survey_log VALUES (5,'SKIP',369,NULL,2,126);
/*
创建完成的survey_log表如下：
5	SHOW	285		1	123
5	ANSWER	285	124124	1	124
5	SHOW	369		2	125
5	SKIP	369		2	126
 */
SELECT 
    question_id 
FROM
    survey_log
GROUP BY question_id
ORDER BY COUNT(answer_id) / COUNT(IF(action = 'show', 1, 0)) DESC
LIMIT 1;
#输出的question_id为285

#练习八：各部门前3高工资的员工（难度：中等）
将练习一中的 employee 表清空，
#重新插入以下数据（也可以复制练习一中的 employee 表，再插入第5、第6行数据）：
#算了，给每个题目的exercise都加上exercise名字把
create table employee_exercise8
(Id CHAR(1) NOT NULL,
Name VARCHAR(5) NOT NULL,
Salary CHAR(5),
DepartmentId CHAR(1) NOT NULL,
PRIMARY KEY (Id)
); 
insert into employee_exercise8 values(1,'Joe',70000,1);
insert into employee_exercise8 values(2,'Henry',80000,2);
insert into employee_exercise8 values(3,'Sam',60000,2);
insert into employee_exercise8 values(4,'Max',90000,1);
insert into employee_exercise8 values(5,'Janet',69000,1);
insert into employee_exercise8 values(6,'Randy',85000,1);
/*
创建完成的employee_exercise8表如下：
1	Joe	70000	1
2	Henry	80000	2
3	Sam	60000	2
4	Max	90000	1
5	Janet	69000	1
6	Randy	85000	1
*/
SELECT department_name, Name, Salary
FROM department
JOIN(
   SELECT Name,
          DepartmentId,
          Salary,
          DENSE_RANK() over (PARTITION BY DepartmentId
              ORDER BY Salary DESC) as "rank"
   FROM employee_exercise8) salary_rank
ON department.department_id=salary_rank.DepartmentId
WHERE salary_rank.rank<4;
/*
上方查询，找出每个部门工资前三高的员工。
IT	Max	90000
IT	Randy	85000
IT	Joe	70000
Sales	Henry	80000
Sales	Sam	60000
*/


#练习九：平面上最近距离 (难度: 困难）
#point_2d表包含一个平面内一些点（超过两个）的坐标值（x，y）。
#写一条查询语句求出这些点中的最短距离并保留2位小数。
CREATE TABLE point_2d
(x FLOAT NOT NULL,
y FLOAT not NULL,
PRIMARY KEY(x,y)
); 
INSERT INTO point_2d VALUES (-1,-1);
INSERT INTO point_2d VALUES (0,0);
INSERT INTO point_2d VALUES (-1,-2); 
/*
创建的三个点为：
-1.0	-2.0
-1.0	-1.0
0.0	0.0
*/
SELECT * FROM point_2d;
select p1.x,p1.y,p2.x,p2.y,
			 round(sqrt(power(p1.x-p2.x,2)+power(p1.y-p2.y,2)),2) as shortest
from point_2d as p1,point_2d as p2
where p1.x != p2.x
or   p1.y != p2.y
order by shortest;
/*
从而计算得到的距离矩阵为：
-1.0	-1.0	-1.0	-2.0	1.0   #可见最短距离就是1
-1.0	-2.0	-1.0	-1.0	1.0
0.0	0.0	-1.0	-1.0	1.41
-1.0	-1.0	0.0	0.0	1.41
0.0	0.0	-1.0	-2.0	2.24
-1.0	-2.0	0.0	0.0	2.24
*/


#练习十：行程和用户（难度：困难）
#Trips 表中存所有出租车的行程信息。每段行程有唯一键 Id，Client_Id 和 Driver_Id 是 Users 表中 Users_Id 的外键。
#Status 是枚举类型，枚举成员为 (‘completed’, ‘cancelled_by_driver’, ‘cancelled_by_client’)。

#Users 表存所有用户。每个用户有唯一键 Users_Id。Banned 表示这个用户是否被禁止，
#Role 则是一个表示（‘client’, ‘driver’, ‘partner’）的枚举类型。

#要求为：写一段 SQL 语句查出2013年10月1日至2013年10月3日期间非禁止用户的取消率。基于上表，
#你的 SQL 语句应返回如下结果，取消率（Cancellation Rate）保留两位小数。


#首先创建trips表
CREATE TABLE Trips
(Id INT,
Client_Id INT,
Driver_Id INT,
City_Id INT,
Status VARCHAR(30),
Request_at DATE,
PRIMARY KEY (Id)
); 
INSERT INTO Trips VALUES (1, 1, 10, 1, 'completed', '2013-10-1');
INSERT INTO Trips VALUES (2, 2, 11, 1, 'cancelled_by_driver', '2013-10-1');
INSERT INTO Trips VALUES (3, 3, 12, 6, 'completed', '2013-10-1');
INSERT INTO Trips VALUES (4, 4, 13, 6, 'cancelled_by_client', '2013-10-1');
INSERT INTO Trips VALUES (5, 1, 10, 1, 'completed', '2013-10-2');
INSERT INTO Trips VALUES (6, 2, 11, 6, 'completed', '2013-10-2');
INSERT INTO Trips VALUES (7, 3, 12, 6, 'completed', '2013-10-2');
INSERT INTO Trips VALUES (8, 2, 12, 12, 'completed', '2013-10-3');
INSERT INTO Trips VALUES (9, 3, 10, 12, 'completed', '2013-10-3');
INSERT INTO Trips VALUES (10, 4, 13, 12, 'cancelled_by_driver', '2013-10-3');
#其次创建users表
CREATE TABLE Users 
(Users_Id  INT,
 Banned    VARCHAR(30),
 Role      VARCHAR(30),
PRIMARY KEY (Users_Id)
); 
INSERT INTO Users VALUES (1,    'No',  'client');
INSERT INTO Users VALUES (2,    'Yes', 'client');
INSERT INTO Users VALUES (3,    'No',  'client');
INSERT INTO Users VALUES (4,    'No',  'client');
INSERT INTO Users VALUES (10,   'No',  'driver');
INSERT INTO Users VALUES (11,   'No',  'driver');
INSERT INTO Users VALUES (12,   'No',  'driver');
INSERT INTO Users VALUES (13,   'No',  'driver');
#解题思路为：
#表Trips与表Users进行关联，查询所有非禁止用户的出租车行程信息；通过request_at进行分组；通过count(if())语句，
#分别统计各日期非禁止用户取消订单数和各日期总订单数，并计算比率，保留两位小数。
SELECT
	t.Request_at DAY,
	round( sum( CASE WHEN t.STATUS LIKE 'cancelled%' THEN 1 ELSE 0 END )/ count(*), 2 ) AS 'Cancellation Rate' 
FROM
	Trips t
	INNER JOIN Users u ON u.Users_Id = t.Client_Id 
	AND u.Banned = 'No' 
WHERE
	t.Request_at BETWEEN '2013-10-01' 
	AND '2013-10-03' 
GROUP BY
	t.Request_at;
/*
输出结果为：
2013-10-01	0.33
2013-10-02	0.00
2013-10-03	0.50
*/


