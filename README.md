# Synthesis of Temporally-Robust Policies for Signal Temporal Logic Tasks using Reinforcement Learning

## Abstract

This paper investigates the problem of designing control policies that satisfy high-level specifications described by signal temporal logic (STL) in unknown, stochastic environments.
While many existing works concentrate on optimizing the spatial robustness of a system, our work takes a step further by also considering **temporal robustness** as a critical metric to quantify the tolerance of time uncertainty in STL. To this end, we formulate two relevant control objectives to enhance the temporal robustness of the synthesized policies. The first objective is to maximize the probability of being temporally robust for a given threshold. The second objective is to maximize the worst-case spatial robustness value within a bounded time shift. We use reinforcement learning to solve both control synthesis problems for unknown systems. Specifically, we approximate both control objectives in a way that enables us to apply the standard Q-learning algorithm. Theoretical bounds in terms of the approximations are also derived. We present case studies to demonstrate the feasibility of our approach.

## Demonstration


[![Video]()](https://github.com/WSQsGithub/TimeRobustLearning/assets/70429350/f7435da7-6c6b-46c4-978f-dbc77f3d29de)




## Comment

This paper has been summitted to ICRA 2024.
