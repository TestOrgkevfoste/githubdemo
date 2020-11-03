# Webhook for proctected branches
GitHub Demo for protected branches


Perl code based webhook for enabling protected branches:

## **Assumpmtions**

    - Simple web service enabled. This configuration used a basic Apache install.
    
    - Enables protected branching but does not enable any options


Branch protection rule options located under your repository settings/branches

**Protect matching branches**

 - [ ] Require pull request reviews before merging

When enabled, all commits must be made to a non-protected branch and submitted via a pull request with the required number of approving reviews and no changes requested before it can be merged into a branch that matches this rule.

- [ ] Require status checks to pass before merging

Choose which status checks must pass before branches can be merged into a branch that matches this rule. When enabled, commits must first be pushed to another branch, then merged or pushed directly to a branch that matches this rule after status checks have passed.
 
- [ ] Require signed commits

Commits pushed to matching branches must have verified signatures.
 
- [ ] Require linear history

Prevent merge commits from being pushed to matching branches.
 
- [ ] Include administrators

Enforce all configured restrictions above for administrators.
 
- [ ] Restrict who can push to matching branches

Specify people, teams or apps allowed to push to matching branches. Required status checks will still prevent these people, teams and apps from merging if the checks fail.

Rules applied to everyone including administrators

- [ ] Allow force pushes

- [ ] Permit force pushes for all users with push access.

- [ ] Allow deletions
- [ ] Allow users with push access to delete matching branches.
