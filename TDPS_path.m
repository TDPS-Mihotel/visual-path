clc;clear all;close all;
img=imread('C:\Users\Œƒ≤©\Desktop\s–ÕÕ‰µ¿3.0\l2.jpg');
A=rgb2gray(img);

%% Image blurring
n=16;
height=size(A,1)-mod(size(A,1),n);
length=size(A,2)-mod(size(A,2),n);
A=A(1:height,1:length);

for i=1:n:height
    for j=1:n:length
        k=mean(A(i:i+n-1,j:j+n-1),'all');
        map=repmat(k,[n n]);   
        A(i:i+n-1,j:j+n-1)=map; 
    end
end

%% Image division
piece=8;
cuttedC=size(A,1)-rem(size(A,1),piece);
newC=A(1:cuttedC,:);
newsize=cuttedC/piece;

A=zeros([newsize size(A,2) piece]);
for i=1:1:piece
    A(:,:,i)=newC(1+(i-1)*newsize:i*newsize,:);
end

%% Geometric center calculation
threshold=70;

for k=1:1:piece
    [locationx,locationy]=find(A(:,:,k)<threshold); 
    fy(k)=floor(mean(locationx))+(k-1)*newsize;
    fx(k)=floor(mean(locationy));
end

%% Angle calculation
% for i=1:1:piece-1
%    diff(1,i)=fx(i)-fx(i+1);
%    diff(2,i)=fy(i+1)-fy(i);
% end
diffx=fx(1)-fx(piece);
diffy=fy(piece)-fy(1);

% pathx=mean(diff(1,:));
% pathy=mean(diff(2,:));
degree=atan2d(diffy,diffx);

%% Visualization
subplot(1,2,1);
hold on;
imshow(img);
plot(fx(:),fy(:),'x');
hold off;
subplot(1,2,2);
compass(diffx,diffy);
title({['course=',num2str(degree)];['correction=',num2str(90-degree)]});