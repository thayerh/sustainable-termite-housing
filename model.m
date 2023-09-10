%Initializing Variables

% Hard code mound

% Size of simulation grid
moundSizeX = 100; 
moundSizeY = 100;

% Initialize sim grid
mound = ones(moundSizeX, moundSizeY);

for x = 1:100
    for y = (1:100)
         if mound(y, x) == 1
             mound(y, x) = 2; 
             %Blue to symbolize mound structure
         end
         if (48 <= x && x <= 52)
             mound(y,x) = 10;
             %chimney tunnel open space
         end
         if  rem(y,5) == 0
             mound(y,x) = 10;
             %Symbolize tunnels
         end 
         if 0 <= x && x <= 20 || 80 <= x && x <= 100
             mound(y,x) = 1;
             %Symbolize outside
         end
         if  (85 <= y && y <= 100) 
             mound(y,x) = 6.2;
             % to symbolize underground (where cool water vapor is store)
         end 
         if ((y == 90) && (x >= 15 && x <= 85)) || ((x == 15 || x == 85) && (y <= 90 && y >= 85))
             mound(y,x) = 10;
             % Symbolize pores that reach from underground to find cool
             % air
         end
         if  (80 <= y && y <= 100) && (30 <= x && x <= 70)
             mound(y,x) = 9;
             % to symbolize colony (where heat is produced)   
         end
    end 
end


%% initialization 
N=20; %The length of the tunnel 
x=0:N-1; %The positions along the tunnel 
Tair=40; %Air temperature 
Tsoil=20; %Soil temperature 
Tinf=Tsoil*ones(N,1);
t_end=10000; %The final time of the simulation 
T=Tair*ones(N,t_end); %Temperature at diffrent positions (N) and times

%Thermal Properties of air that determine how fast its 
%temperature changes 
alpha=0.01; 

%The heat convection at soil-air inteface that controls how fast the air
%cools down through heat exchange with the soil 
h=0.1;

q=0;%Flow rate of air 

eps=5*sqrt(alpha); % Air is not a complete insulator 
%so we asssume some heat conduction coefficeint for it (eps) 

beta=0.01; %the prefactor that relates air flow rate to the difference 
%between the air and the tunnel average temperature

%% Time loop begins 
for t=1:t_end
    m=2:N-1; 
    q=beta*(Tair-mean(T(:,t)));
    s=(T(m-1,t)-2*T(m,t)+T(m+1,t));
    T(m,t+1)=T(m,t)+...
        alpha*(s*eps-h*(T(m,t)-Tinf(m))+q*(T(m,t)-T(m-1,t)));
end

%% Show heat map
% Calculate distance from the colony and use T to assign a heat for each
% point at distance d, for each time t

% Green represents cooler air, red represents hotter air

temp = mound; % Use a copy of mound to make sure that only air pockets are evaluated (air in mound is air in temp)
maxD = 20; % Max distance calculated by T
minD = 1; % Min distance calculated by T

colormap turbo;

for t = 10:1000
    for x = 1:100
        for y = 1:100
            if mound(x,y)==10 %if space for temp flow
                d = abs(floor(sqrt(((y-50)*(y-50)/3) + ((x-80)*(x-80)) / 25)));
                if d > maxD % Adjust in case distance is more than T can handle
                    d = 20;
                end
                if d < minD % Adjust in case distance is less than T can handle
                    d = 1;
                end
                %distance from colony
                newcolor = (T(d,t) / 4);
                % Adjusted to make bigger color difference
                temp(x,y) = newcolor; 
                %assign color off of temp @ distance
               
            end
        end
    end
    if t == 10
        imagesc(temp);
        caxis([0 11]);
        pause(2)
    end
    imagesc(temp);
    caxis([0 11]);
    pause(0.00001)
end
