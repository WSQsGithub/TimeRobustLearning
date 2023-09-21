function TimerFunction(obj, event)
	% user code
    msg =  obj.UserData;
    fprintf('%s\t Episode: %d\t Q-Entries: %d\n',datestr(now,31),msg.index,msg.lenQ);
end