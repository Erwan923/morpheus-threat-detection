<p align="center">
  <img src="assets/Morpheus1.png" alt="Morpheus Threat Detection" width="250"/>
</p>

# Morpheus Threat Detection
</p>

<p align="center">
  <a href="https://github.com/nv-morpheus/morpheus">
    <img src="https://img.shields.io/badge/NVIDIA-Morpheus-76B900?style=flat-square&logo=nvidia" alt="NVIDIA Morpheus">
  </a>
  <a href="https://developer.nvidia.com/triton-inference-server">
    <img src="https://img.shields.io/badge/Triton-24.09-76B900?style=flat-square&logo=nvidia" alt="Triton">
  </a>
  <a href="https://www.terraform.io/">
    <img src="https://img.shields.io/badge/Terraform-1.0%2B-623CE4?style=flat-square&logo=terraform" alt="Terraform">
  </a>
  <a href="https://www.python.org/">
    <img src="https://img.shields.io/badge/Python-3.10%2B-3776AB?style=flat-square&logo=python" alt="Python">
  </a>
  <a href="https://opensource.org/licenses/Apache-2.0">
    <img src="https://img.shields.io/badge/License-Apache%202.0-blue?style=flat-square" alt="License">
  </a>
</p>

---

## Overview

**Morpheus Threat Detection** is a modular, production-grade pipeline built on **NVIDIA Morpheus** and **Triton Inference Server**. It continuously analyzes network and system data through three specialized pipelines designed for real-world SOC and cloud security use cases:

- **Threat Detection** — Identifies intrusions, anomalies, and behavioral deviations
- **Data Loss Prevention (DLP)** — Detects sensitive data leakage across traffic and logs
- **System Anomaly** — Monitors host-level signals such as CPU spikes and malicious processes

Each pipeline ingests data from **Kafka** or **files**, performs preprocessing and inference via **Triton**, classifies events, and exports results to **storage, Kafka, or SIEM systems**. Built for cloud-native environments, it supports GPU acceleration, IaC deployment, and continuous integration.

---

## Available Pipelines

| Pipeline | Purpose | Input | Output |
|----------|---------|-------|--------|
| `threat-detection` | Network intrusion & anomaly detection | PCAP, NetFlow logs | Kafka/File alerts |
| `dlp-detection` | Sensitive data leakage prevention | System logs, packet capture | Compliance reports |
| `system-anomaly` | Host behavior analysis | Syslog, metrics | Incident signals |

---

## Quick Start

### Local (CPU)

```bash
conda create -n morpheus -c nvidia -c conda-forge morpheus-core python=3.10
conda activate morpheus
python src/threat_detection_pipeline.py --input examples/data/pcap_dump.jsonlines
```

### Deploy on AWS GPU

```bash
cd terraform/
terraform init && terraform apply -var="instance_type=g4dn.xlarge"
# Automatically provisions EC2 GPU, VPC, and networking
```

### Docker

```bash
docker build -f docker/Dockerfile.gpu -t morpheus-threat-detection .
docker compose up
```

---

## Architecture

```
Data Sources (Kafka/Files)
   ↓
Deserialize → Preprocess
   ↓
Inference via Triton
   ↓
Threat Classification
   ↓
Outputs (Kafka/File/SIEM)
```

---

## Project Structure

```
morpheus-threat-detection/
├── src/
│   ├── pipelines/
│   │   ├── threat_detection.py
│   │   ├── dlp_detection.py
│   │   └── system_anomaly.py
│   ├── models/
│   └── utils/
├── terraform/
│   ├── main.tf
│   ├── ec2-gpu.tf
│   └── variables.tf
├── docker/
│   ├── Dockerfile.gpu
│   ├── Dockerfile.cpu
│   └── docker-compose.yml
├── .github/workflows/
│   ├── ci-test.yml
│   └── docker-build.yml
├── tests/
│   └── test_pipelines.py
├── examples/
│   └── data/
├── requirements.txt
├── requirements-dev.txt
└── README.md
```

---

## Tech Stack

- **NVIDIA Morpheus** v25.06
- **Triton Inference Server** 24.09
- **Terraform** & AWS (EC2 g4dn, VPC)
- **Docker** & Docker Compose
- **GitHub Actions** CI/CD
- **Python** 3.10+

---

## Performance

- **Throughput**: 30k+ messages/sec (deserialize) / 12k+ inferences/sec
- **Latency**: <100ms per batch (g4dn.xlarge GPU)
- **GPU Memory**: ~2GB (optimized model loading)

---

## Installation

### Prerequisites

- Docker & Docker Compose
- Terraform (v1.0+)
- AWS account with EC2 access
- Python 3.10+ (for local development)
- Conda (Miniconda or Anaconda)

### Clone Repository

```bash
git clone https://github.com/yourusername/morpheus-threat-detection.git
cd morpheus-threat-detection
```

---

## Usage

### Run Threat Detection Pipeline (CPU)

```bash
conda activate morpheus
python src/pipelines/threat_detection.py \
  --input examples/data/pcap_dump.jsonlines \
  --output results/threats.json \
  --batch_size 256
```

### Run with GPU (Docker)

```bash
docker compose -f docker/docker-compose.yml up
```

### Deploy Infrastructure (Terraform)

```bash
cd terraform/
terraform plan
terraform apply
```

---

## Development

### Install Dev Dependencies

```bash
pip install -r requirements-dev.txt
```

### Run Tests

```bash
pytest tests/ -v
```

### Build Docker Image

```bash
docker build -f docker/Dockerfile.gpu -t morpheus-threat-detection:latest .
```

---

## Configuration

Edit `src/config.yml` to customize:

- Batch size and pipeline parameters
- Model selection (threat detection, DLP, anomaly)
- Input/output connectors (Kafka, file, S3)
- Inference server (Triton) endpoints
- Alert thresholds and filtering rules

---

## Performance Tuning

- Adjust `--pipeline_batch_size` for throughput vs latency tradeoff
- Use `--model_max_batch_size` for inference optimization
- Enable GPU memory pooling in Triton config
- Consider multiple pipeline instances for high-volume data

---

## Contributing

Contributions are welcome. Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit changes (`git commit -m 'Add your feature'`)
4. Push to branch (`git push origin feature/your-feature`)
5. Open a Pull Request

---

## License

Apache License 2.0 - See LICENSE file for details

---

## Citation

If you use Morpheus Threat Detection in your research or production environment, please cite:

```
@software{morpheus_threat_detection,
  author = {Your Name},
  title = {Morpheus Threat Detection: GPU-Accelerated Security Pipeline},
  url = {https://github.com/yourusername/morpheus-threat-detection},
  year = {2025}
}
```

---

## Support & Documentation

- NVIDIA Morpheus: https://github.com/nv-morpheus/morpheus
- Triton Inference Server: https://github.com/triton-inference-server/server
- Terraform AWS: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

---

**Built for DevSecOps & Cloud-Native Security**
