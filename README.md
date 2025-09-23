# 📊 SQL Gold Layer Project – Dashboard & Reporting  

## 📌 Overview  
This project implements the **Gold Layer** of a SQL-based data pipeline, and then the Data Analyst role comes
The Gold Layer provides **clean, aggregated, business-ready data** used for dashboards and business reports.  

### Objectives  
- Ensure **data quality & governance**  
- Create **derived metrics** and **KPI calculations** 
- Build **fact and dimension tables**  
- Power **dashboards & reports** with optimized SQL queries  

---

## 📂 Project Structure  
```
sql-gold-layer/
│
├── README.md               # Project overview, setup, conventions
├── scripts/                # All SQL scripts
│   └── KPIs Views          # Create views for KPIs calculations, CTEs, EDA
│
├── reports/                # Research, KPI definitions
├── dashboard/              # Excel, Power BI
│
├── data/                   # Example input data or synthetic samples
│   ├── raw/                # Source raw files (SQL Script file for creation)
│   └── processed/          # Cleansed, joined datasets
│
└──  docs/                   # Extended docs (ERD, data dictionary, KPIs)
│   ├── data-dictionary.md  # Column descriptions, Sample data, Column relationship, analytics notes
|   ├── Industry Overview.docx 
|   ├── ERD Model.png       # Modeling data tables and defining the relationships 
|   ├── KPI mapping.xlsx    # Show how to calculate or apply KPIs on the dataset   
    └── Industry KPIs.docx  # KPI list and definitions


```

---

## 🚀 Workflow  

### 1. Setup  
- Create Git repository  
- Define coding standards  
- Add `.gitignore` for unnecessary files 

### 2. Data Preparation  
- Check data quality (Silver quality)  
- Apply business rules  
- Create derived columns (profit, margin, session duration)  

### 3. EDA (Exploratory Data Analysis)  
- Explore distributions & anomalies  
- Validate assumptions  

### 4. Gold Layer Modeling  
#### ⭐ Fact Constellation Schema (Galaxy Schema)

**Fact Tables**
- `orders`
- `order_items`
- `order_item_refunds`
- `website_pageviews`

**Dimension Tables**
- `website_sessions`
- `products`


### 5. KPI Calculations  
- GMV (Gross Merchandise Value)  
- CAC (Customer Acquisition Cost)  
- CLV (Customer Lifetime Value)  
- Conversion Rate  
- Churn Rate  

### 6. Dashboard & Reports  
- Connect BI tool (Power BI)  
- Create dashboards (executive overview + drilldowns)  
- Validate numbers with SQL queries  

---

## 📑 Documentation  

Extended documentation is in the **docs/** folder:  
- `docs/erd.png` → Entity Relationship Diagram  
- `docs/data-dictionary.md` → Columns, Sample data, Columns relationships, Quality check → [Data Dictionary](docs/data-dictionary.md)
- `docs/Industry Overview.docx` → E-Commerce industry overview report 
- `docs/Industry KPIs.docx` → KPI formulas & explanations  
- `docs/KPI Mapping.xlsx` → Dataset KPIs calculations
- 
---

## ✅ Deliverables  
- SQL scripts for **Gold Layer tables & KPIs**  
- **Documentation** of KPI definitions & formulas  
- **Dashboard** (Excel / Power BI) with KPIs & drilldowns  
- Git repository with version-controlled code  

---

## 👨‍💻 Contributors  
- Project Team Leader: Nouran 
- Data Engineering Support: Omar  
- Data Analyst & BI Developer: Manar, Faris, Hassan, Nouran, Omar

---
