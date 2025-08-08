**Note: This practice should be done in the EKS cluster**

# Persistent Storage in Kubernetes

- Volumes are important for data persistence and file sharing between pods.
- **Persistent volumes (PVs)** are volume plugins managed by kubernetes
- They are just like physical storage on a hard drive that are attached to your pods for data storage
- A **Persistent Volume Claim (PVC)** is a request for storage (PV) by a user.

## PV provisioning

PV Provisioning can be static or dynamic:

- **Static:** The cluster administrator create a number of PVs of various type, users can then define PVCs to use the PV created.
- **Dynamic:** kubernetes dynamically provision a volume for a specific PVC (using storage classes).

## How to create a PV or a PVC
When defining a PV or a PVC, there are some parameters we need to know:
- The **PV name** in the metadata section
- The **capacity** (storage size)
- the **access mode**
    - ReadWriteOnce (RWO)
    - ReadOnlyMany (ROX)
    - ReadWriteMany (RWX)
    - ReadWriteOncePod (RWOP)**
- The persistent volume **reclaim policy** (optional): specify what happens when the PV is released. It can take the values
    - Retain: keep the PV after the PVC deletion
    - Delete: Delete the PV after the PVC deletion
- the **storage backend:** define the storage type (Example: NFS, csi, local ...)
- the **storageClass name** (optional): for dynamic provisioning

## Setting up dynamic provisioning in EKS cluster with EBS volumes

Open the `ebs-volume` folder and go through the `readme.md` to practice 

**Note:** In AWS EKS, **EBS does not support** **RWX(ReadWriteMany)**. It is limited to **RWO(ReadWriteOnce)** It means the volume created by ebs can only be mounted to one node. 

To allow many nodes to mount a volume, you need to use another service like **Amazon EFS** that support **RWX**.

## Setting up dynamic provisioning in EKS using Amazon EFS

Open the `efs-volume` folder and go through the `readme.md` to practice