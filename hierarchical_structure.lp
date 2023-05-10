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
