/*3.1 创建出满足下述三个条件的视图（视图名称为 ViewPractice5_1）。
 * 使用 product（商品）表作为参照表，假设表中包含初始状态的 8 行数据。  */
CREATE view  ViewPractice5_1 (product_name , sale_price , regist_date)
as
select product_name , sale_price , regist_date
from product
where sale_price >=1000 and regist_date='2009-09-20';
#检验
SELECT * FROM ViewPractice5_1;

/* 3.2向习题一中创建的视图 
ViewPractice5_1 中插入如下数据，会得到什么样的结果？为什么？*/
INSERT INTO ViewPractice5_1 VALUES (' 刀子 ', 300, '2009-11-02');
#会报错，因为向视图插入数据时,同时也在向原表插入数据,而原表中有6列,
#其中3列不允许为空,插入的数据中not null列的数据为空,所以无法插入

/*3.3 请根据如下结果编写 SELECT 语句，其中 sale_price_avg 列为全部商品的平均销售单价。 */
select   product_id,product_name,product_type,sale_price,(SELECT AVG( sale_price) FROM product) as sale_price_avg
from product


/*3.4 请根据习题一中的条件编写一条 SQL 语句，创建一幅包含如下数据的视图（名称为AvgPriceByType）。*/
CREATE VIEW AvgPriceByType(product_id, product_name, product_type, sale_price,sale_price_avg)
 AS
 SELECT product_id, product_name, product_type, sale_price,
 (SELECT AVG( sale_price)FROM product AS p2
   WHERE p1. product_type = p2. product_type
   GROUP BY  product_type) AS sale_price_avg
  FROM product AS p1;
  SELECT * FROM AvgPriceByType;
 
 /*3.5 四则运算中含有 NULL 时（不进行特殊处理的情况下），运算结果是否必然会变为NULL ？*/
 #答：否，例如 is null
 
 
 /*3.6 对本章中使用的 product（商品）表执行如下 2 条 SELECT 语句，能够得到什么样的结果呢？ */
 SELECT product_name, purchase_price
  FROM product
 WHERE purchase_price NOT IN (500, 2800, 5000);
#作用是选出了purchase_price不为500，2800，500的产品名称purchase_price；

SELECT product_name, purchase_price
 FROM product
WHERE purchase_price NOT IN (500, 2800, 5000, NULL);
#结果为空，原因是null不能参与比较运算符，即与任何数据比较结果都为null

/*3.7 按照销售单价( sale_price )对练习 3.6 中的 product（商品）表中的商品进行如下分类*/
SELECT SUM(CASE WHEN ( product_name not in ('菜刀','运动T恤','高压锅')) AND ( sale_price<=1000) THEN 1 ELSE 0 END) AS low_price,
        SUM(CASE WHEN ( product_name in('菜刀')) AND (1001<= sale_price<=3000) THEN 1 ELSE 0 END) AS mid_price,
        SUM(CASE WHEN ( product_name in ('运动T恤','高压锅')) AND ( sale_price>=3001) THEN 1 ELSE 0 END) AS high_price
  FROM product;



