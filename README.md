# Medical Appointment Data Analytics Project (醫療預約數據分析專案)

Here is a comprehensive data analytics project focused on predicting and analyzing medical appointment no-shows. 
這是一個完整的醫療預約數據分析作品集，旨在透過數據找出患者不赴約（No-show）的核心原因與趨勢。

---

##  Project Structure & Tech Stack (專案結構與技術棧)

This repository demonstrates an end-to-end data analytics pipeline using Python, SQL, and Tableau:
本專案展示了從數據清洗、資料庫分析到前端視覺化的完整商業分析流程：

*   ** Python (`main.py`)**: 
    *   負責前期的環境調教（Robust Environment Configuration）與自動化數據鏈結。
    *   使用 **Pandas** 進行數據讀取與初步特徵檢查（Data Inspection），並建立自動化防錯機制（Try-Catch block）。
*   ** SQL (`medical.sql`)**: 
    *   負責核心數據指標的撈取與高級分析（Advanced Querying）。
    *   分析患者年齡、預約週期、簡訊通知（SMS）與赴約率之間的關聯性。
*   ** Tableau (`medical_tableau_analysis.twb`)**: 
    *   將分析結果轉化為動態商業儀表板（Interactive Dashboard）。
    *   提供決策者一目了然的視覺化洞察。

---

##  How to Run Python Script (如何運行 Python 主程式)

1. Clone this repository to your local machine. (將此儲存庫下載至本機)
2. Ensure you have **Pandas** installed: (確保已安裝 Pandas 套件)
   ```bash
   pip install pandas
   ```
3. Run the automation script: (執行主程式)
   ```bash
   python main.py
   ```

---

##  Key Insights Preview (核心數據分析洞察)

*   **Lead Time Effect (預約週期的影響)**: Patients who book appointments far in advance have a significantly higher no-show rate. (提前預約天數越長的患者，不赴約率明顯較高。)
*   **SMS Reminders (簡訊提醒的威力)**: Sending text reminders effectively boosts attendance rates across all age groups. (發送簡訊提醒能顯著提升各年齡層的實際赴約率。)
