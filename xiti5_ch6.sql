/* 习题5.1 请说出针对本章中使用的 product（商品）表执行如下 SELECT 语句所能得到的结果。*/

SELECT  product_id
       ,product_name
       ,sale_price
       ,MAX(sale_price) OVER (ORDER BY product_id) AS Current_max_price
  FROM product;

 #输出的是  Current_max_price的值返回的是当前product_id和之前商品售价中的最大值，其中product_id按升序排列。
 #具体的编译输出为：
/*0001	T恤	1000	1000
0002	打孔器	500	1000
0003	运动T恤	4000	4000
0004	菜刀	3000	4000
0005	高压锅	6800	6800
0006	叉子	500	6800
0007	擦菜板	880	6800
0008	圆珠笔	100	6800*/
 
/*习题5.2 继续使用product表，计算出按照登记日期（regist_date）升序进行排列的各日期的销售单价（sale_price）的总额。
 排序是需要将登记日期为NULL 的“运动 T 恤”记录排在第 1 位（也就是将其看作比其他日期都早） */
 SELECT  product_id
       , product_name
       , sale_price
       , regist_date
       ,SUM( sale_price) OVER (ORDER BY  regist_date) AS Current_SUM_price
  FROM product;
 /*输出的是
0003	运动T恤	4000		4000
0007	擦菜板	880	2008-04-28	4880
0005	高压锅	6800	2009-01-15	11680
0002	打孔器	500	2009-09-11	12180
0001	T恤	1000	2009-09-20	16680
0004	菜刀	3000	2009-09-20	16680
0006	叉子	500	2009-09-20	16680
0008	圆珠笔	100	2009-11-11	16780 */
 
 /*习题5.3 思考题*/
#第一题：窗口函数不指定PARTITION BY的效果是什么？
#partition by 用来选择要看哪个窗口，类似于分组，不使用partition by是查看全局。
 
#为什么说窗口函数只能在SELECT子句中使用？实际上，在ORDER BY 子句使用系统并不会报错。
##窗口函数是对WHERE或者GROUP BY子句处理后的结果进行操作，所以窗口函数原则上只能写在SELECT子句中。
#ORDER BY子句中能够使用窗口函数的原因（UPDATE的SET子句中也能够使用窗口函数）是因为ORDER BY子句会在SELECT子句之后执行，并且记录也不会减少。

 
 
 /*习题5.4 使用简洁的方法创建20个与 shop.product 表结构相同的表 */
 -- 1.动态创建多张表存储过程：
DELIMITER $$
DROP PROCEDURE IF EXISTS world.p
CREATE DEFINER=`root`@`localhost` PROCEDURE `world`.`p`()
BEGIN
DECLARE i INT;
DECLARE table_name VARCHAR(20);
DECLARE table_pre VARCHAR(20);
DECLARE sql_text VARCHAR(2000);
SET i=1;
SET table_name='';
SET table_pre='table';
SET sql_text='';
WHILE i<21 DO
IF i<10 THEN SET table_name=CONCAT(table_pre,'0',i);
ELSE SET table_name=CONCAT(table_pre,i);
END IF;
SET sql_text=CONCAT('CREATE TABLE ', table_name, '(product_id CHAR(4) NOT NULL,
 product_name VARCHAR(100) NOT NULL,
 product_type VARCHAR(32) NOT NULL,
 sale_price INTEGER ,
 purchase_price INTEGER ,
 regist_date DATE ,
 PRIMARY KEY (product_id))');
SELECT sql_text;
SET @sql_text=sql_text;
PREPARE stmt FROM @sql_text;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
SET i=i+1;
END WHILE;
END$$
DELIMITER ;
-- 2.执行存储过程，创建表
CALL p();