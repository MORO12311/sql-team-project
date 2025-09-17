sql-gold-layer/
│
├── README.md                # Main documentation
├── diagrams/                # ERDs, pipeline diagrams
├── scripts/                 # SQL scripts
│   ├── staging/             # Staging scripts
│   ├── silver/              # Cleansing / transformations
│   ├── gold/                # Final aggregated tables & KPIs
│   └── utils/               # Indexes, views, helpers
├── reports/                 # KPI definitions, validation queries
├── notebooks/               # Optional EDA / validation (SQL or Python)
├── dashboard/               # BI dashboard files (Power BI / Tableau / Looker)
└── docs/                    # Extended documentation
    ├── erd.md               # Entity Relationship Diagram explanation
    ├── data_dictionary.md   # Tables, columns, and definitions
    ├── kpi_definitions.md   # Business KPIs formulas
    └── project_notes.md     # Notes, assumptions, and decisions
