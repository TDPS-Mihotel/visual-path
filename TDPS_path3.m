%高斯滤波+梯度计算

%TDPS_path1选取图像中前num位梯度最大点以确定路径边缘方向，
%再将边缘方向转置90度得到路径方�?

%TDPS_path2较TDPS_path1由直接地选取前num位梯度最大点改为
%对一定阈值以上的梯度点的方向进行直方图统计，取点数最多的方向作为边缘方向�?
%部分改善了路面污点和图像噪声对方向判别的干扰

%TDPS_path3较TDPS_path2将图像在排方向上等分为n段，
%分别求每段内的最多方向，再将n段求平均值以改善弯道处方向判别�?�能
%并且优化了语句，改善运算速度
clc;clear all;close all;
A=imread('D:\image_processing_cache\path5.png');

W = fspecial('gaussian',[5,5],1); 
B = imfilter(A(:,:,1), W, 'replicate');
[Gmag, Gdir] = imgradient(B,'prewitt');%高斯滤波+求梯�?

piece=4;%图像分割段数
cuttedgmag=size(Gmag,1)-rem(size(Gmag,1),piece);%将图像裁剪为分割段数的整数�??
newGmag=Gmag(1:cuttedgmag,:);%裁剪后的梯度�?
newGdir=Gdir(1:cuttedgmag,:);%裁剪后的梯度方向
newsize=cuttedgmag/piece;%每段图像的宽�?

%将分割后的图像装入一个三维矩阵中，方便后面操�?
Gmags=zeros([newsize size(Gmag,2) piece]);
for i=1:1:piece
    Gmags(:,:,i)=newGmag(1+(i-1)*newsize:i*newsize,:);
end
%imshowpair(A,Gmags(:,:,1),'montage');

finalcourse=zeros([piece 1]);
for k=1:1:piece %各段图像
    course=zeros([360 1]); %用于统计高于某阈值的梯度方向即像素点个数
    rdir=0;%用于记录每一符合要求点的梯度方向
    
    for i=1:1:size(Gmags,1)
      for j=1:1:size(Gmags,2)%扫描图像 
        if Gmags(i,j,k)>15 %阈�??
          rdir=floor(newGdir(i+(k-1)*newsize,j)); %记录方向，取�?
          if rdir<=0
            course(rdir+360,1)=course(rdir+360,1)+1; %�?-179�?+180度的梯度统计存放�?1-360的数组中
          elseif rdir>0
            course(rdir,1)=course(rdir,1)+1;
          end  
          %course中角度与矩阵序号的对应以及后面每象限maxdq角度与矩阵序号的对应
          %1.....<-.......1       1.....<-.......1
          %.              .       .              .
          %.              .       90....<-......90 
          %90....<-......90       ----------------
          %.              .       1.....<-......91
          %.              .       .              .
          %180...<-.....180       90....<-.....180
          %---------------------------------------      
          %181...<-...(-179)      1.....<-...(-179)
          %.              .       .              .
          %.              .       90....<-....(-90)
          %270...<-....(-90)      ----------------
          %.              .       1.....<-....(-89)
          %.              .       .              .
          %360...<-.......0       90....<-.......0
        end
      end
    end
 
    maxdq=zeros([4 1]);%选取各象限符合条件的像素点最多的方向
    [val1 maxdq1]=max(course(1:90,1));
    [val2 maxdq2]=max(course(91:180,1));
    [val3 maxdq3]=max(course(181:270,1));
    [val4 maxdq4]=max(course(271:360,1));
    
    maxdq(1)=maxdq1;
    maxdq(2)=maxdq2+90;
    maxdq(3)=maxdq3-180;
    maxdq(4)=maxdq4-90;
    
    for i=1:1:4 %将边缘方向按左右转置90度得到路径方�?
       if maxdq(i)<=90 && maxdq(i)>=-90
         maxdq(i)=maxdq(i)+90;
       elseif maxdq(i)>90
         maxdq(i)=maxdq(i)-90;
       elseif maxdq(i)<-90
         maxdq(i)=maxdq(i)+270;
       end
    end
    finalcourse(k)=mean(maxdq);%该段图像的最总方�?    
end
 
avefinalcourse=mean(finalcourse);%图像�?终方向为每段总方向求均�??


%作图
pathdx=cosd(avefinalcourse);
pathdy=sind(avefinalcourse);

subplot(1,2,1);
hold on;
imshow(A);
hold off
subplot(1,2,2);
compass(pathdx,pathdy);

title({['course=',num2str(avefinalcourse)];['correction=',num2str(90-avefinalcourse)]});