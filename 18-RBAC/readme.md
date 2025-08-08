## Role Based Access Control (RBAC) in a kubernetes cluster

### Definitions
- **Role Based Access Control** in kubernetes is an authorization method to access the cluster resources based on the roles of users within your organization.
The RBAC is setup by cluster administrators to control access to the cluster and cluster resources.

- **A role** contains a set of rules that represent a set of permissions in a namespace
- **A RoleBinding** is used to bind a Role to a user or a group of users.
- **A ClusterRole** is a role used to define a set of permissions on the entire cluster or on cluster-wide resources.
- **A ClusterRoleBinding** is used to bind a ClusterRole to a user or group of users

### How to setup RBAC in k8s
To set up RBAC, we need to identify the who, the what and the rules:
- Who (the subject like user, group of users, service account)
- What (resources like pods, services, deployments, ...)
- rules (what action is allowed and what action is not allowed)

### Steps
- create a namespace
- create a role
- create a rolebinding
- create the subject (user, group or service account)
- Create the config file for the subject to assume the role for cluster access
- verify that the subjet only have access to the permissions set in the role

### Practice
#### Exercise 1:
We have a new user called Adam in dev team and we need to give him access to the cluster resources. As an administrator, setup RBAC to allow Adam to list and create pods in the dev namespace

Refer to the folder `rback-eks-user` to resolve the exercise.

#### Exercise 2:

We have a new user called Paul in dev team and we need to give him access to the cluster resources. As an administrator, setup RBAC using a service account to allow Paul to list and create pods and services in the dev namespace.

Refer to the folder `rback-eks-sa` to resolve the exercise.
