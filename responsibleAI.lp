%=====================================
%======================== Alternatives
%=====================================
alt(p1;p2;p3).

has(p1,requiredData,clickHabit ).
has(p1,requiredData,interests ).
has(p1,requiredData,activity ).

has(p2,requiredData,interests ).
has(p2,requiredData,politicalBelief ).

has(p3, requiredData ,opinionData).
has(p3, requiredData ,politicalBelief).



has(p1, item_parity,6 ).
has(p2, item_parity,8 ).
has(p3, item_parity,8 ).


has(p1, gender_parity,6 ).
has(p2, gender_parity,8 ).
has(p3, gender_parity,8 ).

has(p1, racial_parity,6 ).
has(p2, racial_parity,8 ).
has(p3, racial_parity,8 ).

has(p1, accuracy,6 ).
has(p2, accuracy,8 ).
has(p3, accuracy,8 ).

has(p1, processType, bigData ).
has(p2, processType, multiSource ).
has(p3, processType, regular ).

has(p1, processTime,2).
has(p2, processTime,2).
has(p3, processTime,4).


has(politicalBelief, category, sensitiveData).
has(opinionData, category, sensitiveData).



%===========================================
%======================== Ethical Evaluation
%===========================================


super_value(root).
moral_value(privacy; fairness; performance ).
sub_value(authorisation ; minimiseData; minimiseSensitiveData; streamingDataSource; item; user ; racial_equality; gender_equality; accuracy; time).

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
    child(fairness, item).
    child(fairness, user).
    child(user, racial_equality).
    child(user, gender_equality).




leanNode(N):- node(N), not child(N,_).
nonLeafNode(N):- node(N), not leanNode(N).


has(A,nbData, N):- N = #count{ D : has(A, requiredData, D)}, alt(A).
pref(minimiseData,A,B):-  has(A,nbData, N1), has(B,nbData, N2), N2>=N1.

has(A,nbSensitiveData, N):- N = #count{ D : has(A, requiredData, D), has(D, category, sensitiveData)}, alt(A).
pref(minimiseSensitiveData,A,B):-  has(A,nbSensitiveData, N1), has(B,nbSensitiveData, N2), N2>=N1.



rankAux(bigData, 3).
rankAux(multiSource, 2).
rankAux(regular, 1).
pref(scaleComplexity,A,B):- 
    has(A, processType, T1),
     has(B, processType, T2),
     rankAux(T1, R1),
     rankAux(T2, R2),
     R2>=R1, alt(A), alt(B).



pref(performance,A,B):- has(A, accuracy,P1 ), has(B, accuracy,P2 ), P1>=P2, alt(A), alt(B).




pref(item,A,B):- has(A, item_parity,P1), has(B, item_parity,P2), P1<=P2, alt(A), alt(B).

pref(racial_equality,A,B):- has(A, racial_parity,P1), has(B, racial_parity,P2), P1<=P2, alt(A), alt(B).
pref(gender_equality,A,B):- has(A, gender_parity,P1), has(B, gender_parity,P2), P1<=P2, alt(A), alt(B).





childPref(privacy, minimiseSensitiveData, minimiseData).
childPref(privacy, minimiseData, scaleComplexity).

childPref(fairness, user, item).
childPref(user, racial_parity, gender_parity).

%childPref(performance, accuracy, time).

%childPref(root, performance,privacy).
childPref(root, fairness, privacy).
childPref(root, privacy, performance).
%childPref(root, privacy, fairness).
%childPref(root, fairness, performance).

%childPref(root, performance, privacy).




childPref(C, X,Z):- childPref(C, X,Y), childPref(C, Y,Z).

pref(C,A,B):- prefLay(C,A,B).

pref(A,B):- pref(root,A,B).


rank(A,R):- R = #count{ B : pref(A,B)},alt(A).
%rank(A,R):- R1 = #count{ B : pref(A,B)} , R2=#count{ X : pref(X,_)}, R=R2-R1+1, alt(A).





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


%#show nonLeafNode/1.
%#show card_S/4.
%#show prefCard/3.
%#show pref/2.
#show rank/2.
%#show prefLay/3.
