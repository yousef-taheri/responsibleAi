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



%===========================================
%======================== Ethical Evaluation
%===========================================


super_value(root).
moral_value(privacy; fairness; performance ).
sub_value(scaleComplexity ; minimization; sensitivity; item_fairness; user_fairness ; racial_fairness; gender_fairness).

node(N):- super_value(N) .
node(N):- moral_value(N).
node(N):- sub_value(N).
nonLeafNode(N):- node(N), child(N,_).

    child(root,privacy).
    child(root,fairness).
    child(root,performance).

    child(privacy, sensitivity).
    child(privacy, minimization).
    child(privacy, scaleComplexity).
    child(fairness, item_fairness).
    child(fairness, user_fairness).
    child(user, racial_fairness).
    child(user, gender_fairness).




leanNode(N):- node(N), not child(N,_).
nonLeafNode(N):- node(N), not leanNode(N).


‰============================
%leaf criteria votes

has(A,nbData, N):- N = #count{ D : has(A, requiredData, D)}, alt(A).
pref(minimization,A,B):-  has(A,nbData, N1), has(B,nbData, N2), N2>=N1.

has(A,nbSensitiveData, N):- N = #count{ D : has(A, requiredData, D), has(D, category, sensitiveData)}, alt(A).
pref(sensitivity,A,B):-  has(A,nbSensitiveData, N1), has(B,nbSensitiveData, N2), N2>=N1.



rankAux(largeScale, 2).
rankAux(smallScale, 1).
pref(scaleComplexity,A,B):- 
    has(A, processType, T1),
     has(B, processType, T2),
     rankAux(T1, R1),
     rankAux(T2, R2),
     R2>=R1, alt(A), alt(B).



pref(performance,A,B):- has(A, perfMetric,P1 ), has(B, perfMetric,P2 ), P1>=P2, alt(A), alt(B).




pref(item_fairness,A,B):- has(A, item_parity,P1), has(B, item_parity,P2), P1<=P2, alt(A), alt(B).

pref(racial_fairness,A,B):- has(A, racial_parity,P1), has(B, racial_parity,P2), P1<=P2, alt(A), alt(B).
pref(gender_fairness,A,B):- has(A, gender_parity,P1), has(B, gender_parity,P2), P1<=P2, alt(A), alt(B).



%============================
% priorities

childPref(privacy, sensitivity, minimization).
childPref(privacy, minimization, scaleComplexity).

childPref(fairness, user_fairness, item_fairness).
childPref(user_fairness, racial_fairness, gender_fairness).



%childPref(root, performance,privacy).
childPref(root, fairness, privacy).
childPref(root, privacy, performance).
%childPref(root, privacy, fairness).
%childPref(root, fairness, performance).





childPref(C, X,Z):- childPref(C, X,Y), childPref(C, Y,Z).









criteslength(M, N):- N = #count{ C : child(M,C)}, child(M,_).
rank(A,M,N):- R = #count{ B : childPref(M,A,B)}, child(M, A), N=K-R, criteslength(M, K).
equivClass(M, N):-  rank(_,M,N).
in(C,M,E):- child(M,C), rank(C,M,E).
notInfer(M, E1, E2):-in(C1,M,E1), in(C2,M,E2), not childPref(M,C1,C2), equivClass(M, E1), equivClass(M, E2).
prefSet(M, E1,E2):-   not notInfer(M, E1,E2), equivClass(M, E1), equivClass(M, E2).



revCondLay(M, C,X,Y):- pref(C,X,Y), child(M, C), in(C,M,E), prefSet(M, E1,E), not pVote(M, E1, X,Y).
constLay(M, C,X,Y):- not revCondLay(M, C,X,Y), child(M,C), pref(C,X,Y).
prefLay(M, X,Y):- child(M,C), pref(C,X,Y), in(C,M,E), pVote(M, E, X,Y), constLay(M, C,X,Y).


plural(M, E):- in(C1,M,E), in(C2, M,E),child(M,C1), child(M, C2) ,C1 != C2.
singleton(M,E):- in(C,M,E), child(M,C) ,not plural(M, E).

pVote(M, E, X,Y):- singleton(M, E), in(C,M,E), child(M,C), pref(C,X,Y).

s(M, E,X, N1):- N1 = #count{ C : pref(C,X,Y), in(C,M,E) }, equivClass(M,E), alt(X).
pVote(M, E, X,Y):- plural(M, E), s(M, E,X, N1), s(M, E,Y, N2), N1 >=N2 .



pref(C,A,B):- prefLay(C,A,B).

pref(A,B):- pref(root,A,B).


rank(A,R):- R = #count{ B : pref(A,B)},alt(A).
%rank(A,R):- R1 = #count{ B : pref(A,B)} , R2=#count{ X : pref(X,_)}, R=R2-R1+1, alt(A).



%#show nonLeafNode/1.
%#show card_S/4.
%#show prefCard/3.
%#show pref/2.
#show rank/2.
%#show prefLay/3.
