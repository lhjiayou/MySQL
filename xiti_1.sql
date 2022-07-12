#ch1的练习题

#习题1.1编写一条 CREATE TABLE 语句，用来创建一个包含表 1-A 中所列各项的表 Addressbook 
#（地址簿），并为 regist_no （注册编号）列设置主键约束
DROP TABLE IF EXISTS `Addressbook`;  #如果已经存在这个table，就先删掉它
create table  Addressbook
(
regist_no    integer        not null,
name         varchar(128)   not null,
address      varchar(256)   not null,
tel_no       char(10),
mail_address char(20),
primary key(regist_no)
);

#习题1.2 
#假设在创建练习 2.1 中的 Addressbook 表时忘记添加如下一列 postal_code （邮政编码）了，请把此列添
#加到 Addressbook 表中。
#列名： postal_code
#数据类型：定长字符串类型（长度为 8）
#约束：不能为 NULL
alter table Addressbook add column postal_code char(8) not null

#习题1.3 删除table
drop table addressbook 

#习题1.4
#需要特别注意的是，删除的表是无法恢复的，只能重新插入，请执行删除操作时无比要谨慎。