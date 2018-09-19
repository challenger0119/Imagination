# Imagination
学习swift的习作  
记录日常

***
#### 待完成：    
1. 设计感提升..


#### 已完成：  
1. 本地文件存储：DataCache，DataPicker，FileManager  
2. 检查网络状态：Reachability  
3. 调用高德地图获取附近地点：GaodeMapApi  
4. 本地通知：Notification  
5. 调试期打印：Log  
6. 地图、定位：LocationViewController，Annotation  
7. 富文本：MoodViewController, ContentShowViewController
8. 图像：MoodViewController, ContentShowViewController
9. 指纹识别：AuthorityViewController  
10. 视图动画：DayList，MainTableViewController  
11. 时间日期：Time  
12. 邮件：MoreViewController
13. iPhone SplitView样式：MainTableViewController, CatalogueViewController
14. 图像模糊：UIImage+BlurImage
15. UIBezierPath(Core Graphic)绘图：IndicatorMapViewBack
16. 录音：AudioRecord, ContentShowViewController
17. 视频：MoodViewController, ContentShowViewController
18. Zip压缩文件：DataCache
19. 集成Realm数据库: DataCache, Item, Media, Location



### 文档

#### Realm 表结构

Table name : Item

| timestamp | content | mood | timeString | dayString | monthString | location | medias      |
| --------- | ------- | ---- | ---------- | --------- | ----------- | -------- | ----------- |
| Double    | String  | Int  | String     | String    | String      | Location | List<Media> |

Table name: Location

| name   | latitude | longtitude |
| ------ | -------- | ---------- |
| String | Double   | Double     |

Table name: Media

| name   | path   | type   | position |
| ------ | ------ | ------ | -------- |
| String | String | String | Int      |

