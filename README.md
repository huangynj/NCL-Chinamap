# NCL-Chinamap
由于```NCL (NCAR Command Language)```官方提供的地图数据的中国边界等存在问题, 
根据全国地理信息资源目录服务系统提供的1:100万全国基础地理数据库 ( http://www.webmap.cn/commres.do?method=result100W ),
对原```NCL```的中国地图数据进行修正，从而能够绘制正确的国界、台湾岛屿、南海诸岛及省界等。


##### 测试成功的 `NCL` 版本有：`6.1.2`, `6.2.0`, `6.2.1`, `6.3.0`, `6.4.0`.

###（一）使用方法
使用 `git` 下载
```
  git clone https://git.coding.net/huangynj/NCL-Chinamap.git
```
或者直接点击下载按钮打包下载。

下载完成后可以直接运行提供的例子脚本进行测试：
```
  ncl plot_with_correct_Chinamap.ncl
```

使用修正的地图数据关键属性是：
```
  res@mpDataSetName              = "./database/Earth..4"
  res@mpDataBaseVersion          = "MediumRes" ; or "Ncarg4_1"
  res@mpAreaMaskingOn            = True
  res@mpMaskAreaSpecifiers       = (/"China"/)
  res@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
```
在 `database` 目录下存在 `Earth..4.lines` 和 `Earth..4.names` 
两个地图数据文件，可以把这两个文件覆盖 `"$NCARG_ROOT/lib/ncarg/database"` 
目录下原来的文件，这样在设置 `mpDataSetName` 属性时可以省略路径，直接使用 `"Earth..4"`，
否则需要把路径填写完整。使用到的地名可以参考：
  http://www.ncl.ucar.edu/Document/HLUs/Classes/MapPlotData4_1_earth_4.shtml

### （二）主要修正
该地图数据中已经将台湾、钓鱼岛等归回中国，并将钓鱼岛命名 `"Senkaku Shoto"` 改为 `"Diaoyu Dao"`，
具体修改的位置可查看 `doc.pdf` 文件。所以，使用完整中国地图只需设置 `"China"` ，
如果需要添加省界，则再添加 `"China:Provinces"` 即可。
详细可以参考提供的例子：`plot_with_correct_Chinamap.ncl` 。

#### （1）修正位置示意图
![1][1]

#### （2）修正后对比图
![2][2]

#### （3）完整中国版图
![3][3]

#### （4）南海诸岛小插图和地图 Mask 功能
![4][4]

#### （5）带南海小图和长江黄河的中国地图
![5][5]


### （三）更新记录

2016-05-22：更新国界、台湾岛屿、南海诸岛及一些粗糙省界；

2016-05-27：更新北京市界；

2016-07-16：修正一些小 bugs.


### 本地图数据作者保留著作权和最终解释权，本数据可用于教育，科研等非商业用途，若商业用途请提前与本数据作者联系，经允许后方可使用，如有违反，本数据作者保留权利！
### 为了表示对贡献者劳动成果的尊重，若使用该地图数据绘图发表论文等，可考虑添加致谢！


```
中文致谢：感谢中国科学院大气物理研究所黄永杰博士提供的包含正确中国国界
和行政区划的地图数据（https://coding.net/u/huangynj/p/NCL-Chinamap/git）。

英文致谢：Thank Dr. Yongjie Huang (IAP/CAS) for providing map database 
(https://coding.net/u/huangynj/p/NCL-Chinamap/git).


Yong-Jie Huang (IAP/CAS) 

huangynj@gmail.com

2016-05-23
```

[1]: http://bbs.06climate.com/data/attachment/forum/201605/23/163019nbumte0zmvzkr0tt.png
[2]: http://bbs.06climate.com/data/attachment/forum/201605/23/163020y3o0b0gdll6th2zp.png
[3]: http://bbs.06climate.com/data/attachment/forum/201605/23/163020lanad0ais7n76cgc.png
[4]: http://bbs.06climate.com/data/attachment/forum/201605/27/201628x317lcnoird7doer.png
[5]: http://bbs.06climate.com/data/attachment/album/201612/02/085435s333q24y4ql9p346.png
