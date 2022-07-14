#第一部分的习题

/* 3.1编写一条 SQL 语句，从 product（商品）表中选取出“登记日期（regist_date）在 2009 年 4 月 28 日之后”
的商品，查询结果要包含 product name 和 regist_date 两列。*/

select product_name,regist_date
from product 
where regist_date>='2009-04-28'

/*3.2 请说出对 product 表执行如下 3 条 SELECT 语句时的返回结果。*/
#1,where不能得到任何东西，因为判断null应该是is null
SELECT *
  FROM product
 WHERE purchase_price = NULL;
 
#2，<>null 其实就是 not null 但是没有is呀，无任何的输出
SELECT *
  FROM product
 WHERE purchase_price <> NULL;
 
#3，无任何的输出
SELECT *
  FROM product
 WHERE product_name > NULL;
 
#4， 筛选出叉子和圆珠笔
SELECT *
  FROM product
 WHERE purchase_price is NULL;
 
#5， 无任何的记录
SELECT *
  FROM product
 WHERE purchase_price <> NULL;
 
#6. 筛选出6条记录
SELECT *
  FROM product
 WHERE purchase_price is not NULL;
 
/*3.3 3.2.3 章节中的 SELECT 语句能够从 product 表中取出“销售单价（sale_price）比进货单价（purchase
price）高出 500 日元以上”的商品。请写出两条可以得到相同结果的 SELECT 语句。执行结果如下所示：*/

#这是书中的原始写法
SELECT product_name, sale_price, purchase_price
  FROM product
 WHERE sale_price - purchase_price >= 500; 

#第一种等价写法,用上not
SELECT product_name, sale_price, purchase_price
  FROM product
 WHERE not sale_price - purchase_price < 500; 

#第二种等价写法，用上null不确定，但是其实没有任何意思
SELECT product_name, sale_price, purchase_price
  FROM product
 WHERE (sale_price - purchase_price >= 500) or null; 

/*3.4 请写出一条 SELECT 语句，从 product 表中选取出满足“销售单价打九折之后利润高于 100 日元的办公
用品和厨房用具”条件的记录。查询结果要包括 product_name 列、 product_type 列以及销售单价打九折之后
的利润（别名设定为 profit）。*/
SELECT product_name, product_type, sale_price * 0.9-purchase_price AS "profit"
  FROM product
  where sale_price * 0.9-purchase_price>100
  
  
  
  #3.5 语法错误是，第一select语句出现了groupby指定的聚合键之外的列名，第二是groupby和where的顺序不对
  
  /*3.6 请编写一条 SELECT 语句，求出销售单价（‘sale_price‘ 列）合计值大于进货单价（‘purchase_price‘ 列）
合计值 1.5 倍的商品种类。执行结果如下所示*/
  select product_type,sum(sale_price),sum(purchase_price)
  from product 
  group by product_type
  having sum(sale_price)>1.5*sum(purchase_price)  #因为要对分组进行过滤，所以不是用where，而是用having
  
  
  #3.7 好像就是regist_date的null在前面，然后日期降序
select *
from product
order by -regist_date   #这个不对，为什么，因为三个9月20号的不对,虽然非null是默认的升序，但是null却放在最后了

select *
from product
order by -regist_date, purchase_price
  
  