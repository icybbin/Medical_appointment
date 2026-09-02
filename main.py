import pandas as pd

def 自動鏈結醫療數據():
    print("專案啟動：正在執行前期環境調教與數據鏈結...")
    
    檔案路徑 = "appointment_data.csv"
    
    try:
        df = pd.read_csv(檔案路徑, encoding='utf-8')
        
        print("鏈結成功！資料已成功載入 Pandas 記憶體中。")
        print(f"數據統計：這個醫療預約資料集目前共有 {len(df)} 筆資料，{len(df.columns)} 個欄位。")
        return df

    except FileNotFoundError:
        print(f"錯誤：在目前資料夾下找不到【{檔案路徑}】檔案！")
        print("解決辦法：請檢查你的CSV檔案名稱是否名爲appointment_data.csv？是否同main.py放在同一資料夾？")
        return None
    except Exception as e:
        print(f" 發生其他未知的鏈結錯誤：{e}")
        return None

if __name__ == "__main__":
    df = 自動鏈結醫療數據()

    if df is not None:
        print("\n--- 執行前期數據檢查（前 5 行） ---")
        
        print(df.head())
        
