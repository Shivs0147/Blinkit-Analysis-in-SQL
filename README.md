# 📊 Blinkit Sales Report – SQL Project

<p align='justify'>
This project presents a detailed SQL-based analysis of sales data from <b>Blinkit</b>, a grocery delivery service. The objective is to import, clean, transform, and analyze item-level retail sales data using SQL Server Management Studio (SSMS).
</p>

## 📁 Dataset Overview

- **Source File**: [`Blinkit.csv`](https://github.com/Shivs0147/Blinkit-Analysis-in-SQL/blob/main/Blinkit.csv)
- **Imported Table**: `dbo.Blinkit`
- **No. of Records**: ~8,500+
- **Key Columns**:
    - `ITEM_IDENTIFIER`
  - `ITEM_FAT_CONTENT`
  - `ITEM_TYPE`
  - `ITEM_WEIGHT`
  - `ITEM_VISIBILITY`
  - `SALES`
  - `RATING`
  - `OUTLET_IDENTIFIER`
  - `OUTLET_ESTABLISHMENT_YEAR`
  - `OUTLET_SIZE`
  - `OUTLET_LOCATION_TYPE`
  - `OUTLET_TYPE`

## 🧩 Setup Instructions

### 1. Create Database & Import CSV
- Create a new database named `blinkit` in SSMS.
- Use **Tasks > Import Flat File Wizard** to import `Blinkit.csv`.
- Table name: `Blinkit` (schema: dbo)
```sql
-- In SSMS
CREATE DATABASE dbo.blinkit;
```
### 2. Data Type Adjustments
| Column | Data Type |
|--------|-----------|
| ITEM_FAT_CONTENT, ITEM_IDENTIFIER, ITEM_TYPE | `VARCHAR` |
| ITEM_VISIBILITY, ITEM_WEIGHT, SALES, RATING | `FLOAT` |
| OUTLET_ESTABLISHMENT_YEAR | `INT` |
| Allow NULL in `ITEM_WEIGHT` |

### 3.  Data Cleaning

Standardize fat content:

```sql
UPDATE Blinkit
SET ITEM_FAT_CONTENT =  
  CASE  
    WHEN ITEM_FAT_CONTENT IN ('LF', 'LOW FAT') THEN 'LOW FAT'
    WHEN ITEM_FAT_CONTENT = 'REG' THEN 'REGULAR'
    ELSE ITEM_FAT_CONTENT
  END;
```

## 📊 KPI Metrics

| KPI | SQL Query |
|-----|-----------|
| ✅ **Total Sales** | `select Concat (cast (SUM(Sales)/1000000 as decimal (10,2)), 'M') AS TotalSalesMillion from blinkit;` |
| 📦 **Total Items** | `SELECT COUNT(*) AS NO_OF_ITEMS FROM Blinkit;` |
| 📊 **Average Sales** | `SELECT ROUND(AVG(SALES),0) AS AVGSALES FROM Blinkit;` |
| 🌟 **Average Rating** | `SELECT ROUND(AVG(RATING),2) AS AVEGRATING FROM Blinkit;` |

## 🔍 Granular Analysis

### 1. 📑 Total Sales by Fat Content
```sql
SELECT ITEM_FAT_CONTENT, 
       CONCAT(ROUND(SUM(SALES)/1000, 2), 'K') AS TOTALSALES
FROM Blinkit
GROUP BY ITEM_FAT_CONTENT;
```

### 2. 🔝 Top 5 Item Types by Sales
```sql
SELECT TOP 5 ITEM_TYPE, 
             ROUND(SUM(SALES), 2) AS TOTALSALES
FROM Blinkit
GROUP BY ITEM_TYPE
ORDER BY TOTALSALES DESC;
```

### 3. 🧠 Sales by Fat Content & Location Type
```sql
SELECT ITEM_FAT_CONTENT, 
       OUTLET_LOCATION_TYPE, 
       ROUND(SUM(SALES), 2) AS TOTALSALES
FROM Blinkit
GROUP BY ITEM_FAT_CONTENT, OUTLET_LOCATION_TYPE
ORDER BY OUTLET_LOCATION_TYPE;
```

### 4. 🔄 Pivot: Fat Content by Outlet Location
```sql
SELECT OUTLET_LOCATION_TYPE, 
       COALESCE([LOW FAT], 0) AS LOW_FAT,
       COALESCE([REGULAR], 0) AS REGULAR
FROM (
    SELECT ITEM_FAT_CONTENT, OUTLET_LOCATION_TYPE, 
           ROUND(SUM(SALES), 2) AS TOTALSALES
    FROM Blinkit
    GROUP BY ITEM_FAT_CONTENT, OUTLET_LOCATION_TYPE
) AS SourceTable
PIVOT (
    SUM(TOTALSALES)
    FOR ITEM_FAT_CONTENT IN ([LOW FAT], [REGULAR])
) AS PivotTable
ORDER BY OUTLET_LOCATION_TYPE;
```

### 5. 🔄 Pivot: Outlet Type by Fat Content
```sql
SELECT ITEM_FAT_CONTENT, 
       COALESCE([TIER 1], 0) AS TIER_1,
       COALESCE([TIER 2], 0) AS TIER_2,
       COALESCE([TIER 3], 0) AS TIER_3
FROM (
    SELECT ITEM_FAT_CONTENT, OUTLET_LOCATION_TYPE, 
           ROUND(SUM(SALES), 2) AS TOTALSALES
    FROM Blinkit
    GROUP BY ITEM_FAT_CONTENT, OUTLET_LOCATION_TYPE
) AS SourceTable
PIVOT (
    SUM(TOTALSALES)
    FOR OUTLET_LOCATION_TYPE IN ([TIER 1], [TIER 2], [TIER 3])
) AS PivotTable
ORDER BY ITEM_FAT_CONTENT;
```

### 6. 🏆 Top 5 Outlet Establishment Years by Sales
```sql
SELECT TOP 5 OUTLET_ESTABLISHMENT_YEAR, 
             ROUND(SUM(SALES), 2) AS TOTALSALES
FROM Blinkit
GROUP BY OUTLET_ESTABLISHMENT_YEAR
ORDER BY TOTALSALES DESC;
```

### 7. 🔽 Bottom 5 Outlet Establishment Years by Sales
```sql
SELECT TOP 5 OUTLET_ESTABLISHMENT_YEAR, 
             ROUND(SUM(SALES), 2) AS TOTALSALES
FROM Blinkit
GROUP BY OUTLET_ESTABLISHMENT_YEAR
ORDER BY TOTALSALES ASC;
```

## 📈 Chart-Based Insights

### 1. 📊 Percentage Sales by Outlet Size
```sql
SELECT OUTLET_SIZE, 
       ROUND(SUM(SALES),2) AS TOTALSALES,
       ROUND((SUM(SALES) * 100.0 / SUM(SUM(SALES)) OVER ()), 2) AS PERSALES
FROM Blinkit
GROUP BY OUTLET_SIZE;
```

### 2. 📍 Sales by Outlet Location Type
```sql
SELECT OUTLET_LOCATION_TYPE,
       ROUND(SUM(SALES),2) AS TOTALSALES
FROM Blinkit
GROUP BY OUTLET_LOCATION_TYPE;
```

### 3. 📋 All Metrics by Outlet Type
```sql
SELECT OUTLET_TYPE,
       ROUND(SUM(SALES),2) AS TOTALSALES,
       ROUND((SUM(SALES) * 100.0 / SUM(SUM(SALES)) OVER ()), 0) AS PERSALES,
       ROUND(AVG(SALES),0) AS AVGSALES,
       COUNT(*) AS NO_OF_ITEMS,
       ROUND(AVG(RATING), 2) AS AVEGRATING,
       ROUND(MAX(SALES),2) AS MAXIMUMSALES,
       ROUND(MIN(SALES),2) AS MINIMUMSALES
FROM Blinkit
GROUP BY OUTLET_TYPE;
```

## 📄 SQL Views Created

### A. KPI Views

| View Name | Purpose |
|-----------|---------|
| `VW_TOTALSALES` | Total revenue |
| `VW_AVGSALES` | Average sales per item |
| `VW_NOOFITEMS` | Count of items sold |
| `VW_AVGRATING` | Average customer rating |

### B. Granular Analysis Views

| View Name | Purpose |
|-----------|---------|
| `VW_SALES_FC` | Sales by Fat Content |
| `VW_SALES_IT` | Sales by Item Type |
| `VW_SALES_OLT` | Sales by Fat Content & Location |
| `VW_SALES_FCO` | Pivot – Fat by Outlet |
| `VW_SALES_OFC` | Pivot – Outlet by Fat |
| `VW_SALES_OET5` | Top 5 Outlet Years |
| `VW_SALES_OEB5` | Bottom 5 Outlet Years |

### C. Charts & Dashboard Views

| View Name | Purpose |
|-----------|---------|
| `VW_PERSALES_OS` | % Sales by Outlet Size |
| `VW_SALES_OTL` | Sales by Location Type |
| `VW_SALES_OT` | All Metrics by Outlet Type |

## 🛠️ Tech Stack

- **SQL Server Management Studio (SSMS 2021)**
- **T-SQL (Aggregation, PIVOT, Views)**
- **Flat File Import Wizard**

## ✅ Deliverables

- Cleaned & Transformed SQL Table (`Blinkit`)
- 15+ Analytical Queries
- 15+ SQL Views
- Ready for Power BI dashboard integration

## 🙋‍♂️ Author Notes

- This project focuses on practical SQL for business insights.
- Data is anonymized and fictional.
- Views allow for modular dashboarding in BI tools like Power BI/Tableau.

## **👤 Author & Contact**

<ul>
  <li>Name - Shivam Gabani</li>
  <li>📧 Email: shivamgabani.744@outlook.com</li>
  <li>💼 LinkedIn: https://www.linkedin.com/in/shivam-gabani-38192a36b/</li>
  <li>📍 Surat, Gujarat.</li>
</ul>

## 🙌 Thanks for Scrolling!

If you liked this project, feel free to star ⭐ the repo or connect with me on LinkedIn.

I’m always open to feedback, learning, and new collaborations.

Cheers!  
**– Shivam Gabani**
