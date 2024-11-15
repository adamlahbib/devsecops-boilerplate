# Instructions

You need to create a **repository implementing** the **best OPS practices** (fork this repository).
You have 4 hours, or more if you choose to take additional time.
The goal is to **automate the deployment** of an **API** on an **IPv4 Kubernetes cluster** in a scalable, observable, secure, and reproducible manner.

## API Image

The deployed image needs to be a FastAPI Python 3.12 API with the following specifications:
- `GET /docs`: API documentation
- `GET /health`: API metrics

Feel free to:
- modify the code and requirements
- add any endpoints you find relevant.

We have provided the API code in the `/app` directory and the requirements in the `requirements.txt` file

## Guidelines

- You need to create the API image
- Regarding the Kubernetes cluster, you can either set up an EKS cluster on a free-tier AWS account and invite us, or you can create a local cluster with the flavour you want.
- You can chose the stack you want for observability, scaling and security.
- The most important is that we can reproduce your work with clear instructions.

# Evaluation Criteria

*Let us know the approximate time you spent on this assignment*

- K8s knowledge
- IAC knowledge
- CI/CD knowledge
- Security practices
- Automation & Reproducibility
- Clarity

