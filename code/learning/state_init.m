function [s_tau s R] = state_init(s_tau_0 s_0)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    s_tau = s_tau_0; % initialize s_tau
    s = s_0;
    R = 0;% initialize episodic return
end