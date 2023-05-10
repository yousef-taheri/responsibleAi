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



%=====================================================================
%=========================== output setting ==========================
%=====================================================================
%in order to run the code using Cingo please execute:
% clingo alternatives.lp hierarchical_structure.lp leaf_criteria_votes.lp aggregators.lp input_priorities.lp 0 


% show the rankoing of all nodes
%#show rank/3.

% shows only the ranking of the root node
#show rankRoot/2.
