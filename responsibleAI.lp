%privacy fairness performance


%=====================================
%======================== Alternatives
%=====================================
alt(p1;p2;p3;p4;p5).

has(p1,requiredData,clickHabit ).
has(p1,requiredData,interests ).
has(p1,requiredData,activity ).

has(p2,requiredData,interests ).
has(p2,requiredData,politicalBelief ).

has(p3, requiredData ,opinionData).
has(p3, requiredData ,politicalBelief).

has(p4, requiredData, location).
has(p4, requiredData, activity).

has(p5, requiredData,location).
has(p5, requiredData,opinionData).
has(p5, requiredData,politicalBelief).

has(clickHabit, subject, u1).
has(interests, subject, u1).
has(activity, subject, u1).
has(location, subject, u1).
has(opinionData, subject, u1).
has(politicalBelief, subject, u1).



has(p1, item_parity,6 ).
has(p2, item_parity,8 ).
has(p3, item_parity,8 ).
has(p4, item_parity,6 ).
has(p5, item_parity,9 ).

has(p1, gender_parity,6 ).
has(p2, gender_parity,8 ).
has(p3, gender_parity,8 ).
has(p4, gender_parity,6 ).
has(p5, gender_parity,9 ).

has(p1, racial_parity,6 ).
has(p2, racial_parity,8 ).
has(p3, racial_parity,8 ).
has(p4, racial_parity,6 ).
has(p5, racial_parity,9 ).

has(p1, accuracy,6 ).
has(p2, accuracy,8 ).
has(p3, accuracy,8 ).
has(p4, accuracy,6 ).
has(p5, accuracy,9 ).


has(p1, processType, bigData ).
has(p2, processType, multiSource ).
has(p3, processType, regular ).
has(p4, processType, multiSource ).
has(p5, processType, bigData ).

has(p1, processTime,2).
has(p2, processTime,2).
has(p3, processTime,4).
has(p4, processTime,3).
has(p5, processTime,5).

has(location, source ,streaming ).
has(opinionData, source ,storage).
has(politicalBelief, source ,storage).
has(clickHabit, source ,storage).
has(interests, source ,storage).
has(activity, source ,storage).

has(politicalBelief, category, sensitiveData).
has(opinionData, category, sensitiveData).




has(u1, authorised, clickHabit).
has(u1, authorised, interests).
has(u1, authorised, activity).
has(u1, authorised, location).
has(u1, authorised, opinionData).
has(u1, authorised, politicalBelief).


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


%child(privacy, authorisation).
child(privacy, minimiseSensitiveData).
child(privacy, minimiseData).
child(privacy, scaleComplexity).

child(fairness, item).
child(fairness, user).

child(user, racial_equality).
child(user, gender_equality).


%child(performance, accuracy).
%child(performance, time).

leanNode(N):- node(N), not child(N,_).
nonLeafNode(N):- node(N), not leanNode(N).

%violates(A,authorisation):- has(A, requiredData, D), has(D,subject, U), not has(U, authorised, D).
%pref(authorisation,A,B):-  not violates(A,authorisation), not violates(B,authorisation), alt(A), alt(B).


has(A,nbData, N):- N = #count{ D : has(A, requiredData, D)}, alt(A).
pref(minimiseData,A,B):-  has(A,nbData, N1), has(B,nbData, N2), N2>=N1.

has(A,nbSensitiveData, N):- N = #count{ D : has(A, requiredData, D), has(D, category, sensitiveData)}, alt(A).
pref(minimiseSensitiveData,A,B):-  has(A,nbSensitiveData, N1), has(B,nbSensitiveData, N2), N2>=N1.


%satisfies(A,hasStreamingData):- has(A, requiredData, D), has(D, source, streaming).
%has(A, sourceRank, 1):- not satisfies(A, hasStreamingData), alt(A).
%has(A, sourceRank, 2):- satisfies(A, hasStreamingData), alt(A).


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


%pref(time,A,B):- has(A, processTime,T1), has(B, processTime,T2), T1<=T2, alt(A), alt(B).


pref(item,A,B):- has(A, item_parity,P1), has(B, item_parity,P2), P1<=P2, alt(A), alt(B).

pref(racial_equality,A,B):- has(A, racial_parity,P1), has(B, racial_parity,P2), P1<=P2, alt(A), alt(B).
pref(gender_equality,A,B):- has(A, gender_parity,P1), has(B, gender_parity,P2), P1<=P2, alt(A), alt(B).

%acceptability(N)

%pref(C,A,A):-pref(C,A,_).
%pref(C,B,B):-pref(C,_,B).


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



unMaximal(C,M,A,B):- childPref(C,M2,M),pref(M2,B,A), not pref(M2,A,B),alt(A),alt(B), child(C,M).
isMaximal(C, M,A,B):- not unMaximal(C,M,A,B),alt(A),alt(B), child(C,M).
prefLex(C,A,B):- pref(M,A,B), not pref(M,B,A), isMaximal(C,M,A,B), alt(A), alt(B), child(C,M).
%prefLex(C,A,B):- pref(M,A,B), pref(M,B,A), isMaximal(C,M,A,B),A=B ,alt(A), alt(B), child(C,M).


card_S(C,A,B,N):- N = #count{ M :pref(M,A,B), child(C,M) }, alt(A), alt(B), child(C,_).
%card_S1(C,A,N):- N = #count{ M :pref(M,A,B), child(C,M) }, alt(A), alt(B), child(C,_).
prefCard(C,A,B):- card_S(C,A,B,N1), card_S(C,B,A,N2), N1>=N2.
%prefCard(C,A,B):- card_S1(C,A,N1), card_S1(C,B,N2), N1>=N2.

% may be replace with nonLeafNode(C)



pref(C,A,B):- prefCard(C,A,B).


pref(A,B):- pref(root,A,B).




rank(A,R):- R = #count{ B : pref(A,B)},alt(A).
%rank(A,R):- R1 = #count{ B : pref(A,B)} , R2=#count{ X : pref(X,_)}, R=R2-R1+1, alt(A).


%#show nonLeafNode/1.
%#show card_S/4.
%#show prefCard/3.
%#show pref/2.
#show rank/2.




pref(c1,c2).
pref(c2,c3).



pref(A, B):- 
