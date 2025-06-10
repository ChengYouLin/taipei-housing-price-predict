[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/HR2Xz9sU)
# [Group1] 台北市房價與租金預測分析
本專案旨在分析台北市房價與租金數據，並建立預測模型。專案包含數據收集、地理編碼處理、捷運站特徵提取等功能。主要目標是研究捷運站距離對房價和租金的影響，並建立有效的預測模型。

## Contributors
| 組員   | 系級   | 學號      | 工作分配         |
| ------ | ------ | --------- | ---------------- |
| 潘煜智 | 資科四 | 110703013 | 資料爬蟲、前處理 |
| 林冠儀 | 資科三 | 110703052 | modeling、前端建構 |


## Input

### Data Source

- 內政部「不動產交易實價查詢服務網」
- 爬取 12,271 筆（14 年跨度），欄位包含：建物標的、面積、屋齡、總價、格局等
- 額外資料：台北捷運公司提供之捷運站點位
- 地理編碼：使用 ArcGIS 將房屋地址轉換為經緯度，並計算與最近捷運站距離

### Input Format

- 原始資料多為結構化表格（CSV）
- 欄位：地區、租賃年月日、建物型態、租賃住宅服務、總樓層、建物面積、屋齡、附屬設備、捷運距離等

---

## Preprocessing & EDA

### 缺失值處理

- 類別型欄位（如「出租型態」、「租賃住宅服務」）NA 統一補為「未知」
- 僅保留「租賃天數 ≥ 30」的樣本，排除短租

### 類別簡化

- 捷運路線整併為單一欄位，未涵蓋歸為「無捷運」

### 新增特徵

- 「附近建物單價平均價格」：蒐集周邊 300 公尺內建物之「單價（元/平方公尺）」並取平均

### EDA 指標

- 目標變數（房價）盒鬚圖+小提琴圖觀察分布
- 各地區/房型/建物類型比例
- 熱力圖觀察變數間關聯

---

## 特徵說明與選擇動機

- 捷運距離：「捷運站距離(公尺)」被證實對租金預測有明顯貢獻（Gain 約 2%）
- 資料篩選：「租賃天數」用於剔除短租干擾
- 地段量化：「附近建物單價均價」作為「地段」價值指標

---

## Modeling

- **主要方法**：LightGBM、XGBoost（梯度提升樹）
  - 優點：處理非線性、缺值與類別型特徵能力強
- **Baseline/Null model**：以「附近建物單價均價 * 建物面積」為預測
- **資料分割**：租金分箱後 stratified split (8:2)，10-fold cross validation
- **超參數調整**  
  - LightGBM：num_leaves, learning_rate, min_data_in_leaf, feature_fraction, nrounds
  - XGBoost：eta, max_depth, subsample, colsample_bytree

### 特徵篩選（部分展示）

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

- [Demo 網頁（如有，請補連結）]
- reproduce：請見 Quick Start 指令與 code/資料目錄

---

## Challenges

- 部分租賃資料短租比例高，需謹慎篩選
- 地理編碼落點/地址解析誤差
- 捷運資料需與房屋座標準確對應

---

## References

- **Packages**：
    - lightgbm, xgboost, dplyr, caret, ggplot2, data.table, sf, ...
- **相關文獻/報告**：
    - Noble WS (2009) A Quick Guide to Organizing Computational Biology Projects.
    - 內政部不動產交易實價查詢服務網
    - 台北捷運公司 捷運站出入口資訊

---

## Appendix

- 專案組員：  
統計三 徐語瑭｜統計三 陳沛潔｜統計三 林承佑  
資管三 郭大呈｜資科三 林冠儀｜資科四 潘煜智

---

# 附錄：內容摘要（供快速檢閱）

## 一、背景介紹
臺北市房租高昂，資訊不透明，租屋決策困難。目標為預測租金「總額元」，協助租屋者。

## 二、Input
- 來源：實價登錄（+捷運站、地理編碼）
- 前處理：補NA、分箱篩短租、特徵簡化、地段量化

## 三、Modeling
- LightGBM/XGBoost（CV、超參數優化）
- Baseline 為「附近建物單價均價 × 面積」
- 特徵重要性：前3大貢獻逾7成，捷運距離顯著

## 四、Results
- LightGBM：RMSE 9,172、MAPE 0.154、MEAPE 0.119
- Null Model：RMSE 19,006、MAPE 0.357
- 顯著性檢定：p-value ≪ 0.05，模型顯著優於 baseline

## References
* Packages you use
* Related publications
