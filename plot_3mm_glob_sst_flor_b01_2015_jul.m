clear;
clf;
%figure;
%load /archive/x1y/season/HadISST_chi2_15mons.1950.month.mat;
%load /archive/x1y/sicp/data/glob.sst.3mm.skill.v31.apr.mat;
%load /archive/x1y/sicp/data/glob.sst.3mm.skill.v31.oct.mat;
%load /archive/x1y/sicp/data/sst.monthly.skill.flor.b01.jul.mat;
%%start_month = yyyymm-yyyy2mm2;
%% yyyyymm: starting month, year
%%% yyyymm2: 12 months later
time_start = ['201607'];
time_end = ['201706'];
file_clm = ['/archive/rgg/CM2.5/CM2.5_FLOR_B01_p1_ECDA_2.1Rv3.1_0107/maproom/ocean_month_ens_01-12.198207-201206.temp.climo.nc'];
temp_clm = getnc(file_clm,'temp');
sst_clm = squeeze(temp_clm(:,1,:,:));  %%% the first layer is surface
file_rt = ['/archive/rgg/CM2.5/CM2.5_FLOR_B01_p1_ECDA_2.1Rv3.1_01072016/pp_ensemble/ocean_month/ts/monthly/1yr/ocean_month.' ...
    time_start '-' time_end '.temp.nc'];
temp = getnc(file_rt,'temp');
sst_rt = squeeze(temp(:,1,:,:));
ano_2014_1mm = sst_rt - sst_clm;
lat_obs = getnc(file_rt,'yt_ocean');
lon_obs = getnc(file_rt,'xt_ocean');

%%% anomalies of the 3-month chunk
dm = size(ano_2014_1mm);
for i=1:10;
  tmp = squeeze(mean(ano_2014_1mm(i:i+2,:,:)));
  ano_2014_3mm(i,:,:) = tmp;
end
ano_2014 = ano_2014_3mm;
% Blue shades
b1=[0 0 255; 110 110 255; 160 160 255;210 210 255]/255;
b1=[84 39 143;0 0 255; 50 136 189; 215 215 255;230 230 255]/255;
%white shades
b2=[100 255 200; 255 255 255; 200 255 100]/255;
%red shades
b3=[255 210 210; 255 160 160; 255 110 110; 255 50 50; 125 0 0]/255;
% orenge and red shades
bred=[1.0 1 0.75; 1.0 0.75 0; 1.0 0.5 0.0; 1.0 0.25 0; 0.85 0.1 0.25];
%bred=[255 255 178; 254 204 92; 253 141 60; 240 59 32; 189 0 38]/255;
%Gray shades
b4=[200 200 200;150 150 150;80 80 80; 10 10 10]/255;
bw=[255 255 255]/255;
bora=[1.0 1.0 0.0; 1.0 0.75 0.0];
bred=[1.0 0.5 0.0; 1.0 0.25 0.0; 1.0 0 0];
bora=[1.0 231/255 186/255;1.0 1.0 0.0; 1.0 0.75 0.0;184/255 134/255 11/255];
bred=[1.0 0.5 0.0; 1.0 0.25 0.0;0.75 0 0; 0.5 0 0];
b=[b1(2:3,:);b2(2,:);b3(1:4,:)];
bb=[bora;bred];
%mix=[b1(1:3,:);b3(2:5,:)];
bblu=[10 10 255;70 70 255; 120 120 255;180 180 255; 230 230 255]/255;
mix=[bblu(2:3,:);bw;bw;bb(1:8,:)];
mix=[bw;bb(1:8,:)];
%% NCEP CFS color
ncep=[100.0 100.0 100.0;40.0 100.0 0.0;30.0 55.0 0.0;60.0 90.0 100.0; ...
       30.0 80.0 100.0;20.0 30.0 100.0;30.0 30.0 50.0;95.0 76.0 5.0;  ...
       90.0 30.0  5.0;90.0 10.0 0.0;60.0 0.0 0.0]/100;
factor = [0.0 0.15 .25 .3 0.4 0.5 0.6 0.61 0.8 0.9 1.0];
%%% anomaly color
RNB = [40.   0.  0.; ...
      100.   0.  0.;  ...
      100   45.   45. ;  ...
       100.   75.  0.;  ...
       100.  100.   100.;  ...
       45.  70.    100.; ...
       25.    50.    100.; ...
       10     10     100;  ...
       0.    20.    40.]/100;

lon_obs1=lon_obs;
lon2=lon_obs1;
lat2=lat_obs;

%subplot(2,2,1)
load coast;                                     % GET MATLAB COAST DATA
%[linelat,linelon] = maptriml(lat,long,[lat2(1) lat2(end)],[lon2(1) lon2(end)]); % JUST NH LAND

%shifting longtitudes for displaying land
ish=find(lon2 <= 22.0 & lon2 >= 21.0);
%ish=1;
lon3=[lon2(ish:end)-360; lon2(1:ish-1)];

elats   = lat2;
elons   = lon2;
elatmat = ones(length(elons),1)*elats';  % Matrix of latitudes  of grid edges
elonmat = elons*ones(1,length(elats));  % Matrix of longitudes of grid edges
lonlim = [lon2(1) lon2(end)];
latlim = [-89 89];
%% nonlinear contour
nsize=size(ano_2014);
ano_2014_non = ano_2014;
p1=0.25;p2=0.5;p3=1.0;p4=2.0;p5=3.0;
ind_p1 = find(ano_2014 <p2 & ano_2014 >= p1);
ind_p2 = find(ano_2014 <p3 & ano_2014 >= p2);
ind_p3 = find(ano_2014 <p4 & ano_2014 >= p3);
ind_p4 = find(ano_2014 <p5 & ano_2014 >= p4);
ind_p5= find(ano_2014 >= p5);
ano_2014_non(ind_p1) = 0.5;
ano_2014_non(ind_p2) = 1.0;
ano_2014_non(ind_p3) = 1.5;ano_2014_non(ind_p4) = 2.;
ano_2014_ano(ind_p5)=2.5;
ind_m1 = find(ano_2014 <-p1 & ano_2014 >= -p2);
ind_m2 = find(ano_2014 <-p2 & ano_2014 >= -p3);
ind_m3 = find(ano_2014 <-p3 & ano_2014 >= -p4);
ind_m4 = find(ano_2014 <-p4 & ano_2014 >= -p5);
ind_m5 = find(ano_2014 <-p5);
ano_2014_non(ind_m1) = -0.5;
ano_2014_non(ind_m2) = -1.;
ano_2014_non(ind_m3) = -1.5;ano_2014_non(ind_m4) = -2.;
ano_2014_non(ind_m5)=-2.5;
ind_0 = find(ano_2014 < p1 & ano_2014 >= -p1);
ano_2014_non(ind_0) = 0.;
%lonlim=[ -10 lon2(end)];
ratio_x = 1.;
%%% panel size
xs=0.4; ys=0.27;
ytick=[-60 -30 0 30 60];
fh1=subplot('position',[0.1 0.675 xs ys]);
%load topo;
proj_name='mercator';
proj_name='eqdcylin';

proj_name='Equidistant cylindrical';
m_proj(proj_name,'long',[lonlim(1) lonlim(2)],'lat',[latlim(1) latlim(2)]);

colormap(RNB(end:-1:1,:));
cv1=-2.25;cv2=2.25;
tmp1=squeeze(ano_2014_non(1,:,:));
tmp2=double(tmp1);
%tmp0=shiftx(tmp2,ish);
%v=[-1.8 -1.4 -0.6 -.4 -0.2 0 0.2 .4 .6 .8 1.8];

h=m_pcolor(elonmat,elatmat,tmp2(:,:)');
set(h,'EdgeColor','none')
hold on
m_grid('xticklabels',[],'ytick',ytick);
%m_grid;
m_coast('color','k');
set(gca,'DataAspectRatio',[ratio_x 1 1])
caxis([cv1 cv2]);
m_text(40,-75,'JJA','BackgroundColor',[0.95 0.95 0.95])

fh2=subplot('position',[0.1 0.4 xs ys]);

%colormap(mix);
tmp1=squeeze(ano_2014_non(2,:,:));
%tmp2=[tmp1(:,181:360) tmp1(:,1:180)];
tmp2=double(tmp1);
%tmp0=shiftx(tmp2,ish);
h=m_pcolor(elonmat,elatmat,tmp2(:,:)');
set(h,'EdgeColor','none')
hold on
m_grid('xticklabels',[],'ytick',ytick);
%m_grid;
m_coast('color','k');
set(gca,'DataAspectRatio',[ratio_x 1 1])
caxis([cv1 cv2]);
m_text(40,-75,'ASO','BackgroundColor',[0.95 0.95 0.95])
%m_text(-300,40,'I.C.: 1OCT','BackgroundColor',[0.95 0.95 0.95])

fh3=subplot('position',[0.1 0.125 xs ys]);

%colormap(mix);
tmp1=squeeze(ano_2014_non(3,:,:));

%tmp2=[tmp1(:,181:360) tmp1(:,1:180)];
tmp2=double(tmp1);
%tmp0=shiftx(tmp2,ish);
h=m_pcolor(elonmat,elatmat,tmp2(:,:)');
set(h,'EdgeColor','none')
hold on
%m_grid('xticklabels',[]);
m_grid('ytick',ytick);
m_coast('color','k');
set(gca,'DataAspectRatio',[ratio_x 1 1])
caxis([cv1 cv2]);
m_text(40,-75,'SON','BackgroundColor',[0.95 0.95 0.95])



fh4=subplot('position',[0.51 0.675 xs ys]);
%load topo;
tmp1=squeeze(ano_2014_non(4,:,:));

%tmp2=[tmp1(:,181:360) tmp1(:,1:180)];
tmp2=double(tmp1);
%tmp0=shiftx(tmp2,ish);
%v=[-1.8 -1.4 -0.6 -.4 -0.2 0 0.2 .4 .6 .8 1.8];

h=m_pcolor(elonmat,elatmat,tmp2(:,:)');
set(h,'EdgeColor','none')
hold on
m_grid('xticklabels',[],'yticklabels',[],'ytick',ytick);
%m_grid;
m_coast('color','k');
set(gca,'DataAspectRatio',[ratio_x 1 1])
caxis([cv1 cv2]);
m_text(40,-75,'OND','BackgroundColor',[0.95 0.95 0.95])

fh5=subplot('position',[0.51 0.4 xs ys]);

tmp1=squeeze(ano_2014_non(5,:,:));
tmp2=double(tmp1);
%tmp0=shiftx(tmp2,ish);
%v=[-1.8 -1.4 -0.6 -.4 -0.2 0 0.2 .4 .6 .8 1.8];
v=[0 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 0.9];
h=m_pcolor(elonmat,elatmat,tmp2(:,:)');
set(h,'EdgeColor','none')
hold on
m_grid('yticklabels',[],'xticklabels',[],'ytick',ytick);
%m_grid;
m_coast('color','k');
set(gca,'DataAspectRatio',[ratio_x 1 1])
caxis([cv1 cv2]);
m_text(40,-75,'NDJ','BackgroundColor',[0.95 0.95 0.95])


fh6=subplot('position',[0.51 0.125 xs ys]);

tmp1=squeeze(ano_2014_non(6,:,:));

tmp2=double(tmp1);
%tmp0=shiftx(tmp2,ish);
h=m_pcolor(elonmat,elatmat,tmp2(:,:)');
set(h,'EdgeColor','none')
hold on
m_grid('yticklabels',[],'ytick',[-90 -60 -30 0 30 60 90]);
%m_grid;
m_coast('color','k');
set(gca,'DataAspectRatio',[ratio_x 1 1])
caxis([cv1 cv2]);
m_text(40,-75,'DJF','BackgroundColor',[0.95 0.95 0.95])

%h=colorbar('Location','Southoutside','XLim',[cv1 cv2],'XTick',[ -2.25 -1.75 -1.25 -0.75 -0.25 0.25 0.75 1.25 1.75 2.25]);
%h=colorbar('Location','Southoutside','XLim',[cv1 cv2]);

xticklabel_non = [' -3  ';' -2  ';' -1  ';'-0.5 ';'-0.25';' 0.25';'  0.5';'  1  ';'  2  ';'  3  '];
h=colorbar('Location','Southoutside','XLim',[cv1 cv2],'XTick',[-2.25 -1.75 -1.25 -0.75 -0.25 0.25 0.75 1.25 1.75 2.25], ...
           'XTickLabels',xticklabel_non);
set(h,'Position',[0.15 0.065 0.7 0.015 ]);
%textm(-10,200,'\rho^2=0.81')
%orient landscape
%tightmap
ax = axes('position',[0,0,1,1],'visible','off');
  % tx = text(0.46,0.825,'Prec ');
  % set(tx,'fontweight','bold','fontsize',12);
  % tx = text(0.46,0.15,'DJF');
  % set(tx,'fontweight','bold','fontsize',12);
   tx = text(0.175,0.96,'GFDL FLOR-B01 Forecast of SST Anom IC=201507');
   set(tx,'fontweight','bold','fontsize',12);
   %tx = text(0.8,0.45,'CM2.5');
   %set(tx,'fontweight','bold','fontsize',14);
   
   set(gcf, 'Renderer', 'painters')

