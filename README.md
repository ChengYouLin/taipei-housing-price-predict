[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/HR2Xz9sU)
# [Group1] 台北市房價與租金預測分析
本專案旨在分析台北市房價與租金數據，並建立預測模型。專案包含數據收集、地理編碼處理、捷運站特徵提取等功能。主要目標是研究捷運站距離對房價和租金的影響，並建立有效的預測模型。

#### 透過 Shiny 將專案內容以網頁方式呈現，讓使用者可以查看資料說明、數據 EDA、建模架構，並且實際進行操作，輸入不同參數並預測房價
###### 網站連結：https://lgyeee.shinyapps.io/mrt_rental_prediction/

## Contributors
| 組員   | 系級   | 學號      | 工作分配         |
| ------ | ------ | --------- | ---------------- |
| 潘煜智 | 資科四 | 110703013 | 資料爬蟲、前處理 |
| 林冠儀 | 資科三 | 110703052 | modeling、前端建構 |
| 徐語瑭 | 統計三 | 111304040 | 資料前處理、資料EDA、簡報、海報  |
| 陳沛潔 | 統計三 | 111304038 | 資料前處理、資料EDA、簡報、海報 |
| 林承佑 | 統計三 | 111304019 | 資料前處理、資料EDA、簡報、海報 |
| 郭大呈 | 資管三 | 111306070 | 捷運資料爬蟲前處理、modeling |

### 專案總覽

```
finalproject-finalproject_group1/
├── code/
├── data/
│ ├── rent_mrg.csv
│ └── docs/
│ ├── 1132_DS-FP_group1.pdf
│ ├── 1132_DS_Group1_海報.png
├── model/
│ ├── model_lgbm/
│ ├── model_null/
│ ├── model_xgb/
├── my_shiny_app/
│ ├── app.R
│ └── modules/
│ ├── welcome.R
│ ├── intro.R
│ ├── dataset.R
│ └── model.R
├── results/
└── README.md
```

###### 簡報資料
```
data/1132_DS-FP_group1.pdf
```

###### `model/`
- **模型相關檔案資料夾**。
  - `model_lgbm/`：儲存 LightGBM 模型。
  - `model_xgb/`：儲存 XGBOOST 模型。

###### lgbm 訓練過程
```
cd model/model_lgbm
Rscript lgb_train_script.R
```

###### xgb 訓練過程
```
cd model/model_xgb
Rscript xgb_train_script.R
```

###### `my_shiny_app/`
- **Shiny App 主程式資料夾**，負責專案互動式前端。
  - `app.R`：Shiny 應用主程式，定義主題、UI 架構、載入各模組、總控各頁籤（如 Welcome、資料說明、模型頁等）。
  - `modules/`：Shiny 子模組，將頁面內容拆分維護。
    - `welcome.R`：首頁簡介與專案動機。
    - `intro.R`：專案背景與分析目標。
    - `dataset.R`：數據來源、特徵說明、前處理細節。
    - `model.R`：模型架構、特徵選擇、訓練與評估結果。

## Input

### Data Source
- 內政部「不動產交易實價查詢服務網」
- 爬取 12,271 筆（14 年跨度），欄位包含：建物標的、面積、屋齡、總價、格局等
- 清洗之後，最後使用為期5年的資料
- 額外資料：台北捷運公司提供之捷運站點位
- 地理編碼：使用 ArcGIS 將房屋地址轉換為經緯度，並計算與最近捷運站距離

### Input Format
- 原始資料多為結構化表格（CSV）
- 欄位：地區、租賃年月日、建物型態、租賃住宅服務、總樓層、建物面積、屋齡、附屬設備、捷運距離等

---

## Preprocessing & EDA
### 缺失值處理
- 移除不相關欄位
- 類別型欄位（如「出租型態」、「租賃住宅服務」）NA 統一補為「未知」
- 僅保留「租賃天數 ≥ 30」的樣本，排除短租

### 類別簡化
- 捷運路線整併為單一欄位，未涵蓋歸為「無捷運」

### 新增特徵
- 「附近建物單價平均價格」：蒐集周邊 300 公尺內建物之「單價（元/平方公尺）」並取平均
- 新增捷運距離與捷運線資料

### EDA 指標
- 目標變數（房價）盒鬚圖+小提琴圖觀察分布
- 各地區/房型/建物類型比例
- 熱力圖觀察變數間關聯

---

## Modeling

- **主要方法**：LightGBM、XGBoost（梯度提升樹）
  - 優點：處理非線性、缺值與類別型特徵能力強
- **Baseline/Null model**：以「附近建物單價均價 * 建物面積」為預測
- **資料分割**：租金分箱後 stratified split (8:2)，10-fold cross validation
- **超參數調整**  
  - LightGBM：num_leaves, learning_rate, min_data_in_leaf, feature_fraction, nrounds
  - XGBoost：eta, max_depth, subsample, colsample_bytree

### Feature selection（部分展示）

| Feature          | Gain    | Cover | Frequency |
|------------------|---------|-------|-----------|
| 建物總面積平方公尺 | 0.3547  | ...   | ...       |
| 租賃住宅服務      | 0.3002  | ...   | ...       |
| 建物型態          | 0.0777  | ...   | ...       |
| ...              | ...     | ...   | ...       |
| 捷運站距離(公尺)  | 0.0196  | ...   | ...       |

- 前三大特徵貢獻度高達 73%
- 捷運距離貢獻 Gain 約2%，模型第八高
- 前 20 大特徵合計貢獻 98.8% 模型效能
- 捷運距離：「捷運站距離(公尺)」被證實對租金預測有明顯貢獻（Gain 約 2%）

---

## 統計顯著性檢定

- 對 20 種模型進行顯著性檢定（移除 n 個最小 Gain 特徵）
- 以 bootstrap 重抽樣 30,000 次評估 RMSE 差異 Δ，計算 95% 信賴區間與 p-value
- 結論：移除任一特徵組合後模型效能皆未顯著提升

---

## Results

### 評估指標

- **RMSE** (Root Mean Squared Error)：預測平均誤差（元），單位直觀但對極端值敏感
- **MAPE** (Mean Absolute Percentage Error)：平均百分比誤差（無單位，易比較）
- **MEAPE** (Median Absolute Percentage Error)：百分比誤差中位數，對極端值最不敏感

| Model    | RMSE    | MAPE   | MEAPE  |
|----------|---------|--------|--------|
| Null     | 19006.1 | 0.3572 | 0.2405 |
| XGBoost  | 11970.9 | 0.1530 | 0.1140 |
| LightGBM |  9172.4 | 0.1538 | 0.1191 |

> 結論：LightGBM 與 XGBoost 均大幅優於 null model，平均預測誤差降低約 10,000 元。LightGBM 控制 RMSE 最佳，XGBoost 在 MAPE/MEAPE 稍有優勢。

---

## 統計檢定與效能提升

- **Null hypothesis H₀**：LGBM 模型預測效能不優於 Null
- **Test result**：Δ 的 95% 信賴區間 [5130.76, 7918.84]，p-value ≪ 0.05
- **結論**：LGBM 預測 RMSE 顯著小於 Null baseline，統計上顯著提升

---

## Demo

- [Demo 網頁](https://lgyeee.shinyapps.io/mrt_rental_prediction/)

---

## Challenges

- 部分租賃資料短租比例高，需謹慎篩選
- 地理編碼落點/地址解析誤差
- 捷運資料需與房屋座標準確對應

---

## References

- **Packages**：
    - lightgbm, xgboost, dplyr, caret, ggplot2, data.table...
- **相關文獻/報告**：
    - 內政部不動產交易實價查詢服務網
    - 台北捷運公司 捷運站出入口資訊



