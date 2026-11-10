---
title: Numerics of Particle Splitting
summary: 
date: 2026-11-10
authors:
  - admin
tags:
image:
  caption: 
  #'Image credit: Khullar et al (2020)'
  #I'm interested in understanding how stars form. 
show_date: false
---

Hyper-Lagrangian refinement or particle splitting is a technique to increase resolution and therefore the dynamic range in Lagrangian simulations. However, such methods can introduce numerical noise that may affect the rate of convergence, particularly for collapse problems where fragmentation could be artificially suppressed or enhanced. Thus it is necessary to determine how these errors propagate to key quantities of interest, and to correct or mitigate them where possible. 

In [Khullar et al. (2026)](https://arxiv.org/abs/2610.00513), we show that the particle splitting method in the GIZMO Meshless Finite Mass code does not suffer from artificial fragmentation in smooth collapse tests. However, in chaotic GMCs, simulations where we split particles exhibit minor differences in the density field, and the density and turbulence statistics. They form about the same total stellar mass as the control non-splitting runs, albeit with a slightly different mass spectrum. As a result, particle splitting runs have a different evolutionary history, compared to runs without particle splitting, especially when stellar feedback is present. Despite the changes seen in runs where we split particles, the numerical solution lies within the scatter inherently present in these chaotic systems, which we model by modifying the initial turbulent velocity field. This paper shows that particle splitting generally ``works" for star formation applications, despite some systematic differences in the specifics. 
