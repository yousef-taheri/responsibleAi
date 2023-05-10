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

childrenLayers(Node, Layer):-  
    belongs(Node, _ , Layer).

belongs(Node, Child , Layer):- 
    Layer = #count{ Child1 : 
        childPref(Node , Child, Child1)}, 
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
rankRoot(Alt,R):- rank(root,Alt,R).
