function [bot] = testLocalise(bot,map,target)

scans =6;
RobotSize = 13;

modifiedMap = map;

num =500;
particles(num,1) = BotSim;

sensorNoise = 1.363160109; % from robot calibration - 0;%
motionNoise = 0.012088592; % from robot calibration - 0;%
turningNoise = toRadians('degrees', 5.444208795); % from robot calibration - 0;%
turnBot =pi/4;

variance = 60; 

for i = 1:num
    particles(i) = BotSim(modifiedMap);  %each particle should use the same map as the botSim object
    particles(i).randomPose(10); %spawn the particles in random locations
    particles(i).setScanConfig(particles(i).generateScanConfig(scans));
end


maxNumOfIterations = 30;
n = 0;

while(n < maxNumOfIterations)
    n = n+1;
    hold on;
    botScan = bot.ultraScan();

    while (botScan < 0)  %Catch invalid scan results
        bot.turn(turnBot);
        
        for i=1:num
           particles(i).turn(turnBot); 
        end
        botScan = bot.ultraScan(); %get a scan from the real robot.
    end
    
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
    
    botScan = bot.ultraScan();
    difference_mean= zeros(360,1);
    
    for i=1:360    %Check scans of mode and mean estimates at every angle
    Friend_meanScan = Friend_mean.ultraScan();
    difference_mean(i) = norm(Friend_meanScan-botScan);
    Friend_mean.setBotAng(i*pi/180);
    end
    
        figure(3)
        hold off; %the drawMap() function will clear the drawing when hold is off
        particles(1).drawMap(); %drawMap() turns hold back on again, so you can draw the botsn
        for i =1:num
            particles(i).drawBot(3); %draw particle with line length 3 and default color
        end
        Friend_mean.drawBot(30, 'r');
        drawnow;
        
    %% Write code to check for convergence   

    if std(pos) < 5 % convergence threshold
        break; %particles have converged
    end
    
    %% Write code to take a percentage of your particles and respawn in randomised locations (important for robustness)
    mutation_rate=0.01;
    
    for i=1:mutation_rate*num
        particles(randi(num)).randomPose(0);
    end
    %% Write code to decide how to move next
    botScanFront = bot.getDistance_cm();

    while (botScanFront < 0)
         
        bot.turn(turnBot);
        for i=1:num
            particles(i).turn(turnBot);
        end
        
        botScanFront = bot.getDistance_cm();
    end

    if (botScanFront > 30)
        move = botScanFront*0.3; % potentially use small fixed increment
    else
        move = 0;
    end
        
    turn = pi/2;
    
    bot.move(move); %move the real robot. These movements are recorded for marking 
    bot.turn(turn);

    for i =1:num %for all the particles.
        particles(i).move(move); %move the particle in the same way as the real robot
        particles(i).turn(turn); %turn the particle in the same way as the real robot

    end
    
    %% Drawing
    %only draw if you are in debug mode or it will be slow during marking
    figure(3)
    hold off; %the drawMap() function will clear the drawing when hold is off
    particles(1).drawMap(); %drawMap() turns hold back on again, so you can draw the bots
    for i =1:num
        particles(i).drawBot(3); %draw particle with line length 3 and default color
    end
    plot(target(1),target(2),'Marker','o','Color','g');
    drawnow;  
end
end