#!/usr/bin/env bash

ollama serve &
sleep 10
ollama pull llama3.2
ollama pull qwen2.5:7b

ollama pull nomic-embed-text
ollama pull all-minilm:l6-v2

ollama pull gemma3:4b-it-qat            
ollama pull lukasmalkmus/llama3-sauerkraut:latest      
ollama pull starcoder2:3b      



tail -f /dev/null
