%==================================================================
%======================= leaf criteria votes ======================
%==================================================================

% Minimisation
pref(minimization,Alt1,Alt2):-  
    has(Alt1, nbData, N1), 
    has(Alt2, nbData, N2), 
    N2>=N1.

has(Alt,nbData, N):- 
    N = #count{ Data : has(Alt, requiredData, Data)}, 
    alt(Alt).

%Sensitivity
pref(sensitivity, Alt1, Alt2):-  
    has(Alt1, nbSensitiveData, N1), 
    has(Alt2,nbSensitiveData, N2), 
    N2>=N1.

has(Alt, nbSensitiveData, N):- 
    N = #count{ Data : has(Alt, requiredData, Data), 
    has(Data, category, sensitiveData)}, 
    alt(Alt).
% knowledge about sensitive data categories
has(politicalBelief, category, sensitiveData).
has(opinionData, category, sensitiveData).


%Scale and Complexity
pref(scaleComplexity,Alt1,Alt2):- 
    has(Alt1, processType, Type1),
     has(Alt2, processType, Type2),
     rankAux(Type1, R1),
     rankAux(Type2, R2),
     R2>=R1, alt(Alt1), alt(Alt2).
rankAux(largeScale, 2).
rankAux(smallScale, 1).


% Performance
pref(performance, Alt1, Alt2):- 
    has(Alt1, perfMetric, P1), 
    has(Alt2, perfMetric, P2), 
    P1>=P2, alt(Alt1), alt(Alt2).

% Item Fairness
pref(item_fairness,Alt1,Alt2):- 
    has(Alt1, item_parity,P1), 
    has(Alt2, item_parity,P2), 
    P1<=P2, alt(Alt1), alt(Alt2).

%Item Fairness
pref(racial_fairness,Alt1,Alt2):- 
    has(Alt1, racial_parity,P1), 
    has(Alt2, racial_parity,P2), 
    P1<=P2, alt(Alt1), alt(Alt2).

%Gender Fairness
pref(gender_fairness,Alt1,Alt2):- 
    has(Alt1, gender_parity,P1), 
    has(Alt2, gender_parity,P2), 
    P1<=P2, alt(Alt1), alt(Alt2).
