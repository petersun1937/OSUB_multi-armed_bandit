
setup = "sim7";

switch setup
    case 'sim1'
        % 1st setup
        Rate = [2 3 5 6 9];
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        AvgThruput = [0.198 0.54 1 0.78 0.405];
        TranProbb = 0.9;
    case 'sim2'
       % 2nd setup
        Beam = [1 2 3 4 5 6 7 8 9]; 
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        AvgThruput = [0.0198 0.216 5.44 1.32 0.5225];
        PredProb = 1;
        TranProbr = 1;  
    case 'sim3'
       % 3rd setup (w/ beam selection)
        Rate = [2 3 5 6 9]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
    case 'sim4'
       % 4th setup (vertically not unimodal)
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.15 0.3 0.45 0.6 0.75];
        TranProbr = [0.99 0.8 0.5 0.38 0.2];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim5'
       % 5th setup (vertically not unimodal)
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.15 0.3 0.45 0.6 0.75];
        TranProbr = [0.99 0.8 0.4 0.35 0.2];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.1:0.2:0.9 0.7:-0.2:0.1];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim6'
       % 6th setup (trans prob peaks at opt beam)
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.01 0.05 0.15 0.3 0.9 0.3 0.15 0.05 0.01];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim7'
       % 7th setup
        Rate = [2 3 5 6 8]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        TranProbr = [0.99 0.9 0.85 0.15 0.05];
        
        Beam = [1 2 3 4 5 6 7 8 9];
        TranProbb = [0.01:0.01:0.05 0.15 0.3 0.9 0.3 0.15 0.05:-0.01:0.01];
        
        TransProb = TranProbr'.*TranProbb;
        AvgThruput = (PredProb.*TranProbr)'.*TranProbb;
        
    case 'sim8'
       % 8th setup (realistic?)
        Rate = [2 3 5 8 10]; 
        
        PredProb = [0.01 0.08 0.8 0.88 0.95];
        
        
        Capacity = [ones(1,7) 2 3 8 10 8 3 2 ones(1,7)];
        TProb = [1 0.99 0.95 0.92 0.9]'*[ones(1,7)*0.5 0.7 0.8 0.9 0.99 0.9 0.8 0.7 ones(1,7)*0.5];
        
        TransProb = Rate'*ones(1,length(Capacity));
        
        TransProb = double(TransProb<=Capacity);
        TransProb(TransProb==0) = 0.01;
        
        TransProb = TransProb.*TProb;
        AvgThruput = PredProb'.*TransProb;
        
        %figure
        %surf(1:length(Capacity), 1:length(Rate), TransProb)
        %figure
        %surf(1:length(Capacity), 1:length(Rate), AvgThruput)
end


[A,Sl,l] = Median_Elim(1,0.1,AvgThruput);