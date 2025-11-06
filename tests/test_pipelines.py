"""
Basic tests for Morpheus pipelines
"""

import pytest
import os
import json


def test_sample_data_exists():
    """Test that sample data file exists"""
    assert os.path.exists("examples/data/pcap_dump.jsonlines")


def test_sample_data_format():
    """Test that sample data is valid JSONL"""
    with open("examples/data/pcap_dump.jsonlines", "r") as f:
        for line in f:
            data = json.loads(line)
            assert "timestamp" in data
            assert "src_ip" in data
            assert "dst_ip" in data
            assert "payload" in data


def test_pipeline_script_exists():
    """Test that main pipeline script exists"""
    assert os.path.exists("src/pipelines/threat_detection.py")


def test_requirements_exist():
    """Test that requirements files exist"""
    assert os.path.exists("requirements.txt")
    assert os.path.exists("requirements-dev.txt")


def test_docker_files_exist():
    """Test that Docker files exist"""
    assert os.path.exists("docker/Dockerfile.gpu")
    assert os.path.exists("docker/Dockerfile.cpu")
    assert os.path.exists("docker/docker-compose.yml")


def test_terraform_files_exist():
    """Test that Terraform files exist"""
    assert os.path.exists("terraform/main.tf")
    assert os.path.exists("terraform/variables.tf")
    assert os.path.exists("terraform/outputs.tf")


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
