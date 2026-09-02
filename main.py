import pandas as pd

# ==========================================
# 一：前期環境調教與數據鏈結
# ==========================================
def 自動鏈結醫療數據():
    print("專案啟動：正在執行前期環境調教與數據鏈結...")
    
    # 這是你 GitHub 上的真實數據檔名
    檔案路徑 = "appointment_data.csv"
    
    try:
        # 使用 Pandas 鏈結並讀取你的 CSV 檔（設定好 utf-8 編碼防止亂碼）
        df = pd.read_csv(檔案路徑, encoding='utf-8')
        print("鏈結成功！資料已成功載入 Pandas 記憶體中。")
        print(f"數據統計：資料集目前共有 {len(df)} 筆資料，{len(df.columns)} 個欄位。")
        return df

    except FileNotFoundError:
        print(f"錯誤：在目前資料夾下找不到【{檔案路徑}】檔案！")
        print("解決辦法：請確保你的 CSV 檔案名稱叫做 appointment_data.csv，並且跟 main.py 放在同一個資料夾。")
        return None
    except Exception as e:
        print(f"發生其他未知的鏈結錯誤：{e}")
        return None

# ==========================================
# 二：核心商業分析
# ==========================================
def 執行商業數據分析(df):
    print("\n進入資料分析（Data Analytics）流程...")
    
    # 【DA 基本功 1】：計算整體的不赴約率（核心 KPI 指標）
    # 假設欄位叫 'No-show'，其中 'Yes' 代表放鴿子
    整體放鴿子次數 = (df['No-show'] == 'Yes').sum()
    總預約人數 = len(df)
    整體放鴿子率 = (整體放鴿子次數 / 總預約人數) * 100
    print(f"核心 KPI：醫院整體的預約不赴約率為 {整體放鴿子率:.2f}%")
    
    # 【DA 基本功 2】：交叉表（Pivot Table）分析簡訊提醒的效果
    print("\n交叉分析：簡訊通知（SMS_received）對不赴約率（No-show）的影響（百分比 %）：")
    # normalize='index' 會自動把人數換算成橫向的百分比，方便我們比較
    簡訊交叉表 = pd.crosstab(df['SMS_received'], df['No-show'], normalize='index') * 100
    print(簡訊交叉表)
    
    # 【DA 基本功 3】：數據分組（Group By）分析年齡規律
    print("\n數據分組：赴約狀況與患者平均年齡的關聯：")
    年齡分析 = df.groupby('No-show')['Age'].mean()
    print(f"乖乖赴約的人（No-show = No），平均年齡是：{年齡分析['No']:.1f} 歲")
    print(f"放鴿子不來的人（No-show = Yes），平均年齡是：{年齡分析['Yes']:.1f} 歲")

# ==========================================
# 三：程式啟動入口
# ==========================================
if __name__ == "__main__":
    # 1. 先跑第一步：把資料準備好並鏈結起來
    醫療數據表格 = 自動鏈結醫療數據()

    # 2. 如果資料成功讀進來了，就跑第二步：執行剛剛學的 DA 分析
    if 醫療數據表格 is not None:
        執行商業數據分析(醫療數據表格)

 
