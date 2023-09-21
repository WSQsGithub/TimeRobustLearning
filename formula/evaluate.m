function res = evaluate(trace, task, T, h)
% return satisfaction/ spatial robustness/ temporal robustness
    res =  shifted_rb(trace,task,T,h,0);
    trb = TDB(trace,task,T,h);
    res = [res,trb];
end

function res = TDB(trace,task,T,h)
    d = 0;
    res = shifted_rb(trace,task,T,h,d);
    sat = 2*res(1)-1; % 0 as -1 and 1 as 1
    rb = res(2);
    for d = 1:T+h
        res = shifted_rb(trace,task,T,h,d);
        rb_d = res(2);
        if(rb*rb_d<=0)
            break;
        end
    end
    res = sat*d;
end

function res = shifted_rb(trace,task,T,h,d)
    trace = [zeros(d,2); trace(1:end-d,:)];
    if(task==1)
        % F[0,T)G[0,h)(x>3 and y>3)
        rb_seq1 = min(trace - [3,3],[],2);
        rb_seq2 = min([6,6]-trace,[],2);
        rb_seq = min(rb_seq1,rb_seq2);
        rb_seq_G = zeros(T,1);
        for i = 1:T
            rb_seq_G(i) = min(rb_seq(i:i+h-1));
        end
        rb_seq_FG = max(rb_seq_G);
        sat = (rb_seq_FG>0);
        res = [sat rb_seq_FG];
    elseif(task==2)
        %G[0,12](F[0,2] x in A and F[0,2] x in B)')
        A = [1 3;2 4]; B = [2 2;3 3];
        rb_seq1 = min(min(trace-A(1,:),[],2),min(A(2,:)-trace,[],2));
        rb_seq2 = min(min(trace-B(1,:),[],2),min(B(2,:)-trace,[],2));
        
        rb_seq_F1 = zeros(T,1);
        rb_seq_F2 = zeros(T,1);
        for i = 1:T
            rb_seq_F1(i) = max(rb_seq1(i:i+h-1));
            rb_seq_F2(i) = max(rb_seq2(i:i+h-1));
        end
        rb_seq_F = min(rb_seq_F1,rb_seq_F2);
        rb_seq_GF = min(rb_seq_F);
        sat = (rb_seq_GF>0);
        res = [sat rb_seq_GF];
    end
end