#!/bin/bash
git rebase -i --root --exec "git commit --amend --reset-author --no-edit"
