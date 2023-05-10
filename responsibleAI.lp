%=====================================
%======================== Alternatives
%=====================================


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

% variant inputs

%childPref(root, performance,privacy).
childPref(root, fairness, privacy).
childPref(root, privacy, performance).
childPref(root, privacy, fairness).
%childPref(root, fairness, performance).
%childPref(root, performance, fairness).



% transitivity of the order
childPref(C, X,Z):- childPref(C, X,Y), childPref(C, Y,Z).


%==================================================================
%=========================== Aggregator ===========================
%==================================================================

criteslength(M, N):- N = #count{ C : child(M,C)}, child(M,_).
rank1(A,M,N):- R = #count{ B : childPref(M,A,B)}, child(M, A), N=K-R, criteslength(M, K).
equivClass(M, N):-  rank1(_,M,N).
in(C,M,E):- child(M,C), rank1(C,M,E).
notInfer(M, E1, E2):-in(C1,M,E1), in(C2,M,E2), not childPref(M,C1,C2), equivClass(M, E1), equivClass(M, E2).
prefSet(M, E1,E2):-   not notInfer(M, E1,E2), equivClass(M, E1), equivClass(M, E2).




childrenLayers(Node,Layer):- child(Node, Child), in(Child, Node, Layer).

is_dominated(Node, Layer, Alt1,Alt2):- 
    childrenLayers(Node,Layer),
    pVote(Node, Layer, Alt1, Alt2),
    prefSet(Node, Layer1, Layer), 
    not pVote(Node, Layer1, Alt1,Alt2).

is_dominant(Node, Layer,Alt1,Alt2):- 
    not is_dominated(Node, Layer,Alt1,Alt2), 
    childrenLayers(Node,Layer),
    pVote(Node, Layer, Alt1, Alt2).

prefLay(Node, Alt1, Alt2):- 
    childrenLayers(Node,Layer),
    pVote(Node, Layer, Alt1, Alt2),
    is_dominant(Node, Layer, Alt1, Alt2).



plural(M, E):- in(C1,M,E), in(C2, M,E),child(M,C1), child(M, C2) ,C1 != C2.
singleton(M,E):- in(C,M,E), child(M,C) ,not plural(M, E).

pVote(M, E, X,Y):- singleton(M, E), in(C,M,E), child(M,C), pref(C,X,Y).


%%%================= Copelands rule 
ss(M,E, X,Y , N1):- N1 = #count{ C : pref(C,X,Y), not pref(C,Y,X),  in(C,M,E) }, equivClass(M,E), alt(X), alt(Y).

superCount( M,E, X,Y, N):- N= #count{ N1 : ss(M,E, X,Y , N1), ss(M,E, Y,X , N2) ,in(C,M,E), N1>N2 }, equivClass(M,E), alt(X), alt(Y).
tie( M,E, X,Y ,N):- N= #count{ N1 : ss(M,E, X,Y , N1), ss(M,E, Y,X , N2) ,in(C,M,E), N1=N2 }, equivClass(M,E), alt(X), alt(Y) .
%infCount( M,E, X,Y, N):- N= #count{ N1 : ss(M,E, X,Y , N1), ss(M,E, Y,X , N2) ,in(C,M,E), N1<N2 }, equivClass(M,E), alt(X), alt(Y).

sumRab( M,E, X,Y, S):- superCount( M,E, X,Y, N1), tie( M,E, X,Y, N2), S = N1*2+N2, equivClass(M,E), alt(X), alt(Y) .

sumRab( M,E, X,S):- S= #sum{ S1: sumRab( M,E, X,Y, S1), alt(Y)}, equivClass(M,E), alt(X) .

pVote(M, E, X,Y):- plural(M, E), sumRab( M,E, X,S1), sumRab( M,E, Y,S2), S1>S2.




pref(C,A,B):- prefLay(C,A,B).

%% ranking correction
rankA(C,A,R):- R1 = #count{ B : pref(C, A,B)} , R2=#count{ X : pref(C,X,_)}, R=R2-R1+1, node(C) ,alt(A).
rankR(C, R2,R+1):- R = #count{ R1 : rankA(C,_,R1), R2>R1 }, rankA(C,_,R2).
rank(C,A,N):- rankA(C,A,R), rankR(C, R,N).


%eqlass(E):-equivClass(fairness,E).
%prefRoot(A,B):- pref(root, A,B).
rankRoot(A,N):- rank(root,A,N).
%#show eqlass/1.
%#show card_S/4.
#show rankRoot/2.
%#show pVote/4.
%#show rank/3.

%#show prefLay/3.

