## Current task: admin get/post actions

## Notes:

- Decided to replace client activation/deactivation with asset moderation activation/deactivation, cause going with clients would require an introduction of another subdomain (ClientManagement)
- ActiveAdmin hacks:
  - https://gist.github.com/amkisko/af1b2f7dc4f0f941437ea16400277864
  - https://github.com/activeadmin/activeadmin/discussions/8621
  - https://github.com/activeadmin/activeadmin/discussions/8538

## TODOs:

- Think of a better way to store asset states related to comment retrieval. Maybe "comment retrieval" should even belong to `Moderation::Asset` (but controlled by integrations, informing it of whether they are retrieving or not).
- Finish Moderation::Asset admin resourse
- Remove `active` from clients
- ? Remove Cleint admin resource
- Setup authentication for active_admin
