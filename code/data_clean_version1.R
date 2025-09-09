setwd("/Users/Cheng_You /Desktop/1132/資料科學/project/repo/1132_Data_Science_Final/dataset")
df <- read.csv("taipei_rent.csv")

colnames(df)
head(df)

library(dplyr)
library(ggplot2)
library(showtext)
showtext_auto()
library(stringr)
library(lubridate)

#df <- df[, -1]
#df <- df[, -ncol(df)]
#df <- df[, -ncol(df)]


###############################
# 這地方使用開會後的資料集後，不用處理
df <- subset(df, select = -`非都市土地使用分區`)
df <- subset(df, select = -`非都市土地使用編定`)

###############################
# 這地方使用開會後的資料集後，不用處理
## 看第一個欄位有哪些類別在裡面
distinct(df["鄉鎮市區"])

table(df$鄉鎮市區, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(鄉鎮市區 = Var1, 數量 = Freq) %>% 
  select(鄉鎮市區, 數量, Percent)
## 發現有三種沒有區的資料「 」「有」「無」，抓下來看看內容是什麼
#df_special <- df %>%
#  filter(`鄉鎮市區` %in% c("", "無", "有"))
#head(df_special)

## 確定這三種資料內容都不正常，所以直接刪除
#remove(df_special)
#df <- df %>%
#  filter(!`鄉鎮市區` %in% c("", "無", "有"))

###############################
# 第二個欄位有哪些類別在裡面
#distinct(df["交易標的"])

#table(df$交易標的, useNA = "ifany") %>% 
#  as.data.frame() %>% 
#  arrange(desc(Freq)) %>% 
#  mutate(Percent = Freq / sum(Freq) * 100) %>% 
#  mutate(Percent = round(Percent, 2)) %>% 
#  mutate(Percent = paste0(Percent, "%")) %>% 
#  rename(交易標的 = Var1,數量 = Freq) %>% 
#  select(交易標的, 數量, Percent)

## 我不確定這裡要怎麼改？是直接改成有沒有包含車位就好嗎？
## 是把這裡的房地什麼的都歸類在租屋就好嗎？
## 土地指的有車位嗎？

###############################


df <- df %>%
  mutate(主要用途 = as.character(主要用途))


# 用文字內容做初步的分類(創建為新的欄位，叫做"主要用途_分類")
df <- df %>%
  mutate(主要用途_分類 = case_when(
    str_detect(主要用途, "住宅|住家用|集合住宅|多戶住宅|公寓") ~ "住宅類",
    str_detect(主要用途, "住商|住工|住宅、店舖") ~ "住商混合",
    str_detect(主要用途, "商業|辦公|事務所|零售業|店舖") ~ "商業用途",
    str_detect(主要用途, "工業|工廠|廠房|倉儲") ~ "工業用途",
    str_detect(主要用途, "防空|醫|學|福利|宿舍|交通") ~ "特殊用途",
    str_trim(主要用途) == "" | is.na(主要用途) ~ "未知",
    TRUE ~ "其他"
  ))

distinct(df["主要用途_分類"])

# 查看每一個分類後內有幾個原始類別
df %>%
  group_by(主要用途_分類) %>%
  summarise(原始類別 = paste(unique(主要用途), collapse = "、")) %>%
  mutate(類別數 = str_count(原始類別, "、") + 1)

# 列出所有分類內的原始類別，確認是否有分錯或太奇怪的
用途清單 <- df %>%
  group_by(主要用途_分類) %>%
  summarise(原始用途 = sort(unique(主要用途))) %>%
  tidyr::unnest(cols = c(原始用途)) 
print(用途清單, n = Inf)  

# 看分完後的每個類別有幾筆資料
table(df$主要用途_分類, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(主要用途_分類 = Var1, 數量 = Freq) %>% 
  select(主要用途_分類, 數量, Percent)

# 刪除住宅類我覺得偏奇怪的
df %>%
  filter(主要用途 == "第八組：社會福利設施—兒童、少年福利機構、防空避難室兼停車空間、第三組：寄宿住宅、機房及水箱、停車空間，機房、第十九組：") %>%
  nrow()

# 保留只有住宅和住商混合的資料
df <- df %>% 
  filter(`主要用途_分類` %in% c("住宅類", "住商混合"))

df <- subset(df, select = -`主要用途_分類`)
df <- subset(df, select = -`主要用途`)



###############################

# 做完主要用途後，這裡土地分區有點微妙，我覺得可以刪掉！
distinct(df["都市土地使用分區"])
table(df$都市土地使用分區, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(都市土地使用分區 = Var1, 數量 = Freq) %>% 
  select(都市土地使用分區, 數量, Percent)

# 我選擇刪除這個欄位
df <- subset(df, select = -`都市土地使用分區`)

###############################

table(df$車位類別, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(車位類別 = Var1, 數量 = Freq) %>% 
  select(車位類別, 數量, Percent)

# 刪掉所有有車位類別的資料
df <- df %>%
  filter(`車位類別` %in% c(""))

distinct(df["車位面積平方公尺"])
distinct(df["車位總額元"])
df <- subset(df, select = c(-`車位類別`, -`車位面積平方公尺`, -`車位總額元`))


###############################

table(df$有無管理組織, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(有無管理員 = Var1, 數量 = Freq) %>% 
  select(有無管理員, 數量, Percent)

###############################

table(df$有無附傢俱, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(有無附傢俱 = Var1, 數量 = Freq) %>% 
  select(有無附傢俱, 數量, Percent)

###############################

table(df$有無電梯, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(有無電梯 = Var1, 數量 = Freq) %>% 
  select(有無電梯, 數量, Percent)

###############################

table(df$有無管理員, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(有無管理員 = Var1, 數量 = Freq) %>% 
  select(有無管理員, 數量, Percent)

###############################


distinct(df["主要建材"])

table(df$主要建材, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(車位類別 = Var1, 數量 = Freq) %>% 
  select(車位類別, 數量, Percent)


df <- df %>%
  mutate(主要建材 = case_when(
    str_detect(主要建材, "鋼筋混凝土|ＲＣ") ~ "鋼筋混凝土造",
    str_detect(主要建材, "加強磚造") ~ "加強磚造",
    str_detect(主要建材, "鋼骨鋼筋混凝土|鋼骨混凝土") ~ "鋼骨鋼筋混凝土造",
    str_detect(主要建材, "鋼骨造") ~ "鋼骨造",
    str_detect(主要建材, "磚造") ~ "磚造",
    str_detect(主要建材, "木|竹") ~ "木造",
    str_detect(主要建材, "見使用執照|見其他登記事項") ~ NA_character_,
    str_trim(主要建材) == "" ~ NA_character_,
    TRUE ~ 主要建材
  ))

# 看看整理後的狀況
df %>%
  count(主要建材, sort = TRUE) %>%
  mutate(Percent = round(n / sum(n) * 100, 2),
         Percent = paste0(Percent, "%"))

# 刪掉缺失值
df <- df %>% 
  filter(!is.na(主要建材))

# 再把分出來的類別再縮小類別！
df <- df %>%
  mutate(主要建材 = case_when(
    str_detect(主要建材, "鋼筋混凝土造|鋼骨鋼筋混凝土造") ~ "鋼筋混凝土造類",
    str_detect(主要建材, "加強磚造|磚造|磚石造|土磚石混合造|加強石造|石造") ~ "加強磚造類",
    str_detect(主要建材, "鋼骨造|鋼骨|鋼構造") ~ "鋼骨類",
    str_detect(主要建材, "木造") ~ "木造類",
    is.na(主要建材) | 主要建材 == "" ~ "其他",
    TRUE ~ "其他"
  ))

# 看結果狀況
df %>%
  count(主要建材, sort = TRUE) %>%
  mutate(Percent = round(n / sum(n) * 100, 2),
         Percent = paste0(Percent, "%"))




# 因為數據分布很極端，這裡我先選擇保留前二多，剩下統合為其他
## 也可以分成是不是鋼筋混泥土就好
#top <- df %>%
#  count(主要建材, sort = TRUE) %>%
#  top_n(3, n) %>%
#  pull(主要建材)

#df <- df %>%
#  mutate(主要建材 = ifelse(主要建材 %in% top, 主要建材, "其他"))


###############################

table(df$租賃住宅服務, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(租賃住宅服務 = Var1, 數量 = Freq) %>% 
  select(租賃住宅服務, 數量, Percent)

###############################
# 出租型態
table(df$出租型態, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(出租型態 = Var1, 數量 = Freq) %>% 
  select(出租型態, 數量, Percent)

# 因為我們認為這個部分重要，所以選擇刪除大約14%的空白值，剩下的資料量至少還有一萬四千筆
df <- df %>%
  filter(!`出租型態` %in% c(""))

###############################

distinct(df["交易標的"])
df <- subset(df, select = -`交易標的`)
df <- subset(df, select = -`source_file`)
df <- subset(df, select = -`編號`)
df <- subset(df, select = -`備註`)
df <- subset(df, select = -`土地位置建物門牌`)
df <- subset(df, select = -`土地面積平方公尺`)
# 我覺得型態就已經大致區分了！
# 不需要這個樓層數，反而會影響透天厝等型態的因子
df <- subset(df, select = -`總樓層數`)



###############################
所有設備 <- df$附屬設備 %>%
  str_split("、") %>%
  unlist() %>%
  trimws() %>%
  unique()

sort(所有設備)

設備列表 <- c("冰箱", "冷氣", "有線電視", "洗衣機", 
          "熱水器", "瓦斯或天然氣", "網路", "電視機")

for (item in 設備列表) {
  df[[item]] <- grepl(item, df$附屬設備)
}
df <- df %>%
  mutate(across(all_of(設備列表), ~ as.integer(.)))

df <- subset(df, select = -`附屬設備`)

###############################
# 處理租賃期間轉為天數「租期天數」

df <- df %>%
  mutate(
    起始日_raw = str_sub(租賃期間, 1, 7),
    結束日_raw = str_sub(租賃期間, 9, 15)
  )

convert_minguo_to_date <- function(x) {
  y <- as.integer(str_sub(x, 1, 3)) + 1911
  m <- str_sub(x, 4, 5)
  d <- str_sub(x, 6, 7)
  ymd(paste0(y, "-", m, "-", d))
}

df <- df %>%
  mutate(
    起始日 = convert_minguo_to_date(起始日_raw),
    結束日 = convert_minguo_to_date(結束日_raw),
    租期天數 = as.numeric(結束日 - 起始日)
  )

summary(df$租期天數)
df <- subset(df, select = -`起始日_raw`)
df <- subset(df, select = -`結束日_raw`)
df <- subset(df, select = -`租賃期間`)
df <- subset(df, select = -`起始日`)
df <- subset(df, select = -`結束日`)

###############################

table(df$建物型態, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(建物型態 = Var1, 數量 = Freq) %>% 
  select(建物型態, 數量, Percent)

df <- df %>%
  filter(!(建物型態 %in% c("辦公商業大樓", "店面(店鋪)", "工廠")))

###############################

table(df$租賃層次, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(租賃層次 = Var1, 數量 = Freq) %>% 
  select(租賃層次, 數量, Percent)

# 兩者數量正確！
df %>% 
  filter( (租賃層次 == "全" & 建物型態 == "透天厝")) %>% 
  nrow()

df <- df %>%
  filter(!(租賃層次 %in% c("見其他登記事項")))

###############################

head(df$租賃筆棟數)

df <- df %>%
  mutate(
    土地數 = str_extract(租賃筆棟數, "(?<=土地)\\d+") %>% as.integer(),
    建物數 = str_extract(租賃筆棟數, "(?<=建物)\\d+") %>% as.integer(),
    車位數 = str_extract(租賃筆棟數, "(?<=車位)\\d+") %>% as.integer()
  )

df <- subset(df, select = -`租賃筆棟數`)

table(df$土地數, useNA = "ifany") %>% 
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(土地數 = Var1, 數量 = Freq) %>% 
  select(土地數, 數量, Percent)

table(df$建物數, useNA = "ifany") %>%
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(建物數 = Var1, 數量 = Freq) %>% 
  select(建物數, 數量, Percent)

table(df$車位數, useNA = "ifany") %>%
  as.data.frame() %>% 
  arrange(desc(Freq)) %>% 
  mutate(Percent = Freq / sum(Freq) * 100) %>% 
  mutate(Percent = round(Percent, 2)) %>% 
  mutate(Percent = paste0(Percent, "%")) %>% 
  rename(車位數 = Var1, 數量 = Freq) %>% 
  select(車位數, 數量, Percent)

# 這裡我選擇刪除車位數，確定都是零。
df <- subset(df, select = -`車位數`)

## 不確定以下做法是否正確，所以沒有刪除兩欄位

# 這裡我選擇刪除土地數大於一的資料
# 從土地面積的零的定義，我覺得大於一的應該就是非單純租房的
df <- df %>%
  filter(土地數 <= 1)

# 這裡我選擇刪除建物數大於一的資料
# 直觀來說我們的對象就是一個想租一間房的人，
# 那建物數太多也很怪（反正多的資料也很少）
df <- df %>%
  filter(建物數 <= 1)

###############################

# 刪除租賃年月日，已經有天數了
df <- subset(df, select = -`租賃年月日`)
# 把完成年月轉成屋齡

sum(is.na(df$建築完成年月))
# 並沒有很多筆，所以選擇刪除
df <- df %>%
  filter(!is.na(建築完成年月))

library(dplyr)
library(lubridate)

df <- df %>%
  mutate(
    建築完成年月_chr = as.character(建築完成年月),
    建築完成年月_chr = str_pad(建築完成年月_chr, width = 7, side = "left", pad = "0"),
    建築完成日期 = ymd(paste0(as.integer(substr(建築完成年月_chr, 1, 3)) + 1911,
                        substr(建築完成年月_chr, 4, 6),
                        substr(建築完成年月_chr, 7, 7))),
    # 距離現在的年數，無條件進位
    屋齡 = ceiling(time_length(interval(建築完成日期, Sys.Date()), "year"))
  )

df <- subset(df, select = -`建築完成年月`)
df <- subset(df, select = -`建築完成年月_chr`)
df <- subset(df, select = -`建築完成日期`)

