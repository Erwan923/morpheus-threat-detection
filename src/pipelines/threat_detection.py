#!/usr/bin/env python3
"""
Morpheus Threat Detection Pipeline
GPU-accelerated network intrusion detection
"""

import logging
import click
from morpheus.config import Config
from morpheus.pipeline import LinearPipeline
from morpheus.stages.input.file_source_stage import FileSourceStage
from morpheus.stages.output.write_to_file_stage import WriteToFileStage
from morpheus.stages.preprocess.deserialize_stage import DeserializeStage
from morpheus.stages.inference.triton_inference_stage import TritonInferenceStage
from morpheus.stages.postprocess.add_classifications_stage import AddClassificationsStage
from morpheus.stages.postprocess.serialize_stage import SerializeStage

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def create_pipeline(input_file: str, output_file: str, model_name: str = "phishing-bert-onnx"):
    """Create and configure the threat detection pipeline"""
    
    # Configure Morpheus
    config = Config()
    config.mode = "NLP"
    config.num_threads = 8
    config.pipeline_batch_size = 256
    config.model_max_batch_size = 32
    config.feature_length = 128
    config.edge_buffer_size = 128
    
    # Create pipeline
    pipeline = LinearPipeline(config)
    
    # Add stages
    pipeline.set_source(FileSourceStage(config, filename=input_file, iterative=False))
    
    pipeline.add_stage(DeserializeStage(config))
    
    pipeline.add_stage(
        TritonInferenceStage(
            config,
            model_name=model_name,
            server_url="localhost:8001",
            force_convert_inputs=True
        )
    )
    
    pipeline.add_stage(
        AddClassificationsStage(
            config,
            threshold=0.7,
            labels=["benign", "malicious"],
            prefix="threat_"
        )
    )
    
    pipeline.add_stage(SerializeStage(config, include=["threat_*"]))
    
    pipeline.add_sink(WriteToFileStage(config, filename=output_file, overwrite=True))
    
    return pipeline


@click.command()
@click.option("--input", "-i", required=True, help="Input JSONL file path")
@click.option("--output", "-o", default="results/threats.json", help="Output file path")
@click.option("--model", "-m", default="phishing-bert-onnx", help="Model name in Triton")
@click.option("--batch-size", "-b", default=256, type=int, help="Pipeline batch size")
def main(input: str, output: str, model: str, batch_size: int):
    """Run Morpheus threat detection pipeline"""
    
    logger.info(f"Starting threat detection pipeline")
    logger.info(f"Input: {input}")
    logger.info(f"Output: {output}")
    logger.info(f"Model: {model}")
    logger.info(f"Batch size: {batch_size}")
    
    try:
        pipeline = create_pipeline(input, output, model)
        pipeline.run()
        logger.info("Pipeline completed successfully")
    except Exception as e:
        logger.error(f"Pipeline failed: {e}")
        raise


if __name__ == "__main__":
    main()
