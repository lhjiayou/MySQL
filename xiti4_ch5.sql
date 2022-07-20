#习题4.1 找出 product 和 product2 中售价高于 500 的商品的基本信息
SELECT  *
  FROM Product 
 WHERE  sale_price > 500
 UNION ALL
SELECT *
  FROM Product2 
 WHERE  sale_price > 500;

/*输出结果为：
0001	T恤	衣服	1000	500	2009-09-20
0003	运动T恤	衣服	4000	2800	
0004	菜刀	厨房用具	3000	2800	2009-09-20
0005	高压锅	厨房用具	6800	5000	2009-01-15
0007	擦菜板	厨房用具	880	790	2008-04-28
0001	T恤	衣服	1000	500	2009-09-20
0003	运动T恤	衣服	4000	2800	
0009	手套	衣服	800	500	
0010	水壶	厨房用具	2000	1700	2009-09-20
 */

#习题4.2借助对称差的实现方式, 求product和product2的交集。
SELECT * FROM 
	(SELECT * FROM product 
		UNION 
	 SELECT * FROM product2) 
	as u
	WHERE product_id 
		NOT IN(SELECT product_id 
			FROM product 
			WHERE product_id 
			NOT IN 
			(SELECT product_id FROM product2)
			UNION
			SELECT product_id 
			FROM product2 
			WHERE product_id 
			NOT IN 
			(SELECT product_id FROM product)
			);
/*输出结果为：
0001	T恤	衣服	1000	500	2009-09-20
0002	打孔器	办公用品	500	320	2009-09-11
0003	运动T恤	衣服	4000	2800	
 */
		
#习题4.3 每类商品中售价最高的商品都在哪些商店有售 ？
SELECT sp.shop_id, sp. shop_name, sp.quantity,
        p.product_id, p. product_name, p. product_type, p. sale_price,
        mp.maxp AS '该类商品的最大售价' 
FROM product AS p 
INNER JOIN shopproduct AS sp 
ON sp.product_id = p.product_id
INNER JOIN (
			SELECT  product_type, MAX( sale_price) AS maxp FROM product 
            GROUP BY  product_type
            ) AS mp
ON mp. product_type = p. product_type AND p. sale_price = mp.maxp;
/*
输出为：
000A	东京	50	0002	打孔器	办公用品	500	500
000A	东京	15	0003	运动T恤	衣服	4000	4000
000B	名古屋	30	0002	打孔器	办公用品	500	500
000B	名古屋	120	0003	运动T恤	衣服	4000	4000
000C	大阪	20	0003	运动T恤	衣服	4000	4000
 */

#习题4.4 分别使用内连结和关联子查询每一类商品中售价最高的商品。
#内连结
SELECT p.product_id, p. product_name, p. product_type, p. sale_price
FROM product AS p 
INNER JOIN(
			SELECT  product_type, MAX( sale_price) AS maxp FROM product 
            GROUP BY  product_type
            ) AS mp
ON mp. product_type = p. product_type AND p. sale_price = mp.maxp;
/*
 输出为：
0002	打孔器	办公用品	500
0003	运动T恤	衣服	4000
0005	高压锅	厨房用具	6800
 */

#关联子查询也是相同的输出结果
SELECT p.product_id, p. product_name, p. product_type, p. sale_price 
FROM product AS p
WHERE  sale_price = (SELECT MAX( sale_price) 
					FROM product AS p1 
					WHERE p. product_type = p1. product_type
					GROUP BY  product_type);


#习题4.5 用关联子查询实现：在 product 表中，取出 product_id, product_name, sale_price, 
#并按照商品的售价从低到高进行排序、对售价进行累计求和。
SELECT p.product_id, p. product_name, p. product_type, p. sale_price,
	(SELECT SUM( sale_price) FROM product AS p1
	WHERE p. sale_price > p1. sale_price
	OR (p. sale_price = p1. sale_price AND p.product_id >= p1.product_id)
	) AS '累计求和'
FROM product AS p 
ORDER BY  sale_price;
/*
 输出为：
0008	圆珠笔	办公用品	100	100
0002	打孔器	办公用品	500	600
0006	叉子	厨房用具	500	1100
0007	擦菜板	厨房用具	880	1980
0001	T恤	衣服	1000	2980
0004	菜刀	厨房用具	3000	5980
0003	运动T恤	衣服	4000	9980
0005	高压锅	厨房用具	6800	16780
 */


