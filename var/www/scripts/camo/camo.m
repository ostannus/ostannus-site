

args = argv();
argString  = arg_list{1};



% --- x 1
% 
% 0000|       gridSize                    ~ 01-05
%                                         
% --- x 3                                 
%                                         
% 255|        r                           ~ 06-08
% 127|        g                           ~ 10-12
% 000|        b                           ~ 14-16
%                                         
% 00|         waveBlurIterations          ~ 18-20
% 00|         waveBlurKernelSize          ~ 21-23
% 00.00|      waveBlurStrength            ~ 25-29
% 0.00|       waveHeight                  ~ 31-34
% 0.00|       waveOffset                  ~ 36-39
%                                         
% 00|         rippleBlurIterations        ~ 00-00
% 00|         rippleBlurKernelSize        ~ 00-00
% 00.00|      rippleBlurStrength          ~ 00-00
% 0.00|       rippleHeight                ~ 00-00
% 0.00|       rippleOffset                ~ 00-00
%                                         
% 0.00|       heightThreshold             ~ 00-00
% 
% ---




function fleckMask = getFleckMask(gridSize, blurIterations, poleFrequency, waveHeight, waveOffset, rippleHeight, rippleOffset, heightThreshold)
      
    gridSizeSmall = floor(gridSize./4);
    poles = struct('x', rand([1, poleFrequency]), 'y', rand([1, poleFrequency]), 'v', waveOffset + waveHeight.*(2.*rand([1, poleFrequency])-0.5) );
      
    grid = struct('x', repmat((([1:gridSizeSmall]-1)./(gridSizeSmall-1)),[gridSizeSmall,1]), 'y', repmat((([1:gridSizeSmall]-1)./(gridSizeSmall-1))',[1 gridSizeSmall]));
      
    x = [-1+grid.x, grid.x, 1+grid.x; -1+grid.x, grid.x, 1+grid.x; -1+grid.x, grid.x, 1+grid.x];
    y = [-1+grid.y, -1+grid.y, -1+grid.y; grid.y, grid.y, grid.y; 1+grid.y, 1+grid.y, 1+grid.y];
      
    vv = repmat(poles.v,[1,3*3]);
      
    xx = [-1+poles.x, poles.x, 1+poles.x, -1+poles.x, poles.x, 1+poles.x, -1+poles.x, poles.x, 1+poles.x];
    yy = [-1+poles.y, -1+poles.y, -1+poles.y, poles.y, poles.y, poles.y, 1+poles.y, 1+poles.y, 1+poles.y];
    
    [xq,yq,vq] = griddata(xx,yy,vv,x,y,'nearest');
    
    voronoiMap = imresize(repmat(vq((gridSizeSmall):(2*gridSizeSmall),(gridSizeSmall+1):(2*gridSizeSmall)),[1,1,3]),[gridSize, gridSize]);
    
    lowFrequencyMap = voronoiMap(:,:,1);
    
    for i = 1:waveBlurIterations
        lowFrequencyMap = imfilter(lowFrequencyMap,fspecial('gaussian',20,10),'symmetric');
    end
    
    staticMap = rippleOffset + rippleHeight.*(2.*rand([gridSize, gridSize])-0.5);
    
    highFrequencyMap = staticMap;
    for i = 1:blurIterations.lowFrequency
        highFrequencyMap = imfilter(highFrequencyMap,fspecial('gaussian',5,1),'symmetric');
    end
    
    fleckMask = logical((highFrequencyMap+lowFrequencyMap(:,:,1)) > heightThreshold);
    
end




gridSize = 512;

colours = struct('primary',[0.3,0.1,0.0],'secondary',[0.4,0.2,0.0],'tertiary',[0.2,0.5,0.0]);

blurIterations = struct('lowFrequency',10,'highFrequency',5);

poleFrequency = 200;


fleckMask = struct('primary',[],'secondary',[],'tertiary',[]);

fleckMask.primary = logical(ones([gridSize, gridSize, 3]));
fleckMask.secondary = repmat(getFleckMask(gridSize, blurIterations, poleFrequency),[1, 1, 3]);
fleckMask.tertiary = repmat(getFleckMask(gridSize, blurIterations, poleFrequency),[1, 1, 3]);


fleckMap = struct('primary',[],'secondary',[],'tertiary',[]);

fleckMap.primary = fleckMask.primary .* repmat(reshape(colours.primary,[1,1,3]),[gridSize, gridSize, 1]);
fleckMap.secondary = fleckMask.secondary .* repmat(reshape(colours.secondary,[1,1,3]),[gridSize, gridSize, 1]);
fleckMap.tertiary = fleckMask.tertiary .* repmat(reshape(colours.tertiary,[1,1,3]),[gridSize, gridSize, 1]);


fleckImage = double(ones([gridSize, gridSize, 3]));

fleckImage(fleckMask.primary) = fleckMap.primary(fleckMask.primary);
fleckImage(fleckMask.secondary) = fleckMap.secondary(fleckMask.secondary);
fleckImage(fleckMask.tertiary) = fleckMap.tertiary(fleckMask.tertiary);

imwrite(fleckImage, '/var/www/html/camo.jpg');




