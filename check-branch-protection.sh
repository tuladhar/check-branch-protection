#!/bin/bash
# MIT License

# Copyright (c) 2023 Puru Tuladhar (ptuladhar3@gmail.com)

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

PROGRAM_NAME="check-branch-protection"
COLOR_REST="$(tput sgr0)"
COLOR_GREEN="$(tput setaf 2)"
COLOR_RED="$(tput setaf 1)"

function show_usage() {
    echo "Usage: $PROGRAM_NAME owner/repo:branch"
    echo
    echo -e "\towner  - The account owner of the repository. The name is not case sensitive." 
    echo -e "\trepo   - The name of the repository. The name is not case sensitive." 
    echo -e "\tbranch - The name of the branch. Cannot contain wildcard characters." 
    echo 
    echo "Example:"
    echo -e "\t$ $PROGRAM_NAME tuladhar/aws-whats-new-bot:main"
    exit 1
}

function die() {
    echo -e "$1"
    exit 1
}

if [[ -z "$GITHUB_TOKEN"  ]]; then
    printf '%s%s%s\n' $COLOR_GREEN 'error: Authorization token "GITHUB_TOKEN" is missing.' $COLOR_REST

fi

REPO_OWNER=$(echo $1 | cut -sd '/' -f1)
REPO_NAME=$(echo $1 | cut -sd '/' -f2 | cut -sd ':' -f1)
BRANCH_NAME=$(echo $1 | cut -sd ':' -f2)

if [[ -z "$REPO_OWNER" ]] || [[ -z "$REPO_NAME" ]] || [[ -z "$BRANCH_NAME" ]]; then
    show_usage
fi

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/branches/$BRANCH_NAME/protection)

case "$STATUS_CODE" in
    "200")
        printf '%s%s%s\n' $COLOR_GREEN "Branch is protected for $REPO_OWNER/$REPO_NAME:$BRANCH_NAME" $COLOR_REST
        ;;
    "404")
        printf '%s%s%s\n' $COLOR_RED "Branch is not protected for $REPO_OWNER/$REPO_NAME:$BRANCH_NAME" $COLOR_REST
        ;;
    *)
        printf '%s%s%s\n' $COLOR_RED "error: GitHub API request failed with $STATUS_CODE status code." $COLOR_REST
        ;;
esac

