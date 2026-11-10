---
title: 'Star Formation Mitosis: The Effects of Particle Splitting on the Star Formation Outcome'

# Authors
# A YAML list of author names
# If you created a profile for a user (e.g. the default `admin` user at `content/authors/admin/`),
# write the username (folder name) here, and it will be replaced with their full name and linked to their profile.
authors:
- admin
- Michael Y. Grudić
- Christopher D. Matzner
- Philip F. Hopkins
- Norman Murray
- Claude-André Faucher-Giguère

# Author notes (such as 'Equal Contribution')
# A YAML list of notes for each author in the above `authors` list
author_notes: []

# arXiv submission date
date: '2026-09-30'

# Date to publish webpage (NOT necessarily Bibtex publication's date).
publishDate: '2026-11-10T05:45:36.009031Z'

# Publication type.
# A single CSL publication type but formatted as a YAML list (for Hugo requirements).
# `article` renders as "Preprint"; switch to `article-journal` once accepted.
publication_types:
- article

# Publication name and optional abbreviated publication name.
publication: 'Submitted to *OJAp*'
publication_short: ''

doi: 10.48550/arXiv.2610.00513

abstract: |-
  Particle splitting can increase the dynamic range in Lagrangian astrophysical simulations by several orders of magnitude. However, such methods can introduce numerical noise that may affect the rate of convergence, particularly for collapse problems where fragmentation could be artificially suppressed or enhanced. Thus it is necessary to determine how these errors propagate to key quantities of interest, and to correct or mitigate them where possible. Using GIZMO's MFM-MHD method, we perform a set of ≈220 simulations of a uniform-density turbulent gas sphere undergoing collapse, systematically varying the cloud mass and radius, feedback physics, initial resolution, the pace and cadence at which we split particles and the sink (accreting) or single-age stellar population (SSP; non-accreting) particle formation prescription. Crucially, we compare with control runs that start with uniformly-high resolution without splitting. While we find no evidence for artificial fragmentation caused by splitting particles, particle splitting runs have a smoother density field than their non-splitting counterparts. Due to this, particle splitting runs exhibit minor differences in the density and turbulence statistics. However, they form about the same total stellar mass as the control non-splitting runs, albeit with a slightly different mass spectrum. As a result, particle splitting runs have a different evolutionary history, compared to runs without particle splitting, especially when stellar feedback is present. Despite the changes seen in runs where we split particles, the numerical solution lies within the scatter inherently present in these chaotic systems, which we model by modifying the initial turbulent velocity field. Our results here argue that particle splitting generally “works” for star formation applications, despite some systematic differences in the specifics.

# Summary. An optional shortened abstract.
summary: ''

tags:
- Astrophysics - Astrophysics of Galaxies

# Display this page in a list of Featured pages?
featured: false

# Links
url_pdf: ''
url_code: ''
url_dataset: ''
url_poster: ''
url_project: ''
url_slides: ''
url_source: ''
url_video: ''

# Custom links (uncomment lines below)
# links:
# - name: Custom Link
#   url: http://example.org

# Publication image
# Add an image named `featured.jpg/png` to your page's folder then add a caption below.
image:
  caption: |-
    **Figure 3.** Same as Figure 2 of the paper, but comparing runs with (bottom 3 rows) and without (top row) particle splitting. At early times, there are slight differences between the evolution of the cloud at different resolutions. By 1.5 *t*<sub>ff</sub>, star particles in the particle splitting runs form in roughly the same location as the natively high resolution run. However, the masses of the stars can be different (as seen in the size of the markers) and thus the feedback from the stars affects the cloud evolution differently at late times in the various runs.
  # 2 = wide (up to 1200px) layout for multi-panel figures
  placement: 2
  focal_point: ''
  preview_only: false

# Associated Projects (optional).
#   Associate this publication with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. `projects: ['internal-project']` links to `content/project/internal-project/index.md`.
#   Otherwise, set `projects: []`.
projects: []
links:
- name: arXiv
  url: https://arxiv.org/abs/2610.00513
- name: ADS
  url: https://ui.adsabs.harvard.edu/abs/2026arXiv261000513K/abstract
---
