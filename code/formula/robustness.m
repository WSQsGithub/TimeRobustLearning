function res = robustness(state,task)
    if(task==1)
        % given phi = G[0,h] state>[3,3] & state<[6,6]
        space_rb_seq1 = min(state-[3,3],[],2);
        space_rb_seq2 = min([6,6]-state,[],2);
        space_rb_seq = min(space_rb_seq1,space_rb_seq2);
        space_rb = min(space_rb_seq, [], 'all'); 
    elseif(task==2)
        % Phi = G[0,T](F[0,h] x in A and F[0,h] x in B
        A = [1 3;2 4]; B = [2 2;3 3];
        space_rb_seq1 = min(min(state-A(1,:),[],2),min(A(2,:)-state,[],2));
        space_rb_seq2 = min(min(state-B(1,:),[],2),min(B(2,:)-state,[],2));

        space_rb_F1 = max(space_rb_seq1);
        space_rb_F2 = max(space_rb_seq2);
        
        space_rb = min(space_rb_F1,space_rb_F2);
    end
    res = space_rb;
end