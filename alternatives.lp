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
