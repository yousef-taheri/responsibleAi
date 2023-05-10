%========================================================
%======================== Alternatives ==================
%========================================================
alt(sys1;sys2;sys3).

has(sys1,requiredData,clickHabit ).
has(sys1,requiredData,interests ).
has(sys1,requiredData,activity ).

has(sys2,requiredData,interests ).
has(sys2,requiredData,politicalBelief ).

has(sys3, requiredData ,interests).
has(sys3, requiredData ,activity).

has(sys1, item_parity,3 ).
has(sys2, item_parity,6 ).
has(sys3, item_parity,4 ).

has(sys1, gender_parity,1 ).
has(sys2, gender_parity,2 ).
has(sys3, gender_parity,3 ).

has(sys1, racial_parity,2 ).
has(sys2, racial_parity,4 ).
has(sys3, racial_parity,1 ).

has(sys1, perfMetric,30 ).
has(sys2, perfMetric,25 ).
has(sys3, perfMetric,20 ).

has(sys1, processType, largeScale ).
has(sys2, processType, largeScale ).
has(sys3, processType, smallScale ).



has(politicalBelief, category, sensitiveData).
has(opinionData, category, sensitiveData).

%===================================================================
%======================== Hierarchical Structure ===================
%===================================================================

child(root,privacy).
child(root,fairness).
child(root,performance).

child(privacy, sensitivity).
child(privacy, minimization).
child(privacy, scaleComplexity).
child(fairness, item_fairness).
child(fairness, user_fairness).
child(user_fairness, racial_fairness).
child(user_fairness, gender_fairness).

node(Node):- child(Node,_).
node(Node):- child(_,Node).

%==================================================================
%======================= leaf criteria votes ======================
%==================================================================

% Minimisation
has(Alt,nbData, N):- 
    N = #count{ Data : has(Alt, requiredData, Data)}, 
    alt(Alt).

pref(minimization,Alt1,Alt2):-  
    has(Alt1, nbData, N1), 
    has(Alt2, nbData, N2), 
    N2>=N1.

%Sensitivity
has(Alt, nbSensitiveData, N):- 
    N = #count{ Data : has(Alt, requiredData, Data), 
    has(Data, category, sensitiveData)}, 
    alt(Alt).
pref(sensitivity, Alt1, Alt2):-  
    has(Alt1, nbSensitiveData, N1), 
    has(Alt2,nbSensitiveData, N2), 
    N2>=N1.

%Scale and Complexity
rankAux(largeScale, 2).
rankAux(smallScale, 1).
pref(scaleComplexity,Alt1,Alt2):- 
    has(Alt1, processType, Type1),
     has(Alt2, processType, Type2),
     rankAux(Type1, R1),
     rankAux(Type2, R2),
     R2>=R1, alt(Alt1), alt(Alt2).

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

%==================================================================
%======================== Input priorities ========================
%==================================================================
% Fixed Inputs
childPref(privacy, sensitivity, minimization).
childPref(privacy, minimization, scaleComplexity).

childPref(fairness, user_fairness, item_fairness).
childPref(user_fairness, racial_fairness, gender_fairness).
childPref(user_fairness, gender_fairness,  racial_fairness).


% transitivity of the order
childPref(C, X,Z):- childPref(C, X,Y), childPref(C, Y,Z).


% variant inputs for the root to reproduce the result in the article

% case 1) fairness = privacy = pereformance

childPref(root, fairness, privacy).
childPref(root, privacy, fairness).
childPref(root, privacy, performance).
childPref(root, performance,privacy).


% case 2 fairness > privacy > pereformance

%childPref(root, fairness, privacy).
%childPref(root, privacy, performance).


% case 3 fairness = privacy > pereformance

%childPref(root, fairness, privacy).
%childPref(root, privacy, fairness).
%childPref(root, privacy, performance).


% case 4 fairness = pereformance > privacy 

%childPref(root, fairness, performance).
%childPref(root, performance, fairness).
%childPref(root, performance,privacy).


% case 5 fairness > pereformance > privacy 

%childPref(root, fairness, performance).
%childPref(root, performance,privacy).



%==================================================================
%=========================== Aggregator ===========================
%==================================================================

% Implementation of votng rule with dominant voters
pref(Node, Alt1, Alt2):- prefLay(Node, Alt1, Alt2).

prefLay(Node, Alt1, Alt2):- 
    childrenLayers(Node,Layer),
    pVote(Node, Layer, Alt1, Alt2),
    is_dominant(Node, Layer, Alt1, Alt2).

is_dominant(Node, Layer,Alt1,Alt2):- 
    not is_dominated(Node, Layer,Alt1,Alt2), 
    childrenLayers(Node,Layer),
    pVote(Node, Layer, Alt1, Alt2).

is_dominated(Node, Layer, Alt1,Alt2):- 
    childrenLayers(Node,Layer),
    pVote(Node, Layer, Alt1, Alt2),
    superiorThan(Node, Layer1, Layer), 
    not pVote(Node, Layer1, Alt1,Alt2).

superiorThan(Node, Layer1, Layer2):- 
    childrenLayers(Node, Layer1), 
    childrenLayers(Node, Layer2),
    not inferiorThan(Node, Layer1, Layer2).

inferiorThan(Node, Layer1, Layer2):-
    childrenLayers(Node, Layer1), 
    childrenLayers(Node, Layer2),
    belongs(Node, Child1 , Layer1),
    belongs(Node, Child2 , Layer2),
    not childPref(Node, Child1, Child2).

childrenLayers(Node, Layer):-  belongs(Node, _ , Layer).

belongs(Node, Child , Layer):- 
    Layer = #count{ Child1 : childPref(Node , Child, Child1)}, 
    child(Node, Child).


% voting rule

% in case of an only single voter no vote aggregation is needed 
pVote(Node, Layer, Alt1,Alt2):- 
    singleton(Node, Layer), 
    belongs(Node, Child, Layer), 
    pref(Child, Alt1, Alt2).

singleton(Node, Layer):- 
    belongs(Node, Child1, Layer), 
    not plural(Node, Layer).

plural(Node, Layer):- 
    belongs(Node, Child1, Layer), 
    belongs(Node, Child2, Layer),
    Child1 != Child2.


% vote aggregation according to Copelands rule
pVote(Node, Layer, Alt1, Alt2):- 
    plural(Node, Layer), 
    copeland_score( Node, Layer, Alt1, S1), 
    copeland_score( Node, Layer, Alt2, S2), 
    S1>S2.

copeland_score( Node, Layer, Alt, S):- 
    S= #sum{ S1: 
        nb_pairwise_wins( Node, Layer, Alt, Alt1, N1), 
        nb_pairwise_ties( Node, Layer, Alt, Alt1, N2), 
        S1 = N1*2+N2,
        alt(Alt1)}, 
    childrenLayers(Node, Layer), alt(Alt) .

nb_pairwise_ties( Node, Layer, Alt1, Alt2 , N):- 
    N= #count{ N1 : 
        nb_strict_voters(Node, Layer, Alt1, Alt2 , N1), 
        nb_strict_voters(Node, Layer, Alt2, Alt1 , N2),
        belongs(Node, Child, Layer), N1=N2}, 
    childrenLayers(Node,Layer), alt(Alt1), alt(Alt2).

nb_pairwise_wins( Node, Layer, Alt1, Alt2, N):- 
    N= #count{ N1 : 
        nb_strict_voters(Node, Layer, Alt1, Alt2 , N1), 
        nb_strict_voters(Node, Layer, Alt2, Alt1 , N2), 
        belongs(Node, Child, Layer), N1>N2}, 
    childrenLayers(Node, Layer), alt(Alt1), alt(Alt2).

nb_strict_voters(Node, Layer, Alt1, Alt2, N):- 
    N = #count{ Child : 
        pref(Child, Alt1, Alt2), 
        not pref(Child , Alt2, Alt1), 
        belongs(Node, Child, Layer) }, 
    childrenLayers(Node, Layer), alt(Alt1), alt(Alt2).



%% ranking adjustment
primiryRank(Node, Alt, R):- 
    R1 = #count{ Alt1 : pref(Node, Alt, Alt1), alt(Alt1)} , 
    R2 = #count{ Alt2 : pref(Node, Alt2,_)}, 
    R = R2-R1+1, node(Node), alt(Alt).

correction(Node, R2 , R+1):- 
    R = #count{ R1 : primiryRank(Node,_,R1), R2>R1 }, 
    primiryRank(Node,_,R2).

rank(Node, Alt , R):- 
    primiryRank(Node, Alt, R1), 
    correction(Node, R1 , R).

%root ranking 
rankRoot(A,N):- rank(root,A,N).

#show rankRoot/2.
%#show rank/3.
