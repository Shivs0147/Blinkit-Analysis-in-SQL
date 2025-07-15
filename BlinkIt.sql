-- use DATABASE
use blinkit
-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- Show all data
select * from blinkit
-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- Update data for Item_Fat_Content of 'LF', 'low fat' -> 'Low Fat' & 'reg' -> 'Regular'
UPDATE Blinkit
SET	Item_Fat_Content = 
CASE 
	WHEN Item_Fat_Content IN ('LF', 'low fat') THEN 'Low Fat'
	WHEN Item_Fat_Content = 'reg' THEN 'Regular'
	ELSE Item_Fat_Content
END

-- Check the update data
select distinct Item_Fat_Content from blinkit

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 1. The overall revenue generated from all items sold.

	--Query
		select 
			Concat (
				cast (
					SUM(Sales)/1000000 
				as decimal (10,2)),
			'M') TotalSalesMillion 
		from blinkit;

	--View
		create view vw_totalsales as
		select 
			Concat (
				cast (
					SUM(Sales)/1000000 
				as decimal (10,2)),
			'M') TotalSalesMillion 
		from blinkit;

	--Result set
		select * from vw_totalsales

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 2. The average revenue per sale.

	--Query
		select 
			round(
				AVG(Sales),
			0) AvgSales
		from blinkit;

	--View
		create view vw_avgsales as 
		select 
			round(
				AVG(Sales),
			0) AvgSales
		from blinkit;
		
	--Result set
		select * from vw_avgsales;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 3. The total count of different items sold.

	--Query
		select 
			Count (*) as No_of_Items 
		from blinkit;

	--View
		create view vw_NOOFITEMS as 
		select 
			Count (*) as No_of_Items 
		from blinkit;
		
	--Result set
		select * from vw_NOOFITEMS;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 4. The average customer rating for items sold.

		select 
			round(
				avg(Rating), 2
			) as AvegRating 
		from blinkit;

	--View
		create view vw_avgrating as 
		select 
			round(
				avg(Rating), 2
			) as AvegRating 
		from blinkit;
		
	--Result set
		select * from vw_avgrating;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 5. Total Sales by Fat Content

		select 
			Item_Fat_Content, 
			concat(round(SUM(Sales)/1000, 2), 'K') as TotalSales
		from 
			blinkit
		group by 
			Item_Fat_Content;
	--View
		create view vw_Sales_FC as 
		select 
			Item_Fat_Content, 
			concat(round(SUM(Sales)/1000, 2), 'K') as TotalSales
		from 
			blinkit
		group by 
			Item_Fat_Content;
		
	--Result set
		select * from vw_Sales_FC;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 6. Total Sales by Item Type:

		select Top 5
			Item_Type,
			round(SUM(Sales), 2) as TotalSales 
		from 
			blinkit
		group by
			Item_Type
		order by 
			TotalSales DESC;
	--View
		create view VW_SALES_IT as 
		select Top 5
			Item_Type,
			round(SUM(Sales), 2) as TotalSales 
		from 
			blinkit
		group by
			Item_Type
		order by 
			TotalSales DESC;
		
	--Result set
		select * from VW_SALES_IT;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 7. Total sales by Item Fat Content and Outlet Location Type
	
		select 
			Item_Fat_Content,
			Outlet_Location_Type, 
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by 
			Item_Fat_Content, 
			Outlet_Location_Type;

	--View
		create view vw_Sales_OLT as 
		select 
			Item_Fat_Content,
			Outlet_Location_Type, 
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by 
			Item_Fat_Content, 
			Outlet_Location_Type;
		
	--Result set
		select * from vw_Sales_OLT;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 8. Fat Content by Outlet for Total Sales:

		select Outlet_Location_Type,
			   Coalesce([Low Fat], 0) as Low_Fat,
			   Coalesce([Regular], 0) as Regular
		from 
		(select 
			Item_Fat_Content,
			Outlet_Location_Type, 
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by 
			Item_Fat_Content, 
			Outlet_Location_Type
		) AS SourceTable
		PIVOT
		(
			Sum(TotalSales)
			FOR Item_Fat_Content IN ([Low Fat], [Regular])
		) AS PivotTable
		Order by Outlet_Location_Type;

	--View
		create view vw_Sales_FCO as 
		select Outlet_Location_Type,
			   Coalesce([Low Fat], 0) as Low_Fat,
			   Coalesce([Regular], 0) as Regular
		from 
		(select 
			Item_Fat_Content,
			Outlet_Location_Type, 
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by 
			Item_Fat_Content, 
			Outlet_Location_Type
		) AS SourceTable
		PIVOT
		(
			Sum(TotalSales)
			FOR Item_Fat_Content IN ([Low Fat], [Regular])
		) AS PivotTable;
		
	--Result set
		select * from vw_Sales_FCO
		Order by Outlet_Location_Type;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 9. Outlet by Fat Content for Total Sales:
		select 
			Item_Fat_Content,
			Coalesce([Tier 1], 0) as Tier_1,
			Coalesce([Tier 2], 0) as Tier_2,
			Coalesce([Tier 3], 0) as Tier_3
		from
		(select 
			Item_Fat_Content,
			Outlet_Location_Type, 
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by 
			Item_Fat_Content, 
			Outlet_Location_Type) as SourceTable
		PIVOT
		(
			Sum(TotalSales)
			For Outlet_Location_Type IN ([Tier 1], [Tier 2], [Tier 3])
		) AS PivotTable
		order by Item_Fat_Content;

	--View
		create view vw_Sales_OFC as 
		select 
			Item_Fat_Content,
			Coalesce([Tier 1], 0) as Tier_1,
			Coalesce([Tier 2], 0) as Tier_2,
			Coalesce([Tier 3], 0) as Tier_3
		from
		(select 
			Item_Fat_Content,
			Outlet_Location_Type, 
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by 
			Item_Fat_Content, 
			Outlet_Location_Type) as SourceTable
		PIVOT
		(
			Sum(TotalSales)
			For Outlet_Location_Type IN ([Tier 1], [Tier 2], [Tier 3])
		) AS PivotTable;
		
	--Result set
		select * from vw_Sales_OFC
		order by Item_Fat_Content;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 10. Total Sales by Outlet Establishment (Top 5):

		select top 5
			Outlet_Establishment_Year,
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by
			Outlet_Establishment_Year
		order by 
			TotalSales desc;

	--View
		create view vw_Sales_OET5 as 
		select top 5
			Outlet_Establishment_Year,
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by
			Outlet_Establishment_Year
		order by 
			TotalSales desc;
		
	--Result set
		select * from vw_Sales_OET5;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 11. Total Sales by Outlet Establishment (Bottom 5):

		select top 5
			Outlet_Establishment_Year,
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by
			Outlet_Establishment_Year
		order by 
			TotalSales;

	--View
		create view vw_Sales_OEB5 as 
		select top 5
			Outlet_Establishment_Year,
			round(SUM(Sales), 2) AS TotalSales 
		from 
			blinkit
		group by
			Outlet_Establishment_Year
		order by 
			TotalSales ASC;
		
	--Result set
		select * from vw_Sales_OEB5;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 12. Percentage of Sales by Outlet Size:

		select 
			Outlet_Size,
			round(SUM(sales),2) as TotalSales,
			round((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()), 2) as PerSales
		from
			blinkit
		group by 
			Outlet_Size;

	--View

		create view vw_PerSales_OS as 
		select 
			Outlet_Size,
			round(SUM(sales),2) as TotalSales,
			round((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()), 2) as PerSales
		from
			blinkit
		group by 
			Outlet_Size;

	--Result set
		select * from vw_PerSales_OS;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 13. Sales by Outlet Location:

		select 
			Outlet_Location_Type,
			ROUND(SUM(Sales),2) as TotalSales
		from 
			blinkit
		group by
			Outlet_Location_Type;

	--View
		create view vw_Sales_OTL as 
		select 
			Outlet_Location_Type,
			ROUND(SUM(Sales),2) as TotalSales
		from 
			blinkit
		group by
			Outlet_Location_Type;
		
	--Result set
		select * from vw_Sales_OTL;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
-- 14. All Metrics by Outlet Type:

		select 
			Outlet_Type,
			ROUND(SUM(Sales),2) as TotalSales,
			round((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()), 0) as PerSales,
			round(AVG(Sales),0) AvgSales,
			Count(*) AS No_of_items,
			round(avg(Rating), 2) as AvegRating,
			ROUND(max(Sales),2) as MaximumSales,
			ROUND(min(Sales),2) as MinimumSales
		from 
			blinkit
		group by 
			Outlet_Type;

	--View
		create view vw_Sales_OT as 
		select 
			Outlet_Type,
			ROUND(SUM(Sales),2) as TotalSales,
			round((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()), 0) as PerSales,
			round(AVG(Sales),0) AvgSales,
			Count(*) AS No_of_items,
			round(avg(Rating), 2) as AvegRating,
			ROUND(max(Sales),2) as MaximumSales,
			ROUND(min(Sales),2) as MinimumSales
		from 
			blinkit
		group by 
			Outlet_Type;
		
	--Result set
		select * from vw_Sales_OT;

-------------------------------------XXXXXXXXXXXXXXXXXXXX-------------------------------------
