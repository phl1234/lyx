# Snake类，继承Game类
library(beepr)
X11(type="Xlib")
Snake<-setRefClass("Snake",contains="Game",

                   methods=list(

                     # 构造函数
                     initialize = function(name,width,height,debug) {
                       callSuper(name,width,height,debug) # 调父类

                       name<<-"Snake Game"
                     },

                     # 初始化变量
                     init = function(){
                       callSuper()  # 调父类

                       e$step<<-1/width #步长
                       e$dir<<-e$lastd<<-'up' # 移动方向
                       e$head<<-c(2,2) #初始蛇头坐标
                       e$lastx<<-e$lasty<<-2 # 蛇头上一个点坐标
                       e$tail<<-data.frame(x=c(),y=c())#初始蛇尾坐标

                       e$col_furit<<-2 #水果颜色
                       e$col_head<<-4 #蛇头颜色
                       e$col_tail<<-8 #蛇尾颜色
                       e$col_path<<-0 #路颜色
                       e$col_barrier<<-1 #障碍颜色
                     },

                     # 失败检查
                     lose=function(){
                       # head出边界
                       if(length(which(e$head<1))>0 | length(which(e$head>width))>0){
                         fail("Out of ledge.")
                         return(NULL)
                       }

                       # head碰到tail
                       if(m[e$head[1],e$head[2]]==e$col_tail){
                         fail("head hit tail.")
                         return(NULL)
                       }
                     },

                     # 随机的水果点
                     furit=function(){
                       if(length(index(e$col_furit))<=0){ #不存在水果
                         idx<-sample(index(e$col_path),1)

                         fx<-ifelse(idx%%width==0,10,idx%%width)
                         fy<-ceiling(idx/height)
                         m[fx,fy]<<-e$col_furit

                         if(debug){
                           print(paste("furit idx",idx))
                           print(paste("furit axis:",fx,fy))
                         }
                       }
                     },

                     # snake head
                     head=function(){
                       e$lastx<<-e$head[1]
                       e$lasty<<-e$head[2]

                       # 方向操作
                       if(e$dir=='up') e$head[2]<<-e$head[2]+1
                       if(e$dir=='down') e$head[2]<<-e$head[2]-1
                       if(e$dir=='left') e$head[1]<<-e$head[1]-1
                       if(e$dir=='right') e$head[1]<<-e$head[1]+1
                     },

                     # snake body
                     body=function(){
                       if(isFail) return(NULL)

                       m[e$lastx,e$lasty]<<-e$col_path
                       m[e$head[1],e$head[2]]<<-e$col_head #snake
                       if(length(index(e$col_furit))<=0){ #不存在水果
                         e$tail<<-rbind(e$tail,data.frame(x=e$lastx,y=e$lasty))
                         beep(9)
                       }

                       if(nrow(e$tail)>0) { #如果有尾巴
                         e$tail<<-rbind(e$tail,data.frame(x=e$lastx,y=e$lasty))
                         m[e$tail[1,]$x,e$tail[1,]$y]<<-e$col_path
                         e$tail<<-e$tail[-1,]
                         m[e$lastx,e$lasty]<<-e$col_tail

                       }

                       if(debug){
                         print(paste("snake idx",index(e$col_head)))
                         print(paste("snake axis:",e$head[1],e$head[2]))

                       }
                     },

                     # 画布背景
                     drawTable=function(){
                       if(isFail) return(NULL)

                       plot(0,0,xlim=c(0,1),ylim=c(0,1),type='n',xaxs="i", yaxs="i")

                       # 显示背景表格
                       # if(debug){
                       #
                       #   abline(h=seq(0,1,e$step),col="gray60") # 水平线
                       #   abline(v=seq(0,1,e$step),col="gray60") # 垂直线
                       #   # 显示矩阵
                       #   df<-data.frame(x=rep(seq(0,0.95,e$step),width),y=rep(seq(0,0.95,e$step),each=height),lab=seq(1,width*height))
                       #   text(df$x+e$step/2,df$y+e$step/2,label=df$lab)
                       # }
                     },

                     # 根据矩阵画数据
                     drawMatrix=function(){
                       if(isFail) return(NULL)

                       idx<-which(m>0)
                       px<- (ifelse(idx%%width==0,width,idx%%width)-1)/width+e$step/2
                       py<- (ceiling(idx/height)-1)/height+e$step/2
                       pxy<-data.frame(x=px,y=py,col=m[idx])
                       points(pxy$x,pxy$y,col=pxy$col,pch=15,cex=4.4)
                     },

                     # 游戏场景
                     stage1=function(){
                       callSuper()

                       furit()
                       head()
                       lose()
                       body()
                       drawTable()
                       drawMatrix()
                     },

                     # 开机画图
                     stage0=function(){
                       callSuper()
                       plot(0,0,xlim=c(0,1),ylim=c(0,1),type='n',xaxs="i", yaxs="i")
                       text(0.5,0.7,label=name,cex=5)
                       text(0.5,0.4,label="Any keyboard to start",cex=2,col=4)
                       text(0.5,0.3,label="Up,Down,Left,Rigth to control direction",cex=2,col=2)
                       text(0.2,0.05,label="Author:DanZhang",cex=1)
                       text(0.5,0.05,label="http://blog.fens.me",cex=1)
                     },

                     # 结束画图
                     stage2=function(){
                       callSuper()
                       info<-paste("Congratulations! You have eat",nrow(e$tail),"fruits!")
                       print(info)

                       plot(0,0,xlim=c(0,1),ylim=c(0,1),type='n',xaxs="i", yaxs="i")
                       text(0.5,0.7,label="Game Over",cex=5)
                       beep(3)
                       text(0.5,0.4,label="空格键重新开始，p暂停",cex=2,col=4)
                       text(0.5,0.3,label=info,cex=2,col=2)
                       text(0.2,0.05,label="Author:Chenhongwei",cex=1)
                     },

                     # 键盘事件，控制场景切换
                     keydown=function(K){
                       callSuper(K)

                       if(stage==1){ #游戏中
                         if(K == "q") stage2()
                         else {
                           if(tolower(K) %in% c("up","down","left","right")){
                             e$lastd<<-e$dir
                             e$dir<<-tolower(K)
                             stage1()
                             text(0.5,0.3,label=paste("Congratulations!You have eat",nrow(e$tail),"fruits!"),cex=2,col=2)
                           }
                         }
                         return(NULL)
                       }
                       return(NULL)
                     }
                   )
)

snake<-function(){
  game<-Snake$new()
  game$initFields(debug=TRUE)
  game$run()
}

snake()
