clear
tic
%杂波仿真参数
N = 16;                        % 阵元个数
M = 8;                        % 相干脉冲数
CNR = 30;                      % 杂噪比
beta = 1;                      % 杂波折叠系数(beta = 2*v*T/d)
sita_a = -90:.9:90.;         % 杂波单元个数   
c=3e8;
f0=1.2e9;
lamda=c/f0;
d=lamda/2;
v=100;
sita = sita_a*pi/180;
[NN N_bin] = size(sita);
%目标参数
sita_t = -25;                  % 目标DOA
omiga_t = 0.4;                 % 目标Doppler
SNR = 0;                       % 信噪比

%空间导向矢量和时间导向矢量
%空间频率和Dopple频率满足 omiga_d = beta * omiga_s
omiga_s = pi*sin(sita);      
omiga_d = beta*omiga_s;       

aN = zeros(N,N_bin);
bN = zeros(M,N_bin);

aN = exp(-j*[0:N-1]'*omiga_s)./sqrt(N);
bN = exp(-j*[0:M-1]'*omiga_d)./sqrt(M);


%目标空时信号
aN_t = zeros(N,1);
bN_t = zeros(M,1);

aN_t = exp(-j*pi*[0:N-1]'*sin(sita_t*pi/180))/sqrt(N);
bN_t = exp(-j*pi*[0:M-1]'*omiga_t)/sqrt(M);

S_t = zeros(M*N,1);
S_t = kron(aN_t,bN_t);

%计算杂波协方差矩阵
R = zeros(M*N,M*N);                     
S = zeros(M*N,N_bin);                   
ksai = 10^(CNR/10)*(randn(1,N_bin)+j*randn(1,N_bin))/sqrt(2);               %服从正态分布的随机幅值，方差为1
for ii = 1:N_bin
    S(:,ii) = kron(aN(:,ii),bN(:,ii));  
    R = R + ksai(ii).*(S(:,ii)*S(:,ii)');       
end

%干扰协方差矩阵，杂噪比为30dB
R = R +eye(M*N);     %CNR = 30dB
inv_R = inv(R);                   %逆矩阵
P_min_var = zeros(N_bin,N_bin);
%求杂波谱
for ii = 1:N_bin
    for jj = 1:N_bin
            SS = kron(aN(:,ii),bN(:,jj));
            P_min_var(ii,jj) = 1./(SS'*inv_R*SS);
    end
end        

%最小方差功率谱
figure(1)
mesh(sin(sita),omiga_d/pi,20*log10(abs(P_min_var)));
title('阵元数N=16, 相干脉冲数M=8');
xlabel('方位余弦');
ylabel('归一化Dopple频率');
zlabel('功率(dB)');
grid on
%空时最优权向量
w_opt = inv(R)*S_t./(S_t'*inv_R*S_t);   
%w_opt = inv(RR)*a_t;

%求最优空时响应
for ii = 1:N_bin
    for jj = 1:N_bin
        SSS = kron(aN(:,ii),bN(:,jj));
        res_opt(ii,jj) = SSS'*w_opt;
    end
end
                      
figure(3)
%[X,Y]=meshgrid(omiga_d/pi,sita_a);
mesh(omiga_d/pi,omiga_d/pi,10*log10(abs(res_opt).^2))
title('阵元数N=16, 相干脉冲数M=8');
xlabel('归一化Dopple频率');
ylabel('方位余弦');
zlabel('功率(dB)');
grid on