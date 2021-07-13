#!/bin/bash


#pr_number=1598
#pr_number=1718
#pr_number=171
pr_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

#hub
#hub api graphql --flat -f q="repo:$REPO type:pr $SHA" -f query='
#review_response=$(gh api graphql -F pr_number=$pr_number -f query='
#repository(owner: "OpenMage", name: "magento-lts") {
review_response=$(hub api graphql -F pr_number=$pr_number -f query='
query($pr_number: Int!) {
  repository(owner: "Flyingmana", name: "magento-lts") {
    pullRequest: issueOrPullRequest(number: $pr_number) {
      __typename
      ... on PullRequest {
        title,
        approved: reviews(first: 100, states: APPROVED){

          totalCount,
          nodes {
            authorAssociation,
          authorCanPushToRepository,
            author {login},
            state
          }
        },
        all: reviews(first: 100) {

          totalCount,
          nodes {
            authorAssociation,
          authorCanPushToRepository,
            author {login},
            state
          }
        },
      }
    }
  }
}');

all_reviews=$(echo $review_response | jq '.data.repository.pullRequest.approved.nodes | unique_by(.author.login)');
maintainer_reviews=$(echo $all_reviews | jq -c '.[] | select(.authorCanPushToRepository | contains(true))' | jq -n '[inputs]');

all_reviews_count=$(echo $all_reviews | jq length)
maintainer_reviews_count=$(echo $maintainer_reviews | jq length)

echo $review_response;
echo '
###########
'
echo $all_reviews;
echo '
###########
'
echo $maintainer_reviews;
echo '
###########
'
echo "$all_reviews_count / $maintainer_reviews_count /
";

if [ "$maintainer_reviews_count" -gt 0 ] && [ "$all_reviews_count" -gt 1 ]; then
  echo "review Approved";
else
  echo "Not enough Reviews"
fi

