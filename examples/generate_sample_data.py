#!/usr/bin/env python3
"""Generate sample PCAP data in JSONL format"""

import json
import random
from datetime import datetime, timedelta

def generate_network_events(n=1000):
    """Generate synthetic network events"""
    
    events = []
    base_time = datetime.now()
    
    ips = ["192.168.1.100", "10.0.0.50", "172.16.0.10", "8.8.8.8"]
    ports = [80, 443, 22, 3389, 8080]
    protocols = ["TCP", "UDP", "ICMP"]
    
    benign_patterns = [
        "GET /index.html HTTP/1.1",
        "POST /api/users HTTP/1.1",
        "normal network traffic"
    ]
    
    malicious_patterns = [
        "' OR '1'='1",
        "../../../etc/passwd",
        "<script>alert('XSS')</script>",
        "cmd.exe /c whoami"
    ]
    
    for i in range(n):
        is_malicious = random.random() < 0.1  # 10% malicious
        
        event = {
            "timestamp": (base_time + timedelta(seconds=i)).isoformat(),
            "src_ip": random.choice(ips),
            "dst_ip": random.choice(ips),
            "src_port": random.randint(1024, 65535),
            "dst_port": random.choice(ports),
            "protocol": random.choice(protocols),
            "payload": random.choice(malicious_patterns if is_malicious else benign_patterns),
            "label": "malicious" if is_malicious else "benign"
        }
        
        events.append(event)
    
    return events

if __name__ == "__main__":
    events = generate_network_events(10000)
    
    with open("examples/data/pcap_dump.jsonlines", "w") as f:
        for event in events:
            f.write(json.dumps(event) + "\n")
    
    print(f"Generated {len(events)} events")
    print(f"Saved to examples/data/pcap_dump.jsonlines")
