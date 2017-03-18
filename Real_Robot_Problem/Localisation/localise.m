function [botSim] = localise(botSim,map,target)
%This function returns botSim, and accepts, botSim, a map and a target.
%LOCALISE Template localisation function

%% setup code

scans =6;
RobotSize = 13 ;
%you can modify the map to take account of your robots configuration space
modifiedMap = map; %you need to do this modification yourself
% botSim.setMap(modifiedMap);
% 
% variance = 60; 

num =600;
particles(num,1) = BotSim;

%Particle Filter Localisation Function

sensorNoise = 1.363160109; % from robot calibration - 0;%
motionNoise = 0.012088592; % from robot calibration - 0;%
turningNoise = toRadians('degrees', 5.444208795); % from robot calibration - 0;%
turnBot =pi/4;

%generate some random particles inside the map
for i = 1:num
    particles(i) = BotSim(modifiedMap, [sensorNoise, motionNoise, turningNoise],0);  %each particle should use the same map as the botSim object
    particles(i).randomPose(13); %spawn the particles in random locations
    particles(i).setScanConfig(particles(i).generateScanConfig(scans));
end

%% Localisation code
maxNumOfIterations = 30;
n = 0;

% to scan in 30 directions
botSim.setScanConfig(botSim.generateScanConfig(scans));

while(n < maxNumOfIterations) %particle filter loop
    n = n+1; %increment the current number of iterations
    hold on;
    botScan = botSim.ultraScan(); %get a scan from the real robot.
    
    while (botScan < 0)  %Catch invalid scan results
        bot.turn(turnBot);
        
        for i=1:num
           particles(i).turn(turnBot); 
        end
        botScan = bot.ultraScan(); %get a scan from the real robot.
    end
    
    %% Write code for updating your particles scans
    weight = zeros(num,1);
    sub = zeros(scans,num);
    p_w = zeros(scans,1);
    
    for i=1:num
        if particles(i).insideMap() ==0
            particles(i).randomPose(0);
        end
        
        [dist , crossPnt] = particles(i).ultraScan();
        distCPointMatrix = dist;
        
        for j=1:scans
            %% Write code for scoring your particles  
            temp = circshift(distCPointMatrix,j);
            sub(j,i) = sqrt(sum((temp-botScan).^2));
            p_w(j) = (1/sqrt(2*pi*variance))*exp(-((sub(j,i))^2/(2*variance)));
        end
        [max_weight, max_position] = max(p_w);
        %particle orintation
        particles(i).setBotAng(mod((particles(i).getBotAng() + max_position*2*pi/scans), 2*pi)); 
        weight(i) = max_weight;
    end 
    
    w_distribution = weight./sum(weight);
    %% Write code for resampling your particles
    
    for i = 1:num
        j = find(rand() <= cumsum(w_distribution),1);
        particles(i).setBotPos(particles(j).getBotPos());
        particles(i).setBotAng(particles(j).getBotAng());
    end
    
    %particle's positions and angles
    ang = zeros(num,1);
    pos = zeros(num, 2);   
   
    for i = 1:num
        pos(i,:) = particles(i).getBotPos();
        ang(i)=particles(i).getBotAng();
    end
    
    Friend_mean = BotSim(map);
    Friend_mean.setScanConfig(Friend_mean.generateScanConfig(scans));
    Friend_mean.setBotAng(mean(ang));
    Friend_mean.setBotPos(mean(pos));
    
    botScan = botSim.ultraScan();
    difference_mean= zeros(360,1);
    
    for i=1:360    %Check scans of mode and mean estimates at every angle
    Friend_meanScan = Friend_mean.ultraScan();
    difference_mean(i) = norm(Friend_meanScan-botScan);
    Friend_mean.setBotAng(i*pi/180);
    end
    
    %find the best orientation for the mean estimate
    [min_diff_mean, min_pos_mean] = min(difference_mean);
    Friend_mean.setBotAng(min_pos_mean*pi/180); 
    Friend = Friend_mean;
    
    %% Write code to check for convergence   

    if std(pos) < 2.3 % convergence threshold
        break; %particles have converged
    end

    %% Write code to take a percentage of your particles and respawn in randomised locations (important for robustness)	
    mutation_rate=0.01;
    
    for i=1:mutation_rate*num
        particles(randi(num)).randomPose(0);
    end
    
    %% Write code to decide how to move next

    [maxDistance, maxIndex] = max(botScan);
    cover = maxDistance*0.9*rand(); %random maximum distance
    turn = (maxIndex-1)*2*pi/scans; %orientate towards the max distance        
    
    botSim.turn(turn);        
    botSim.move(cover); %move the real robot. These movements are recorded for marking 

    for i =1:num %for all the particles.
          particles(i).turn(turn);
          particles(i).move(cover);
    end
    
    %% Drawing
    %only draw if you are in debug mode or it will be slow during marking
    if botSim.debug()
        hold off; %the drawMap() function will clear the drawing when hold is off
        botSim.drawMap(); %drawMap() turns hold back on again, so you can draw the bots
        botSim.drawScanConfig();
        botSim.drawBot(30,'r'); %draw robot with line length 30 and green
        scatter(crossPnt(:,1),crossPnt(:,2),'marker','o','lineWidth',3);
        for i =1:num
            particles(i).drawBot(3); %draw particle with line length 3 and default color
        end
        drawnow;
    end
end

%% Path Planning

%% Plot the chosen path
LocationRobot = Friend.getBotPos();
while LocationRobot(1) > target(1) + 0.002 || LocationRobot(1) < target(1) - 0.002 || LocationRobot(2) > target(2) + 0.002 || LocationRobot(2) < target(2) - 0.002
    
    [angle, distance] = Dijkstra(LocationRobot, target, map);
    RobotDirection = Friend.getBotAng();
    angleRadian = (angle) * pi / 180; 

    if botSim.debug()
        botSim.drawBot(10,'red');
        Friend.drawBot(10,'black');
    end
   
    botSim.turn(pi-RobotDirection+angleRadian);
    Friend.turn(pi-RobotDirection+angleRadian);
    
    botScan = botSim.ultraScan();
    
    %if robot moves beyond wall
    if botScan(1)<= distance;
        %[botSim, Friend] = ParticleFilter(botSim, modifiedMap,num, maxNumOfIterations, scans);
        localise(botSim, modifiedMap, target);
        break;
    else
        botSim.move(distance);
        Friend.move(distance);
    end
    
    botScan = botSim.ultraScan();
    FriendScan = Friend.ultraScan();
    
    %calculate the difference between the ghost robot and the real robot
    difference = (sum(FriendScan-botScan)/scans);
    threshold = 3;
    
    %Run particle filter if the difference between the ultrasound values is
    %above the threshold
    if (abs(difference) > threshold)
%         [botSim, Friend] = ParticleFilter(botSim, modifiedMap,num, maxNumOfIterations, scans);
        localise(botSim, modifiedMap, target);
        break;
    end
    
    %Estimated robot location
    LocationRobot = Friend.getBotPos();
    if botSim.debug()
        pause(1);
    end
end

%% Drawing
%only draw if you are in debug mode or it will be slow during marking
if botSim.debug()
    figure(1)
    hold off; %the drawMap() function will clear the drawing when hold is off
    botSim.drawMap(); %drawMap() turns hold back on again, so you can draw the bots
    botSim.drawBot(30,'g'); %draw robot with line length 30 and green
    Friend.drawBot(30,'b'); %draws the mean ghost bot with line length 30 and red
    drawnow;
end
end
