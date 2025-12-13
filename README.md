# Customer Churn & Support Impact Analysis (SQL)

## 📌 Project Overview
This project analyzes customer behavior to identify churn risk and engagement patterns, and evaluates whether customer support interactions contribute to churn.

The analysis focuses on understanding:
- User inactivity and engagement levels
- Churn risk segmentation based on usage behavior
- Impact of customer support volume and resolution time
- Presence of silent churn (customers who disengage without raising support tickets)

---

## 🗂️ Dataset Description
The project uses four relational tables:

- **Customers** – customer profile information  
- **Subscriptions** – subscription and plan details  
- **Usage_Data** – user activity and usage behavior  
- **Support_Tickets** – customer support interactions and resolution time  

The data is intentionally mixed and unsegmented to reflect real-world scenarios.

---

## 🔍 Key Analysis Steps

### Q1–Q3: User Behavior Metrics
- Calculated recency, usage intensity, and active days per customer
- Derived `days_since_last_activity` using a fixed reference date

### Q4: Customer Segmentation
- Segmented users into:
  - High Risk
  - Low Engagement
  - Highly Engaged
- Segmentation based purely on usage behavior
- Ensured correct aggregation before joining support data

### Q5: Support Impact Analysis
- **Q5.1:** Compared support ticket volume across user segments
- **Q5.2:** Analyzed average support resolution time by segment
- **Q5.3:** Identified potential silent churn-risk customers

### Q6: Business Recommendations
- Concluded that churn risk is primarily driven by user behavior
- Provided actionable recommendations for retention, onboarding, and support strategy

---

## 🛠️ Tools & Skills Used
- SQL (CTEs, CASE, Aggregations, Joins)
- Analytical problem solving
- Business insight generation

---

## 📈 Key Takeaways
- Churn risk is strongly linked to inactivity and low engagement
- Support ticket volume alone does not explain churn
- Resolution quality and user behavior provide stronger signals
- Silent churn analysis helps uncover hidden disengagement patterns

---

## 📂 Files Included
- `customer_churn_support_analysis.sql` – Complete SQL queries for the project
